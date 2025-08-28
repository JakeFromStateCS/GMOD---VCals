--[[
    Mesh module
]]--

MODULE = MODULE or {};
MODULE.Name = "Mesh";
MODULE.Hooks = {};
MODULE.Nets = {};
MODULE.Ran = false;
MODULE.Debug = false;
MODULE.Stored = {};

--[[
    Hooks
]]--

local Stored = VCals.Mesh.Stored;
function MODULE.Hooks:PostDrawTranslucentRenderables()
    if( #VCals.Mesh.Stored > 0 ) then
        --if( !self.Ran and !self.Debug ) then
        --    self.Ran = true;
            --render.CullMode( MATERIAL_CULLMODE_CW );
            for meshID = 1, #VCals.Mesh.Stored do
                local decalMesh = VCals.Mesh.Stored[meshID];
                if( decalMesh ) then
                    decalMesh:Draw();
                end;
            end;
            --render.CullMode( MATERIAL_CULLMODE_CCW );
        --end;
    end;
end;

function MODULE.Hooks:HUDPaint()
    if( self.Debug ) then
        if( #VCals.Mesh.Stored > 0 ) then
            surface.SetDrawColor( Color( 255, 255, 255 ) );
            for meshID = 1, #VCals.Mesh.Stored do
                local decalMesh = VCals.Mesh.Stored[meshID];
                if( decalMesh ) then
                    local targetPos = decalMesh.TargetPos;
                    local targetEnt = decalMesh.TargetEntity;
                    if( targetEnt ) then
                        targetPos = targetEnt:LocalToWorld( targetPos );
                        local scrPos = targetPos:ToScreen();
                        surface.DrawRect(
                            scrPos.x - 4,
                            scrPos.y - 4,
                            8,
                            8
                        );
                    end;
                end;
            end;
        end;
    end;
end;