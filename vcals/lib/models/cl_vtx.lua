--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/lib/models/cl_vtx.lua
    Handles parsing of VTX files
    Thanks to "raspbian got DABBED on#0572" in the Gmod Dev Discord for helping me figure this shit out
    Thanks also to MDave on Facepunch for providing his old parsers
    https://developer.valvesoftware.com/wiki/VTX
]]--

--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create a global decal table
VCals.Models = VCals.Models or {};
--This will hold all the functions for parsing VVDs
VCals.Models.VTX = {
    STRIP_IS_TRILIST = 0x01
};
VCals.Models.Cache = VCals.Models.Cache or {};

function VCals.Models.VTX:getStripGroupSize(vtxFileVersion)
    return vtxFileVersion == 49 and 33 or 25;
end

function VCals.Models.VTX:getStripSize(vtxFileVersion)
    return vtxFileVersion == 49 and 35 or 27;
end

--[[
    Start of scratch code
]]--
local function readVtxFileHeader(openFile)
    return {
        --The file version as defined by OPTIMIZED_MODEL_FILE_VERSION ( currently 7 )
        version = openFile:ReadLong(),
        --Hardware params that affect how the model is to be optimized
        vertCacheSize = openFile:ReadLong(),
        maxBonesPerStrip = openFile:ReadUShort(),
        maxBonesPerTri = openFile:ReadUShort(),
        maxBonesPerVert = openFile:ReadLong(),
        --Must match the checksum in the .mdl and .vvd
        checksum = openFile:ReadLong(),
        --Should also match the .mdl and .vvd
        numLODs = openFile:ReadLong(),
        --Offset to material replacement list array. One of these for each LOD, 8 in total
        materialReplacementListOffset = openFile:ReadLong(),
        --Defines the size and location of the body part array
        numBodyParts = openFile:ReadLong(),
        bodyPartOffset = openFile:ReadLong(),
    };
end

local function readVtxBodyPartHeader(openFile)
    return {
        numModels = openFile:ReadLong(),
        modelOffset = openFile:ReadLong(),
    };
end;

local function readVtxModelHeader(openFile)
    return {
        numLODs = openFile:ReadLong(),
        lodOffset = openFile:ReadLong(),
    };
end;

local function readVtxLModelLodHeader(openFile)
    return {
        numMeshes = openFile:ReadLong(),
        meshOffset = openFile:ReadLong(),
        switchPoint = openFile:ReadFloat(),
    };
end;

local function readVtxMeshHeader(openFile)
    return {
        numGroups = openFile:ReadLong(),
        groupOffset = openFile:ReadLong(),
        flags = openFile:ReadByte(),
    };
end;

local function readVtxStripGroupHeader(openFile, vtxFileVersion)
    local stripGroupHeader = {
        numVerts = openFile:ReadLong(),
        vertOffset = openFile:ReadLong(),
        numIndices = openFile:ReadLong(),
        indexOffset = openFile:ReadLong(),
        numStrips = openFile:ReadLong(),
        stripOffset = openFile:ReadLong(),
        flags = openFile:ReadByte(),
    };
    if (vtxFileVersion == 49) then
        stripGroupHeader.numTopologyIndices = openFile:ReadLong();
        stripGroupHeader.topologyOffset = openFile:ReadLong();
    end;
    return stripGroupHeader;
end;

local function readVtxStripHeader(openFile, vtxFileVersion)
    local stripHeader = {
        numIndices = openFile:ReadLong(), -- 1 byte
        indexOffset = openFile:ReadLong(), -- 1 byte
        numVerts = openFile:ReadLong(), -- 1 byte
        vertOffset = openFile:ReadLong(), -- 4 bytes
        numBones = openFile:ReadShort(), -- 2 bytes
        flags = openFile:ReadByte(), -- 1 byte
        numBonesStateChanges = openFile:ReadLong(), -- 1 byte
        boneStateChangeOffset = openFile:ReadLong(), -- 1 byte
    };
    if (vtxFileVersion == 49) then
        stripHeader.numTopologyIndices = openFile:ReadLong(); -- 4 bytes
        stripHeader.topologyOffset = openFile:ReadLong(); -- 4 bytes
    end;
    return stripHeader;
end;

local function readVtxVertex(openFile)
    return {
        boneWeightIndex = {
            openFile:ReadByte(),
            openFile:ReadByte(),
            openFile:ReadByte(),
        },
        numBones = openFile:ReadByte(),
        origMeshVertId = openFile:ReadShort(),
        boneId = {
            openFile:ReadByte(),
            openFile:ReadByte(),
            openFile:ReadByte(),
        },
    };
end;


-- Read one strip group once
local function readStripGroupData(openFile, groupBase, hdr, vtxVersion)
    -- read all group verts
    local verts = {}
    local vtxVertSize = 9 -- bytes you read in readVtxVertex()
    for i = 0, hdr.numVerts - 1 do
        openFile:Seek(groupBase + hdr.vertOffset + i * vtxVertSize)
        verts[i] = readVtxVertex(openFile)      -- store 0-based; easier with VTX indices
    end

    -- read all group indices
    local indices = {}
    openFile:Seek(groupBase + hdr.indexOffset)
    for i = 0, hdr.numIndices - 1 do
        indices[i] = openFile:ReadUShort()  -- UNSIGNED
    end
    return verts, indices
end

-- VVD fixup: map an origMeshVertId -> final VVD vertex index for a given LOD
local function mapVvdIndex(vvd, lod, src)
    local fixups = vvd.fixups
    if not fixups or #fixups == 0 then return src end
    for _, f in ipairs(fixups) do
        if lod >= f.lod and src >= f.sourceVertexID and src < f.sourceVertexID + f.numVertices then
            return f.vertexID + (src - f.sourceVertexID)
        end
    end
    return src
end

-- Expand one strip to a list of VVD vertex indices (triangles as triples)
local function expandStripToVvdTris(stripHeader, groupVerts, groupIndices, vvd, lod)
    local first = stripHeader.indexOffset / 2      -- bytes -> ushorts (0-based)
    local count = stripHeader.numIndices
    local triVvd = {}

    local function vvdIndexFromGroupIndex(gidx)
        -- indices[] gives a vertex index in the strip group
        local groupVertIndex = stripHeader.vertOffset + groupIndices[gidx] -- 0-based
        local vtxv = groupVerts[groupVertIndex]
        local base = vtxv.origMeshVertId  -- make sure read as UShort in readVtxVertex
        return mapVvdIndex(vvd, lod, base)
    end

    local isTriList = bit.band(stripHeader.flags, 0x01) ~= 0
    if isTriList then
        -- triangles are [0..count-1] in triples
        for k = 0, count - 1, 3 do
            local a = vvdIndexFromGroupIndex(first + k)
            local b = vvdIndexFromGroupIndex(first + k + 1)
            local c = vvdIndexFromGroupIndex(first + k + 2)
            triVvd[#triVvd+1] = a; triVvd[#triVvd+1] = b; triVvd[#triVvd+1] = c
        end
    else
        -- tri-strip expansion with odd/even flip; skip degenerates
        for k = 0, count - 3 do
            local a = vvdIndexFromGroupIndex(first + k)
            local b = vvdIndexFromGroupIndex(first + k + 1)
            local c = vvdIndexFromGroupIndex(first + k + 2)
            if (a ~= b) and (b ~= c) and (a ~= c) then
                if (bit.band(k, 1) == 0) then
                    triVvd[#triVvd+1] = a; triVvd[#triVvd+1] = b; triVvd[#triVvd+1] = c
                else
                    triVvd[#triVvd+1] = a; triVvd[#triVvd+1] = c; triVvd[#triVvd+1] = b
                end
            end
        end
    end
    return triVvd
end
--[[
    End of scratch code
]]--

--[[
    VCals.Models.VTX:Parse( String/fileName ):
        Parses the .vtx file for the visual mesh
]]--
function VCals.Models.VTX:Parse(fileName)
    --Open the file in binary mode
    local openFile = file.Open( fileName, "rb", "GAME" );
    if (openFile == nil) then
        --VCals.Debug:Print( Color( 255, 255, 0 ), "Unable to read file: " .. fileName );
        print( "Unable to read file" );
        return;
    end;
    local modelData = {
        headers = {
            --The file version as defined by OPTIMIZED_MODEL_FILE_VERSION ( currently 7 )
            version = openFile:ReadLong(),
            --Hardware params that affect how the model is to be optimized
            vertCacheSize = openFile:ReadLong(),
            maxBonesPerStrip = openFile:ReadUShort(),
            maxBonesPerTri = openFile:ReadUShort(),
            maxBonesPerVert = openFile:ReadLong(),
            --Must match the checksum in the .mdl and .vvd
            checksum = openFile:ReadLong(),
            --Should also match the .mdl and .vvd
            numLODs = openFile:ReadLong(),
            --Offset to material replacement list array. One of these for each LOD, 8 in total
            materialReplacementListOffset = openFile:ReadLong(),
            --Defines the size and location of the body part array
            numBodyParts = openFile:ReadLong(),
            bodyPartOffset = openFile:ReadLong(),
        },
    };
    local rebuiltTriangles = {};
    PrintTable(parsedVVD.vertices);
    --Read the body parts
    for bodyPartIndex = 0, vtxFileHeader.numBodyParts - 1 do
        local bodyPartOffset = vtxFileHeader.bodyPartOffset + bodyPartIndex * 8;
        openFile:Seek(bodyPartOffset);
        -- Read the header
        local bodyPartHeader = readVtxBodyPartHeader(openFile);
        -- Read the models
        for modelIndex = 0, bodyPartHeader.numModels - 1 do
            local modelOffset = bodyPartOffset + bodyPartHeader.modelOffset + modelIndex * 8;
            openFile:Seek(modelOffset);
            -- Read the model header
            local modelHeader = readVtxModelHeader(openFile);
            -- Read the lod headers
            for lodIndex = 0, modelHeader.numLODs - 1 do
                local lodHeaderBase = modelOffset + modelHeader.lodOffset;
                local lodHeaderOffset = lodHeaderBase + lodIndex * 12;
                openFile:Seek(lodHeaderOffset);
                -- Read the lod header
                local lodHeader = readVtxLModelLodHeader(openFile);
                -- Read the meshes
                for meshIndex = 0, lodHeader.numMeshes - 1 do
                    local meshOffsetBase = lodHeaderOffset + lodHeader.meshOffset;
                    local meshOffset = meshOffsetBase + meshIndex * 9;
                    openFile:Seek(meshOffset);
                    local meshHeader = readVtxMeshHeader(openFile);
                    for stripGroupIndex = 0, meshHeader.numGroups - 1 do
                        local stripGroupOffsetBase = meshOffset + meshHeader.groupOffset;
                        local stripGroupOffset = stripGroupOffsetBase + stripGroupIndex * stripGroupSize;
                        openFile:Seek(stripGroupOffset);
                        local stripGroupHeader = readVtxStripGroupHeader(openFile, vtxFileVersion);
                        for stripIndex = 0, stripGroupHeader.numStrips - 1 do
                            local stripOffsetBase = stripGroupOffset + stripGroupHeader.stripOffset;
                            local stripOffset = stripOffsetBase + stripIndex * stripSize;
                            openFile:Seek(stripOffset);
                            local stripHeader = readVtxStripHeader(openFile, vtxFileVersion);
                            local groupBase = stripGroupOffset
                            local groupVerts, groupIndices = readStripGroupData(openFile, groupBase, stripGroupHeader, vtxFileVersion)

                            -- For each strip:
                            local triVvd = expandStripToVvdTris(stripHeader, groupVerts, groupIndices, parsedVVD, lodIndex)

                            -- Build Mesh() triangles (3 entries per tri)
                            for i = 1, #triVvd, 3 do
                                local ia, ib, ic = triVvd[i], triVvd[i+1], triVvd[i+2]
                                local va, vb, vc = parsedVVD.vertices[ia], parsedVVD.vertices[ib], parsedVVD.vertices[ic] -- +1 for Lua
                                table.insert(rebuiltTriangles, {pos=va.position, normal=va.normal, u=va.texCoord.u, v=va.texCoord.v})
                                table.insert(rebuiltTriangles, {pos=vb.position, normal=vb.normal, u=vb.texCoord.u, v=vb.texCoord.v})
                                table.insert(rebuiltTriangles, {pos=vc.position, normal=vc.normal, u=vc.texCoord.u, v=vc.texCoord.v})
                            end
                        end;
                    end;
                end;
            end;
        end;
    end;
    openFile:Close();
    return modelData;
end;



--[[
    VCals.Models.VTX:ParseHeader( Stream/openFile ):
        Parses the header of the VTX file and returns it as a table
]]--
function VCals.Models.VTX:ParseHeaders( openFile )
    return {
        --The file version as defined by OPTIMIZED_MODEL_FILE_VERSION ( currently 7 )
        version = openFile:ReadLong(),
        --Hardware params that affect how the model is to be optimized
        vertCacheSize = openFile:ReadLong(),
        maxBonesPerStrip = openFile:ReadUShort(),
        maxBonesPerTri = openFile:ReadUShort(),
        maxBonesPerVert = openFile:ReadLong(),
        --Must match the checksum in the .mdl and .vvd
        checksum = openFile:ReadLong(),
        --Should also match the .mdl and .vvd
        numLODs = openFile:ReadLong(),
        --Offset to material replacement list array. One of these for each LOD, 8 in total
        materialReplacementListOffset = openFile:ReadLong(),
        --Defines the size and location of the body part array
        numBodyParts = openFile:ReadLong(),
        bodyPartOffset = openFile:ReadLong(),
    };
end;

function VCals.Models.VTX:ParseBodyPartHeaders(openFile, modelData)
    local bodyPartHeaders = {};
    local bodyPartOffset, numBodyParts =
        modelData.headers.bodyPartOffset,
        modelData.headers.numBodyParts;
    -- First thing we need to do is parse the body part headers
    for bodyPartIndex = 1, numBodyParts do
        -- The body part header is relative to the
        --      value in the global headers
        -- Header size is 8 (Two 4 byte ints)
        local fileOffset = bodyPartOffset + (bodyPartIndex - 1) * 8;
        openFile:Seek(fileOffset);
        -- Parse the body part header
        local bodyPartHeader = self:ParseBodyPartHeader(openFile);
        -- Store the offset in the bodyPartHeader so we can use it
        --      Later when we parse the model headers as the offset
        --      Add 8 to it to make sure it marks the end of the bodyPartHeader
        bodyPartHeader.fileOffset = fileOffset + 8;
        bodyPartHeaders[bodyPartIndex] = bodyPartHeader;
    end;
    return bodyPartHeaders;
end;

--[[
    VCals.Models.VTX:ParseBodyPartHeader( Stream/openFile ):
        Parses the next BodyPartHeader in the open file stream

    @class BodyPartHeader
    @field numModels int
    @field modelOffset int
    }
]]--
function VCals.Models.VTX:ParseBodyPartHeader( openFile )
    return {
        numModels = openFile:ReadLong(),
        modelOffset = openFile:ReadLong(),
    };
end;


--[[
    VCals.Models.VTX:ParseModelHeaders( Table/bodyArray, Stream/openFile ):
        Parses the Model Array from the open file stream
        Returns it as a table
]]--
function VCals.Models.VTX:ParseModelHeaders(openFile, modelData)
    local modelHeaders = {};
    local bodyPartHeaders = modelData.bodyPartHeaders;
    --Loop through all the body part headers
    for bodyPartHeaderId = 1, #bodyPartHeaders do
        -- Get our body part header
        local bodyPartHeader = bodyPartHeaders[bodyPartHeaderId];
        -- We can use the offset in there to seek to the start of the model headers
        local numModels = bodyPartHeader.numModels;
        local modelBaseOffset = bodyPartHeader.fileOffset + bodyPartHeader.modelOffset;
        for modelHeaderId = 1, numModels do
            -- Don't subtract 1 because we're technically at the start of
            --      The body part header, and need to move to the end of it
            local modelHeaderOffset = modelBaseOffset + (modelHeaderId - 1) * 8;
            openFile:Seek(modelHeaderOffset);
            local modelHeader = self:ParseModelHeader(openFile);
            modelHeader.fileOffset = modelHeaderOffset + 8;
            modelHeaders[modelHeaderId] = modelHeader;
        end
        --local bodyPartHeader = modelData.bodyPartHeaders[bodyPartId];
        --local modelOffset = bodyPartHeader.modelOffset;
        --for modelHeaderId = 1, bodyPartHeader.numModels do
        --    -- Jump to the correct offset for the model header
        --    openFile:Seek(modelOffset + (modelHeaderId - 1) * 8);
        --    modelHeaders[modelHeaderId] = self:ParseModelHeader(openFile);
        --end
        --    local bodyPartHeader = bodyPartHeaders[bodyPartId];
        --    print(bodyPartHeader.modelOffset);
        --    --Seek to the start of the model array
        --    openFile:Read(bodyPartHeader.modelOffset);
        --    modelHeaders[bodyPartId] = self:ParseModelHeader(openFile);
    end;
    return modelHeaders;
end;

--[[
VCals.Models.VTX:ParseModelHeader( Stream/openFile ):
Parses the ModelHeader_t section of the VTX file
Returns it as a table
]]--
function VCals.Models.VTX:ParseModelHeader(openFile)
    local modelHeader = {
        numLODs = openFile:ReadLong(),
        lodOffset = openFile:ReadLong(),
    };
    return modelHeader;
end;

function VCals.Models.VTX:ParseModelLODHeaders(openFile, modelData)
    local modelLODHeaders = {};
    local modelHeaders = modelData.modelHeaders;
    for modelHeaderId = 1, #modelHeaders do
        local modelHeader = modelHeaders[modelHeaderId];
        for modelLODHeaderId = 1, modelHeader.numLODs do
            local headerSize = 12;
            -- Each lod header is 12 bytes large
            --      Two 4 byte ints (8 bytes)
            --      One 4 byte float
            local fileOffset = modelHeader.lodOffset + (modelLODHeaderId - 1) * headerSize;
            -- Seek to the offset
            openFile:Seek(fileOffset);
            local modelLODHeader = self:ParseLODHeader(openFile);
            -- Move the fileOffset to the end of the lod header
            modelLODHeader.fileOffset = fileOffset + headerSize;
            modelLODHeaders[modelLODHeaderId] = modelLODHeader;
        end;
    end;
    return modelLODHeaders;
end;

--[[
    VCals.Models.VTX:ParseLODHeader( Stream/openFile ):
        Parses ModelLODHeader_t from the open file stream
]]--
function VCals.Models.VTX:ParseLODHeader( openFile )
    return {
        numMeshes = openFile:ReadLong(),
        meshOffset = openFile:ReadLong(),
        switchPoint = openFile:ReadFloat()
    };
end;

function VCals.Models.VTX:ParseVertex(openFile)
    return {
        boneWeights = {
            openFile:ReadFloat(),
            openFile:ReadByte(),
            openFile:ReadByte(),
        },
        vecPosition = self:ReadVector(openFile)
    }
end

--[[
    VCals.Models.VTX:ParseMeshArray( Table/modelArray, Stream/openFile ):
        Parses the LOD Mesh Array into a table of LOD Headers
]]--
function VCals.Models.VTX:ParseLODMeshHeaders( modelHeaders, openFile )
    local lodMeshHeaders = {};
    --Seek to the start of the mesh array
    for modelHeaderID = 1, #modelHeaders do
        local modelHeader = modelHeaders[modelHeaderID];
        openFile:Read(modelHeader.lodOffset);
        for lodId = 1, modelHeader.numLODs do
            --Skip to the start of the mesh array
            local lodHeader = self:ParseLODHeader( openFile );
            local lodVertices = {};
            for vertexId = 1, lodHeader.numVertexes do

            end
            lodMeshHeaders[lodId] = lodHeader;
        end;
    end;
    return lodMeshHeaders;
end;

function VCals.Models.VTX:ParseMeshHeader( openFile )
    local meshHeader = {
        numStripGroups = openFile:ReadLong(),
        stripGroupHeaderOffset = openFile:ReadLong(),
        flags = openFile:ReadByte()
    };
    return meshHeader;
end;

function VCals.Models.VTX:ParseMeshHeaders( meshLODHeaders, openFile )
    local meshHeaders = {};
    --Seek to the start of the
    for meshLODHeaderID = 1, 1 do--#meshLODHeaders do
        local meshLODHeader = meshLODHeaders[meshLODHeaderID];
        --Seek to the offset
        openFile:Read( meshLODHeader.meshOffset );
        print(meshLODHeader.numMeshes);
        --Loop through the number of meshes
        for meshID = 1, meshLODHeader.numMeshes do
            meshHeaders[meshID] = self:ParseMeshHeader( openFile );
        end;
    end;
    return meshHeaders;
end;

function VCals.Models.VTX:ReadVector(openFile)
    return {
        x = openFile:ReadFloat(),
        y = openFile:ReadFloat(),
        z = openFile:ReadFloat(),
    };
end

--[[
VCals.Models.VTX:ParseBodyPartHeaders( Int/numBodyParts, Int/bodyPartOffset, Stream/openFile ):
Parses the body array of the open file stream
]]--
--function VCals.Models.VTX:ParseBodyPartHeaders(headers, openFile)
--    local bodyPartHeaders = {};
--    local triangles = {};
--    for bodyPartIndex = 1, headers.numBodyParts do
--        openFile:Seek(headers.bodyPartOffset + (bodyPartIndex - 1) * 8);
--        local bodyPartHeader = self:ParseBodyPartHeader(openFile);
--        local numModels = bodyPartHeader.numModels;
--        local lodOffset = bodyPartHeader.modelOffset;
--        for modelId = 1, numModels do
--            -- Seek to the start of the lod offset because our lod is 0
--            openFile:Seek(lodOffset);
--            local numMeshes = openFile:ReadLong();
--            local meshOffset = openFile:ReadLong();
--            local switchPoint = openFile:Read(16);
--            for meshId = 1, numMeshes do
--                openFile:Seek(meshOffset + (meshId - 1)*9);
--                local numGroups = openFile:ReadLong();
--                local groupOffset = openFile:ReadLong();
--                local flags = openFile:ReadByte();
--                print(numGroups, groupOffset, flags);
--                print(openFile:EndOfFile());
--                for stripeGroupId = 1, numGroups do
--                    openFile:Seek(groupOffset + (stripeGroupId - 1) * 25)
--                    print(openFile:EndOfFile());
--                    local numGV   = openFile:ReadLong();
--                    print(numGV);
--                    local vertOfs = openFile:ReadLong();
--                    print(vertOfs);
--                    local numIdx  = openFile:ReadLong();
--                    local idxOfs  = openFile:ReadLong();
--                    local numStr  = openFile:ReadLong();
--                    local strOfs  = openFile:ReadLong();
--                    local _flags  = openFile:ReadByte();
--
--                    -- cache this StripGroup’s Vertex_t table
--                    local sgVerts = {}
--                    do
--                        openFile:Seek(vertOfs);
--                        for v = 1, numGV do
--                            local boneW0   = openFile:ReadByte();  -- weights, #bones ...
--                            local boneW1   = openFile:ReadByte();
--                            local boneW2   = openFile:ReadByte();
--                            local numBones = openFile:ReadByte();
--                            local origID   = openFile:ReadShort();  -- uint16
--                            openFile:Read(3)                        -- bone IDs (3 bytes) – ignored
--                            sgVerts[v] = origID              -- save mapping
--                        end
--                    end
--
--                    -- grab raw index list once
--                    local sgIndices = {}
--                    openFile:Seek(idxOfs);
--                    for i = 1, numIdx do
--                        sgIndices[i] = openFile:ReadShort() + 1       -- Lua 1-based
--                    end
--
--                    -------------------------------
--                    -- 3.4  Expand every Strip
--                    -------------------------------
--                    for s = 1, numStr do
--                        openFile:Seek(strOfs + (s-1)*17) -- StripHeader_t (17 bytes here)
--                        local sNumIdx  = openFile:ReadLong();
--                        local sIdxOfs  = openFile:ReadLong();
--                        local _sNumV   = openFile:ReadLong();
--                        local _sVertOf = openFile:ReadLong();
--                        local _sBones  = openFile:ReadShort();
--                        local sFlags   = openFile:ReadByte();
--                        openFile:Read(4)                            -- numBoneStateChanges
--
--                        --------------------------------
--                        -- Build triangle list for strip
--                        --------------------------------
--                        -- Gather the sub-slice of indices this strip refers to
--                        local first = sIdxOfs/2 + 1         -- because idx array is uint16
--                        local last  = first + sNumIdx - 1
--                        local slice = {}
--                        for j=first,last do slice[#slice+1]=sgIndices[j] end
--
--                        local addTri = function(a,b,c)
--                            triangles[tri_i] = {a,b,c}; tri_i = tri_i+1
--                        end
--
--                        if bit.band(sFlags, 0x01) ~= 0 then
--                            -- already a triangle list
--                            for j=1,#slice,3 do
--                                addTri(
--                                        sgVerts[slice[j  ]],
--                                        sgVerts[slice[j+1]],
--                                        sgVerts[slice[j+2]]
--                                )
--                            end
--                        else -- treat as triangle strip
--                            for j=3,#slice do
--                                local i0,i1,i2 = slice[j-2],slice[j-1],slice[j]
--                                if (j % 2)==0 then i1,i0 = i0,i1 end -- flip winding on odd
--                                addTri(
--                                        sgVerts[i0],
--                                        sgVerts[i1],
--                                        sgVerts[i2]
--                                )
--                            end
--                        end
--                    end
--                end
--            end
--        end
--        --bodyPartHeaders[bodyPartIndex] = bodyPartHeader;
--    end
--    return triangles;
--    ----Move to the start of the body part header
--    --openFile:Seek(headers.bodyPartOffset);
--    --
--    --for bodyPartID = 1, headers.numBodyParts do
--    --    bodyParts[bodyPartID] = self:ParseBodyPartHeader(openFile);
--    --end;
--    --return bodyPartHeaders;
--end;

--local headers = modelData.headers;
--local triangles = {};
--for bodyPartIndex = 1, headers.numBodyParts do
--    openFile:Seek(headers.bodyPartOffset + (bodyPartIndex - 1) * 8);
--    --local bodyPartHeader = self:ParseBodyPartHeader(openFile);
--    local bodyPartHeader = {
--        numModels = openFile:ReadLong(),
--        modelOffset = openFile:ReadLong()
--    };
--    local numModels = bodyPartHeader.numModels;
--    local modelOffset = bodyPartHeader.modelOffset;
--    for modelId = 1, numModels do
--        local lodHeaderOffset = modelOffset + (modelId - 1) * 8;
--        print('lodHeaderOffset ' .. lodHeaderOffset);
--        openFile:Seek(lodHeaderOffset);
--        local numLODs = openFile:ReadLong();
--        local lodOffset = openFile:ReadLong();
--        openFile:Seek(lodOffset);
--        local numMeshes = openFile:ReadLong();
--        local meshOffset = openFile:ReadLong();
--        local switchPoint = openFile:ReadFloat();
--        print('meshData', numMeshes, meshOffset, switchPoint);
--        for meshId = 1, numMeshes do
--            openFile:Seek(meshOffset + (meshId - 1)*9);
--            print(openFile:EndOfFile());
--            local numGroups = openFile:ReadLong();
--            local groupOffset = openFile:ReadLong();
--            local flags = openFile:ReadByte();
--            print(numGroups, groupOffset, flags);
--            print(openFile:EndOfFile());
--            for stripeGroupId = 1, numGroups do
--                openFile:Seek(groupOffset + (stripeGroupId - 1) * 25)
--                print(openFile:EndOfFile());
--                local numGV   = openFile:ReadLong();
--                print(numGV);
--                local vertOfs = openFile:ReadLong();
--                print(vertOfs);
--                local numIdx  = openFile:ReadLong();
--                local idxOfs  = openFile:ReadLong();
--                local numStr  = openFile:ReadLong();
--                local strOfs  = openFile:ReadLong();
--                local _flags  = openFile:ReadByte();
--
--                -- cache this StripGroup’s Vertex_t table
--                local sgVerts = {}
--                do
--                    openFile:Seek(vertOfs);
--                    for v = 1, numGV do
--                        local boneW0   = openFile:ReadByte();  -- weights, #bones ...
--                        local boneW1   = openFile:ReadByte();
--                        local boneW2   = openFile:ReadByte();
--                        local numBones = openFile:ReadByte();
--                        local origID   = openFile:ReadShort();  -- uint16
--                        openFile:Read(3)                        -- bone IDs (3 bytes) – ignored
--                        sgVerts[v] = origID              -- save mapping
--                    end
--                end
--
--                -- grab raw index list once
--                local sgIndices = {}
--                openFile:Seek(idxOfs);
--                for i = 1, numIdx do
--                    sgIndices[i] = openFile:ReadShort() + 1       -- Lua 1-based
--                end
--
--                -------------------------------
--                -- 3.4  Expand every Strip
--                -------------------------------
--                for s = 1, numStr do
--                    openFile:Seek(strOfs + (s-1)*17) -- StripHeader_t (17 bytes here)
--                    local sNumIdx  = openFile:ReadLong();
--                    local sIdxOfs  = openFile:ReadLong();
--                    local _sNumV   = openFile:ReadLong();
--                    local _sVertOf = openFile:ReadLong();
--                    local _sBones  = openFile:ReadShort();
--                    local sFlags   = openFile:ReadByte();
--                    openFile:Read(4)                            -- numBoneStateChanges
--
--                    --------------------------------
--                    -- Build triangle list for strip
--                    --------------------------------
--                    -- Gather the sub-slice of indices this strip refers to
--                    local first = sIdxOfs/2 + 1         -- because idx array is uint16
--                    local last  = first + sNumIdx - 1
--                    local slice = {}
--                    for j=first,last do slice[#slice+1]=sgIndices[j] end
--
--                    local addTri = function(a,b,c)
--                        triangles[tri_i] = {a,b,c}; tri_i = tri_i+1
--                    end
--
--                    if bit.band(sFlags, 0x01) ~= 0 then
--                        -- already a triangle list
--                        for j=1,#slice,3 do
--                            addTri(
--                                    sgVerts[slice[j  ]],
--                                    sgVerts[slice[j+1]],
--                                    sgVerts[slice[j+2]]
--                            )
--                        end
--                    else -- treat as triangle strip
--                        for j=3,#slice do
--                            local i0,i1,i2 = slice[j-2],slice[j-1],slice[j]
--                            if (j % 2)==0 then i1,i0 = i0,i1 end -- flip winding on odd
--                            addTri(
--                                    sgVerts[i0],
--                                    sgVerts[i1],
--                                    sgVerts[i2]
--                            )
--                        end
--                    end
--                end
--            end
--        end
--    end
--    --bodyPartHeaders[bodyPartIndex] = bodyPartHeader;
--end
----Parse the body part headers
----modelData.triangles = self:ParseBodyPartHeaders(
----        modelData.headers,
----        openFile
----);
--modelData.triangles = triangles;
------Parse the model headers
----modelData.modelHeaders = self:ParseModelHeaders(
----        modelData,
----        openFile
----);
------ Parse the lod mesh array
----modelData.lodMeshHeaders = self:ParseLODMeshHeaders(
----    modelData.modelHeaders,
----    openFile
----);
------ Parse the mesh headers
----modelData.meshHeaders = self:ParseMeshHeaders(
----    modelData.lodMeshHeaders,
----    openFile
----);