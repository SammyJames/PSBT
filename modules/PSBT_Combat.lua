local PSBT_Module           = PSBT_Module
local PSBT_Combat           = PSBT_Module:Subclass()
PSBT_Combat._iconRegistry   = setmetatable( {}, { __mode = 'kv' } )
local CBM                   = CALLBACK_MANAGER

local MAX_EVENTS            = 15
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

local combat_events =
{
    [ ACTION_RESULT_ABSORBED ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( 'Absorbed <<1>>', abilityName ), area, false
    end,
    [ ACTION_RESULT_BLADETURN ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( 'Blocked <<1>>', abilityName ), area, false
    end,
    [ ACTION_RESULT_BLOCKED ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( 'Blocked <<1>>', abilityName ), area, false
    end,
    [ ACTION_RESULT_BLOCKED_DAMAGE ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue, damageType )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( 'Blocked <<1>>', hitValue ), area, false
    end,
    [ ACTION_RESULT_CANT_SEE_TARGET ] = function( ... )
        return 'Can\'t See Target!', PSBT_AREAS.STATIC, true
    end,
    [ ACTION_RESULT_CRITICAL_DAMAGE ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue, damageType )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( '<<1>>!', hitValue ), area, true
    end,
    [ ACTION_RESULT_CRITICAL_HEAL ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( '+<<1>>!', hitValue ), area, true
    end,
    [ ACTION_RESULT_DAMAGE ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue, damageType )
        local area = nil
        local format = '<<1>>'
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
            format = '-' .. format
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( format, hitValue ), area, false
    end,
    [ ACTION_RESULT_DAMAGE_SHIELDED ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue, damageType )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( 'Shielded <<1>>', hitValue ), area, false
    end,
    [ ACTION_RESULT_DEFENDED ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue, damageType )
        local area = nil
        if ( IsPlayer( targetType ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( 'Defended <<1>>', hitValue ), area, false
    end,
    [ ACTION_RESULT_DOT_TICK ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue, damageType )
        local area = nil
        local format = '<<1>>'
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
            format = '-' .. format
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( format, hitValue ), area, false
    end,
    [ ACTION_RESULT_DOT_TICK_CRITICAL ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue, damageType )
        local area = nil
        local format = '<<1>>!'
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
            format = '-' .. format
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( format, hitValue ), area, true
    end,
    [ ACTION_RESULT_HEAL ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( '+<<1>>' , hitValue ), area, false
    end,
    [ ACTION_RESULT_HOT_TICK ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( '+<<1>>', hitValue ), area, false
    end,
    [ ACTION_RESULT_HOT_TICK_CRITICAL ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( '+<<1>>!', hitValue ), area, true
    end,
    [ ACTION_RESULT_DODGED ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( 'Dodged <<1>>', abilityName ), area, false
    end,
    [ ACTION_RESULT_MISS ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return 'Miss!', area, false
    end,
    [ ACTION_RESULT_PARRIED ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( 'Parried <<1>>!', abilityName ), area, false
    end,
    [ ACTION_RESULT_RESIST ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( 'Resisted <<1>>!', abilityName ), area, false
    end,
    [ ACTION_RESULT_PARTIAL_RESIST ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( 'Partially Resisted <<1>>!', abilityName ), nil, false
    end,
    [ ACTION_RESULT_FALL_DAMAGE ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            return nil, nil, false
        end

        return zo_strformat( '-<<1>> falling', hitValue ), area, false
    end,
    [ ACTION_RESULT_KILLING_BLOW ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType )
        if ( IsPlayer( targetType, targetName ) ) then
            return 'Looks like you\'re dead.', PSBT_AREAS.STATIC, true
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            return zo_strformat( 'Killing Blow |cCC7D5E<<1>>|r!', targetName ), PSBT_AREAS.STATIC, true
        end

        return nil, nil, false
    end,

    [ ACTION_RESULT_POWER_DRAIN ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local mechanicName = GetString( 'SI_COMBATMECHANICTYPE', mechanicValue )
        return zo_strformat( '-<<1>> (<<2>>)', hitValue, mechanicName ), PSBT_AREAS.OUTGOING, false
    end,

    [ ACTION_RESULT_POWER_ENERGIZE ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local mechanicName = GetString( 'SI_COMBATMECHANICTYPE', mechanicValue )
        return zo_strformat( '+<<1>> (<<2>>)', hitValue, mechanicName ), PSBT_AREAS.INCOMING, false
    end,

    --[[[ ACTION_RESULT_BAD_TARGET ] = function( ... )
        return 'Bad Target', PSBT_AREAS.STATIC, true
    end,]]

    [ ACTION_RESULT_CANNOT_USE ] = function( ... )
        return 'Cannot Use', PSBT_AREAS.STATIC, true
    end,

    [ ACTION_RESULT_BUSY ] = function( ... )
        return 'Busy', PSBT_AREAS.STATIC, true
    end,   

    [ ACTION_RESULT_FALLING ] = function( ... )
        return 'You\'re falling', PSBT_AREAS.STATIC, true
    end,

    [ ACTION_RESULT_DISORIENTED ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        if ( IsPlayer( targetType, targetName ) ) then
            return 'Disoriented!', PSBT_AREAS.INCOMING, true
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            return 'Disoriented!', PSBT_AREAS.OUTGOING, true
        end
        return nil, nil, false
    end,

    [ ACTION_RESULT_DISARMED ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        if ( IsPlayer( targetType, targetName ) ) then
            return 'Disarmed!', PSBT_AREAS.OUTGOING, true
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            return 'Disarmed!', PSBT_AREAS.INCOMING, true
        end
        return nil, nil, false
    end,

    [ ACTION_RESULT_FEARED ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
         if ( IsPlayer( targetType, targetName ) ) then
            return 'Feared!', PSBT_AREAS.INCOMING, true
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            return 'Feared!', PSBT_AREAS.OUTGOING, true
        end
        return nil, nil, false
    end,

    [ ACTION_RESULT_IMMUNE ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        if ( IsPlayer( targetType, targetName ) ) then
            return 'Immune!', PSBT_AREAS.INCOMING, true
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            return 'Immune!', PSBT_AREAS.OUTGOING, true
        end
        return nil, nil, false
    end,

    [ ACTION_RESULT_INTERRUPT ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue ) 
        if ( IsPlayer( targetType, targetName ) ) then
            return 'Interrupt!', PSBT_AREAS.INCOMING, true
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            return 'Interrupt!', PSBT_AREAS.OUTGOING, true
        end
        return nil, nil, false
    end,

    --ACTION_RESULT_BEGIN
    --ACTION_RESULT_ABILITY_ON_COOLDOWN
    --ACTION_RESULT_BEGIN_CHANNEL
    --ACTION_RESULT_CASTER_DEAD
    --ACTION_RESULT_COMPLETE
    --ACTION_RESULT_DEBUFF
    --ACTION_RESULT_DIED
    --ACTION_RESULT_DIED_XP
    --ACTION_RESULT_EFFECT_FADED
    --ACTION_RESULT_EFFECT_GAINED
    --ACTION_RESULT_EFFECT_GAINED_DURATION
    --ACTION_RESULT_FAILED
    --ACTION_RESULT_FAILED_REQUIREMENTS
    --ACTION_RESULT_FAILED_SIEGE_CREATION_REQUIREMENTS
    --ACTION_RESULT_GRAVEYARD_DISALLOWED_IN_INSTANCE
    --ACTION_RESULT_GRAVEYARD_TOO_CLOSE
    --ACTION_RESULT_INSUFFICIENT_RESOURCE
    --ACTION_RESULT_INTERCEPTED
    --ACTION_RESULT_INTERRUPT
    --ACTION_RESULT_INVALID
    --ACTION_RESULT_INVALID_FIXTURE
    --ACTION_RESULT_INVALID_TERRAIN
    --ACTION_RESULT_IN_AIR
    --ACTION_RESULT_IN_COMBAT
    --ACTION_RESULT_IN_ENEMY_KEEP
    --ACTION_RESULT_LEVITATED
    --ACTION_RESULT_LINKED_CAST
    --ACTION_RESULT_MISSING_EMPTY_SOUL_GEM
    --ACTION_RESULT_MISSING_FILLED_SOUL_GEM
    --ACTION_RESULT_MOUNTED
    --ACTION_RESULT_MUST_BE_IN_OWN_KEEP
    --ACTION_RESULT_NOT_ENOUGH_INVENTORY_SPACE
    --ACTION_RESULT_NOT_ENOUGH_SPACE_FOR_SIEGE
    --ACTION_RESULT_NO_LOCATION_FOUND
    --ACTION_RESULT_NO_RAM_ATTACKABLE_TARGET_WITHIN_RANGE
    --ACTION_RESULT_NPC_TOO_CLOSE
    --ACTION_RESULT_OFFBALANCE
    --ACTION_RESULT_PACIFIED        
    --ACTION_RESULT_PRECISE_DAMAGE
    --ACTION_RESULT_QUEUED
    --ACTION_RESULT_RAM_ATTACKABLE_TARGETS_ALL_DESTROYED
    --ACTION_RESULT_RAM_ATTACKABLE_TARGETS_ALL_OCCUPIED
    --ACTION_RESULT_REFLECTED
    --ACTION_RESULT_REINCARNATING
    --ACTION_RESULT_ROOTED
    --ACTION_RESULT_SIEGE_LIMIT
    --ACTION_RESULT_SIEGE_TOO_CLOSE
    --ACTION_RESULT_STAGGERED
    --ACTION_RESULT_STUNNED
    --ACTION_RESULT_SWIMMING
    --ACTION_RESULT_TARGET_DEAD
    --ACTION_RESULT_TARGET_NOT_IN_VIEW
    --ACTION_RESULT_TARGET_NOT_PVP_FLAGGED
    --ACTION_RESULT_TARGET_OUT_OF_RANGE
    --ACTION_RESULT_TARGET_TOO_CLOSE
    --ACTION_RESULT_UNEVEN_TERRAIN
    --ACTION_RESULT_WEAPONSWAP
    --ACTION_RESULT_WRECKING_DAMAGE
    --ACTION_RESULT_WRONG_WEAPON2
}


function PSBT_Combat:Initialize( ... )
    PSBT_Module.Initialize( self, ... )

    self._buffer    = ZO_CircularBuffer:New( DEFAULT_MAX_BUFFERED_EVENTS )
    self._index     = 1
    self._free      = nil

    self:RegisterForEvent( EVENT_COMBAT_EVENT,          function( ... ) self:OnCombatEvent( ... )    end )
    self:RegisterForEvent( EVENT_SKILLS_FULL_UPDATE,    function() self:RefreshAbilityIcons()        end )
    self:RegisterForEvent( EVENT_SKILL_POINTS_CHANGED,  function() self:RefreshAbilityIcons()        end )

    self:RefreshAbilityIcons()
end

function PSBT_Combat:RefreshAbilityIcons()
    for i=1,GetNumAbilities() do
        local name, icon = GetAbilityInfoByIndex( i )
        self._iconRegistry[ name ] = icon
    end
end

function PSBT_Combat:OnCombatEvent( ... )
    local result        = select( 1, ... )
    if ( not combat_events[ result ] ) then 
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

function PSBT_Combat:OnUpdate( frameTime )
    if ( self._index <= 0 ) then
        self._index = 1
    end

    local bufferSize = self._buffer:Size()
    local endPoint = zo_min( self._index + MAX_EVENTS, bufferSize )
    for i = self._index, endPoint do
        local entry = self._buffer:At( i )
        if ( entry ) then
            self:DispatchEvent( unpack( entry ) )
        end
    end 

    if ( endPoint >= bufferSize ) then
        self._buffer:Clear()
    else
        self._index = endPoint + 1
    end
end

--integer result, bool isError, string abilityName, integer abilityGraphic, integer abilityActionSlotType, string sourceName, integer sourceType, string targetName, integer targetType, integer hitValue, integer powerType, integer damageType, bool log
function PSBT_Combat:DispatchEvent( result, _, ... )
    local func = combat_events[ result ]
    local text, area, crit = func( ... )

    local icon = self._iconRegistry[ select( 1, ... ) ]

    self:NewEvent( area, crit, icon, text )
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.COMBAT, PSBT_Combat:New( psbt ), kVerison )
    end)