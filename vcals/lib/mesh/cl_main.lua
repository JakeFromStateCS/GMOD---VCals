--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/lib/mesh/cl_util.lua
]]--

--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create a global decal table
VCals.Mesh = {};
VCals.Mesh.Stored = {};

--[[
    VCals.Mesh:GridTraceLine( Vec/origin, Vec/direction, Int/distance, Int/width, Int/height, Table/filter, Boolean/debug ):
        Runs x by y trace lines from the origin in the direction provided
        Returns a list of points hit as a table of vectors
]]--
function VCals.Mesh:GridTraceLine( origin, direction, distance, width, height, filter, debug )
    local points = {};
    for y = 0, height - 1 do
        if( points[y] == nil ) then
            points[y] = {};
        end;
        for x = 0, width - 1 do
            local rightOffset = direction:Right() * x;
            local upOffset = direction:Up() * y;
            local pointOffset = -direction:Right() * width / 2 - direction:Up() * height / 2;
            local startPoint = origin + rightOffset + upOffset + pointOffset;
            local endPoint = startPoint + direction:Forward() * distance;
            local traceData = {
                start = startPoint,
                endpos = endPoint,
                filter = filter or {}
            };
            traceData = util.TraceLine( traceData );
            local HitPos = traceData.HitPos;
            if( traceData.Entity ) then
                if( traceData.Entity:IsValid() ) then
                    HitPos = traceData.Entity:WorldToLocal( traceData.HitPos );
                end;
            end;
            local point = {
                HitPos = HitPos,
                HitNorm = traceData.HitNormal,
                Entity = traceData.Entity
            };

            if( debug ) then
                point.Hit = traceData.Hit;
                point.Start = startPoint;
                point.End = endPoint;
            end;
            points[y][x] = point;
        end;
    end;
    return points;
end;


--[[
    VCals.Mesh:SetPointsTarget( Table/points, Decal/target ):
        Sets the target for the points and updates the position of the point to be relative to the target
]]--
function VCals.Mesh:SetPointsTarget( points, target )
    for y = 0, #points do
        local xPoints = points[y];
        for x = 0, #xPoints do
            local point = points[y][x];
            point.Target = target;
        end;
    end;
    return points;
end;


--[[
    VCals.Mesh:GridPointsToTriangles( Table/points ):
        Takes a table of points and converts them to triangles for use in mesh creation
]]--
function VCals.Mesh:GridPointsToTriangles( points )
    local triangles = {};
    for y = 0, #points do
        local xPoints = points[y];
        for x = 0, #xPoints do
            if( x < #xPoints and y < #xPoints) then
                local uBase = 1 / #xPoints;
                local vBase = 1 / #points;
                --Thanks to Foohy for helping me fix the U,V coords.
                --Literally just had to add -1 to the V coords.
                local order = {
                    { xPoints[x], uBase * x, -vBase * y },
                    { xPoints[x+1], uBase * ( x + 1 ), -vBase * y  },
                    { points[y+1][x+1], uBase * ( x + 1 ), -vBase * ( y + 1 ) },

                    { points[y+1][x+1], uBase * ( x + 1 ), -vBase * ( y + 1 ) },
                    { points[y+1][x], uBase * ( x ), -vBase * ( y + 1 ) },
                    { xPoints[x], uBase * x, -vBase * y }
                };
                --[[
                local order = {
                    { xPoints[x], uBase * x, vBase * y },
                    { xPoints[x+1], uBase * ( x + 1 ), vBase * y  },
                    { points[y+1][x+1], uBase * ( x + 1 ), vBase * ( y + 1 ) },

                    { points[y+1][x], uBase * ( x ), vBase * ( y + 1 ) },

                    { xPoints[x], uBase * x, vBase * y },


                    { points[y+1][x+1], uBase * ( x + 1 ), vBase * ( y + 1 ) },
                };
                ]]--

                --First
                triangles[#triangles + 1] = {
                    pos = order[1][1].HitPos,
                    u = order[1][2],
                    v = order[1][3],
                    normal = order[1][1].HitNorm
                    --entity = order[1][1].Entity,
                    --offset = order[1][1].Entity:WorldToLocal( order[1][1].HitPos ),
                };
                triangles[#triangles + 1] = {
                    pos = order[2][1].HitPos,
                    u = order[2][2],
                    v = order[2][3],
                    normal = order[2][1].HitNorm
                    --entity = order[2][1].Entity,
                    --offset = order[2][1].Entity:WorldToLocal( order[2][1].HitPos ),
                };
                triangles[#triangles + 1] = {
                    pos = order[3][1].HitPos,
                    u = order[3][2],
                    v = order[3][3],
                    normal = order[3][1].HitNorm
                    --entity = order[3][1].Entity,
                    --offset = order[3][1].Entity:WorldToLocal( order[3][1].HitPos ),
                };
                triangles[#triangles + 1] = {
                    pos = order[4][1].HitPos,
                    u = order[4][2],
                    v = order[4][3],
                    normal = order[4][1].HitNorm
                    --entity = order[4][1].Entity,
                };
                triangles[#triangles + 1] = {
                    pos = order[5][1].HitPos,
                    u = order[5][2],
                    v = order[5][3],
                    normal = order[5][1].HitNorm
                    --entity = order[5][1].Entity,
                    --offset = order[5][1].Entity:WorldToLocal( order[5][1].HitPos ),
                };
                triangles[#triangles + 1] = {
                    pos = order[6][1].HitPos,
                    u = order[6][2],
                    v = order[6][3],
                    normal = order[6][1].HitNorm
                    --entity = order[6][1].Entity,
                    --offset = order[6][1].Entity:WorldToLocal( order[6][1].HitPos ),
                };
            end;
        end;
    end;
    return triangles;
end;

function VCals.Mesh:BuildMeshFromVVD(vvdData)
    local vertexes = vvdData.vertexes;
    local triangles = {};
    --local order = {
    --    {
    --        xPoints[x],
    --        uBase * x,
    --        -vBase * y
    --    },
    --    {
    --        xPoints[x+1],
    --        uBase * ( x + 1 ),
    --        -vBase * y
    --    },
    --    {
    --        points[y+1][x+1],
    --        uBase * ( x + 1 ),
    --        -vBase * ( y + 1 )
    --    },
    --
    --    {
    --        points[y+1][x+1],
    --        uBase * ( x + 1 ),
    --        -vBase * ( y + 1 )
    --    },
    --    {
    --        points[y+1][x],
    --        uBase * ( x ),
    --        -vBase * ( y + 1 )
    --    },
    --    {
    --        xPoints[x],
    --        uBase * x,
    --        -vBase * y
    --    }
    --};
    --for vertexIndex = 1, #vertexes, 6 do
    --    local vertex1 = vertexes[vertexIndex];
    --    local vertex2 = vertexes[vertexIndex + 1];
    --    local vertex3 = vertexes[vertexIndex + 2];
    --    local vertex4 = vertexes[vertexIndex + 3];
    --    local vertex5 = vertexes[vertexIndex + 4];
    --    local vertex6 = vertexes[vertexIndex + 5];
    --
    --end
    for _,vertex in pairs(vertexes) do
        table.insert(
                triangles,
                {
                    pos = vertex.position,
                    u = vertex.texCoord.u,
                    v = vertex.texCoord.v,
                    normal = vertex.normal
                }
        );
        ----First
        --triangles[#triangles + 1] = {
        --    pos = order[1][1].HitPos,
        --    u = order[1][2],
        --    v = order[1][3],
        --    normal = order[1][1].HitNorm
        --    --entity = order[1][1].Entity,
        --    --offset = order[1][1].Entity:WorldToLocal( order[1][1].HitPos ),
        --};
        --triangles[#triangles + 1] = {
        --    pos = order[2][1].HitPos,
        --    u = order[2][2],
        --    v = order[2][3],
        --    normal = order[2][1].HitNorm
        --    --entity = order[2][1].Entity,
        --    --offset = order[2][1].Entity:WorldToLocal( order[2][1].HitPos ),
        --};
        --triangles[#triangles + 1] = {
        --    pos = order[3][1].HitPos,
        --    u = order[3][2],
        --    v = order[3][3],
        --    normal = order[3][1].HitNorm
        --    --entity = order[3][1].Entity,
        --    --offset = order[3][1].Entity:WorldToLocal( order[3][1].HitPos ),
        --};
        --triangles[#triangles + 1] = {
        --    pos = order[4][1].HitPos,
        --    u = order[4][2],
        --    v = order[4][3],
        --    normal = order[4][1].HitNorm
        --    --entity = order[4][1].Entity,
        --};
        --triangles[#triangles + 1] = {
        --    pos = order[5][1].HitPos,
        --    u = order[5][2],
        --    v = order[5][3],
        --    normal = order[5][1].HitNorm
        --    --entity = order[5][1].Entity,
        --    --offset = order[5][1].Entity:WorldToLocal( order[5][1].HitPos ),
        --};
        --triangles[#triangles + 1] = {
        --    pos = order[6][1].HitPos,
        --    u = order[6][2],
        --    v = order[6][3],
        --    normal = order[6][1].HitNorm
        --    --entity = order[6][1].Entity,
        --    --offset = order[6][1].Entity:WorldToLocal( order[6][1].HitPos ),
        --};
    end;
    return triangles;
end;