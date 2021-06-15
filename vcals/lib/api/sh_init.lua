/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/lib/api/sh_init.lua

	Handles the loading of the API plugins.
	The API plugins manage compatibility with other garage addons
	In order to avoid the necessity of creating a full garage back-end
*/
--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create the api table
VCals.Api = {};
VCals.Api.Config = {
	--The directory to load the module from
	Directory = "/vals/api/"
};

--[[
	function VCals.Api:LoadModules():
		Loads modules for compatibility
]]--
function VCals.Api:LoadModules()
	local directories, _ = file.Find( self.Config.Directory .. "*", "LUA" );
	if( directories ) then
		for _,dir in pairs( directories ) do
			print( dir );
		end;
	end;
end;

--[[
	function VCals.Api:Register( Table/API ):
		Registers an API module
]]--
function VCals.Api:Register( API )

end;

VCals.Api:LoadModules();