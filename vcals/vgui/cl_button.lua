--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_button.lua
]]--

surface.CreateFont(
    "VCals_Button",
    {
        font = "Arial",
        size = ScreenScale( 5 ),
        weight = 600
    }
);

local PANEL = {};
function PANEL:Init()
    self.Text = "";
    self.Font = "VCals_Button";
    self.Icon = "";
    self.IconColor = Color( 255, 255, 255 );
    self.MouseOver = false;
    self.TextColor = Color( 255, 255, 255 );
    self.OutlineColor = Color( 0, 0, 0 );
    self.LightColor = Color( 88, 88, 88 );
    self.DarkColor = Color( 54, 54, 54 );
    self.HoverLightColor = Color( 112, 112, 112 );
    self.HoverDarkColor = Color( 82, 82, 82 );
    self.TopColor = self.LightColor;
    self.BottomColor = self.DarkColor;
    self:SetSize( 308, 26 );
end;

function PANEL:SetText( text )
    self.Text = text;
end;

function PANEL:SetIcon( icon )
    self.Icon = icon;
    self.Material = Material( icon );
end;

function PANEL:OnMousePressed()
    self.TextColor = Color( 240, 150, 66 );
    self.TopColor = Color( 0, 0, 0 );
    self.BottomColor = Color( 0, 0, 0 );
    self.IconColor = self.TextColor;
    self.OutlineColor = self.TextColor;
end;

function PANEL:OnMouseReleased()
    self.TextColor = Color( 255, 255, 255 );
    self.TopColor = self.LightColor;
    self.BottomColor = self.DarkColor;
    self.IconColor = self.TextColor;
    self.OutlineColor = Color( 0, 0, 0 );

    if( self.OnClick ~= nil ) then
        self:OnClick();
    end;
    local drip = CreateSound( LocalPlayer(), "ambient/water/rain_drip4.wav" );
    drip:SetDSP( 1 );
    drip:PlayEx( 100, 206 );
end;

function PANEL:OnCursorEntered()
    self.TopColor = self.HoverLightColor;
    self.BottomColor = self.HoverDarkColor;
    self:SetCursor( "hand" );
end;

function PANEL:OnCursorExited()
    self.TextColor = Color( 255, 255, 255 );
    self.TopColor = self.LightColor;
    self.BottomColor = self.DarkColor;
    self.IconColor = self.TextColor;
    self.OutlineColor = Color( 0, 0, 0 );
    self:SetCursor( "arrow" );
end;

function PANEL:SetOnClick( func )
    self.OnClick = func;
end;

function PANEL:Paint( w, h )
    local highlightAmount = 8;
    local highlightStripColor = Color( self.BottomColor.r + highlightAmount, self.BottomColor.g + highlightAmount, self.BottomColor.b + highlightAmount );
    surface.SetDrawColor( self.OutlineColor );
    surface.DrawRect(
        0,
        0,
        w,
        h
    );
    surface.SetDrawColor( self.TopColor );
    surface.DrawRect(
        2,
        2,
        w - 4,
        h / 2 - 2
    );
    surface.SetDrawColor( self.BottomColor );
    surface.DrawRect(
        2,
        h / 2,
        w - 4,
        h / 2 - 2
    );
    surface.SetDrawColor( highlightStripColor );
    surface.DrawRect(
        2,
        h / 2,
        w - 4,
        h / 3 - 2
    );
    draw.SimpleText(
        self.Text,
        self.Font,
        w / 2,
        h / 2,
        self.TextColor,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    );

    if( self.Icon ~= "" ) then
        local iconSize = 60;
        local iconPos = { x = 1, y = 1 };
        local iconSize = { w = h - 2, h = h - 2 };
        if( self.IconPos ) then iconPos = self.IconPos end;
        if( self.IconSize ) then iconSize = self.IconSize end;
        surface.SetDrawColor( self.IconColor );
        surface.SetMaterial( self.Material );
        surface.DrawTexturedRect(
            iconPos.x,
            iconPos.y,
            iconSize.w,
            iconSize.h
        );
    end;
end;
vgui.Register( "VCals_Button", PANEL );