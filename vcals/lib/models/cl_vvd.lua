/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/lib/models/cl_vvd.lua
	Handles parsing of VVD files
	Thanks to "raspbian got DABBED on#0572" in the Gmod Dev Discord for helping me figure this shit out
*/

--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create a global decal table
VCals.Models = VCals.Models or {};
--This will hold all the functions for parsing VVDs
VCals.Models.VVD = {};
VCals.Models.Cache = VCals.Models.Cache or {};

function VCals.Models.VVD:ParseHeader( openFile )
	--Stores the header data to be returned after we read it
	local headerData = {
		id = openFile:ReadLong(),
		version = openFile:ReadLong(),
		checksum = openFile:ReadLong(),
		numLODs = openFile:ReadLong(),
		numLODVertexes = openFile:ReadLong()
	};
	--Read 7 more longs for 8 levels of detail ( LODs )
	for i = 2, 8 do
		openFile:ReadLong();
	end;
	headerData.numFixups = openFile:ReadLong();
	headerData.fixupTableStart = openFile:ReadLong();
	headerData.vertexDataStart = openFile:ReadLong();
	headerData.tangentDataStart = openFile:ReadLong();
	return headerData;
end;

--[[
	VCals.Models.VVD:ParseFixupTable( Stream/openFile ):
		Parses the next fixup table in the open file stream
		Returns it as a table
]]--
function VCals.Models.VVD:ParseFixupTable( openFile )
	local fixupTable = {
		lod = openFile:ReadLong(),
		sourceVertexID = openFile:ReadLong(),
		numVertexes = openFile:ReadLong()
	};
	return fixupTable;
end;

--[[
	VCals.Models.VVD:ParseFixupTables( Int/numLODs, Stream/openFile ):
		Parses numLODs number of fixup tables
		Returns them as a table of fixup tables
]]--
function VCals.Models.VVD:ParseFixupTables( numLODs, openFile )
	local fixupTables = {};
	for curLOD = 1, numLODs do
		local fixupTable = self:ParseFixupTable( openFile );
		if( fixupTable ) then
			fixupTables[fixupTable.lod] = fixupTable;
		end;
	end;
	return fixupTables;
end;

--[[
	VCals.Models.VVD:ParseVertex( Stream/openFile ):
		Parses the next vertex in the file stream
		Returns it as a table
]]--
function VCals.Models.VVD:ParseVertex( openFile )
	--Skip the first 16 bytes since it's bone weight and we don't care about that
	openFile:Read( 16 );
	local vertex = {
		position = Vector( openFile:ReadFloat(), openFile:ReadFloat(), openFile:ReadFloat() ),
		normal = Vector( openFile:ReadFloat(), openFile:ReadFloat(), openFile:ReadFloat() ),
		texCoord = { u = openFile:ReadFloat(), v = openFile:ReadFloat() }
	};
	return vertex;
end;

function VCals.Models.VVD:ParseVertexes( numLODVertexes, vertexDataStart, openFile )
	--Define our vertex table
	local vertexes = {};
	--Jump to the start of the vertex data
	openFile:Seek( vertexDataStart );
	--Loop through all the vertexes
	for vertexID = 1, numLODVertexes do
		--Insert them into our vertex table
		table.insert( vertexes, self:ParseVertex( openFile ) );
	end;
	--Return it
	return vertexes;
end;

--[[
	VCals.Models.VVD:Parse( String/fileName ):
		Parses the .vtx file for the visual mesh
]]--
function VCals.Models.VVD:Parse( fileName )
	--Open the file in binary mode
	local openFile = file.Open( fileName, "rb", "GAME" );
	if( !openFile ) then
		VCals.Debug:Print( Color( 255, 255, 0 ), "Unable to read file: " .. fileName );
		return;
	end;
	local modelData = {
		headers = self:ParseHeader( openFile )
		
	};
	modelData.fixupTables = self:ParseFixupTables( modelData.headers.numLODs, openFile );
	modelData.vertexes = self:ParseVertexes( modelData.headers.numLODVertexes, modelData.headers.vertexDataStart, openFile );
	
	return modelData;
end;