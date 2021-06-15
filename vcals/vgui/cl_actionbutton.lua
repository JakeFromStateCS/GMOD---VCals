/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/vgui/cl_actionbutton.lua
*/

local PANEL = {};

function PANEL:Init()
	self.Icon = Material( "/vcals/replace.png" );
	self.Selected = false;
	self.Black = Color( 0, 0, 0 );
	self.Yellow = Color( 240, 150, 66 );
	self.Gray = Color( 20, 20, 20, 200 );
	self.White = Color( 255, 255, 255 );
	self.OutlineColor = self.White;
	self.BackgroundColor = self.Gray;
	self.Padding = 4;
	self.Action = "";
	self:SetSize( 36, 36 );
end;

function PANEL:SetSelected( bool )
	self.Selected = bool;
	if( bool ) then
		self.OutlineColor = self.Yellow;
		self.BackgroundColor = self.Black;
	else
		self.OutlineColor = self.White;
		self.BackgroundColor = self.Gray;
	end;
end;

function PANEL:SetAction( action )
	local ACTION = VCals.Editor.Actions[action];
	if( ACTION ) then
		self.Action = action;
		self.Icon = Material( ACTION.Icon );
		ACTION.Panel = self;
	end;
end;

function PANEL:OnMousePressed()
	VCals.Editor:SetAction( self.Action );
	self:SetSelected( true );
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
	
	surface.SetMaterial( self.Icon );
	surface.DrawTexturedRect(
		self.Padding / 2,
		self.Padding / 2,
		w - self.Padding,
		h - self.Padding
	);
end;
vgui.Register( "VCals_ActionButton", PANEL );