local PSBT                  = PSBT
local ModuleProto           = PSBT.ModuleProto
local PSBT_Infamy           = ModuleProto:Subclass()
local CBM                   = CALLBACK_MANAGER
local kVerison              = 1.0

local PSBT_EVENTS           = PSBT.EVENTS
local PSBT_MODULES          = PSBT.MODULES
local PSBT_AREAS            = PSBT.AREAS
local PSBT_STRINGS          = PSBT.STRINGS

function PSBT_Infamy:Initialize( ... )
    ModuleProto.Initialize( self, ... )

    self._Format = GetString( _G[ PSBT_STRINGS.INFAMY ] )

    self:RegisterForEvent( EVENT_JUSTICE_INFAMY_UPDATED, 'OnInfamyUpdated' )
    self:RegisterForEvent( EVENT_PLAYER_ACTIVATED, 'OnPlayerActivated' )

    if ( HUD_INFAMY_METER ) then
        HUD_INFAMY_METER.control:SetHidden( true )

        self._OldUpdate = HUD_INFAMY_METER[ 'OnInfamyUpdated' ]
        self._OldRequestHidden = HUD_INFAMY_METER[ 'RequestHidden' ]

        HUD_INFAMY_METER[ 'OnInfamyUpdated' ] = function( ... ) end
        HUD_INFAMY_METER[ 'RequestHidden' ] = function( ... ) end
    end

end

function PSBT_Infamy:Shutdown()
    if ( HUD_INFAMY_METER ) then
        HUD_INFAMY_METER.control:SetHidden( false )

        HUD_INFAMY_METER[ 'OnInfamyUpdated' ] = self._OldUpdate
        self._OldUpdate = nil

        HUD_INFAMY_METER[ 'RequestHidden' ] = self._OldRequestHidden
        self._OldRequestHidden = nil
    end

    self:UnregisterForEvent( EVENT_JUSTICE_INFAMY_UPDATED, 'OnInfamyUpdated' )
    self:UnregisterForEvent( EVENT_PLAYER_ACTIVATED, 'OnPlayerActivated' )

    -- do this after you unregister events
    ModuleProto.Shutdown( self )
end

function PSBT_Infamy:OnPlayerActivated()
    self:OnInfamyUpdated( 0, GetInfamy(), GetInfamyLevel( 0 ), GetInfamyLevel( GetInfamy() ) )
end

function PSBT_Infamy:OnInfamyUpdated( OldInfamy, NewInfamy, OldLevel, NewLevel )
    if ( NewLevel ~= OldLevel ) then
        local text = zo_strformat( SI_JUSTICE_INFAMY_LEVEL_CHANGED, GetString( 'SI_INFAMYTHRESHOLDSTYPE' , NewLevel ) )
        self:NewEvent( PSBT_AREAS.NOTIFICATION, true, [[esoui/art/stats/infamy_kos_icon-notification.dds]], text )
    end

    local gain = OldInfamy < NewInfamy
    local difference = NewInfamy - OldInfamy

    local area = PSBT_AREAS.OUTGOING
    if ( not gain ) then
        area = PSBT_AREAS.INCOMING
    end

    self:NewEvent( area, false, [[esoui/art/stats/infamy_kos_icon-notification.dds]], zo_strformat( self._Format, difference ) )
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED,
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.INFAMY, PSBT_Infamy, kVerison )
    end )

