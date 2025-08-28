--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/modules/menu/cl_init.lua
]] --
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
    if (VCalsMenu and VCalsMenu ~= nil) then
        VCalsMenu:Remove();
        VCalsMenu = nil;
    end;
    --Create the global html element for SVGs
    self:CreateHTML();
    VCals.Menu = self;
    concommand.Add("vcals_menu", function(client, cmd, args)
        self:OpenMenu();
    end);
    concommand.Add("vcals_designer", function(client, cmd, args)
        self:OpenDesigner();
    end);
end;

--[[
	MODULE:CreateHTML():
		Creates the HTML panel to be updated for SVGs
]]--
function MODULE:CreateHTML()
    if (VCalsHTML) then
        VCalsHTML:Remove();
    end;
    self.DHTML = vgui.Create("DHTML");
    self.DHTML:NoClipping(true);
    self.DHTML:SetScrollbars(false);

    --self.DHTML:SetPaintedManually( true );
    VCalsHTML = self.DHTML;
end;

--[[
	MODULE:UpdateHTML( String/svgSource ):
		Updates the html element to use the source provided
		Manually paints and updates the HTML texture on the panel
]]--
function MODULE:UpdateHTML(svgSource)
    local viewBox = string.Split(string.Split(string.Split(svgSource, 'viewBox="')[2], '"')[1], " ");
    --Scale it up
    local minX, minY, width, height = viewBox[1], viewBox[2], viewBox[3], viewBox[4];
    print(minX, minY, width, height);

    self.DHTML:Center();
    self.DHTML:SetHTML(svgSource);
    self.DHTML:SetSize(width * 2, height * 2);
    self.DHTML:PaintManual();
    self.DHTML:UpdateHTMLTexture();

    print("Updating HTML");
end;

function MODULE:OpenMenu()
    if (VCalsMenu and VCalsMenu ~= nil) then
        VCalsMenu:Remove();
        VCalsMenu = nil;
    end;
    local menu = vgui.Create("VCals_Menu");
    menu.Sidebar = vgui.Create("VCals_Sidebar", menu);
    menu.ModelPanel = vgui.Create("VCals_ModelPanel", menu);

    self.Menu = menu;
    VCalsMenu = menu;
end;

function MODULE:OpenDesigner()
    if (VCalsMenu and VCalsMenu ~= nil) then
        VCalsMenu:Remove();
        VCalsMenu = nil;
    end;

    self.Menu = vgui.Create("VCals_Designer");
    VCalsMenu = self.Menu;
end;

--[[
    Hooks
]] --
function MODULE.Hooks:PostDrawTranslucentRenderables()

end;

--[[
    Net messages
]] --
function MODULE.Nets:OpenMenu()

end;
