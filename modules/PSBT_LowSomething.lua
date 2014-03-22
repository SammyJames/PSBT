local PSBT_Module           = PSBT_Module
local PSBT_LowSomething     = PSBT_Module:Subclass()
PSBT_LowSomething._pools    = {}
local CBM                   = CALLBACK_MANAGER

local threshold             = 0.33

local PSBT_AREAS            = PSBT_AREAS
local PSBT_MODULES          = PSBT_MODULES
local PSBT_EVENTS           = PSBT_EVENTS

local POWERTYPE_HEALTH      = POWERTYPE_HEALTH
local POWERTYPE_MAGICKA     = POWERTYPE_MAGICKA
local POWERTYPE_STAMINA     = POWERTYPE_STAMINA
local POWERTYPE_MOUNT_STAMINA = POWERTYPE_MOUNT_STAMINA

function PSBT_LowSomething:Initialize( ... )
    PSBT_Module.Initialize( self, ... )

    self._pools[ POWERTYPE_HEALTH ]        = 0
    self._pools[ POWERTYPE_MAGICKA ]       = 0
    self._pools[ POWERTYPE_STAMINA ]       = 0
    self._pools[ POWERTYPE_MOUNT_STAMINA ] = 0

    self:RegisterForEvent( EVENT_POWER_UPDATE, function( ... ) self:OnPowerUpdate( ... ) end )
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

    local string = nil
    if ( powerType == POWERTYPE_HEALTH ) then
        string = 'Health Low! (|cF2920C' .. powerPool .. '|r)'
    elseif ( powerType == POWERTYPE_MAGICKA ) then
        string = 'Magicka Low! (|cCC0CF2' .. powerPool .. '|r)'
    elseif ( powerType == POWERTYPE_STAMINA ) then
        string = 'Stamina Low! (|c0CF2B9' .. powerPool .. '|r)'
    elseif ( powerType == POWERTYPE_MOUNT_STAMINA ) then
        string = 'Mount Stamina Low! (|c0CF2B9' .. powerPool .. '|r)'
    end

    PlaySound( 'Quest_StepFailed' )
    self:NewEvent( PSBT_AREAS.STATIC, true, nil, string )
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.LOW, PSBT_LowSomething:New( psbt ) )
    end)