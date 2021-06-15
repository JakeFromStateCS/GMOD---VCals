/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/vgui/cl_actionbuttoncontainer.lua
*/

local PANEL = {};

function PANEL:Init()
	self:SetSize( 10, 44 );
	self.DGrid = vgui.Create( "DGrid", self );
	self.DGrid:Dock( TOP );
	self.DGrid:DockMargin( 4, 4, 4, 4 );
	self.DGrid:SetColWide( 40 );
	self.DGrid:SetRowHeight( 36 );
end;

function PANEL:SetCategory( category )
	local actions = VCals.Editor.Categories[category];
	if( actions ) then
		local count = #actions;
		self.DGrid:SetCols( count );
		self:SetWide( count * 36 + ( ( count + 1 ) * 4 ) )
		for actionID = 1, count do
			local action = actions[actionID];
			local panel = vgui.Create( "VCals_ActionButton" );
			panel:SetSize( 36, 36 );
			panel:SetAction( action );
			self.DGrid:AddItem( panel );
		end;
	end;
	self:Center();
	local x, y = self:GetPos();
	self:SetPos( x, 60 );
end;

function PANEL:Paint( w, h )
	surface.SetDrawColor( Color( 20, 20, 20, 200 ) );
	surface.DrawRect( 0, 0, w, h );
end;
vgui.Register( "VCals_ActionButtonContainer", PANEL );