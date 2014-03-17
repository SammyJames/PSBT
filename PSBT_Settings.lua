local PSBT_Module   = PSBT_Module
local PSBT_Settings = PSBT_Module:Subclass()
local CBM           = CALLBACK_MANAGER

local PSBT_MODULES  = PSBT_MODULES
local PSBT_EVENTS   = PSBT_EVENTS
local PSBT_AREAS    = PSBT_AREAS

local ZO_SavedVars  = ZO_SavedVars

local RIGHT = RIGHT
local LEFT = LEFT
local CENTER = CENTER

local defaults = 
{
    [ PSBT_AREAS.INCOMING       ] = { RIGHT,  CENTER, -300,  150   },
    [ PSBT_AREAS.OUTGOING       ] = { LEFT,   CENTER, 300,   150   },
    [ PSBT_AREAS.STATIC         ] = { CENTER, CENTER, 0,     -300  },
    [ PSBT_AREAS.NOTIFICATION   ] = { CENTER, CENTER, 0,     450   }
}

function PSBT_Settings:Initialize( ... )
    PSBT_Module.Initialize( self, ... )

    self.db = ZO_SavedVars:New( 'PSBT_DB', 1.5, nil, defaults )
    self.profile = self.db:GetInterfaceForCharacter( GetDisplayName(), GetUnitName( 'player' ) )
end

function PSBT_Settings:GetSetting( identity )
    if ( not self.profile[ identity ] ) then
        return nil
    end

    return self.profile[ identity ]
end

function PSBT_Settings:SetSetting( identity, value )
    self.profile[ identity ] = value
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.SETTINGS, PSBT_Settings:New( psbt ) )
    end)