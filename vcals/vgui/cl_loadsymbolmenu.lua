/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/vgui/cl_loadsymbolmenu.lua
*/

--Title font
surface.CreateFont(
	"VCals_LoadSymbolTitle",
	{
		font = "Arial",
		size = ScreenScale( 11 ),
		weight = 600
	}
);

--Subtitle font
surface.CreateFont(
	"VCals_LoadSymbolSubtitle",
	{
		font = "Arial",
		size = ScreenScale( 5.8 ),
		weight = 400
	}
);

local PANEL = {};

function PANEL:Init()
	self:SetSize( ScrW() / 4, ScrH() / 2 );
	self:Center();

	self.Title = "LOAD SYMBOL";
	self.TitleFont = "VCals_LoadSymbolTitle";
	self.SubtitleFont = "VCals_LoadSymbolSubtitle";
	self.SymbolCount = 0;
	self.MaxSymbols = 45;
	
	--Height of the header
	self.HeaderHeight = 48;
	self.FooterHeight = 38;
	self.Icon = Material( "/vcals/icons/icon_title_symbol_load.png", "smooth" );
	self.IconPadding = 10;
	self.IconSize = self.HeaderHeight - self.IconPadding;

	self.CloseButton = vgui.Create( "VCals_CloseButton", self );
	self.CloseButton:SetPos(
		self:GetWide() - self.CloseButton:GetWide() - 1,
		1
	);
	--ToDo: Create these
	self.SymbolContainer = vgui.Create( "DGrid", self );
	self.SymbolContainer:SetCols( 6 );
	self.SymbolContainer:SetColWide( self:GetWide() / 6 - 10/6 );
	self.SymbolContainer:SetRowHeight( self:GetWide() / 6 - 10/6 );
	self.SymbolContainer:SetPos( 10, self.HeaderHeight + 16 );
	self.SymbolContainer:SetSize(
		self:GetWide(),
		self:GetTall() - self.HeaderHeight - self.FooterHeight - 26
	);
	self.CancelButton = nil;
	self.PageWidget = nil;
	
	self.BlurAmount = 1;
end;

function PANEL:SetSymbols( symbols )
	for symbolID = 1, #symbols do
		local symbol = symbols[symbolID];
		self:AddSymbolButton( symbol );
	end;
	--self.SymbolContainer:AddItem(
	self:AddNewSymbolButton();
end;

function PANEL:AddSymbolButton( symbol )
	local button = vgui.Create( "VCals_SymbolButton" );
	button:SetSize(
		self:GetWide() / 6 - 10,
		self:GetWide() / 6 - 10
	);
	button:SetDecal( symbol );
	self.SymbolContainer:AddItem( button );
end;

function PANEL:AddNewSymbolButton()
	local button = vgui.Create( "VCals_SymbolButton" );
	button:SetSize(
		self:GetWide() / 6 - 10,
		self:GetWide() / 6 - 10
	);
	button.Material = Material( "/vcals/icons/new_symbol.png", "smooth" );
	button:SetTooltip( "New Symbol" );
	self.SymbolContainer:AddItem( button );
end;

function PANEL:Paint( w, h )
	--Yeah I'm lazy, fuck it
	for i = 1, self.BlurAmount do
		Derma_DrawBackgroundBlur( self, CurTime() );
	end;
	
	--Black background
	surface.SetDrawColor( Color( 0, 0, 0 ) );
	surface.DrawRect(
		0,
		0,
		w,
		h
	);
	
	--Header divider
	surface.SetDrawColor( Color( 50, 50, 50 ) );
	surface.DrawRect(
		0,
		self.HeaderHeight,
		w,
		6
	);
	
	--Footer
	surface.DrawRect(
		0,
		h - self.FooterHeight,
		w,
		self.FooterHeight
	);

	--Icon
	surface.SetDrawColor( Color( 255, 255, 255 ) );
	surface.SetMaterial( self.Icon );
	surface.DrawTexturedRect(
		self.IconPadding / 2,
		self.IconPadding / 2,
		self.IconSize,
		self.IconSize
	);
	
	--Title
	draw.SimpleText(
		self.Title,
		self.TitleFont,
		self.IconSize + self.IconPadding,
		2,
		Color( 255, 255, 255 )
	);
	
	--Subtitle
	draw.SimpleText(
		self.SymbolCount .. "/" .. self.MaxSymbols,
		self.SubtitleFont,
		self.IconSize + self.IconPadding,
		self.HeaderHeight - 2,
		Color( 255, 255, 255 ),
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_BOTTOM
	);
end;
vgui.Register( "VCals_LoadSymbolMenu", PANEL );