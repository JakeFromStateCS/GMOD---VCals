--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_designercanvas.lua
]]--

local PANEL = {};

function PANEL:Init()
    local parent = self:GetParent();
    self.Decal = VCals.Editor.Decal;
    self.Elements = {};
    self:SetSize( ScrH() / 3 * 2 + 50, ScrH() / 3 * 2 + 50 );
    self:Center();
    local x, y = self:GetPos();
    self:SetPos( x, 114 );
end;

function PANEL:AddElement()
    local parent = self:GetParent();
    local element = self.Decal:AddElement();
    parent.LayerContainer:AddElement( element );
    local panel = vgui.Create( "VCals_CanvasElement", self );
    panel:SetElement( element );
    panel:SetSize( self:GetWide() / 2, self:GetTall() / 2 );
    panel:Center();
    self.Elements[element] = panel;
    element.CanvasPanel = panel;
    return panel;
end;

function PANEL:OnMousePressed()
    VCals.Editor:StartAction();
end;

function PANEL:OnMouseReleased()
    VCals.Editor:EndAction();
end;

function PANEL:Paint( w, h )
    surface.SetDrawColor( Color( 0, 0, 0 ) );
    surface.DrawRect( 0, 0, w, h );
    surface.SetDrawColor( Color( 114, 110, 104 ) );
    surface.DrawRect( 2, 2, w - 4, h - 4 );

    if( VCals.Editor.Action ) then
        local ACTION = VCals.Editor.Actions[VCals.Editor.Action];
        if( ACTION.Angle ) then
            draw.SimpleText(
                ACTION.Angle,
                "ChatFont",
                w,
                h,
                Color( 255, 255, 255 ),
                TEXT_ALIGN_RIGHT,
                TEXT_ALIGN_BOTTOM
            );
        end;
    end;
end;
vgui.Register( "VCals_Canvas", PANEL );