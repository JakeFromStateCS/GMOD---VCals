/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/lib/vgui/sh_init.lua
*/
--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
VCals.Vgui = {};
VCals.Vgui.Stored = {};
VCals.Vgui.Config = {
	Directory = "vcals/vgui/"
};


--[[
	VCals.Vgui:Load():
		Loads all the vgui elements necessary
]]--
function VCals.Vgui:Load()
	VCals:LoadFolder(self.Config.Directory);
	-- local files = file.Find( self.Config.Directory .. "*.lua", "LUA" );
	-- for _,file in pairs( files ) do
	-- 	local filePath = self.Config.Directory .. file;
	-- 	VCals:LoadFile( filePath );
	-- end;
end;

--Load the vgui elements
VCals.Vgui:Load();