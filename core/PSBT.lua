------------------------------------------------
-- Pawkette's Scrolling Battle Text
--
-- @author Pawkette ( pawkette.heals@gmail.com )
------------------------------------------------
local LMP = LibStub( 'LibMediaProvider-1.0' )
if ( not LMP ) then return end

local PSBT              = PSBT
local CBM               = CALLBACK_MANAGER
local PSBT_AREAS        = PSBT.AREAS
local PSBT_EVENTS       = PSBT.EVENTS
local PSBT_MODULES      = PSBT.MODULES
local PSBT_SETTINGS     = PSBT.SETTINGS
local PSBT_STRINGS      = PSBT.STRINGS
local tinsert           = table.insert
local tremove           = table.remove
local _

function PSBT:Initialize( control )
    self.control = control
    self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( _, addon ) self:OnLoaded( addon ) end )

    CBM:FireCallbacks( PSBT_EVENTS.INITIALIZE )
end

function PSBT:FormatFont( font )
    local face, size, decoration = font.face, font.size, font.deco
    local fmt = '%s|%d'
    if ( decoration and decoration ~= 'none' ) then
        fmt = fmt .. '|%s'
    end

    return fmt:format( LMP:Fetch( LMP.MediaType.FONT, face ), size, decoration ) 
end

function PSBT:OnLoaded( addon )
    if ( addon ~= 'PSBT' ) then
        return
    end

    print( 'Loading PSBT' )
    CBM:FireCallbacks( PSBT_EVENTS.LOADED, self )

    self._fadeIn    = self.FadeProto:New( 1.0, 0.0 )
    self._fadeOut   = self.FadeProto:New( 0.0, 1,0 )


    self:CreateModule( PSBT_MODULES.SETTINGS )
    self:CreateModule( PSBT_MODULES.OPTIONS )

    self._areas[ PSBT_AREAS.INCOMING ]     = self.ScrollAreaProto:New( self.control, PSBT_AREAS.INCOMING,     self:GetSetting( PSBT_AREAS.INCOMING ), self._fadeIn, self._fadeOut, GetString( _G[ PSBT_STRINGS.AREA_INCOMING ] ) )
    self._areas[ PSBT_AREAS.OUTGOING ]     = self.ScrollAreaProto:New( self.control, PSBT_AREAS.OUTGOING,     self:GetSetting( PSBT_AREAS.OUTGOING ), self._fadeIn, self._fadeOut, GetString( _G[ PSBT_STRINGS.AREA_OUTGOING ] ) )
    self._areas[ PSBT_AREAS.STATIC ]       = self.ScrollAreaProto:New( self.control, PSBT_AREAS.STATIC,       self:GetSetting( PSBT_AREAS.STATIC ), self._fadeIn, self._fadeOut, GetString( _G[ PSBT_STRINGS.AREA_STATIC ] ) )
    self._areas[ PSBT_AREAS.NOTIFICATION ] = self.ScrollAreaProto:New( self.control, PSBT_AREAS.NOTIFICATION, self:GetSetting( PSBT_AREAS.NOTIFICATION ), self._fadeIn, self._fadeOut, GetString( _G[ PSBT_STRINGS.AREA_NOTIFICATION ] ) )

    CBM:RegisterCallback( PSBT_EVENTS.CONFIG, function( ... ) self:SetConfigurationMode( ... ) end )
    CBM:RegisterCallback( PSBT_EVENTS.DEMO, function() self:TriggerFakeEvents() end )
    self.control:SetHandler( 'OnUpdate', function( _, frameTime ) self:OnUpdate( frameTime ) end )

    for k,v in pairs( PSBT_MODULES ) do
        if ( k ~= 'SETTINGS' and k ~= 'OPTIONS' ) then
              if ( self:GetSetting( v ) ) then
                self:CreateModule( v ) 
            end
        end
    end

end

function PSBT:OnUpdate( frameTime )
    self.LabelFactory:OnUpdate( frameTime )

    for k,v in pairs( self._loadedModules ) do
        v:OnUpdate( frameTime )
    end
end

function PSBT:ToggleModule( InModule )
    local enabled = self:GetSetting( InModule )
    -- do fancy stuff here
    local mod = self:GetModule( InModule )
    if ( enabled and mod == nil ) then
        self:CreateModule( InModule )
    elseif( not enabled and mod ~= nil ) then
        mod:Shutdown()
        self._loadedModules[ InModule ] = nil
    end
end

function PSBT:SetConfigurationMode( mode )
    if ( not mode ) then
        for k,v in pairs( self._areas ) do
            local settings = self:GetSetting( k )
            local point, relPoint, offsX, offsY = v:GetAnchorOffsets()

            settings.to = point
            settings.from = relPoint
            settings.x = offsX
            settings.y = offsY

            self:SetSetting( k, settings )
        end
    end
end

function PSBT:CreateModule( InModule )
    local proto = self._modules[ InModule ]

    if ( proto ~= nil ) then
        self._loadedModules[ InModule ] = proto:New( self )
    else
        print( 'Hey, we don\'t have = %s', InModule )
    end
end

function PSBT:RegisterModule( identity, class, version )
    if ( not version ) then
        version = -1
    end

    if ( self._modules[ identity ] and ( version < ( self._modules[ identity ].__version or 0 ) ) ) then
        return
    end

    self._modules[ identity ] = class
    self._modules[ identity ].__version = version
end

function PSBT:GetModule( identity )
    if ( not self._loadedModules[ identity ] ) then
        return nil
    end

    return self._loadedModules[ identity ]
end

function PSBT:GetSetting( name )
    local settings = self:GetModule( PSBT_MODULES.SETTINGS )
    return settings:GetSetting( name )
end

function PSBT:SetSetting( name, value )
    local settings = self:GetModule( PSBT_MODULES.SETTINGS )
    settings:SetSetting( name, value )

    if ( name == PSBT_AREAS.INCOMING or 
         name == PSBT_AREAS.OUTGOING or
         name == PSBT_AREAS.STATIC or 
         name == PSBT_AREAS.NOTIFICATION ) then
    
        self._areas[ name ]:SetSettings( value )    
    end
end

function PSBT:TriggerFakeEvents()
    self:NewEvent( PSBT_AREAS.INCOMING,     ( math.random( 1, 2 ) == 2 ), [[/esoui/art/icons/icon_missing.dds]], tostring( math.ceil( math.random( 1, 100 ) ) ) )
    self:NewEvent( PSBT_AREAS.OUTGOING,     ( math.random( 1, 2) == 2 ), [[/esoui/art/icons/icon_missing.dds]], tostring( math.ceil( math.random( 1, 100 ) ) ) )
    self:NewEvent( PSBT_AREAS.STATIC,       true, [[/esoui/art/icons/icon_missing.dds]], tostring( math.ceil( math.random( 1, 100 ) ) ) )
    self:NewEvent( PSBT_AREAS.NOTIFICATION, true, [[/esoui/art/icons/icon_missing.dds]], tostring( math.ceil( math.random( 1, 100 ) ) ) )
end

function PSBT:RegisterForEvent( event, scope, callback )
    if ( not self._events[ event ] ) then
        self._events[ event ] = {}
    end

    tinsert( self._events[ event ], { [ 'scope' ] = scope, [ 'func' ] = callback } )

    self.control:RegisterForEvent( event, function( ... ) self:OnEvent( ... ) end )
end

function PSBT:OnEvent( event, ... ) 
    if ( not self._events[ event ] ) then
        return
    end

    local callbacks = self._events[ event ]
    for _,v in pairs( callbacks ) do
        v.scope[ v.func ]( v.scope, ... )
    end
end

function PSBT:UnregisterForEvent( event, scope, callback )
    if ( not self._events[ event ] ) then
        return
    end

    local callbacks = self._events[ event ]
    local i = 1
    while( i <= #callbacks ) do
        local listener = callbacks[ i ]
        if ( listener.scope == scope and listener.func == callback ) then
            tremove( callbacks, i )
        else
            i = i + 1
        end
    end

    if ( #callbacks == 0 ) then
        self.control:UnregisterForEvent( event, function( ... ) self:OnEvent( ... ) end )
    end
end

function PSBT:NewEvent( scrollArea, sticky, icon, text, color )
    local entry = self.LabelFactory:AcquireObject()
    local area = self._areas[ scrollArea ]
    if ( not area ) then 
        return
    end

    if ( not color ) then
        color = self:GetSetting( PSBT_SETTINGS.normal_color )
    end

    if ( sticky ) then
        entry.label:SetFont( self:FormatFont( self:GetSetting( PSBT_SETTINGS.sticky_font ) ) )
        entry.control:SetDrawTier( DT_HIGH )
    else
        entry.label:SetFont( self:FormatFont( self:GetSetting( PSBT_SETTINGS.normal_font ) ) )
        entry.control:SetDrawTier( DT_LOW )
    end

    entry:SetExpire( -1 )
    entry:SetText( text ) 
    entry:SetTexture( icon )
    entry:SetColor( color )

    area:Push( entry, sticky, direction )
end