local PSBT                  = PSBT
local ModuleProto           = PSBT.ModuleProto
local PSBT_Auras            = ModuleProto:Subclass()
local CBM                   = CALLBACK_MANAGER
local kVerison = 1.0

local EFFECT_RESULT_FADED   = EFFECT_RESULT_FADED
local EFFECT_RESULT_GAINED  = EFFECT_RESULT_GAINED

local PSBT_EVENTS           = PSBT.EVENTS
local PSBT_AREAS            = PSBT.AREAS
local PSBT_MODULES          = PSBT.MODULES
local PSBT_STRINGS          = PSBT.STRINGS
local zo_strformat          = zo_strformat

function PSBT_Auras:Initialize( ... )
    ModuleProto.Initialize( self, ... )

    self:RegisterForEvent( EVENT_EFFECT_CHANGED, 'OnEffectChanged' )

    self._gained = GetString( _G[ PSBT_STRINGS.AURA_GAINED ] )
    self._fades = GetString( _G[ PSBT_STRINGS.AURA_FADES ] )
end

function PSBT_Auras:Shutdown()
    self:UnregisterForEvent( EVENT_EFFECT_CHANGED, 'OnEffectChanged' )

    -- do this after you unregister events
    ModuleProto.Shutdown( self )
end

function PSBT_Auras:OnEffectChanged( changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType )
    if ( unitTag ~= 'player' ) then
        return
    end

    if ( iconName == '/esoui/art/icons/ability_warrior_008.dds') then
        return
    end

    if ( changeType == EFFECT_RESULT_FADED ) then
        self:Remove( effectName, iconName )
    elseif ( changeType == EFFECT_RESULT_GAINED ) then
        self:Add( effectName, iconName )
    end
end

function PSBT_Auras:Add( name, iconName )
    self:NewEvent( PSBT_AREAS.NOTIFICATION, true, iconName, zo_strformat( self._gained, name ) )
end

function PSBT_Auras:Remove( name, iconName )
    self:NewEvent( PSBT_AREAS.NOTIFICATION, true, iconName, zo_strformat( self._fades, name ) )
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED,
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.AURAS, PSBT_Auras, kVerison )
    end)


