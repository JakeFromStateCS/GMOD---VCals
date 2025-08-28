--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/lib/elements/cl_textelement.lua
]]--

--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create a global decal table
VCals.Decals = {};
--Holds all the decals on each vehicle
VCals.Decals.Stored = {};

TextElement = {};
TextElement.Meta = {};
TextElement.Proto = {
    Position = {
        x = 0,
        y = 0
    },
    Text = "",
    Font = "",
    Color = Color( 255, 255, 255 ),
    YAlign = TEXT_ALIGN_TOP,
    XAlign = TEXT_ALIGN_LEFT,
    Scale = 1,
    Rotation = 0,
    Matrix = Matrix(),
    Outlined = false,
    OutlineColor = Color( 0, 0, 0 ),
    OutlineWidth = 1
};

--[[
    ELEMENT PROTOTYPE METHODS
]]--

function TextElement.Proto:SetPos( x, y )
    self.Position.x = x;
    self.Position.y = y;
end;

function TextElement.Proto:GetPos()
    return self.Position;
end;

function TextElement.Proto:SetText( text )
    self.Text = text;
end;

function TextElement.Proto:GetText()
    return self.Text;
end;

function TextElement.Proto:SetFont( font )
    self.Font = font;
end;

function TextElement.Proto:GetFont()
    return self.Font;
end;

function TextElement.Proto:SetColor( color )
    self.Color = color;
end;

function TextElement.Proto:GetColor()
    return self.Color;
end;

function TextElement.Proto:SetXAlign( alignment )
    self.XAlign = alignment;
end;

function TextElement.Proto:GetXAlign()
    return self.XAlign;
end;

function TextElement.Proto:SetYAlign( alignment )
    self.YAlign = alignment;
end;

function TextElement.Proto:GetYAlign()
    return self.YAlign;
end;

function TextElement.Proto:SetScale( scale )
    self.Scale = scale;
end;

function TextElement.Proto:GetScale()
    return self.Scale;
end;

function TextElement.Proto:SetRotation( rotation )
    self.Rotation = rotation;
end;

function TextElement.Proto:GetRotation()
    return self.Rotation;
end;

function TextElement.Proto:Draw()
    --Push our rotation and scale
    self.Matrix:SetAngles( Angle( 0, self.Rotation, 0 ) );
    self.Matrix:SetScale( Vector( 1, 1, 1 ) * self.Scale );
    render.PushFilterMag( TEXFILTER.ANISOTROPIC );
    render.PushFilterMin( TEXFILTER.ANISOTROPIC );
    cam.PushModelMatrix( self.Matrix );
        if( not self.Outlined ) then
            draw.SimpleText(
                self.Text,
                self.Font,
                self.Position.x,
                self.Position.y,
                self.Color,
                self.XAlign,
                self.YAlign
            );
        else
            draw.SimpleTextOulined(
                self.Text,
                self.Font,
                self.Position.x,
                self.Position.y,
                self.Color,
                self.XAlign,
                self.YAlign,
                self.OutlineWidth,
                self.OutlineColor
            );
        end;
    cam.PopModelMatrix();
    render.PopFilterMag();
    render.PopFilterMin();
end;


--[[
    ELEMENT METAMETHODS
]]--

function TextElement.Meta.__index( table, key )
    return TextElement.Proto[key];
end;

function TextElement.Meta.__call( table, ... )
    local element = {
        Position = {
            x = 0,
            y = 0
        },
        Text = "",
        Font = "",
        Color = Color( 255, 255, 255 ),
        YAlign = TEXT_ALIGN_TOP,
        XAlign = TEXT_ALIGN_LEFT,
        Scale = 1,
        Rotation = 0,
        Matrix = Matrix(),
        Outlined = false,
        OutlineColor = Color( 0, 0, 0 ),
        OutlineWidth = 1
    };

    setmetatable( element, TextElement.Meta );
    return element;
end

setmetatable( TextElement, TextElement.Meta );