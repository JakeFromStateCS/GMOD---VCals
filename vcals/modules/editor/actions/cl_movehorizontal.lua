/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/modules/editor/actions/cl_movevertical.lua
*/

ACTION = ACTION or {};
ACTION.Name = "Move Horizontal";
ACTION.Category = "Movement";
ACTION.Icon = "/vcals/icons/Button_Symbol_Move_Horizontal.png";
ACTION.Active = false;
ACTION.Default = true;
ACTION.SingleUse = false;
ACTION.Hooks = {};

--[[
	ACTION:Start():
		Stuff do do when you start the current action
]]--
function ACTION:Start()
	self.MouseX, self.MouseY = gui.MousePos();
	self.Active = true;
end;

--[[
	ACTION:End():
		Stuff to do when you end the current action
]]--
function ACTION:End()
	self.MouseX, self.MouseY = nil;
	self.Active = false;
end;

--[[
	ACTION:Perform():
		Stuff to do while performing the current action
		( Assuming that it needs to happen over a period of time or w/e )
]]--
function ACTION:Perform()
	local panel = VCals.Editor.Panel;
	local xPos, yPos = panel:GetPos();
	local mouseX, mouseY = gui.MousePos();
	local diffX, diffY = self.MouseX - mouseX, self.MouseY - mouseY;
	panel:SetPos( xPos - diffX, yPos );
	self.MouseX = mouseX;
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