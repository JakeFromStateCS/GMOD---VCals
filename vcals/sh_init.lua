--[[
    Vehicle Decal System
    JakeFromStateCS
    Credit to The Maw for helping my dumb ass
    vcals/sh_init.lua
]]--
--Pass our global table to this file
VCals = VCals or {};


--[[
    VCals:LoadFile( String/filePath ):
        Handles loading of files at the specified path
]]--
function VCals:LoadFile( filePath )
    local split = string.Split( filePath, "/" );
    --Separate our file name from the full path
    local fileName = split[#split];
    --Get the prefix to determine how to load it
    local prefix = string.sub( fileName, 1, 3 );

    if( SERVER ) then
        if( prefix == "sh_" or prefix == "cl_" ) then
            AddCSLuaFile( filePath );
        end;
        if( prefix ~= "cl_" ) then
            include( filePath );
        end;
    else
        if( prefix ~= "sv_" ) then
            include( filePath );
        end;
    end;
end;

--[[
	VCals:LoadFolder(String/filePath):
		Recursively loads all lua files under a particular directory
]]--
function VCals:LoadFolder(filePath)
	local files, folders = file.Find(filePath .. '*', 'LUA');
	for _, folder in pairs(folders) do
		if (folder ~= filePath) then
			self:LoadFolder(filePath .. folder);
		end;
	end;

	for _,file in pairs(files) do
		self:LoadFile(filePath .. file);
	end;
end;


function VCals:RunOnLoads()
    for _,libTable in pairs( VCals ) do
        print(libTable);
        if( type( libTable ) == "table" ) then
            if( libTable.Load ) then
                PrintTable(libTable);
                libTable:Load();
            end;
        end;
    end;
end;

--Load our lib sh_init
VCals:LoadFile( "vcals/lib/sh_init.lua" );
VCals:RunOnLoads()
VCals.Debug:Print( Color( 255, 255, 255 ), "Loaded sh_init.lua" );