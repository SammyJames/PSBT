local PSBT_LowSomething     = PSBT_Module:Subclass()
PSBT_LowSomething._pools    = {}
local CBM                   = CALLBACK_MANAGER

local threshold = 0.33

function PSBT_LowSomething:Initialize( ... )
    PSBT_Module.Initialize( self, ... )

    self._pools[POWERTYPE_HEALTH]        = 0
    self._pools[POWERTYPE_MAGICKA]       = 0
    self._pools[POWERTYPE_STAMINA]       = 0
    self._pools[POWERTYPE_MOUNT_STAMINA] = 0

    self:RegisterForEvent( EVENT_POWER_UPDATE, function( event, ... ) self:OnPowerUpdate( ... ) end )
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

    self:NewEvent( PSBT_AREAS.STATIC, false, nil, string )
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.LOW, PSBT_LowSomething:New( psbt ) )
    end)