--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/lib/decals/sv_init.lua
]]--
--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create a global decal table
VCals.DecalMesh = {};

function VCals.DecalMesh:RayTri(ox,oy,oz, dx,dy,dz, t)
    local ax,ay,az,bx,by,bz,cx,cy,cz = t.ax,t.ay,t.az, t.bx,t.by,t.bz, t.cx,t.cy,t.cz
    local e1x,e1y,e1z = bx-ax, by-ay, bz-az
    local e2x,e2y,e2z = cx-ax, cy-ay, cz-az

    local px,py,pz = dy*e2z - dz*e2y, dz*e2x - dx*e2z, dx*e2y - dy*e2x
    local det = e1x*px + e1y*py + e1z*pz
    if det > -1e-8 and det < 1e-8 then return nil end -- parallel
    local invDet = 1/det

    local tx,ty,tz = ox-ax, oy-ay, oz-az
    local u = (tx*px + ty*py + tz*pz) * invDet
    if u < 0 or u > 1 then return nil end

    local qx,qy,qz = ty*e1z - tz*e1y, tz*e1x - tx*e1z, tx*e1y - ty*e1x
    local v = (dx*qx + dy*qy + dz*qz) * invDet
    if v < 0 or u+v > 1 then return nil end

    local tdist = (e2x*qx + e2y*qy + e2z*qz) * invDet
    if tdist <= 0 then return nil end

    return tdist, u, v
end

function VCals.DecalMesh:MakeScreenBucketsROI(tris, cols, rows, roiX, roiY, roiW, roiH)
    local W,H = ScrW(), ScrH()
    roiX = math.max(0, math.min(roiX, W-1))
    roiY = math.max(0, math.min(roiY, H-1))
    roiW = math.max(1, math.min(roiW, W - roiX))
    roiH = math.max(1, math.min(roiH, H - roiY))

    local cellW, cellH = roiW/cols, roiH/rows
    local buckets = {}
    for ix=0,cols-1 do
        buckets[ix] = {}
        for iy=0,rows-1 do buckets[ix][iy] = {} end
    end

    for ti,t in ipairs(tris) do
        local sa = Vector(t.ax,t.ay,t.az):ToScreen()
        local sb = Vector(t.bx,t.by,t.bz):ToScreen()
        local sc = Vector(t.cx,t.cy,t.cz):ToScreen()

        if sa.visible or sb.visible or sc.visible then
            local triMinX = math.min(sa.x,sb.x,sc.x)
            local triMaxX = math.max(sa.x,sb.x,sc.x)
            local triMinY = math.min(sa.y,sb.y,sc.y)
            local triMaxY = math.max(sa.y,sb.y,sc.y)

            local minXpx = math.max(triMinX, roiX)
            local maxXpx = math.min(triMaxX, roiX + roiW - 1)
            local minYpx = math.max(triMinY, roiY)
            local maxYpx = math.min(triMaxY, roiY + roiH - 1)

            if maxXpx >= minXpx and maxYpx >= minYpx then
                local minix = math.max(0, math.min(cols-1, math.floor((minXpx - roiX) / cellW)))
                local maxix = math.max(0, math.min(cols-1, math.floor((maxXpx - roiX) / cellW)))
                local miniy = math.max(0, math.min(rows-1, math.floor((minYpx - roiY) / cellH)))
                local maxiy = math.max(0, math.min(rows-1, math.floor((maxYpx - roiY) / cellH)))

                for ix=minix,maxix do
                    for iy=miniy,maxiy do
                        local cell = buckets[ix][iy]
                        cell[#cell+1] = ti
                    end
                end
            end
        end
    end

    return buckets, cellW, cellH, roiX, roiY
end

function VCals.DecalMesh:ProjectScreenPatchToMesh(tris, cols, rows, roiPixelW, roiPixelH, maxDist)
    maxDist = maxDist or 32768
    local W,H = ScrW(), ScrH()
    local cx, cy = W*0.5, H*0.5
    local roiW, roiH = roiPixelW, roiPixelH
    local roiX, roiY = cx - roiW*0.5, cy - roiH*0.5

    local buckets, cellW, cellH, rx, ry = self:MakeScreenBucketsROI(tris, cols, rows, roiX, roiY, roiW, roiH)
    local origin = EyePos()

    local function vindex(ix,iy) return iy*cols + ix + 1 end
    local verts = {}

    for iy=0,rows-1 do
        for ix=0,cols-1 do
            local px = rx + (ix + 0.5) * cellW
            local py = ry + (iy + 0.5) * cellH
            local dir = gui.ScreenToVector(px, py)
            local dx,dy,dz = dir.x, dir.y, dir.z

            local best = nil
            local cellTris = buckets[ix][iy]
            for _,ti in ipairs(cellTris) do
                local tdist,u,v = self:RayTri(origin.x,origin.y,origin.z, dx,dy,dz, tris[ti])
                if tdist and tdist < (best and best.t or 1e30) and tdist < maxDist then
                    best = { t=tdist, u=u, v=v, ti=ti }
                end
            end

            if best then
                local hit = Vector(origin.x + dx*best.t, origin.y + dy*best.t, origin.z + dz*best.t)

                -- interpolate per-vertex normals using barycentrics
                local tri = tris[best.ti]
                local w = 1 - best.u - best.v
                local nx = w*tri.anx + best.u*tri.bnx + best.v*tri.cnx
                local ny = w*tri.any + best.u*tri.bny + best.v*tri.cny
                local nz = w*tri.anz + best.u*tri.bnz + best.v*tri.cnz
                -- normalize
                local nlen = math.sqrt(nx*nx + ny*ny + nz*nz)
                if nlen > 0 then nx,ny,nz = nx/nlen, ny/nlen, nz/nlen else nx,ny,nz = 0,0,1 end

                -- keep normal in same hemisphere as the face normal (prevents inward flips)
                do
                    local e1x,e1y,e1z = tri.bx - tri.ax, tri.by - tri.ay, tri.bz - tri.az
                    local e2x,e2y,e2z = tri.cx - tri.ax, tri.cy - tri.ay, tri.cz - tri.az
                    local fnx = e1y*e2z - e1z*e2y
                    local fny = e1z*e2x - e1x*e2z
                    local fnz = e1x*e2y - e1y*e2x
                    if nx*fnx + ny*fny + nz*fnz < 0 then
                        nx,ny,nz = -nx,-ny,-nz
                    end
                end
                local normal = Vector(nx,ny,nz);
                -- Move the hit position out to stop z fighting
                local pos = hit - normal * 0.5;
                verts[vindex(ix,iy)] = {
                    pos = pos,
                    normal = normal,   -- outward-from-mesh normal
                    u = ix/(cols-1),
                    v = iy/(rows-1)
                }
            else
                verts[vindex(ix,iy)] = false
            end
        end
    end

    -- triangulate the grid (skip holes)
    local out = {}
    for iy=0,rows-2 do
        for ix=0,cols-2 do
            local a = verts[vindex(ix,  iy)]
            local b = verts[vindex(ix+1,iy)]
            local c = verts[vindex(ix,  iy+1)]
            local d = verts[vindex(ix+1,iy+1)]
            if a and b and c then out[#out+1]=a; out[#out+1]=b; out[#out+1]=c end
            if b and d and c then out[#out+1]=b; out[#out+1]=d; out[#out+1]=c end
        end
    end
    return out
end

function VCals.DecalMesh:CreateMesh(colCount, rowCount, pixelW, pixelH, modelPath)
    local visualModels = util.GetModelMeshes(modelPath);
    local visualModelTriangles = visualModels[1].triangles;

end;