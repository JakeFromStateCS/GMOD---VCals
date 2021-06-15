/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/vgui/cl_vehiclepanel.lua
*/

local TOP_RIGHT = 1;
local BOTTOM_RIGHT = 2;
local TOP_LEFT = 3;
local BOTTOM_LEFT = 4;

local PANEL = {};

function PANEL:Init()
	self.BackgroundColor = Color( 220, 170, 66 );
	self.Text = "x";
	self.Corner = TOP_RIGHT;
	self.Verts = {};
	self:UpdateVerts();
end;

function PANEL:UpdateVerts()
	local w = self:GetWide();
	local h = self:GetTall();
	if( self.Corner == TOP_RIGHT ) then
		self.Verts = {
			{
				x = w / 2,
				y = h / 2
			},
			{
				x = w / 2,
				y = 0
			},
			{
				x = w,
				y = h / 2
			}
		};
	end;
end;

function PANEL:Paint( w, h )
	surface.SetDrawColor( self.BackgroundColor );
	surface.DrawPoly( self.Verts );

	/*draw.SimpleText(

	);*/
end;
vgui.Register( "VCals_CornerButton", PANEL );