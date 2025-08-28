--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/vgui/cl_modelpanel.lua
]]--
surface.CreateFont(
    "VCals_ModelPanelTitle",
    {
        font = "Tahoma",
        size = ScreenScale( 12 ),
        weight = 600
    }
);

surface.CreateFont(
    "VCals_ModelPanelSubtitle",
    {
        font = "Tahoma",
        size = ScreenScale( 5 ),
        weight = 600
    }
);

local PANEL = {};

function PANEL:Init()
    self.Distance = 160;
    self.mouseX, self.mouseY = gui.MouseX(), gui.MouseY();
    local parent = self:GetParent();
    self:SetSize( parent:GetWide() - ScrW() / 6 / 4 * 3, parent:GetTall() - 46 );
    self:SetPos( parent:GetWide() - self:GetWide() + 100, 46 );

    self.Title = "MACCHINA CALABRIA 127";
    self.Subtitle = "Macchina Calabria 127";
    self.TitleFont = "VCals_ModelPanelTitle";
    self.SubtitleFont = "VCals_ModelPanelSubtitle";
end;

function PANEL:DrawModel()
    local curparent = self
    local rightx = self:GetWide()
    local leftx = 0
    local topy = 0
    local bottomy = self:GetTall()
    local previous = curparent
    while( curparent:GetParent() ~= nil ) do
        curparent = curparent:GetParent()
        local x, y = previous:GetPos()
        topy = math.Max( y, topy + y )
        leftx = math.Max( x, leftx + x )
        bottomy = math.Min( y + previous:GetTall(), bottomy + y )
        rightx = math.Min( x + previous:GetWide(), rightx + x )
        previous = curparent
    end
    render.SetScissorRect( leftx, topy, rightx, bottomy, true )

    local ret = self:PreDrawModel( self.Entity )
    if ( ret ~= false ) then
        self.Entity:DrawModel()
        if( self.MeshTable ) then
            for meshID = 1, #self.MeshTable do
                local mesh = self.MeshTable[meshID];
                mesh:Draw( self.Entity );
            end;
        end;
        self:PostDrawModel( self.Entity )
    end

    render.SetScissorRect( 0, 0, 0, 0, false )
end;

function PANEL:SetMeshTable( meshTable )
    self.MeshTable = meshTable;
end;

function PANEL:OrbitCamera(p,a1,x)
    local a2=(a1:Forward()*-1):Angle();
    local c=Vector(x,0,0);
    c:Rotate(a1);
    c=c+p;
    return c,a2;
end;

function PANEL:LayoutEntity()

end;

function PANEL:OnMousePressed()
    self.Dragging = true;
    self.mouseX, self.mouseY = gui.MouseX(), gui.MouseY();
end;

function PANEL:OnMouseReleased()
    self.Dragging = false;
end;

function PANEL:OnMouseWheeled( delta )
    self.Distance = self.Distance - delta * 2;
end;

function PANEL:Think()
    local camPos = self:GetCamPos();
    local lookAt = self:GetLookAt();
    local relAng = ( camPos - lookAt ):Angle();
    local curX, curY = gui.MouseX(), gui.MouseY();
    if( self.Dragging ) then
        local diffX, diffY = curX - self.mouseX, curY - self.mouseY;
        relAng = relAng - Angle( diffY, diffX, 0 );
    end;
    self.mouseX = curX;
    self.mouseY = curY;
    local newPos, newAng = self:OrbitCamera( lookAt, relAng, self.Distance );
    self:SetCamPos( newPos );
    self:SetLookAt( lookAt );
end;

function PANEL:UpdateView()
    self.prevMins, self.prevMaxs = self.Entity:GetRenderBounds();
    local pos = self.prevMins:Distance( self.prevMaxs ) * Vector( 0.5, 0.5, 0.5 )
    --self.Entity:OBBCenter() - Vector( 0, 1, 0 ) * prevMins:Distance( prevMaxs )
    self:SetCamPos( pos );
    self:SetLookAt( ( self.prevMaxs + self.prevMins ) / 2 );
    self.Distance = self.prevMins:Distance( self.prevMaxs );
end;

function PANEL:Paint( w, h )

    if ( not IsValid( self.Entity ) ) then return end

    local x, y = self:LocalToScreen( 0, 0 )

    self:LayoutEntity( self.Entity )

    local ang = self.aLookAngle
    if ( not ang ) then
        ang = ( self.vLookatPos - self.vCamPos ):Angle()
    end

    cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )

        render.SuppressEngineLighting( true )
        render.SetLightingOrigin( self.Entity:GetPos() )
        render.ResetModelLighting( self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255 )
        render.SetColorModulation( self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255 )
        render.SetBlend( ( self:GetAlpha() / 255 ) * ( self.colColor.a / 255 ) )

        for i = 0, 6 do
            local col = self.DirectionalLight[ i ]
            if ( col ) then
                render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
            end
        end

        self:DrawModel()

        render.SuppressEngineLighting( false )
    cam.End3D()

    self.LastPaint = RealTime()

end;

function PANEL:PaintOver( w, h )
    draw.SimpleText(
        self.Title,
        self.TitleFont,
        w / 3 * 2 - 100,
        h - ScreenScale( 5 ) - 100 - 8,
        Color( 255, 255, 255 ),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_BOTTOM
    );
    draw.SimpleText(
        self.Subtitle,
        self.SubtitleFont,
        w / 3 * 2 - 100 + 6,
        h - 100,
        Color( 220, 220, 220, 100 ),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_BOTTOM
    );

end;
vgui.Register( "VCals_ModelPanel", PANEL, "DModelPanel" );