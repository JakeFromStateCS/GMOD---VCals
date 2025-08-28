--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_vehicleicon.lua
]]--
local PANEL = {};

function PANEL:Init()
    local parent = self:GetParent();
    local parentHeight = parent:GetTall();
    self:SetSize( parentHeight, parentHeight );
    self.Cog = Material( "/vcals/icons/Garage_customize_button_icon.png" );
    self.CogColor = Color( 240, 170, 66 );
    --models/tdmcars/bmw_1m.mdl
end;

function PANEL:LayoutEntity()

end;

function PANEL:UpdateView()
    local Ent = self:GetEntity()
    PrevMins, PrevMaxs = Ent:GetRenderBounds()
    self:SetCamPos( ( PrevMins:Distance( PrevMaxs ) ) * Vector( 0.3, 0.5, 0.2 ) );
    self:SetLookAt( ( PrevMaxs + PrevMins ) * Vector( 0.5, 0.5, 0.5 ) + Vector( -20, 20, -30 ) );
end;

function PANEL:PaintOver( w, h )
    surface.SetDrawColor( self.CogColor );
    surface.SetMaterial( self.Cog );
    surface.DrawTexturedRect(
        h / 3 * 2,
        h / 3 * 2,
        h / 3,
        h / 3
    );
end;
vgui.Register( "VCals_VehicleIcon", PANEL, "DModelPanel" );