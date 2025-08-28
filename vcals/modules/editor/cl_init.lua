--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/modules/editor/cl_init.lua
]]--
MODULE = MODULE or {};
MODULE.Name = "Editor";
MODULE.Hooks = {};
MODULE.Nets = {};
MODULE.Actions = {};
MODULE.ActionHooks = {};
MODULE.Categories = {};


--[[
    MODULE:SetDecal( Decal/decal ):
        Sets the decal to be edited
]]--
function MODULE:SetDecal( decal )
    self.Decal = decal;
end;

--[[
    MODULE:SetElement( Element/element ):
        Sets the focused element on which to perform actions
]]--
function MODULE:SetElement( element )
    if( self.Element ) then
        if( self.Element.LayerPanel:IsValid() ) then
            self.Element.LayerPanel:SetSelected( false );
        end;
    end;
    if( element.LayerPanel:IsValid() ) then
        element.LayerPanel:SetSelected( true );
    end;
    self.Element = element;
end;

--[[
    MODULE:SetPanel( VCals_ElementPanel/panel ):
        The panel representing the currently focused element
]]--
function MODULE:SetPanel( panel )
    self.Panel = panel;
end;

function MODULE:SetAction( actionName )
    if( self.Action ) then
        local ACTION = self.Actions[self.Action];
        if( ACTION ) then
            ACTION:End();
            if( ACTION.Panel ) then
                ACTION.Panel:SetSelected( false );
            end;
        end;
    end;
    local ACTION = self.Actions[actionName];
    if( ACTION ) then
        self.Action = actionName;
    end;
end;

function MODULE:StartAction()
    print( "Starting action:", self.Action );
    if( self.Action ) then
        local ACTION = self.Actions[self.Action];
        if( ACTION ) then
            ACTION:Start();
        end;
    end;
end;

function MODULE:EndAction()
    print( "Ending action:", self.Action );
    if( self.Action ) then
        local ACTION = self.Actions[self.Action];
        if( ACTION ) then
            ACTION:End();
        end;
    end;
end;

--[[
    MODULE:GetElementByID( Int/elementID ):
        Returns an element based on its ID
]]--
function MODULE:GetElementByID( elementID )
    if( self.Decal ) then
        return self.Decal.Elements[elementID];
    end;
end;

--[[
    MODULE:MoveElementDown( Element/element ):
        Moves an element down in the stack
]]--
function MODULE:MoveElementDown( element )
    local elementID = element.ID;
    if( elementID > 1 ) then
        local newID = elementID - 1;
        table.remove( self.Decal.Elements, elementID );
        table.insert( self.Decal.Elements, newID, element );
        element.ID = newID;
    end;
end;

--[[
    MODULE:MoveElementUp( Element/element ):
        Moves an element up in the stack
]]--
function MODULE:MoveElementUp( element )
    local elementID = element.ID;
    if( elementID < #self.Decal.Elements ) then
        local newID = elementID + 1;
        table.remove( self.Decal.Elements, elementID );
        table.insert( self.Decal.Elements, newID, element );
        element.ID = newID;
    end;
end;

--[[
    Legacy Code

--Start/Stop Actions
function MODULE:StartAction( action )
    if( self.Funcs[action] ) then
        --Store the initial mouse position for the action
        self.MouseX, self.MouseY = gui.MousePos();
        self.Action = action;
    end;
end;

function MODULE:StopAction( action )
    self.Action = nil;
end;

function MODULE.Funcs:Move()
    local panel = self.Panel;
    local xPos, yPos = panel:GetPos();
    local mouseX, mouseY = gui.MousePos();
    local diffX, diffY = self.MouseX - mouseX, self.MouseY - mouseY;
    panel:SetPos( xPos - diffX, yPos - diffY );
    self.MouseX = mouseX;
    self.MouseY = mouseY;
end;
]]--