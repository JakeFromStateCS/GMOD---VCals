/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/vgui/cl_closebutton.lua
*/

surface.CreateFont(
	"VCals_CloseButton",
	{
		font = "Arial",
		size = ScreenScale( 12 ),
		weight = 600
	}
);

local PANEL = {};
function PANEL:Init()
	self:SetSize( 46, 46 );
end;

function PANEL:SetOnClick( func )
	self.OnClick = func;
end;

function PANEL:OnMousePressed()
	if( !self.OnClick ) then
		self:GetParent():Remove();
	else
		self:OnClick();
	end;
end;

function PANEL:Paint( w, h )
	--Top half
	surface.SetDrawColor( Color( 255, 0, 0 ) );
	surface.DrawRect( 0, 0, w, h / 2 );
	--Bottom half
	surface.SetDrawColor( Color( 200, 0, 0 ) );
	surface.DrawRect( 0, h / 2, w, h / 2 );

	draw.SimpleText(
		"X",
		"VCals_CloseButton",
		w / 2,
		h / 2,
		Color( 255, 255, 255 ),
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER
	);
end;
vgui.Register( "VCals_CloseButton", PANEL );