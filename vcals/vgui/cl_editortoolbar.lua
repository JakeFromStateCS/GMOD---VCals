local PANEL = {};

function PANEL:Init()
	self:SetSize( ScrH() / 3 * 2 + 50, 44 );
	self.DGrid = vgui.Create( "DGrid", self );
	self.DGrid:Dock( TOP );
	self.DGrid:DockMargin( 0, 0, 0, 0 );
	self.DGrid:SetColWide( 200 );
	self.DGrid:SetRowHeight( 44 );
	self:Center();
	local x, y = self:GetPos();
	self:SetPos( x, 60 );
end;

function PANEL:AddCategory( panel )
	self.DGrid:AddItem( panel );
end;

function PANEL:Paint( w, h )
	surface.SetDrawColor( Color( 255, 255, 255 ) );
	surface.DrawRect( 0, 0, w, h );
end;

vgui.Register( "VCals_EditorToolbar", PANEL );