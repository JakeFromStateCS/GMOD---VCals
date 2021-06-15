/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/lib/modules/sh_init.lua
*/
--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create the modules table
VCals.Modules = VCals.Modules or {};
VCals.Modules.Config = {
	Directory = "vcals/modules/"
}
VCals.Modules.Stored = VCals.Modules.Stored or {};
VCals.Modules.Hooks = {};
VCals.Modules.PostLoads = {};

--[[
	VCals.Modules:RegisterHooks( Table/MODULE ):
		Registers the hook for the specified module
]]--
function VCals.Modules:RegisterHooks( MODULE )
	for hookName,hookFunc in pairs( MODULE.Hooks ) do
		local func = function( ... )
			local retVal = hookFunc( MODULE, ... );
			if( retVal ) then
				return retVal;
			end;
		end;
		if( !self.Hooks[hookName] ) then
			self.Hooks[hookName] = {};
		end;
		local hooks = self.Hooks[hookName];
		hook.Add( hookName, "VCals_" .. hookName, function( ... )
			local retVal;
			for _,hookFunc in pairs( hooks ) do
				retVal = hookFunc( ... );
			end;
			if( retVal ) then
				return retVal;
			end;
		end );
		table.insert( self.Hooks[hookName], func );
	end;
end;

--[[
	VCals.Modules:RegisterNets( Table/MODULE ):
		Registers the net messages for the specified module
]]--
function VCals.Modules:RegisterNets( MODULE )
	for netName,netFunc in pairs( MODULE.Nets ) do
		local func = function( ... )
			netFunc( MODULE, ... );
		end;
		VCals.Netmsg:Register( netName, func );
	end;
end;

--[[
	VCals.Modules:Register( Table/MODULE ):
		Handles module registration
]]--
function VCals.Modules:Register( MODULE )
	if( MODULE.PreLoad ) then
		MODULE:PreLoad();
	end;
	self:RegisterNets( MODULE );
	self:RegisterHooks( MODULE );
	self.Stored[MODULE.Name] = MODULE;
end;

--[[
	VCals.Modules:Load():
		Loads all the modules
]]--
function VCals.Modules:Load()
	local files, folders = file.Find( self.Config.Directory .. "*", "LUA" );
	for _,dir in pairs( folders ) do
		MODULE = {};
		local filePath = self.Config.Directory .. dir;
		local files = file.Find( filePath .. "/*.lua", "LUA" );
		MODULE.Directory = filePath;
		for _,file in pairs( files ) do
			VCals:LoadFile( filePath .. "/" .. file );
		end;
		if( MODULE.Name ) then
			self:Register( MODULE );
		end;
		--If it has an onload, run it
		if( MODULE.OnLoad ) then
			MODULE:OnLoad();
		end;
		--If the module has a post load function
		--Insert it into the table to be run after all
		--Modules are loaded
		if( MODULE.PostLoad ) then
			table.insert( self.PostLoads, MODULE.Name );
		end;
		MODULE = nil;
	end;
	--Run the post loads
	for _,name in pairs( self.PostLoads ) do
		local MODULE = self.Stored[name];
		MODULE:PostLoad();
	end;
end;