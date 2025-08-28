--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_layerpanel.lua
]]--

surface.CreateFont(
    "VCals_LayerPanelTitle",
    {
        font = "Tahoma",
        size = ScreenScale( 8 )
    }
);

local PANEL = {};

function PANEL:Init()
    self.Selected = false;
    self.Black = Color( 0, 0, 0 );
    self.Yellow = Color( 240, 150, 66 );
    self.Gray = Color( 20, 20, 20, 200 );
    self.White = Color( 255, 255, 255 );
    self.OutlineColor = Color( 0, 0, 0 );
    self.BackgroundColor = self.Gray;
    self.TextColor = self.White;
    self.Padding = 16;
    self.Font = "VCals_LayerPanelTitle";
    self.Title = "";
    self.ElementPanel = vgui.Create( "VCals_ElementPanel", self );
    self.StarButton = vgui.Create( "VCals_IconPanel", self );
    self.StarButton:SetIcon( "/vcals/icons/Star5Point03.png" );
    self.StarButton:SetColor( Color( 255, 166, 0 ) );
end;

function PANEL:PerformLayout( w, h )
    self.ElementPanel:SetSize( h - self.Padding, h - self.Padding );
    self.ElementPanel:SetPos( self.Padding / 2, self.Padding / 2 );
    self.StarButton:SetSize( h / 2, h / 2 );
    self.StarButton:SetPos(
        w - self.Padding - self.StarButton:GetWide(),
        h / 2 - self.StarButton:GetWide() / 2
    );
end;

function PANEL:SetElement( element )
    element.LayerPanel = self;
    self.ElementPanel:SetElement( element );
    self.Element = element;
end;

function PANEL:SetSelected( bool )
    self.Selected = bool;
    if( bool ) then
        self.OutlineColor = self.Yellow;
        self.BackgroundColor = self.Black;
        self.TextColor = self.Yellow;
    else
        self.OutlineColor = self.Black;
        self.BackgroundColor = self.Gray;
        self.TextColor = self.White;
    end;
end;

function PANEL:SetIconSize( w, h )
    self.ElementPanel:SetSize( w, h );
end;

function PANEL:SetIconPos( x, y )
    self.ElementPanel:SetPos( x, y );
end;

function PANEL:OnMousePressed()
    VCals.Editor:SetElement( self.Element );
    VCals.Editor:SetPanel( self.Element.CanvasPanel );
end;

function PANEL:Paint( w, h )
    surface.SetDrawColor( self.BackgroundColor );
    surface.DrawRect(
        0,
        0,
        w,
        h
    );

    surface.SetDrawColor( self.OutlineColor );
    surface.DrawOutlinedRect(
        0,
        0,
        w,
        h
    );
    surface.DrawOutlinedRect(
        1,
        1,
        w - 2,
        h - 2
    );

    local elementX, elementY = self.ElementPanel:GetPos();
    draw.SimpleText(
        self.Title,
        self.Font,
        elementX + self.ElementPanel:GetWide() + self.Padding / 2,
        h / 2,
        self.TextColor,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    );
end;
vgui.Register( "VCals_LayerPanel", PANEL );
