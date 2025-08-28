--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/lib/mesh/cl_modelmesh.lua

    TODO: @matthewa The gist of the idea is: We will create a model mesh
        Using a particular model. Then we will call something like DecalMesh:ProjectToMesh
        Passing in the ModelMesh
        This will then do all of the work in cl_test.lua
        Then the idea is that we draw that on the entity in the model panel
        But one other thing we need to figure out is how/whether we want to allow
        Projecting onto things like the wheels, headlights, bumper, or windows
        Since those are technically separate models..They all get combined in the
        Entity though. So that could be a challenge since we're running the trace
        Against one single mesh (The main body right now)
        We would have to figure out how to combine all of those into a singular mesh
        For projecting our decal mesh onto..
]]--

ModelMesh = {};
ModelMesh.Meta = {};
ModelMesh.Proto = {}


--[[
    ModelMesh prototype methods
]]--
function ModelMesh.Proto:SetVisualModels(visualModels)
    local visualModel = visualModels[1];
    -- TODO: @matthewa We might not need to store this whole thing tbh
    --  Because we really only need the triangles and material which we
    --  Extract from it
    self.VisualModel = visualModel;
    self.Triangles = visualModel.triangles;
    self.Material = Material(visualModel.material);
end;

function ModelMesh.Proto:GetVisualMesh()
    return self.VisualMesh;
end;

function ModelMesh.Proto:BuildMesh()
    self.GmodMesh = new Mesh(self.Material);
    self.GmodMesh:BuildFromTriangles(self.Triangles);
end;

function ModelMesh.Proto:GetMesh()
    return self.GmodMesh;
end;

-- TODO @matthewa remove this method probably
function ModelMesh.Proto:SetTargetEntity( entity )
    if( entity.DecalTable == nil ) then
        entity.DecalTable = {};
    end;
    self.TargetEntity = entity;
    table.insert( entity.DecalTable, self );
end;

-- TODO: @matthewa This will probably be SetPos
function ModelMesh.Proto:SetTargetPos( targetPos )
    self.TargetPos = targetPos;
end;

-- TODO: @matthewa This will probably be SetAngles
function ModelMesh.Proto:SetTargetAng( targetAng )
    self.TargetAng = targetAng;
end;

-- TODO: @matthewa Remove this method probably?
function ModelMesh.Proto:Draw( ent )
    local material = self.Material;
    local mesh = self.Mesh;
    local entity = ( ent or self.TargetEntity );
    if( entity == nil or not entity:IsValid() ) then
        self:Remove();
        return;
    end;

    local pos = entity:GetPos();
    local ang = entity:GetAngles();
    --Create a matrix to modify the pos, scale, and angles of upcoming render functions
    local posMatrix = Matrix();

    --ent is used when we're drawing onto a DModelPanel
    --So we can draw relative to the DModelPanel's ent instead of the in-world one
    --The entity for the dmodel panel is at 0,0,0 so if it exists, we don't need to move the mesh matrix
    --Otherwise, we need to update the position
    if( not ent ) then
        posMatrix:Translate( pos );
    end;
    posMatrix:SetAngles( ang );

    --Set the material of the next render to our decal material
    render.SetMaterial( material );

    --Suppress the engine lighting so it doesn't fuck shit up
    render.SuppressEngineLighting( true );
    render.SetLightingOrigin( pos );
    render.ResetModelLighting( 1, 1, 1 );
    render.SetColorModulation( 1, 1, 1 );
    render.SetBlend( 1 );
    for i = 0, 6 do
        render.SetModelLighting( i, 1, 1, 1 );
    end

    --Update the render matrix
    cam.PushModelMatrix( posMatrix );
        --Draw our mesh
        mesh:Draw();
    --Go back to the normal rendering
    cam.PopModelMatrix();
    --Turn engine lighting back on
    render.SuppressEngineLighting( false );
end;


function ModelMesh.Proto:Remove()
    -- Remove the gmod mesh and clean up our extra data
    if (self.GmodMesh and self.GmodMesh:IsValid()) then
        self.GmodMesh:Remove();
        self.GmodMesh = nil;
        self.Triangles = nil;
        self.VisualModel = nil;
        self.Material = nil;
    end
    table.remove( VCals.Mesh.Stored, self.ID );
end;

--[[
    DECALMESH METAMETHODS
]]--

function ModelMesh.Meta.__index( tab, key )
    return ModelMesh.Proto[key];
end;

function ModelMesh.Meta.__call(modelPath, ... )
    if (file.Exists(modelPath) == false) then
        VCals.Debug:Print(
            Color( 255, 255, 0 ),
            "Unable to read file: ",
            modelPath
        );
        return;
    end
    local visualModels = util.GetModelMeshes(modelPath);
    local modelMesh = {
        id = #VCals.Mesh.Stored + 1
    };
    setmetatable(modelMesh, ModelMesh.Meta);
    -- Set the visual models
    modelMesh:SetVisualModels(visualModels);
    -- Build the mesh
    modelMesh:BuildMesh();
    table.insert(VCals.Mesh.Stored, decalMesh);
    return decalMesh;
end;

setmetatable( ModelMesh, ModelMesh.Meta );

--[[
AddPreRenderHook("Islands",function()
local pl = LocalPlayer()
local pos,fpos = pl:GetShipPos()

--Islands
for k,v in pairs(GetWorldGenerated(pos,MAIN_VISIBLE_SECTORRANGE)) do
render.SetMaterial(v.Mat)

local m = pl:GetRelativePos(v.Pos,v.FloatPos)
local m_pos = Matrix()
m_pos:Translate( m )

cam.PushModelMatrix( m_pos )
v.Mesh:Draw()
cam.PopModelMatrix()
end
end)
]]--