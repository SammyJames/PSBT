local PSBT_Experience = PSBT_Module:Subclass()
local CBM = CALLBACK_MANAGER


function PSBT_Experience:Initialize( ... )
    PSBT_Module.Initialize( self, ... )

    self._currentExperience = GetUnitXP( 'player' )

    self:RegisterForEvent( EVENT_EXPERIENCE_UPDATE, function( event, ... ) self:OnXPUpdated( ... )     end )
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

    if ( gain <= 0 ) then return end
    self:NewEvent( PSBT_AREAS.INCOMING, false, nil, '+' .. tostring( gain ) .. ' XP' )
end



CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.XP, PSBT_Experience:New( psbt ) )
    end)