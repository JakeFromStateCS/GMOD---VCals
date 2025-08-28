--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_canvaselement.lua
]]--

local PANEL = {};

function PANEL:Init()
    self.BaseClass = baseclass.Get( "Panel" );
    self.OldSetSize = self.SetSize;
    self.OldSetPos = self.SetPos;
end;

function PANEL:SetColor( col )
    self.Element:SetColor( col );
end;

function PANEL:SetMaterial( mat )
    self.Element:SetMaterial( mat );
end;

function PANEL:SetSize( w, h )
    self.Element:SetSize( w, h );
    self.BaseClass.SetSize( self, w, h );
end;

function PANEL:SetPos( x, y )
    self.Element:SetPos( x, y );
    self.BaseClass.SetPos( self, x, y );
    --self:OldSetPos( x, y );
end;

function PANEL:SetRotation( rotation )
    self.Element:SetRotation( rotation );
end;

function PANEL:OnMouseReleased()
    self:GetParent():OnMouseReleased();
end;
vgui.Register( "VCals_CanvasElement", PANEL, "VCals_ElementPanel" );