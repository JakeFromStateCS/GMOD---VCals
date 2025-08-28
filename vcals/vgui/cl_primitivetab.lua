--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_primitivetab.lua
]]--

local PANEL = {};

function PANEL:Init()
    self.Icon = Material( "" );
    self.IconColor = Color( 255, 255, 255 );
    self.BackgroundColor = Color( 0, 0, 0 );
    self.Selected = false;
    self.Primitives = {};
end;

function PANEL:Paint( w, h )
    --Background
    surface.SetDrawColor( self.BackgroundColor );
    surface.DrawRect(
        0,
        0,
        w,
        h
    );
end;