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

    self:RegisterForEvent( EVENT_EXPERIENCE_GAIN, 'OnXPUpdated' )
end

function PSBT_Experience:Shutdown()
    self:UnregisterForEvent( EVENT_EXPERIENCE_GAIN, 'OnXPUpdated' )

    ModuleProto.Shutdown( self )
end

function PSBT_Experience:OnXPUpdated( _, _, previousExperience, currentExperience  )
    self:NewEvent( PSBT_AREAS.NOTIFICATION, true, [[/psbt/textures/exp.dds]], tostring( currentExperience - previousExperience ) )
end


CBM:RegisterCallback( PSBT_EVENTS.LOADED,
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.XP, PSBT_Experience, kVersion )
    end )
