local PSBT_Module           = PSBT_Module
local PSBT_Combat           = PSBT_Module:Subclass()
PSBT_Combat._iconRegistry   = setmetatable( {}, { __mode = 'kv' } )
PSBT_Combat._stackingIn     = {}
PSBT_Combat._stackingOut    = {}
local CBM                   = CALLBACK_MANAGER

local MAX_EVENTS            = 15
local STACK_TIME            = 0.85
local PlayerName            = GetUnitName( 'player' )
local PlayerNameRaw         = GetRawUnitName( 'player' )

local COMBAT_UNIT_TYPE_PLAYER       = COMBAT_UNIT_TYPE_PLAYER
local COMBAT_UNIT_TYPE_PLAYER_PET   = COMBAT_UNIT_TYPE_PLAYER_PET
local COMBAT_UNIT_TYPE_NONE         = COMBAT_UNIT_TYPE_NONE

local PSBT_AREAS            = PSBT_AREAS
local PSBT_EVENTS           = PSBT_EVENTS

local zo_strformat          = zo_strformat
local GetString             = GetString
local select                = select          
local kVerison              = 1.0
local NonContiguousCount    = NonContiguousCount

local function IsPlayerType( targetType )
    return targetType == COMBAT_UNIT_TYPE_PLAYER or
           targetType == COMBAT_UNIT_TYPE_PLAYER_PET
end

local function IsPlayer( targetType, targetName )
    if ( IsPlayerType( targetType ) ) then
        return true
    end

    if ( targetType == COMBAT_UNIT_TYPE_NONE ) then
        return targetName == PlayerName or targetName == PlayerNameRaw
    end

    return false
end

local static_events =
{
    [ ACTION_RESULT_CANT_SEE_TARGET ] = true,
    [ ACTION_RESULT_KILLING_BLOW ] = true,
    [ ACTION_RESULT_CANNOT_USE ] = true,
    [ ACTION_RESULT_BUSY ] = true,
    [ ACTION_RESULT_FALLING ] = true,
}

local critical_events = 
{
    [ ACTION_RESULT_DOT_TICK_CRITICAL ] = true,
    [ ACTION_RESULT_CRITICAL_DAMAGE ] = true,
    [ ACTION_RESULT_CRITICAL_HEAL ] = true,
    [ ACTION_RESULT_HOT_TICK_CRITICAL ] = true,
    [ ACTION_RESULT_INTERRUPT ] = true,
    [ ACTION_RESULT_BLOCKED ] = true,
    [ ACTION_RESULT_BLOCKED_DAMAGE ] = true,
    [ ACTION_RESULT_ABSORBED ] = true,
    [ ACTION_RESULT_RESIST ] = true,
}

local damage_events =
{
    [ ACTION_RESULT_CRITICAL_DAMAGE ] = true,
    [ ACTION_RESULT_DAMAGE ] = true,
    [ ACTION_RESULT_DAMAGE_SHIELDED ] = true,
    [ ACTION_RESULT_DOT_TICK ] = true,
    [ ACTION_RESULT_DOT_TICK_CRITICAL ] = true,
    [ ACTION_RESULT_FALL_DAMAGE ] = true,
}

local healing_events =
{
    [ ACTION_RESULT_CRITICAL_HEAL ] = true,
    [ ACTION_RESULT_HEAL ] = true,
    [ ACTION_RESULT_HOT_TICK ] = true,
    [ ACTION_RESULT_HOT_TICK_CRITICAL ] = true,
}


function PSBT_Combat:Initialize( ... )
    PSBT_Module.Initialize( self, ... )

    self._buffer    = ZO_CircularBuffer:New( DEFAULT_MAX_BUFFERED_EVENTS )
    self._index     = 1
    self._free      = nil

    self:RefreshAbilityIcons()
    self:Initialize_Text()

    self:RegisterForEvent( EVENT_COMBAT_EVENT,          function( ... ) self:OnCombatEvent( ... )    end )
    self:RegisterForEvent( EVENT_SKILLS_FULL_UPDATE,    function() self:RefreshAbilityIcons()        end )
    self:RegisterForEvent( EVENT_SKILL_POINTS_CHANGED,  function() self:RefreshAbilityIcons()        end )
end

function PSBT_Combat:Initialize_Text()
    self._text = 
    {
        [ ACTION_RESULT_ABSORBED ]          = GetString( _G[ PSBT_STRINGS.ABSORED ] ),
        [ ACTION_RESULT_BLADETURN ]         = GetString( _G[ PSBT_STRINGS.BLADE_TURN ] ),
        [ ACTION_RESULT_BLOCKED ]           = GetString( _G[ PSBT_STRINGS.BLOCK ] ),
        [ ACTION_RESULT_BLOCKED_DAMAGE ]    = GetString( _G[ PSBT_STRINGS.BLOCK_DAMAGE ] ),
        [ ACTION_RESULT_DAMAGE_SHIELDED ]   = GetString( _G[ PSBT_STRINGS.SHIELDED ] ),
        [ ACTION_RESULT_CANT_SEE_TARGET ]   = GetString( _G[ PSBT_STRINGS.CANNOT_SEE ] ),
        [ ACTION_RESULT_CRITICAL_DAMAGE ]   = GetString( _G[ PSBT_STRINGS.DAMAGE_CRIT ] ),
        [ ACTION_RESULT_CRITICAL_HEAL ]     = GetString( _G[ PSBT_STRINGS.HEALING_CRIT ] ),
        [ ACTION_RESULT_DAMAGE ]            = GetString( _G[ PSBT_STRINGS.DAMAGE ] ),
        [ ACTION_RESULT_DEFENDED ]          = GetString( _G[ PSBT_STRINGS.DEFENDED ] ),
        [ ACTION_RESULT_DOT_TICK ]          = GetString( _G[ PSBT_STRINGS.DAMAGE ] ),
        [ ACTION_RESULT_DOT_TICK_CRITICAL ] = GetString( _G[ PSBT_STRINGS.DAMAGE_CRIT ] ),
        [ ACTION_RESULT_HEAL ]              = GetString( _G[ PSBT_STRINGS.HEALING ] ),
        [ ACTION_RESULT_HOT_TICK ]          = GetString( _G[ PSBT_STRINGS.HEALING ] ),
        [ ACTION_RESULT_HOT_TICK_CRITICAL ] = GetString( _G[ PSBT_STRINGS.HEALING_CRIT ] ),
        [ ACTION_RESULT_DODGED ]            = GetString( _G[ PSBT_STRINGS.DODGE ] ),
        [ ACTION_RESULT_MISS ]              = GetString( _G[ PSBT_STRINGS.MISS ] ),
        [ ACTION_RESULT_PARRIED ]           = GetString( _G[ PSBT_STRINGS.PARRY ] ),
        [ ACTION_RESULT_RESIST ]            = GetString( _G[ PSBT_STRINGS.RESIST ] ),
        [ ACTION_RESULT_PARTIAL_RESIST ]    = GetString( _G[ PSBT_STRINGS.RESIST_PARTIAL ] ),
        [ ACTION_RESULT_FALL_DAMAGE ]       = GetString( _G[ PSBT_STRINGS.FALL_DAMAGE ] ),
        [ ACTION_RESULT_KILLING_BLOW ]      = GetString( _G[ PSBT_STRINGS.KILLING_BLOW ] ),
        [ ACTION_RESULT_BUSY ]              = GetString( _G[ PSBT_STRINGS.BUSY ] ),
        [ ACTION_RESULT_FALLING ]           = GetString( _G[ PSBT_STRINGS.FALLING ] ),
        [ ACTION_RESULT_DISORIENTED ]       = GetString( _G[ PSBT_STRINGS.DISORIENTED ] ),
        [ ACTION_RESULT_DISARMED ]          = GetString( _G[ PSBT_STRINGS.DISARMED ] ),
        [ ACTION_RESULT_FEARED ]            = GetString( _G[ PSBT_STRINGS.FEARED ] ),
        [ ACTION_RESULT_IMMUNE ]            = GetString( _G[ PSBT_STRINGS.IMMUNE ] ),
        [ ACTION_RESULT_INTERRUPT ]         = GetString( _G[ PSBT_STRINGS.INTERRUPT ] ),
        [ ACTION_RESULT_INTERCEPTED ]       = GetString( _G[ PSBT_STRINGS.INTERCEPTED ] ),
        [ ACTION_RESULT_POWER_ENERGIZE ]    = GetString( _G[ PSBT_STRINGS.ENERGIZE ] ),
    }
end

function PSBT_Combat:RefreshAbilityIcons()
    for i=1,GetNumAbilities() do
        local name, icon = GetAbilityInfoByIndex( i )
        self._iconRegistry[ name ] = icon
    end
end

function PSBT_Combat:OnCombatEvent( ... )
    local result = select( 1, ... )
    if ( not self._text[ result ] ) then 
        return
    end

    local args = { ... }

    -- did we get hit or do something?
    if ( IsPlayer( args[ 7 ], args[ 6 ] ) 
      or IsPlayer( args[ 9 ], args[ 8 ] ) ) then
    
        if ( self._free ) then
            local argCount = #args
            for i = 1, argCount do
                self._free[ i ] = args[ i ]
            end
            
            for i = #self._free, argCount + 1, -1 do
                self._free[ i ] = nil
            end
            
            self._free = self._buffer:Add( self._free )
        else
            self._free = self._buffer:Add( args )
        end

        self._index = self._index - 1
    end
end

function PSBT_Combat:StackEvent( result, _, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType )
    local stack = nil

    if ( IsPlayer( targetType, targetName ) ) then
        stack = self._stackingIn
    elseif ( IsPlayer( sourceType, sourceName ) ) then
        stack = self._stackingOut
    end

    if ( not stack[ result ] ) then
        stack[ result ] = {}
    end

    if ( not stack[ result ][ abilityName ] ) then
        stack[result][ abilityName ] = 
        { 
            lastTick    = 0, 
            result      = result,
            abilityName = abilityName,
            sourceName  = sourceName, 
            sourceType  = sourceType, 
            targetName  = targetName, 
            targetType  = targetType, 
            hitValue    = 0, 
            powerType   = powerType, 
            damageType  = damageType 
        }
    end

    local entry     = stack[result][ abilityName ]
    entry.lastTick  = GetFrameTimeMilliseconds()
    entry.hitValue  = entry.hitValue + hitValue
end

function PSBT_Combat:OnUpdate()
    if ( self._index <= 0 ) then
        self._index = 1
    end

    local bufferSize = self._buffer:Size()
    local endPoint = zo_min( self._index + MAX_EVENTS, bufferSize )
    for i = self._index, endPoint do
        local entry = self._buffer:At( i )
        if ( entry ) then
            self:StackEvent( unpack( entry ) ) 
        end
    end 

    if ( endPoint >= bufferSize ) then
        self._buffer:Clear()
    else
        self._index = endPoint + 1
    end

    -- Dispatch
    if ( NonContiguousCount( self._stackingOut ) ) then
        self:ProcessStackedEvents( self._stackingOut, GetFrameTimeMilliseconds() )
    end

    if ( NonContiguousCount( self._stackingIn ) ) then
        self:ProcessStackedEvents( self._stackingIn, GetFrameTimeMilliseconds() )
    end
end

function PSBT_Combat:ProcessStackedEvents( stacking, frameTime )
    for result,entries in pairs( stacking ) do
        for k,v in pairs( entries ) do
            if ( frameTime - v.lastTick > STACK_TIME ) then
                self:DispatchEvent( result, v )
                stacking[ result ][ k ] = nil
            end
        end
    end
end

--integer result, bool isError, string abilityName, integer abilityGraphic, integer abilityActionSlotType, string sourceName, integer sourceType, string targetName, integer targetType, integer hitValue, integer powerType, integer damageType, bool log
function PSBT_Combat:DispatchEvent( result, combatEvent )
    local textFormat = self._text[ result ]
    if ( not textFormat ) then
        return
    end

    local area = PSBT_EVENTS.STATIC
    local crit = critical_events[ result ]
    local icon = self._iconRegistry[ combatEvent.abilityName ]
    local color = PSBT_SETTINGS.normal_color
    local text = ''

    if ( not static_events[ result ] ) then
        if ( IsPlayer( combatEvent.targetType, combatEvent.targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( combatEvent.sourceType, combatEvent.sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end
    end

    if ( healing_events[ result ] ) then
        color = PSBT_SETTINGS.healing_color
    elseif( damage_events[ result ] ) then
        color = PSBT_SETTINGS.damage_color
    end

    if ( result == ACTION_RESULT_POWER_ENERGIZE or result == ACTION_RESULT_POWER_DRAIN ) then
        local mechanicName = GetString( 'SI_COMBATMECHANICTYPE', combatEvent.powerType )
        text = zo_strformat( textFormat, combatEvent.hitValue, mechanicName )
    else
        text = zo_strformat( textFormat, combatEvent.hitValue )
    end

    self:NewEvent( area, crit, icon, text, self._root:GetSetting( color ) )
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.COMBAT, PSBT_Combat:New( psbt ), kVerison )
    end)