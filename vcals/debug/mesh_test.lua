/*
	Code by "raspbian got DABBED on#0572" on discord
*/
cache = {};
local function ParsePHY(filename)
	if (!filename) then
		filename = "invalid.mdl"
	end
    if (!cache) then
        cache = {};
    end;
	if (cache[filename]) then
		return cache[filename]
	end
	--Create a cache for the file
	cache[filename] = {
		compactsurfaceheader_t = {},
		legacysurfaceheader_t = {},
		trianglefaceheaders = {},
		Vertices = {}
	};
	--Open the file in binary mode
	local fl = file.Open(
		string.Replace( filename, ".mdl", ".phy" ),
		"rb",
		"GAME"
	);
	--If the file var is nil, we couldn't open it for some reason
	if not fl then
		print("[LuaPHY] Unable to open: "..filename)
		file.Append( "LuaPHY.txt", "[LuaPHY] Unable to open: "..filename.."\r\n" )
		return cache[filename]
	end
	print("[LuaPHY] Parsing: "..filename)
	
	local size = fl:ReadLong()
	if size ~= 16 then NotifyMenu("[LuaPHY] Invalid file size: "..size.. " = " .. filename) return cache[filename] end
	local rtn = {}
	local tmp = {}
	rtn.id = fl:ReadLong()
	rtn.solidCount = fl:ReadLong()
	rtn.checkSum = fl:ReadLong()
	rtn.compactsurfaceheader_t = {}
		rtn.compactsurfaceheader_t.size = fl:ReadLong()
		rtn.compactsurfaceheader_t.vphysicsID = fl:Read(4)
		if (rtn.compactsurfaceheader_t.vphysicsID ~= "VPHY") then
			NotifyMenu("BAD V " .. filename)
			return cache[filename]
		end
		rtn.compactsurfaceheader_t.version = fl:ReadShort()
		rtn.compactsurfaceheader_t.modelType = fl:ReadShort()
		rtn.compactsurfaceheader_t.surfaceSize = fl:ReadLong()
		rtn.compactsurfaceheader_t.dragAxisAreas = Vector(fl:ReadFloat(),fl:ReadFloat(),fl:ReadFloat())
		rtn.compactsurfaceheader_t.axisMapSize = fl:ReadLong()
		rtn.legacysurfaceheader_t = {}
		rtn.legacysurfaceheader_t.m_vecMassCenter = Vector(fl:ReadFloat(),fl:ReadFloat(),fl:ReadFloat())
		rtn.legacysurfaceheader_t.m_vecRotationInertia = Vector(fl:ReadFloat(),fl:ReadFloat(),fl:ReadFloat())
		rtn.legacysurfaceheader_t.m_flUpperLimitRadius = fl:ReadFloat()
		rtn.legacysurfaceheader_t.m_volumeFull = fl:ReadLong()
		rtn.legacysurfaceheader_t.version = fl:Read(16)
	tmp.TFCSt = fl:Tell()
	tmp.tfh = 0
	tmp.vCnt = 0;
	rtn.trianglefaceheaders = {}
	while(true) do
		tmp.tfh = tmp.tfh + 1
		rtn.trianglefaceheaders[tmp.tfh] = {}
			rtn.trianglefaceheaders[tmp.tfh].m_offsetTovertices = fl:ReadLong()
			if(!tmp.OTV) then
				tmp.OTV = rtn.trianglefaceheaders[tmp.tfh].m_offsetTovertices
			end
			rtn.trianglefaceheaders[tmp.tfh].dummy1 = fl:ReadLong()
			rtn.trianglefaceheaders[tmp.tfh].dummy2 = fl:ReadLong()
			rtn.trianglefaceheaders[tmp.tfh].m_countFaces = fl:ReadLong()
		rtn.trianglefaceheaders[tmp.tfh].trianglefaces = {}
 
		for i = 1, rtn.trianglefaceheaders[tmp.tfh].m_countFaces, 1 do
			rtn.trianglefaceheaders[tmp.tfh].trianglefaces[i] = {}
			rtn.trianglefaceheaders[tmp.tfh].trianglefaces[i].id = fl:ReadByte();fl:Read(3)
			rtn.trianglefaceheaders[tmp.tfh].trianglefaces[i].v1 = fl:ReadShort();fl:Read(2)
			if (rtn.trianglefaceheaders[tmp.tfh].trianglefaces[i].v1 > tmp.vCnt) then tmp.vCnt = rtn.trianglefaceheaders[tmp.tfh].trianglefaces[i].v1 end
			rtn.trianglefaceheaders[tmp.tfh].trianglefaces[i].v2 = fl:ReadShort();fl:Read(2)
			if (rtn.trianglefaceheaders[tmp.tfh].trianglefaces[i].v2 > tmp.vCnt) then tmp.vCnt = rtn.trianglefaceheaders[tmp.tfh].trianglefaces[i].v2 end
			rtn.trianglefaceheaders[tmp.tfh].trianglefaces[i].v3 = fl:ReadShort();fl:Read(2)
			if (rtn.trianglefaceheaders[tmp.tfh].trianglefaces[i].v3 > tmp.vCnt) then tmp.vCnt = rtn.trianglefaceheaders[tmp.tfh].trianglefaces[i].v3 end
		end
		if(rtn.trianglefaceheaders[tmp.tfh].dummy1 != 0) then
			print("DUMPING, BAD DUMMY1 ".. tmp.tfh .. " = " .. rtn.trianglefaceheaders[tmp.tfh].dummy1)
			rtn.trianglefaceheaders[tmp.tfh] = nil
		end
		if (fl:Tell() >= tmp.OTV) then
			break
		end
	end
	rtn.Vertices = {}
	if (tmp.vCnt > 300) then
		NotifyMenu("[LuaPHY]Insane physics: " .. tmp.vCnt .. " = " .. filename,7)
	end
	for i = 1, tmp.vCnt+1, 1 do
		rtn.Vertices[i] = {}
		rtn.Vertices[i].v = Vector(fl:ReadFloat(),fl:ReadFloat(),fl:ReadFloat())
		rtn.Vertices[i].unk = fl:ReadLong()
	end
	local rtT = {}
	rtn.triangles = {};
	for th = 1, #rtn.trianglefaceheaders, 1 do
		if (rtn.trianglefaceheaders[th]) then
			tf = rtn.trianglefaceheaders[th].trianglefaces
			for i = 1, #tf, 1 do
				local triangle = {};
				table.insert(triangle, rtn.Vertices[tf[i].v1+1].v*39.37012415030996);
				table.insert(triangle, rtn.Vertices[tf[i].v2+1].v*39.37012415030996);
				table.insert(triangle, rtn.Vertices[tf[i].v3+1].v*39.37012415030996);
				table.insert(rtn.triangles, triangle);

				table.insert(rtT,{pos = rtn.Vertices[tf[i].v1+1].v*39.37012415030996}) // epic magic numbers
				table.insert(rtT,{pos = rtn.Vertices[tf[i].v3+1].v*39.37012415030996})
				table.insert(rtT,{pos = rtn.Vertices[tf[i].v2+1].v*39.37012415030996})
			end
		end
	end
	rtn.meshTriangles = rtT
	rtn.mesh = Mesh()
	rtn.mesh:BuildFromTriangles( rtn.meshTriangles )
	fl:Close()
	cache[filename] = rtn
	return rtn
end

meshVis = {};


-- Loop over all of the points in the meshVerts and get the points within the box
function isPointInBox(vectorPoint, obbMins, obbMaxs)
    return (
        (vectorPoint.x >= obbMins.x && vectorPoint.x <= obbMaxs.x) &&
        (vectorPoint.y >= obbMins.y && vectorPoint.y <= obbMaxs.y) &&
        (vectorPoint.z >= obbMins.z && vectorPoint.z <= obbMaxs.z)
    )
end;

function getSurface(modelPath, camPos, camAng, width, height)
    local meshData = ParsePHY(modelPath);
    local meshVerts = meshData.meshTriangles;
    local depth = 100;
    local obbMins = camPos - camAng:Forward() * depth - camAng:Up() * height / 2 - camAng:Right() * width / 2
    local obbMaxs = camPos + camAng:Forward() * depth + camAng:Up() * height / 2 + camAng:Right() * width / 2;
    print(obbMins);
    print(obbMaxs);
    local vertsInBox = {};
    for _,vertData in pairs(meshVerts) do
        local vector = vertData.pos;
        if (isPointInBox(vector, obbMins, obbMaxs)) then
            table.insert(vertsInBox, vector);
        end;
    end;
    return vertsInBox;
end;

print(LocalPlayer():GetEyeTrace().Entity:GetModel());

--print(LocalPlayer():GetEyeTrace().Entity:GetModel())
local modelPath = 'models/buggy.mdl';
local camPos = Vector(0, 0, 0);
local camAng = Angle(0, 90, 0);
local width = 100;
local height = 100;
local depth = 100;
local obbMins = camPos - camAng:Forward() * depth - camAng:Up() * height / 2 - camAng:Right() * width / 2
local obbMaxs = camPos + camAng:Forward() * depth + camAng:Up() * height / 2 + camAng:Right() * width / 2;
local meshData = ParsePHY(modelPath);
local triangles = meshData.triangles;
PrintTable(triangles);
/*
local meshVerts = meshData.meshTriangles || {};
local vertsInBox = getSurface(modelPath, camPos, camAng, width, height);
*/
hook.Add('PostDrawOpaqueRenderables', 'DrawVertsInBox', function()
	/*
	render.SetColorMaterial();
	for _,meshVert in pairs(meshVerts) do
		render.DrawSphere( meshVert.pos, 2, 30, 30, Color( 0, 175, 175, 255 ) )
	end;
	for _,vertInBox in pairs(vertsInBox) do
		render.DrawSphere( vertInBox, 2, 30, 30, Color( 255, 200, 105, 255 ) )
	end;
	render.DrawWireframeBox(
		Vector(0, 0, 0),
		Angle(0, 90, 0),
		obbMins,
		obbMaxs,
		Color(255, 0, 0)
	);
	*/
end);