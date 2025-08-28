--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/modules/editor/sv_init.lua
]]--
MODULE = MODULE or {};
MODULE.Name = "Editor";
MODULE.Hooks = {};
MODULE.Nets = {};
MODULE.Actions = {};
MODULE.ActionHooks = {};
MODULE.Categories = {};


function MODULE:RegisterHooks( ACTION )
    if( ACTION.Hooks ) then
        for hookType,hookFunc in pairs( ACTION.Hooks ) do
            if( not self.ActionHooks[hookType] ) then
                self.ActionHooks[hookType] = {};
            end;
            if( not self.Hooks[hookType] ) then
                self.Hooks[hookType] = function( self, ... )
                    local retVal;
                    for ACTION,hookFunc in pairs( self.ActionHooks[hookType] ) do
                        retVal = hookFunc( ACTION, ... );
                    end;
                    if( retVal ) then
                        return retVal;
                    end;
                end;
            end;
            self.ActionHooks[hookType][ACTION] = hookFunc;
        end;
    end;
end;

function MODULE:RegisterAction( ACTION )
    self:RegisterHooks( ACTION );
    if( ACTION.Default ) then
        self.Action = ACTION.Name;
    end;
    self.Actions[ACTION.Name] = ACTION;
    if( not self.Categories[ACTION.Category] ) then
        self.Categories[ACTION.Category] = {};
    end;
    table.insert( self.Categories[ACTION.Category], ACTION.Name );
end;

function MODULE:LoadActions()
    local dirPath = self.Directory .. "/actions/";
    local files = file.Find( dirPath .. "*.lua", "LUA" );
    for _,file in pairs( files ) do
        local filePath = dirPath .. file;
        ACTION = {};
            VCals:LoadFile( filePath );
            self:RegisterAction( ACTION );
        ACTION = nil;
    end;
end;

function MODULE:PreLoad()
    self:LoadActions();
end;

--[[
    OnLoad():
        Loads the actions for the editor
        Creates a global VCals var for itself
]]--
function MODULE:OnLoad()
    VCals.Editor = self;
end;
