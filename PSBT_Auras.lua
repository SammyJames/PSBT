local PSBT_Auras = PSBT_Module:Subclass()
local CBM = CALLBACK_MANAGER

function PSBT_Auras:Initialize( ... )  
    PSBT_Module.Initialize( self, ... )

    self:RegisterForEvent( EVENT_EFFECT_CHANGED, function( eventCode, ... ) self:OnEffectChanged( ... ) end )
end

function PSBT_Auras:OnEffectChanged( changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType )
    if ( unitTag ~= 'player' ) then
        return
    end

    print( 'OnEffectChanged' )

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