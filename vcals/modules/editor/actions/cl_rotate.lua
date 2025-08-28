--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/modules/editor/actions/cl_rotate.lua
]]--

ACTION = ACTION or {};
ACTION.Name = "Rotate";
ACTION.Category = "Rotation";
ACTION.Icon = "/vcals/icons/Button_Symbol_Rotate_Free.png";
ACTION.Active = false;
ACTION.Default = false;
ACTION.SingleUse = false;
ACTION.Hooks = {};

--[[
    ACTION:Start():
        Stuff do do when you start the current action
]]--
function ACTION:Start()
    self.MouseX, self.MouseY = gui.MousePos();
    self.Angle = self:GetAngle();
    self.Active = true;
    print( self.Angle );
end;

--[[
    ACTION:End():
        Stuff to do when you end the current action
]]--
function ACTION:End()
    self.MouseX, self.MouseY = nil;
    self.Angle = nil;
    self.Active = false;
end;

--[[
    ACTION:Perform():
        Stuff to do while performing the current action
        ( Assuming that it needs to happen over a period of time or w/e )
]]--
function ACTION:Perform()
    local curX, curY = gui.MousePos();
    local prevX, prevY = self.MouseX, self.MouseY;
    if( curX ~= prevX or curY ~= prevY ) then
        local curAngle = self:GetAngle();
        local prevAngle = self.Angle;
        local diffAngle = prevAngle - curAngle;
        local panel = VCals.Editor.Panel;
        local pRotation = panel.Element.Rotation;

        panel:SetRotation( pRotation + diffAngle );

        self.MouseX, self.MouseY = curX, curY;
        self.Angle = curAngle;
    end;
end;

function ACTION:GetAngle()
    local panel = VCals.Editor.Panel;
    local parent = panel:GetParent();
    local panelX, panelY = panel:GetPos();
    local panelW, panelH = panel:GetSize();
    local centerX, centerY = panelX + panelW / 2, panelY + panelH / 2;
    local curX, curY = parent:ScreenToLocal( gui.MousePos() );

    local deltaX, deltaY = curX - centerX, curY - centerY;
    local angle = math.deg( math.atan2( deltaY, deltaX ) );
    return angle;
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