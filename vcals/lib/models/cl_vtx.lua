/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/lib/models/cl_vtx.lua
	Handles parsing of VTX files
	Thanks to "raspbian got DABBED on#0572" in the Gmod Dev Discord for helping me figure this shit out
	Thanks also to MDave on Facepunch for providing his old parsers
*/

--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create a global decal table
VCals.Models = VCals.Models or {};
--This will hold all the functions for parsing VVDs
VCals.Models.VTX = {};
VCals.Models.Cache = VCals.Models.Cache or {};

--[[
	VCals.Models.VTX:ParseHeader( Stream/openFile ):
		Parses the header of the VTX file and returns it as a table
]]--
function VCals.Models.VTX:ParseHeader( openFile )
	--Stores the header data to be returned after we read it
	local headerData = {
		--The file version as defined by OPTIMIZED_MODEL_FILE_VERSION ( currently 7 )
		version = openFile:ReadLong(),
		--Hardware params that affect how the model is to be optimized
		vertCacheSize = openFile:ReadLong(),
		maxBonesPerStrip = openFile:ReadShort(),
		maxBonesPerTri = openFile:ReadShort(),
		maxBonesPerVert = openFile:ReadLong(),
		--Must match the checksum in the .mdl and .vvd
		checksum = openFile:ReadLong(),
		--Should also match the .mdl and .vvd
		numLODs = openFile:ReadLong(),
	};
	--Offset to material replacement list array. One of these for each LOD, 8 in total
	headerData.materialReplacementListOffset = openFile:ReadLong();
	--Defines the size and location of the body part array
	headerData.numBodyParts = openFile:ReadLong();
	headerData.bodyPartOffset = openFile:ReadLong();
	return headerData;
end;

--[[
	VCals.Models.VTX:ParseBodyPartHeader( Stream/openFile ):
		Parses the next BodyPartHeader in the open file stream
]]--
function VCals.Models.VTX:ParseBodyPartHeader( openFile )
	local bodyPart = {
		numModels = openFile:ReadLong(),
		modelOffset = openFile:ReadLong()
	};
	return bodyPart;
end;

--[[
	VCals.Models.VTX:ParseBodyArray( Int/numBodyParts, Int/bodyPartOffset, Stream/openFile ):
		Parses the body array of the open file stream
]]--
function VCals.Models.VTX:ParseBodyArray( headers, openFile )
	--Move to the start of the body part header
	openFile:Seek( headers.bodyPartOffset );
	local bodyParts = {};
	for bodyPartID = 1, headers.numBodyParts do
		local bodyPart = self:ParseBodyPartHeader( openFile );
		bodyParts[bodyPartID] = bodyPart;
	end;
	return bodyParts;
end;

--[[
	VCals.Models.VTX:ParseModelHeader( Stream/openFile ):
		Parses the ModelHeader_t section of the VTX file
		Returns it as a table
]]--
function VCals.Models.VTX:ParseModelHeader( openFile )
	local modelHeader = {
		numLODs = openFile:ReadLong(),
		lodOffset = openFile:ReadLong()
	};
	return modelHeader;
end;

--[[
	VCals.Models.VTX:ParseModelArray( Table/bodyArray, Stream/openFile ):
		Parses the Model Array from the open file stream
		Returns it as a table
]]--
function VCals.Models.VTX:ParseModelArray( bodyArray, openFile )
	local modelArray = {};
	--Loop through all the body part headers
	for bodyPartID = 1, #bodyArray do
		local bodyPartHeader = bodyArray[bodyPartID];
		--Seek to the start of the model array
		openFile:Read( bodyPartHeader.modelOffset );
		local modelHeader = self:ParseModelHeader( openFile );
		table.insert( modelArray, modelHeader );
	end;
	return modelArray;
end;

--[[
	VCals.Models.VTX:ParseLODHeader( Stream/openFile ):
		Parses ModelLODHeader_t from the open file stream
]]--
function VCals.Models.VTX:ParseLODHeader( openFile )
	local meshHeader = {
		numMeshes = openFile:ReadLong(),
		meshOffset = openFile:ReadLong(),
		switchPoint = openFile:ReadFloat()
	};
	return meshHeader;
end;

--[[
	VCals.Models.VTX:ParseMeshArray( Table/modelArray, Stream/openFile ):
		Parses the LOD Mesh Array into a table of LOD Headers
]]--
function VCals.Models.VTX:ParseMeshArray( modelArray, openFile )
	local meshArray = {};
	--Seek to the start of the mesh array
	for modelHeaderID = 1, #modelArray do
		local modelHeader = modelArray[modelHeaderID];
		--Skip to the start of the mesh array
		openFile:Read( modelHeader.lodOffset );
		local LODHeader = self:ParseLODHeader( openFile );
		table.insert( meshArray, LODHeader );
	end;
	return meshArray;
end;

function VCals.Models.VTX:ParseMeshHeader( openFile )
	local meshHeader = {
		numStripGroups = openFile:ReadLong(),
		stripGroupHeaderOffset = openFile:ReadLong(),
		flags = openFile:Read(1)
	};
	return meshHeader;
end;

function VCals.Models.VTX:ParseMeshHeaders( meshArray, openFile )
	local meshHeaders = {};
	--Seek to the start of the 
	for meshLODHeaderID = 1, #meshArray do
		local meshLODHeader = meshArray[meshLODHeaderID];
		--Seek to the offset
		openFile:Read( meshLODHeader.meshOffset );
		--Loop through the number of meshes
		for meshID = 1, meshLODHeader.numMeshes do
			local meshHeader = self:ParseMeshHeader( openFile );
			table.insert( meshHeaders, meshHeader );
		end;
	end;
	return meshHeaders;
end;

--[[
	VCals.Models.VTX:Parse( String/fileName ):
		Parses the .vtx file for the visual mesh
]]--
function VCals.Models.VTX:Parse( fileName )
	--Open the file in binary mode
	local openFile = file.Open( fileName, "rb", "GAME" );
	if( !openFile ) then
		--VCals.Debug:Print( Color( 255, 255, 0 ), "Unable to read file: " .. fileName );
		print( "Unable to read file" );
		return;
	end;
	local modelData = {
		headers = self:ParseHeader( openFile )
	};
	--Parse the body part headers
	modelData.bodyArray = self:ParseBodyArray(
		modelData.headers,
		openFile
	);
	--Parse the model headers
	modelData.modelArray = self:ParseModelArray(
		modelData.bodyArray,
		openFile
	);
	modelData.meshArray = self:ParseMeshArray(
		modelData.modelArray,
		openFile
	);
	modelData.meshHeaders = self:ParseMeshHeaders(
		modelData.meshArray,
		openFile
	);
	PrintTable( modelData.meshHeaders );
end;