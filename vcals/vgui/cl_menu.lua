/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/vgui/cl_menu.lua
*/

surface.CreateFont(
	"VCals_MenuTitle",
	{
		font = "Verdana",
		size = ScreenScale( 10 ),
		weight = 600
	}
);

surface.CreateFont(
	"VCals_MenuSubtitle",
	{
		font = "Verdana",
		size = ScreenScale( 5.25 )
	}
);

local PANEL = {};

function PANEL:Init()
	self:SetSize( ScrW(), ScrH() );
	self:Center();
	self.Title = "GARAGE";
	self.TitleFont = "VCals_MenuTitle";
	self.Subtitle = "MANAGE YOUR VEHICLES";
	self.SubtitleFont = "VCals_MenuSubtitle";

	self.CloseButton = vgui.Create( "VCals_CloseButton", self );
	self.CloseButton:SetPos( self:GetWide() - self.CloseButton:GetWide() - 2, 2 );
	self.Icon = Material( "vcals/icons/icon_title_garage.png" );
	
	gui.EnableScreenClicker( true );
end;

function PANEL:SetSidebar( sidebar )
	if( self.Sidebar ) then
		self.Sidebar:Remove();
		self.Sidebar = sidebar;
	end;
end;

function PANEL:SetBackground( background )
	self.Background = Material( background );
end;

function PANEL:SetCloseFunction( func )
	self.CloseButton:SetOnClick( func );
end;

function PANEL:SetIcon( icon )
	self.Icon = Material( icon );
end;

function PANEL:SetTitle( title )
	self.Title = title;
end;

function PANEL:SetSubtitle( subtitle )
	self.Subtitle = subtitle;
end;

function PANEL:Paint( w, h )
	if( !self.Background ) then
		--Background
		surface.SetDrawColor( Color( 90, 90, 101 ) );
		surface.DrawRect( 0, 0, w, h );
	else
		surface.SetDrawColor( Color( 255, 255, 255 ) );
		surface.SetMaterial( self.Background );
		surface.DrawTexturedRect(
			0,
			0,
			w,
			h
		);
	end;

	--Title bar
	surface.SetDrawColor(
		Color( 0, 0, 0 )
	);
	surface.DrawRect(
		0,
		0,
		w,
		50
	);

	surface.SetDrawColor( Color( 255, 255, 255 ) );
	surface.SetMaterial( self.Icon );
	surface.DrawTexturedRect(
		4,
		4,
		40,
		40
	);
	
	--Title
	draw.SimpleText(
		self.Title,
		self.TitleFont,
		50,
		2,
		Color( 255, 255, 255 ),
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_TOP
	);
	
	--Subtitle
	draw.SimpleText(
		self.Subtitle,
		self.SubtitleFont,
		50,
		44,
		Color( 255, 255, 255 ),
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_BOTTOM
	);
end;

function PANEL:OpenDesigner()
	--Create the icon sidebar
	self.Sidebar = vgui.Create( "VCals_PrimitiveContainer", self );
	self.Sidebar:SetPrimitives( VCals.Menu.Primitives.Tab1 );

	--Add the layer container
	self.LayerContainer = vgui.Create( "VCals_LayerContainer", self );
	
	--Create the canvas
	self.Canvas = vgui.Create( "VCals_Canvas", self );

	self.Toolbar = vgui.Create( "VCals_EditorToolbar", self );

	self.Toolbars = {};
	for category,_ in pairs( VCals.Editor.Categories ) do
		print( category );
		--And the toolbars
		self.Toolbars[category] = vgui.Create( "VCals_ActionButtonContainer" );
		self.Toolbars[category]:SetCategory( category );
		self.Toolbar:AddCategory( self.Toolbars[category] );
	end;
end;
vgui.Register( "VCals_Menu", PANEL );