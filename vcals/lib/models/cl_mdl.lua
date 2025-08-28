--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/lib/models/cl_vvd.lua
    Handles parsing of VVD files
    Thanks to "raspbian got DABBED on#0572" in the Gmod Dev Discord for helping me figure this shit out
    https://developer.valvesoftware.com/wiki/MDL
]]--

--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create a global decal table
VCals.Models = VCals.Models or {};
--This will hold all the functions for parsing VVDs
VCals.Models.MDL = {};
VCals.Models.Cache = VCals.Models.Cache or {};

function VCals.Models.MDL:ReadVector(openFile)
    return {
        x = openFile:ReadFloat(),
        y = openFile:ReadFloat(),
        z = openFile:ReadFloat(),
    };
end

function VCals.Models.MDL:ParseHeader( openFile )
    --Stores the header data to be returned after we read it
    local headers = {
        id = openFile:ReadLong(),
        version = openFile:ReadLong(),
        checksum = openFile:ReadLong(),
        numLODs = openFile:ReadLong(),
        numLODVertexes = {}
    };

    for lodId = 1, 8 do
        headers.numLODVertexes[lodId] = openFile:ReadLong();
    end
    headers['numFixups'] = openFile:ReadLong();
    headers['fixupTableStart'] = openFile:ReadLong();
    headers['vertexDataStart'] = openFile:ReadLong();
    headers['tangentDataStart'] = openFile:ReadLong();
    --};
    return headers;
end;

--[[
    VCals.Models.MDL:ParseFixupTable( Stream/openFile ):
        Parses the next fixup table in the open file stream
        Returns it as a table
]]--
function VCals.Models.MDL:ParseFixupTable( openFile )
    return {
        lod = openFile:ReadLong(),
        sourceVertexID = openFile:ReadLong(),
        numVertexes = openFile:ReadLong()
    };
end;

--[[
    VCals.Models.MDL:ParseFixupTables( Int/numLODs, Stream/openFile ):
        Parses numLODs number of fixup tables
        Returns them as a table of fixup tables
]]--
function VCals.Models.MDL:ParseFixupTables( modelHeaders, openFile )
    local fixupTables = {};
    openFile:Seek(modelHeaders.fixupTableStart);
    for lodIndex = 1, modelHeaders.numLODs do
        fixupTables[lodIndex] = self:ParseFixupTable(openFile);
    end;
    return fixupTables;
end;

--[[
    VCals.Models.MDL:ParseVertex( Stream/openFile ):
        Parses the next vertex in the file stream
        Returns it as a table
]]--
function VCals.Models.MDL:ParseVertex( openFile )
    --Skip the first 16 bytes since it's bone weight and we don't care about that
    openFile:Read( 16 );
    return {
        position = Vector(
            openFile:ReadFloat(),
            openFile:ReadFloat(),
            openFile:ReadFloat()
        ),
        normal = Vector(
            openFile:ReadFloat(),
            openFile:ReadFloat(),
            openFile:ReadFloat()
        ),
        texCoord = { u = openFile:ReadFloat(), v = openFile:ReadFloat() }
    };
end;

function VCals.Models.MDL:ParseVertexes(modelData, openFile)
    -- Get the start byte of our vertex data
    -- We're going to use this to seek to the beginning of the vertex data
    local vertexDataStart = modelData.headers.vertexDataStart;
    openFile:Seek(vertexDataStart);
    local vertexes = {};
    for _ = 1, modelData.headers.numLODVertexes[1] do
        table.insert(
            vertexes,
            self:ParseVertex( openFile )
        );
        --print(fixupTableIndex, numVertexes);
        ----for _ = 1, numVertexes do
        --
        ----end
    end
    return vertexes;
    --Define our vertex table
    --local vertexes = {};
    ----Jump to the start of the vertex data
    --openFile:Seek(vertexDataStart);
    ----Loop through all the vertexes
    --for vertexID = 1, numLODVertexes do
    --    --Insert them into our vertex table
    --    table.insert( vertexes, self:ParseVertex( openFile ) );
    --end;
    ----Return it
    --return vertexes;
end;

--[[
    VCals.Models.MDL:Parse( String/fileName ):
        Parses the .vtx file for the visual mesh
]]--
function VCals.Models.MDL:Parse( fileName )
    local vvdFilePath = fileName.replace('.mdl', '.vvd');
    local vtxFilePath = fileName.replace('.mdl', '.vtx');
    if (file.Exists(vvdFilePath) == false) then
        VCals.Debug:Print(Color( 255, 255, 0 ), "Unable to read file: " .. vvdFilePath);
        return;
    end

    if (file.Exists(vtxFilePath) == false) then
        -- Look for the file path with a dx90 prefix
        vtxFilePath = vtxFilePath.replace('.vtx', '.dx90.vtx');
        if (file.Exists(vtxFilePath) == false) then
            VCals.Debug:Print( Color( 255, 255, 0 ), "Unable to read file: " .. vtxFilePath );
            return;
        end
    end

    --Open the file in binary mode
    local openFile = file.Open( fileName, "rb", "GAME" );
    if (openFile == nil) then
        VCals.Debug:Print( Color( 255, 255, 0 ), "Unable to read file: " .. fileName );
        return;
    end;
    local modelData = {
        headers = self:ParseHeader(openFile)
    };
    -- We can only parse fixups if we have LODs
    --print('Parsing fixup tables...');
    --modelData.fixupTables = self:ParseFixupTables(
    --    modelData.headers,
    --    openFile
    --);
    modelData.vertexes = self:ParseVertexes(
        modelData,
        openFile
    );

    return modelData;
end;