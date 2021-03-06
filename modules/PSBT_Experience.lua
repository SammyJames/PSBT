local PSBT              = PSBT
local ModuleProto       = PSBT.ModuleProto
local PSBT_Experience   = ModuleProto:Subclass()
local CBM               = CALLBACK_MANAGER

local zo_min            = zo_min
local tostring          = tostring

local PSBT_AREAS        = PSBT.AREAS
local PSBT_EVENTS       = PSBT.EVENTS
local PSBT_MODULES      = PSBT.MODULES

local kVersion          = 1.0

function PSBT_Experience:Initialize( ... )
    ModuleProto.Initialize( self, ... )

    self._currentExperience = GetUnitXP( 'player' )

    self:RegisterForEvent( EVENT_EXPERIENCE_UPDATE, 'OnXPUpdated' )
end

function PSBT_Experience:Shutdown()
    self:UnregisterForEvent( EVENT_EXPERIENCE_UPDATE, 'OnXPUpdated' )

    ModuleProto.Shutdown( self )
end

function PSBT_Experience:OnXPUpdated( tag, exp, maxExp, reason  )
    if ( tag ~= 'player' ) then
        return
    end

    local xp = zo_min( exp, maxExp )

    if ( self._currentExperience == xp ) then
        return 
    end

    local gain = xp - self._currentExperience
    self._currentExperience = xp

    if ( gain <= 0 ) then
        return
    end
    self:NewEvent( PSBT_AREAS.NOTIFICATION, true, [[/psbt/textures/exp.dds]], tostring( gain ) )
end


CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.XP, PSBT_Experience, kVersion )
    end)