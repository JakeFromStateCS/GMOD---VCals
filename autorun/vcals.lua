--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals.lua
]]--
if( SERVER ) then
    AddCSLuaFile();
    AddCSLuaFile( "vcals/cl_init.lua" );
    include( "vcals/sv_init.lua" );
else
    include( "vcals/cl_init.lua" );
end;