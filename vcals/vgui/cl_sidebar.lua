--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_sidebar.lua
]]--

local PANEL = {};

function PANEL:Init()
    self:SetSize( ScrW() / 6, ScrH() / 3 * 2 + 50 );
    self:SetPos( 10, 60 );
    self.Title = "YOUR VEHICLES";
    self.VehicleCount = 0;
    self.MaxVehicles = 12;
    self.ScrollPanel = vgui.Create( "DScrollPanel", self );
    self.ScrollPanel:SetSize( self:GetWide(), self:GetTall() - 96 );
    self.ScrollPanel:SetPos( 0, 36 );
    for i = 1, 10 do
        self:AddVehicle();
    end;

    self.DetailsButton = vgui.Create( "VCals_Button", self );
    self.DetailsButton:SetText( "Show Details" );
    self.DetailsButton:SetWide( self:GetWide() );
    self.DetailsButton:SetPos( 0, self:GetTall() - 60 );

    self.CustomizeButton = vgui.Create( "VCals_Button", self );
    self.CustomizeButton:SetText( "Customize" );
    self.CustomizeButton:SetWide( self:GetWide() );
    self.CustomizeButton:SetPos( 0, self:GetTall() - 26 );
    self.CustomizeButton:SetIcon( "/vcals/icons/25pxCog.png" );
end;

function PANEL:AddVehicle( vehicle )
    --Create a vehicle panel and add it to the scrollpanel
    local vehiclePanel = self.ScrollPanel:Add( "VCals_VehiclePanel" );
    if( not self.ScrollCanvas ) then
        self.ScrollCanvas = self.ScrollPanel:GetCanvas();
    end;
    vehiclePanel:Dock( TOP );
    vehiclePanel:DockMargin( 0, 0, 0, 5 );
    vehiclePanel:SetModel( "models/tdmcars/bmw_1m.mdl" );
    self.Subtitle = #self.ScrollCanvas:GetChildren() .. " / " .. self.MaxVehicles;
end;
vgui.Register( "VCals_Sidebar", PANEL, "VCals_Submenu" );