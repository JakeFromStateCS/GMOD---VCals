--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/lib/sh_init.lua
]]--
--Pass our global table to this file
VCals = VCals or {};

--Create a global lib table
VCals.Libraries = {};
VCals.Libraries.Config = {
    Directory = "vcals/lib/"
};

--[[
    VCals.Libraries:Load():
        Loads the libraries
]]--
function VCals.Libraries:Load()
    local _, dirs = file.Find( self.Config.Directory .. "*", "LUA" );
    for _,dir in pairs( dirs ) do
        VCals.Debug:Print( Color( 255, 150, 0 ), dir );
        VCals.Debug:Print( Color( 255, 255, 255 ), "---------------" );
        local filePath = self.Config.Directory .. dir;
        local files = file.Find( filePath .. "/*.lua", "LUA" );
        for _,file in pairs( files ) do
            VCals.Debug:Print( Color( 255, 255, 255 ), "    " .. file );
            VCals:LoadFile( filePath .. "/" .. file );
        end;
    end;
end;

VCals.Libraries:Load();