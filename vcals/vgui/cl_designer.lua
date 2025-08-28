--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/menus/cl_designer.lua
]] --

local PANEL = {};

function PANEL:Init()
    self:SetSize(ScrW(), ScrH());
    self:Center();
    self.Title = "DESIGNER";
    self.TitleFont = "VCals_MenuTitle";
    self.Subtitle = "NEW SYMBOL";
    self.SubtitleFont = "VCals_MenuSubtitle";
    self:SetBackground("vcals/backgrounds/APB_Designer_Plain_Background.png", "smooth")
    self.CloseButton = vgui.Create("VCals_CloseButton", self);
    self.CloseButton:SetPos(self:GetWide() - self.CloseButton:GetWide() - 2, 2);
    self:SetIcon("vcals/icons/APB_Icon_Designer.png");
    self:SetCloseFunction(function(self)
        self:GetParent():Remove();
        --VCals.Menu:OpenMenu();
    end)


    --DO THIS LAST
    --Open the load symbol menu
    self.SymbolMenu = vgui.Create("VCals_LoadSymbolMenu", self);
    --Temporarily fill it with nothing
    self.SymbolMenu:SetSymbols({});

    gui.EnableScreenClicker(true);
end;

vgui.Register("VCals_Designer", PANEL, 'VCals_Menu');
