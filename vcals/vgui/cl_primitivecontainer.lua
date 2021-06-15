/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/vgui/cl_primitivecontainer.lua
*/

--[[
	Annoying ass list of primitives
]]--

local PANEL = {};

function PANEL:Init()
	self:SetSize( ScrW() / 6, ScrH() / 1.5 );
	self:SetPos(
		20,
		114
	);
	--local gridItemSize = 
	self.SidePadding = 16;
	--Define the grid to contain primitives
	self.PrimitiveContainer = vgui.Create( "DGrid", self );
	self.PrimitiveContainer:SetSize( self:GetWide() - self.SidePadding * 2, self:GetTall() - 75 );
	self.PrimitiveContainer:SetPos( self.SidePadding, 50 );
	
	self.PrimitiveContainer:SetCols( 4 );
	local cols = self.PrimitiveContainer:GetCols();
	self.GridItemSize = self.PrimitiveContainer:GetWide() / cols + 2;
	self.PrimitiveContainer:SetColWide( self.GridItemSize );
	self.PrimitiveContainer:SetRowHeight( self.GridItemSize );
end;

function PANEL:SetPrimitives( primitives )
	local dir = "/vcals/primitives/";
	for primID = 1, #primitives do
		local primName = primitives[primID];
		local button = vgui.Create( "VCals_SymbolButton" );
		button:SetSize( self.GridItemSize - 6, self.GridItemSize - 6 );
		button.Material = Material( dir .. primName .. ".png", "smooth" );
		self.PrimitiveContainer:AddItem( button );
	end;
end;

function PANEL:Paint( w, h )
	--Background
	surface.SetDrawColor( Color( 20, 20, 20, 200 ) );
	surface.DrawRect(
		0,
		0,
		w,
		h
	);
end;
vgui.Register( "VCals_PrimitiveContainer", PANEL );