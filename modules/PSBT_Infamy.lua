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
end

function PSBT_Infamy:Shutdown()
    self:UnregisterForEvent( EVENT_JUSTICE_INFAMY_UPDATED, 'OnInfamyUpdated' )

    -- do this after you unregister events
    ModuleProto.Shutdown( self )
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