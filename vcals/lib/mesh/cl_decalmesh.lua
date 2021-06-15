/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/lib/mesh/cl_decalmesh.lua
*/

DecalMesh = {};
DecalMesh.Meta = {};
DecalMesh.Proto = {
	Triangles = {},
	Decal = {},
}


--[[
	DecalMesh prototype methods
]]--
function DecalMesh.Proto:SetDecal( decal )
	self.Decal = decal;
	self.Material = self.Decal:GetMaterial();
end;

function DecalMesh.Proto:GetDecal()
	return self.Decal;
end;

function DecalMesh.Proto:SetTriangles( triangles )
	self.Triangles = triangles;
	self.Mesh = Mesh( self.Material );
	self.Mesh:BuildFromTriangles( triangles );
end;

function DecalMesh.Proto:GetTriangles()
	return self.Triangles;
end;

function DecalMesh.Proto:SetTargetEntity( entity )
	if( !entity.DecalTable ) then
		entity.DecalTable = {};
	end;
	self.TargetEntity = entity;
	table.insert( entity.DecalTable, self );
end;

function DecalMesh.Proto:SetTargetPos( targetPos )
	self.TargetPos = targetPos;
end;

function DecalMesh.Proto:SetTargetAng( targetAng )
	self.TargetAng = targetAng;
end;

function DecalMesh.Proto:Draw( ent )
	local material = self.Material;
	local mesh = self.Mesh;
	local entity = ( ent or self.TargetEntity );
	if( !entity or !entity:IsValid() ) then
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
	if( !ent ) then
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


function DecalMesh.Proto:Remove()
	table.remove( VCals.Mesh.Stored, self.ID );
end;

--[[
	DECALMESH METAMETHODS
]]--

function DecalMesh.Meta.__index( tab, key )
	return DecalMesh.Proto[key];
end;

function DecalMesh.Meta.__call( tab, ... )
	local decalMesh = {
		Triangles = {},
		Decal = {},
		ID = #VCals.Mesh.Stored
	};
	setmetatable( decalMesh, DecalMesh.Meta );
	table.insert( VCals.Mesh.Stored, decalMesh );
	return decalMesh;
end;

setmetatable( DecalMesh, DecalMesh.Meta );

/*
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
*/