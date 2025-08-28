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

--[[
    OnLoad():
        Loads the actions for the editor
        Creates a global VCals var for itself
]]--
function MODULE:OnLoad()
    self:LoadActions();
    VCals.Editor = self;
end;

function MODULE:LoadActions()
    local dirPath = self.Directory .. "/actions/";
    local files, folders = file.Find( dirPath .. "*.lua", "LUA" );
    for _,file in pairs( files ) do
        local filePath = dirPath .. file;
        VCals:LoadFile( filePath );
    end;
end;