--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_vehiclepanel.lua
]]--

surface.CreateFont(
    "VCals_VehiclePanelText",
    {
        font = "Tahoma",
        size = ScreenScale( 6 ),
        weight = 600
    }
);

local PANEL = {};

function PANEL:Init()
    self:SetTall( 70 );
    self.Font = "VCals_VehiclePanelText";
    self.Title = "Macchina Calabria 127";
    self.Nickname = "Macchina Calabria 127";


    self.BackgroundColor = Color( 0, 0, 0 );
    self.Yellow = Color( 240, 170, 66 );
    self.Blue = Color( 20, 56, 75 );

    --Blue rect width
    self.RectWidth = 43;
    --Need to create custom b/w spawn icon
    self.Icon = vgui.Create( "VCals_VehicleIcon", self );
    self.MouseOver = false;
end;

function PANEL:SetModel( model )
    self.Icon:SetModel( model );
    self.Icon:UpdateView();
end;

function PANEL:SetTitle( title )
    self.Title = title;
end;

function PANEL:SetNickname( nickname )
    self.Nickname = nickname;
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

    --Blue rect
    surface.SetDrawColor( self.Blue );
    surface.DrawRect(
        w - self.RectWidth,
        0,
        self.RectWidth,
        h
    );

    --Outline
    surface.SetDrawColor( self.Yellow );
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

    draw.SimpleText(
        self.Title,
        self.Font,
        self.Icon:GetWide(),
        4,
        self.Yellow
    );

    draw.SimpleText(
        self.Nickname,
        self.Font,
        self.Icon:GetWide(),
        4 + ScreenScale( 6 ),
        self.Yellow
    );

end;
vgui.Register( "VCals_VehiclePanel", PANEL );