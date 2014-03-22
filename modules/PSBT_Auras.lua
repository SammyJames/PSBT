local PSBT_Module           = PSBT_Module
local PSBT_Auras            = PSBT_Module:Subclass()
local CBM                   = CALLBACK_MANAGER

local EFFECT_RESULT_FADED   = EFFECT_RESULT_FADED
local EFFECT_RESULT_GAINED  = EFFECT_RESULT_GAINED

local PSBT_EVENTS           = PSBT_EVENTS
local PSBT_AREAS            = PSBT_AREAS
local PSBT_MODULES          = PSBT_MODULES

function PSBT_Auras:Initialize( ... )  
    PSBT_Module.Initialize( self, ... )

    self:RegisterForEvent( EVENT_EFFECT_CHANGED, function( ... ) self:OnEffectChanged( ... ) end )
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
    self:NewEvent( PSBT_AREAS.NOTIFICATION, true, iconName, name .. ' Gained' )
end

function PSBT_Auras:Remove( name, iconName )
    self:NewEvent( PSBT_AREAS.NOTIFICATION, true, iconName, name .. ' Fades' )
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.AURAS, PSBT_Auras:New( psbt ) )
    end)