--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/lib/elements/cl_element.lua
]]--

--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create a global decal table
VCals.Decals = {};
--Holds all the decals on each vehicle
VCals.Decals.Stored = {};

Element = {};
Element.Meta = {};
Element.Proto = {
    Position = {
        x = 0,
        y = 0
    },
    Material = Material( "models/debug/debugwhite" ),
    Color = Color( 255, 255, 255 ),
    Size = {
        w = 100,
        h = 100
    },
    Rotation = 0
};


--[[
    ELEMENT PROTOTYPE METHODS
]]--

function Element.Proto:GetSVGSource( svgPath )
    if( svgPath ) then
        local scale = 4;
        local fullPath = "materials/" .. svgPath;
        local svgSource = file.Read( "materials/" .. svgPath, "GAME" );
        --svgSource = string.Implode( "<svg style='overflow: visible;' version", string.Split( svgSource, "<svg version" ) );
        --Grab the viewBox
        local viewBox = string.Split( string.Split( string.Split( svgSource, 'viewBox="' )[2], '"' )[1], " " );
        --Scale it up
        local minX, minY, width, height = viewBox[1], viewBox[2], viewBox[3] * scale, viewBox[4] * scale;

        local stringFind = string.Implode( " ", { minX, minY, width / scale .. ".000000", height / scale .. ".000000" } );
        local stringReplace = string.Implode( " ", { minX, minY, width .. ".000000", height .. ".000000" } );
        svgSource = string.Replace( svgSource, stringFind, stringReplace );
        --Replace width
        svgSource = string.Replace( svgSource, width / scale .. ".000000pt", width .. ".000000" );
        --Replace height
        svgSource = string.Replace( svgSource, height / scale .. ".000000pt", height .. ".000000" );
        local textScale = string.format( "%f", 0.5 );
        --Scale up the shape
        svgSource = string.Replace( svgSource, "scale(0.100000,-0.100000)", "scale(" .. textScale .. ",-" .. textScale .. ")" );
        svgSource = string.Replace( svgSource, "<g", "<g width='" .. width .. "' height='" .. height .. "'" );
        --Translate it
        local targetTransX, targetTransY = string.format( "%f", 0 ), string.format( "%f", height );
        local transFind = "translate(" .. string.format( "%f", 0 ) .. "," .. string.format( "%f", height / scale ) .. ")";
        svgSource = string.Replace( svgSource, transFind, "translate(" .. targetTransX .. ","  .. targetTransY .. ")" );
        svgSource = string.Implode(
            '</metadata><rect width="' .. width .. '" height="' .. height .. '" style="fill:rgb(255,255,255);" />',
            string.Explode( "</metadata>", svgSource )
        );
        print( svgSource );
        --svgSource = string.Replace( svgSource, "translate(" .. string.format( "%f", 0 ), "translate(-" .. string.format( "%f", width / 2 ) );
        return svgSource;
    else
        return "";
    end;
end;

function Element.Proto:SetPos( x, y )
    self.Position.x = x;
    self.Position.y = y;
end;

function Element.Proto:GetPos()
    return self.Position;
end;

function Element.Proto:SetMaterial( matString )
    local split = string.Split( matString, "." );
    if( split[#split] == "svg" ) then
        if( not self.RenderTarget ) then
            self.Name = CurTime();
            self.RenderTarget = GetRenderTarget( self.Name, self.Size.w * 10, self.Size.h * 10 );
        end;
        VCals.Menu:UpdateHTML( self:GetSVGSource( matString ) );
        self.Material = CreateMaterial( matString .. CurTime(), "UnlitGeneric",
            {
                ["$basetexture"] = self.RenderTarget,
                ["$additive"] = 1,
                ["$alphatest"] = 1,
            }
        );
        self:Update();
    else
        self.Material = Material( matString, "smooth" );
        self.Material = CreateMaterial( matString .. CurTime(), "UnlitGeneric",
            {
                ["$basetexture"] = self.Material:GetTexture( "$basetexture" ):GetName(),
                ["$additive"] = 1,
                ["$alphatest"] = 1,
            }
        );
    end;

    self.Mask = CreateMaterial( matString .. CurTime(), "UnlitGeneric",
        {
            ["$basetexture"] = self.Material:GetTexture( "$basetexture" ):GetName(),
            ["$additive"] = 0,
            ["$vertexcolor"] = 1,
            ["$vertexalpha"] = 1
        }
    );
end;

function Element.Proto:GetMaterial()
    return self.Material;
end;

function Element.Proto:SetColor( color )
    self.Color = color;
end;

function Element.Proto:GetColor()
    return self.Color;
end;

function Element.Proto:SetSize( w, h )
    self.Size.w = w;
    self.Size.h = h;
end;

function Element.Proto:GetSize()
    return self.Size;
end;

function Element.Proto:SetRotation( rotation )
    self.Rotation = rotation;
end;

function Element.Proto:GetRotation()
    return self.Rotation;
end;

function Element.Proto:Update()
    local element = self;
    if( not self.RenderTarget ) then
        self.Name = CurTime();
        self.RenderTarget = GetRenderTarget( self.Name, self.Size.w * 10, self.Size.h * 10 );
    end;
    local name = self.Name;
    self.Material:SetTexture( "$basetexture", self.RenderTarget );
    hook.Add( "HUDPaint", name .. "_HUDPaint", function()
        --Push the render target
        render.PushRenderTarget( element.RenderTarget );
        render.OverrideAlphaWriteEnable( true, true );

        --Clear the render target
        render.Clear( 0, 0, 0, 0 );
        render.ClearDepth();

        --Start the 2D cam
        cam.Start2D();
            --Draw the elements
            surface.SetDrawColor( element.Color );
            local mat = VCalsHTML:GetHTMLMaterial();
            surface.SetMaterial( mat );
            surface.DrawTexturedRect(
                0,
                0,
                element.Size.w * 1,
                element.Size.h * 1,
                element.Rotation
            );
        --End the 2D cam
        cam.End2D();


        render.OverrideAlphaWriteEnable( false );
        render.PopRenderTarget();

        hook.Remove( "HUDPaint", name .. "_HUDPaint" );
    end );
end;

function Element.Proto:Draw()
    surface.SetDrawColor( self.Color );

    surface.SetMaterial( self.Material );
    surface.DrawTexturedRectRotated(
        self.Position.x + self.Size.w / 2,
        self.Position.y + self.Size.h / 2,
        self.Size.w,
        self.Size.h,
        self.Rotation
    );
end;

function Element.Proto:SetDecal( decal )
    self.Decal = decal;
end;


--[[
    ELEMENT METAMETHODS
]]--

function Element.Meta.__index( table, key )
    return Element.Proto[key];
end;

function Element.Meta.__call( table, ... )
    local element = {
        Position = {
            x = 0,
            y = 0
        },
        Material = Material( "models/debug/debugwhite" ),
        Color = Color( 255, 255, 255 ),
        Size = {
            w = 100,
            h = 100
        },
        Rotation = 0
    };

    setmetatable( element, Element.Meta );
    return element;
end

setmetatable( Element, Element.Meta );