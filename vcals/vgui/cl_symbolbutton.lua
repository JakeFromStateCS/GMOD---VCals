/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/vgui/cl_symbolbutton.lua
*/

local PANEL = {};

function PANEL:Init()

end;

function PANEL:SetDecal( decal )
	self.Material = decal:GetMaterial();
	self:SetTooltip( decal.Name );
end;

function PANEL:Paint( w, h )
	if( self.Material ) then
		surface.SetDrawColor( Color( 255, 255, 255 ) );
		surface.SetMaterial( self.Material );
		surface.DrawTexturedRect(
			0,
			0,
			w,
			h
		);
	end;
end;
vgui.Register( "VCals_SymbolButton", PANEL );