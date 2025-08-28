--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_menu.lua
]]--

surface.CreateFont(
    "VCals_MenuTitle",
    {
        font = "Verdana",
        size = ScreenScale( 10 ),
        weight = 600
    }
);

surface.CreateFont(
    "VCals_MenuSubtitle",
    {
        font = "Verdana",
        size = ScreenScale( 5.25 )
    }
);

local PANEL = {};

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() );
    self:Center();
    self.Title = "GARAGE";
    self.TitleFont = "VCals_MenuTitle";
    self.Subtitle = "MANAGE YOUR VEHICLES";
    self.SubtitleFont = "VCals_MenuSubtitle";

    self.CloseButton = vgui.Create( "VCals_CloseButton", self );
    self.CloseButton:SetPos( self:GetWide() - self.CloseButton:GetWide() - 2, 2 );
    self.Icon = Material( "/vcals/icons/icon_title_garage.png" );

    gui.EnableScreenClicker( true );
end;

function PANEL:SetSidebar( sidebar )
    if( self.Sidebar ) then
        self.Sidebar:Remove();
        self.Sidebar = sidebar;
    end;
end;

function PANEL:SetBackground( background )
    self.Background = Material( background );
end;

function PANEL:SetCloseFunction( func )
    self.CloseButton:SetOnClick( func );
end;

function PANEL:SetIcon( icon )
    self.Icon = Material( icon );
end;

function PANEL:SetTitle( title )
    self.Title = title;
end;

function PANEL:SetSubtitle( subtitle )
    self.Subtitle = subtitle;
end;

function PANEL:Paint( w, h )
    if( not self.Background ) then
        --Background
        surface.SetDrawColor( Color( 90, 90, 101 ) );
        surface.DrawRect( 0, 0, w, h );
    else
        surface.SetDrawColor( Color( 255, 255, 255 ) );
        surface.SetMaterial( self.Background );
        surface.DrawTexturedRect(
            0,
            0,
            w,
            h
        );
    end;

    --Title bar
    surface.SetDrawColor(
        Color( 0, 0, 0 )
    );
    surface.DrawRect(
        0,
        0,
        w,
        50
    );

    surface.SetDrawColor( Color( 255, 255, 255 ) );
    surface.SetMaterial( self.Icon );
    surface.DrawTexturedRect(
        4,
        4,
        40,
        40
    );

    --Title
    draw.SimpleText(
        self.Title,
        self.TitleFont,
        50,
        2,
        Color( 255, 255, 255 ),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_TOP
    );

    --Subtitle
    draw.SimpleText(
        self.Subtitle,
        self.SubtitleFont,
        50,
        44,
        Color( 255, 255, 255 ),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_BOTTOM
    );
end;
vgui.Register( "VCals_Menu", PANEL );