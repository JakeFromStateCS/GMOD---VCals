--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_elementpanel.lua
]]--

local PANEL = {};

function PANEL:Init()
    self.Matrix = Matrix();
    self.IconPos = {
        x = 0,
        y = 0
    };
end;

function PANEL:SetElement( element )
    self.Element = element;
end;

function PANEL:SetIconSize( w, h )
    self.IconSize = {
        w = w / self.Element.Size.w,
        h = h / self.Element.Size.h
    };
end;

function PANEL:SetIconPos( x, y )
    self.IconPos = { x = x, y = y };
end;

function PANEL:Paint( w, h )
    if( self.Element ) then
        local selfX, selfY = self:GetPos();
        local scrX, scrY = self:LocalToScreen( selfX, selfY );
        local x, y = self.Element.Position.x, self.Element.Position.y;
        local scaleW, scaleH = w / self.Element.Size.w, h / self.Element.Size.h;
        local renderPosX, renderPosY = 0, 0;
        if( self.IconSize ) then
            scaleW = self.IconSize.w;
            scaleH = self.IconSize.h;
        end;
        local translation = Vector(
            ( scrX ) - ( selfX ) - ( x * scaleW ),
            ( scrY ) - ( selfY ) - ( y * scaleH ),
            0
        );
        surface.SetDrawColor( Color( 255, 0, 0 ) );
        surface.DrawOutlinedRect( 0, 0, w, h );
        self.Matrix:SetScale( Vector( scaleW, scaleH, 1 ) );
        self.Matrix:SetTranslation( translation );
        cam.Start2D();
            cam.PushModelMatrix( self.Matrix );
                self.Element:Draw();
            cam.PopModelMatrix();
        cam.End2D();
    end;


end;
vgui.Register( "VCals_ElementPanel", PANEL );