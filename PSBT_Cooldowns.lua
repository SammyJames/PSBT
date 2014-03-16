local PSBT_Cooldowns        = PSBT_Module:Subclass()
local CBM = CALLBACK_MANAGER

function PSBT_Cooldowns:Initialize( ... )
    PSBT_Module.Initialize( self, ... )

    self:RegisterForEvent( EVENT_ABILITY_COOLDOWN_UPDATED, function( abilityId ) self:OnAbilityCooldownUpdated( abilityId ) end )
end

function PSBT_Cooldowns:OnAbilityCooldownUpdated( abilityId )

end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.COOLDOWNS, PSBT_Cooldowns:New( psbt ) )
    end)