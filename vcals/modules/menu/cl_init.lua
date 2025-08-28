--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/modules/menu/cl_init.lua
]]--
MODULE = MODULE or {};
MODULE.Name = "Menu";
MODULE.Hooks = {};
MODULE.Nets = {};

MODULE.Primitives = {
    Tab1 = {
        "Circle",
        "CircleSemi",
        "CircleQuarter",
        "Octagon",
        "Square",
        "SquareRounded",
        "Trapezium",
        "Hexagon",
        "Triangle",
        "TriangleRounded",
        "ArrowHead",
        "Shield",
        "SquareConcave",
        "RectangleCurved",
        "CircleSemiPointed",
        "TriangleConcave",
        "Capsule",
        "CapsulePointed",
        "Flag02",
        "Flag01",
        "RectangleConcave",
        "TearDrop",
        "Crescent",
        "OvalPointed",
        "Heart01",
        "Star10Point",
        "Star5Point01",
        "Star5Point02"
    }
};

function MODULE:OnLoad()
    if( VCalsMenu ) then
        VCalsMenu:Remove();
    end;
    --Create the global html element for SVGs
    self:CreateHTML();
    VCals.Menu = self;
    concommand.Add(
        'vcals_menu',
        function()
            VCals.Modules.Stored.Menu:OpenMenu();
        end
    )
end;

--[[
    MODULE:CreateHTML():
        Creates the HTML panel to be updated for SVGs
]]--
function MODULE:CreateHTML()
    if( VCalsHTML ) then
        VCalsHTML:Remove();
    end;
    self.DHTML = vgui.Create( "DHTML" );
    self.DHTML:NoClipping( true );
    self.DHTML:SetScrollbars( false );

    --self.DHTML:SetPaintedManually( true );
    VCalsHTML = self.DHTML;
end;

--[[
    MODULE:UpdateHTML( String/svgSource ):
        Updates the html element to use the source provided
        Manually paints and updates the HTML texture on the panel
]]--
function MODULE:UpdateHTML( svgSource )
    local viewBox = string.Split( string.Split( string.Split( svgSource, 'viewBox="' )[2], '"' )[1], " " );
    --Scale it up
    local minX, minY, width, height = viewBox[1], viewBox[2], viewBox[3], viewBox[4];
    print( minX, minY, width, height );

    self.DHTML:Center();
    self.DHTML:SetHTML( svgSource );
    self.DHTML:SetSize( width * 2, height * 2 );
    self.DHTML:PaintManual();
    self.DHTML:UpdateHTMLTexture();

    print( "Updating HTML" );
end;

function MODULE:OpenMenu()
    if( VCalsMenu ) then
        VCalsMenu:Remove();
    end;
    local menu = vgui.Create( "VCals_Menu" );
    menu.Sidebar = vgui.Create( "VCals_Sidebar", menu );
    menu.ModelPanel = vgui.Create( "VCals_ModelPanel", menu );

    self.Menu = menu;
    VCalsMenu = menu;
end;

function MODULE:OpenDesigner()
    if( VCalsMenu ) then
        VCalsMenu:Remove();
    end;
    local menu = vgui.Create( "VCals_Menu" );
    --Set the title and subtitle
    menu:SetTitle( "DESIGNER" );
    menu:SetSubtitle( "NEW SYMBOL" );
    --Set the background
    menu:SetBackground( "/vcals/backgrounds/APB_Designer_Plain_Background.png", "smooth" );
    --Set the close function to open the main menu
    menu:SetCloseFunction( function( self )
        self:GetParent():Remove();
        --VCals.Menu:OpenMenu();
    end );
    --Set icon to paintbrush shit
    menu:SetIcon( "/vcals/replace.png" );
    --Create the icon sidebar
    menu.Sidebar = vgui.Create( "VCals_PrimitiveContainer", menu );
    menu.Sidebar:SetPrimitives( self.Primitives.Tab1 );

    --Add the layer container
    menu.LayerContainer = vgui.Create( "VCals_LayerContainer", menu );

    --Create the canvas
    menu.Canvas = vgui.Create( "VCals_Canvas", menu );

    menu.Toolbar = vgui.Create( "VCals_EditorToolbar", menu );

    menu.Toolbars = {};
    for category,_ in pairs( VCals.Editor.Categories ) do
        print( category );
        --And the toolbars
        menu.Toolbars[category] = vgui.Create( "VCals_ActionButtonContainer" );
        menu.Toolbars[category]:SetCategory( category );
        menu.Toolbar:AddCategory( menu.Toolbars[category] );
    end;

    --DO THIS LAST
    --Open the load symbol menu
    menu.SymbolMenu = vgui.Create( "VCals_LoadSymbolMenu", menu );
    --Temporarily fill it with nothing
    menu.SymbolMenu:SetSymbols( {} );


    self.Menu = menu;
    VCalsMenu = menu;
end;

--[[
    Hooks
]]--
function MODULE.Hooks:PostDrawTranslucentRenderables()

end;

--[[
    Net messages
]]--
function MODULE.Nets:OpenMenu()

end;