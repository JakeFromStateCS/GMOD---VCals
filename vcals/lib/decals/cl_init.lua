--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/lib/decals/cl_init.lua
]]--
--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create a global decal table
VCals.Decals = {};
--Holds all the decals on each vehicle
VCals.Decals.Stored = {};

Decal = {};
Decal.Meta = {};
Decal.Proto = {
    Elements = {},
    Size = {
        w = 500,
        h = 500
    }
};

function Decal.Proto:SetSize( w, h )
    self.Size.w = w;
    self.Size.h = h;
end;

--Updates the render target material by drawing all elements onto the render target
--This must be called when any of the elements are modified in order to update the material used to draw 
function Decal.Proto:Update()
    local decal = self;
    local name = self.Name;
    self.RenderTarget = GetRenderTarget( self.Name, self.Size.w, self.Size.h );
    self.Material:SetTexture( "$basetexture", self.RenderTarget );
    hook.Add( "HUDPaint", name .. "_HUDPaint", function()

        --Push the render target
        render.PushRenderTarget( decal.RenderTarget );
        render.OverrideAlphaWriteEnable( true, true );

        --Clear the render target
        render.Clear( 0, 0, 0, 0 );
        render.ClearDepth();

        --Start the 2D cam
        cam.Start2D();
            --Draw the elements
            for elementID, element in pairs( decal.Elements ) do
                element:Update();
                --local element = decal.Elements[elementID];
                element:Draw();

            end;
        --End the 2D cam
        cam.End2D();


        render.OverrideAlphaWriteEnable( false );
        render.PopRenderTarget();

        --Disable stencil
        --render.SetStencilEnable( false );
        --render.ClearStencil();
        hook.Remove( "HUDPaint", name .. "_HUDPaint" );
    end );
end;

function Decal.Proto:GetMaterial()
    return self.Material;
end;

function Decal.Proto:AddElement()
    local element = Element();
    element:SetDecal( self );
    table.insert( self.Elements, element );
    element.ID = #self.Elements;
    return element;
end;

function Decal.Proto:AddTextElement()
    local element = TextElement();
    table.insert( self.Elements, element );
    element.ID = #self.Elements;
    return element;
end;

--[[
    DECAL METAMETHODS
]]--

--[[
    Decal.Meta.__call:
        Allows us to call Decal( ... ) to get a new decal instance
]]--
function Decal.Meta.__call( table, name )
    local decal = {};
    setmetatable( decal, Decal.Meta );
    decal.Elements = {};
    decal.Name = name;
    decal.Material = CreateMaterial(
        name,
        "UnlitGeneric",
        {
            ["$basetexture"] = "",
            ["$vertexcolor"] = 1,
            --["$vertexalpha"] = 1,
            ["$model"] = 1,
            ["$nocull"] = 1,
            ["$additive"] = 0
        }
    );
    decal.HTMLPanel = vgui.Create( "DHTML" );
    return decal;
end;

--[[
    Decal.Meta.__index( table, key ):
        Returns the key from the prototype if non-existent in the instance
]]--
function Decal.Meta.__index( table, key )
    return Decal.Proto[key];
end;

setmetatable( Decal, Decal.Meta );

--[[
    DrawTexturedRect/DrawTexturedRectRotated don't like to be drawn outside of hooks apparently..
]]--