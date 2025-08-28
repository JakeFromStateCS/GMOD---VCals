local PANEL = {};

function PANEL:Init()
    self.Icon = Material( "" );
    self.Color = Color( 255, 255, 255 );
end;

function PANEL:SetIcon( icon )
    self.Icon = Material( icon );
end;

function PANEL:SetColor( color )
    self.Color = color;
end;

function PANEL:Paint( w, h )
    surface.SetDrawColor( self.Color );
    surface.SetMaterial( self.Icon );
    surface.DrawTexturedRect(
        0,
        0,
        w,
        h
    );
end;
vgui.Register( "VCals_IconPanel", PANEL );