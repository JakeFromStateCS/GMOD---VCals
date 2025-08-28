--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/modules/editor/actions/cl_scale.lua
]]--

ACTION = ACTION or {};
ACTION.Name = "Scale";
ACTION.Category = "Scale";
ACTION.Icon = "/vcals/icons/Button_Symbol_Scale_Free.png";
ACTION.Active = false;
ACTION.Default = false;
ACTION.SingleUse = false;
ACTION.Hooks = {};

--[[
    ACTION:Start():
        Stuff do do when you start the current action
]]--
function ACTION:Start()
    local panel = VCals.Editor.Panel;
    local parent = panel:GetParent();
    local panelX, panelY = parent:LocalToScreen( panel:GetPos() );
    local mouseX, mouseY = gui.MousePos();
    self.DistX, self.DistY = panelX - mouseX, panelY - mouseY;
    self.Active = true;
end;

--[[
    ACTION:End():
        Stuff to do when you end the current action
]]--
function ACTION:End()
    self.DistX, self.DistY = nil;
    self.Active = false;
end;

--[[
    ACTION:Perform():
        Stuff to do while performing the current action
        ( Assuming that it needs to happen over a period of time or w/e )
]]--
function ACTION:Perform()
    local panel = VCals.Editor.Panel;
    local parent = panel:GetParent();
    local panelX, panelY = parent:LocalToScreen( panel:GetPos() );
    local pWidth, pHeight = panel:GetSize();
    local mouseX, mouseY = gui.MousePos();
    local distX, distY = panelX - mouseX, panelY - mouseY;
    local diffX, diffY = self.DistX - distX, self.DistY - distY;
    panel:SetSize(
        math.Clamp( pWidth + diffX, 1, 999 ),
        math.Clamp( pHeight + diffY, 1, 999 )
    );
    self.DistX = distX;
    self.DistY = distY;
end;


--[[
    Hooks
]]--

--[[
    ACTION.Hooks:Think():
        Just do the action
]]--
function ACTION.Hooks:Think()
    if( self.Active ) then
        self:Perform();
    end;
end;