local PSBT                  = PSBT
local ModuleProto           = PSBT.ModuleProto
local PSBT_LowSomething     = ModuleProto:Subclass()
PSBT_LowSomething._pools    = {}
PSBT_LowSomething._colors   = {}
local CBM                   = CALLBACK_MANAGER

local threshold             = 0.33

local PSBT_AREAS            = PSBT.AREAS
local PSBT_MODULES          = PSBT.MODULES
local PSBT_EVENTS           = PSBT.EVENTS
local PSBT_STRINGS          = PSBT.STRINGS

local POWERTYPE_HEALTH      = POWERTYPE_HEALTH
local POWERTYPE_MAGICKA     = POWERTYPE_MAGICKA
local POWERTYPE_STAMINA     = POWERTYPE_STAMINA
local POWERTYPE_MOUNT_STAMINA = POWERTYPE_MOUNT_STAMINA

local kVersion              = 1.0

function PSBT_LowSomething:Initialize( ... )
    ModuleProto.Initialize( self, ... )

    self._lowText = GetString( _G[ PSBT_STRINGS.LOW_SOMETHING ] )

    self._colors[ POWERTYPE_HEALTH ]        = ZO_ColorDef:New( 'D8594B' )
    self._colors[ POWERTYPE_MAGICKA ]       = ZO_ColorDef:New( '92CEF8' )
    self._colors[ POWERTYPE_STAMINA ]       = ZO_ColorDef:New( '5C9D8E' )
    self._colors[ POWERTYPE_MOUNT_STAMINA ] = ZO_ColorDef:New( '5C9D8E' )

    self._pools[ POWERTYPE_HEALTH ]        = 0
    self._pools[ POWERTYPE_MAGICKA ]       = 0
    self._pools[ POWERTYPE_STAMINA ]       = 0
    self._pools[ POWERTYPE_MOUNT_STAMINA ] = 0

    self:RegisterForEvent( EVENT_POWER_UPDATE, 'OnPowerUpdate' )
end

function PSBT_LowSomething:Shutdown()
    self:UnregisterForEvent( EVENT_POWER_UPDATE, 'OnPowerUpdate' )

    ModuleProto.Shutdown( self )
end

function PSBT_LowSomething:OnPowerUpdate( unit, powerPoolIndex, powerType, powerPool, powerPoolMax )
    if ( unit ~= 'player' ) then
        return
    end

    if ( powerPool == 0 ) then
        return
    end

    if ( not self._pools[ powerType ] ) then
        return
    end

    local newValue = powerPool / powerPoolMax

    if ( self._pools[ powerType ] < threshold
        or newValue > self._pools[ powerType ]
        or newValue > threshold ) then

        self._pools[ powerType ] = newValue
        return
    end

    self._pools[ powerType ] = newValue

    local mechanicName = GetString( 'SI_COMBATMECHANICTYPE', powerType )
    local color = self._colors[ powerType ]

    local string = zo_strformat( self._lowText, mechanicName, color:Colorize( tostring( powerPool ) ) )

    PlaySound( 'Quest_StepFailed' )
    self:NewEvent( PSBT_AREAS.STATIC, true, nil, string )
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED,
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.LOW, PSBT_LowSomething, kVersion )
    end)

