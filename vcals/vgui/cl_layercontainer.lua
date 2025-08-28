--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_layercontainer.lua
]]--

local PANEL = {};

function PANEL:Init()
    local parent = self:GetParent();
    self:SetSize( ScrW() / 6, ScrH() / 3 * 2 + 50 );
    self:SetPos( parent:GetWide() - self:GetWide() - 10, 114 );
    self.Title = "LAYERS";
    self.LayerCount = 0;
    self.MaxLayers = 25;
    self.ScrollPanel = vgui.Create( "DScrollPanel", self );
    self.ScrollPanel:SetSize( self:GetWide(), self:GetTall() - 96 );
    self.ScrollPanel:SetPos( 0, 36 );

    self.DeleteButton = vgui.Create( "VCals_Button", self );
    self.DeleteButton:SetIcon( "/vcals/icons/APB_Button_Delete_Colour.png" );
    self.DeleteButton:SetWide( self.DeleteButton:GetTall() );
    self.DeleteButton:SetPos( 0, self:GetTall() - 26 );
    self.DeleteButton.IconPos = {
        x = 0,
        y = 3
    };
    self.DeleteButton.IconSize = {
        w = self.DeleteButton:GetWide(),
        h = self.DeleteButton:GetTall()
    };
    self.DeleteButton.DarkColor = Color( 77, 23, 17 );
    self.DeleteButton.LightColor = Color( 187, 45, 25 );
    self.DeleteButton:OnMouseReleased();

    self.DuplicateButton = vgui.Create( "VCals_Button", self );
    self.DuplicateButton:SetText( "Duplicate" );
    self.DuplicateButton:SetWide( self:GetWide() - self.DeleteButton:GetTall() - 2 );
    self.DuplicateButton:SetPos( self.DeleteButton:GetWide(), self:GetTall() - 26 );
    for elementID, element in pairs( VCals.Editor.Decal.Elements ) do
        local elementPanel = self:AddElement( element );
        if( element.ID == VCals.Editor.Element.ID ) then
            elementPanel:SetSelected( true );
        end;
    end;
end;

function PANEL:AddElement( element )
    --Create an element panel
    local elementPanel = self.ScrollPanel:Add( "VCals_LayerPanel" );
    if( not self.ScrollCanvas ) then
        self.ScrollCanvas = self.ScrollPanel:GetCanvas();
    end;
    elementPanel:SetSize( self:GetWide(), 48 );
    elementPanel:Dock( TOP );
    elementPanel:DockMargin( 0, 0, 0, -1 );
    elementPanel:SetElement( element );
    elementPanel.Title = "Test";
    return elementPanel;
end;

function PANEL:SetTitle( title )
    self.Title = title;
end;
vgui.Register( "VCals_LayerContainer", PANEL, "VCals_Submenu" );