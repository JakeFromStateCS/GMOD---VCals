--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_submenu.lua
]]--

surface.CreateFont(
    "VCals_SubmenuTitle",
    {
        font = "Tahoma",
        size = ScreenScale( 7.6 ),
        weight = 600
    }
);

local PANEL = {};

function PANEL:Init()
    self.Title = "";
    self.Subtitle = "";
    self.Font = "VCals_SubmenuTitle";
end;

function PANEL:SetTitle( title )
    self.Title = title;
end;

function PANEL:Paint( w, h )
    surface.SetDrawColor( Color( 20, 20, 20, 200 ) );
    surface.DrawRect(
        0,
        0,
        w,
        h
    );

    surface.SetDrawColor( Color( 35, 35, 35 ) );
    surface.DrawRect(
        0,
        0,
        w,
        30
    );

    --Title
    draw.SimpleText(
        self.Title,
        self.Font,
        6,
        15,
        Color( 255, 255, 255 ),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    );

    if( self.Subtitle ~= "" ) then
        draw.SimpleText(
            self.Subtitle,
            self.Font,
            w - 6,
            15,
            Color( 255, 255, 255 ),
            TEXT_ALIGN_RIGHT,
            TEXT_ALIGN_CENTER
        );
    end;
end;
vgui.Register( "VCals_Submenu", PANEL );