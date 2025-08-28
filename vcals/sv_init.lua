--[[
    Vehicle Decal System
    JakeFromStateCS
    Credit to The Maw for helping my dumb ass
    vcals/sv_init.lua
]]--
--Define our global table
VCals = {};

--AddCSLuaFile sh_init.lua
AddCSLuaFile( "vcals/sh_init.lua" );
--AddCSLuaFile and include our config and debug
AddCSLuaFile( "vcals/config/sh_init.lua" );
AddCSLuaFile( "vcals/lib/debug/sh_init.lua" );
include( "vcals/config/sh_init.lua" );
include( "vcals/lib/debug/sh_init.lua" );
--Include sh_init.lua
include( "vcals/sh_init.lua" );