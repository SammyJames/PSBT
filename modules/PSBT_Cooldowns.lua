local PSBT                  = PSBT
local ModuleProto           = PSBT.ModuleProto
local PSBT_Cooldowns        = ModuleProto:Subclass()
local CBM                   = CALLBACK_MANAGER

local PSBT_EVENTS           = PSBT_EVENTS
local PSBT_MODULES          = PSBT_MODULES

local kVerison              = 1.0

function PSBT_Cooldowns:Initialize( ... )
    ModuleProto.Initialize( self, ... )

    self:RegisterForEvent( EVENT_ABILITY_COOLDOWN_UPDATED, function( abilityId ) self:OnAbilityCooldownUpdated( abilityId ) end )
    self:RegisterForEvent( EVENT_ACTION_UPDATE_COOLDOWNS, function() self:OnActionCooldownUpdate() end )
end

function PSBT_Cooldowns:OnAbilityCooldownUpdated( abilityId )
end

function PSBT_Cooldowns:OnActionCooldownUpdate()
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.COOLDOWNS, PSBT_Cooldowns:New( psbt ), kVerison )
    end )