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
        return 'Can\'t See Target!', PSBT_AREAS.STATIC, false
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
        local name = nil
        if ( IsPlayer( targetType, targetName ) ) then
            name = sourceName
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            name = targetName
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( '+<<1>> [|c80C3F2<<2>>|r]!', hitValue, name ), area, true
    end,
    [ ACTION_RESULT_DAMAGE ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue, damageType )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( "<<1>>", hitValue ), area, false
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
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( '<<1>>', hitValue ), area, false
    end,
    [ ACTION_RESULT_DOT_TICK_CRITICAL ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue, damageType )
        local area = nil
        if ( IsPlayer( targetType, targetName ) ) then
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( '<<1>>!', hitValue ), area, true
    end,
    [ ACTION_RESULT_HEAL ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        local name = nil
        if ( IsPlayer( targetType, targetName ) ) then
            name = sourceName
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            name = targetName
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( '+<<1>> [|c80C3F2<<2>>|r]' , hitValue, name ), area, false
    end,
    [ ACTION_RESULT_HOT_TICK ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        local name = nil
        if ( IsPlayer( targetType, targetName ) ) then
            name = sourceName
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            name = targetName
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( '+<<1>> [|c80C3F2<<2>>|r]', hitValue, name ), area, false
    end,
    [ ACTION_RESULT_HOT_TICK_CRITICAL ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local area = nil
        local name = nil
        if ( IsPlayer( targetType, targetName ) ) then
            name = sourceName
            area = PSBT_AREAS.INCOMING
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            name = targetName
            area = PSBT_AREAS.OUTGOING 
        end

        return zo_strformat( '+<<1>> [|c80C3F2<<2>>|r]!', hitValue, name ), area, true
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

        return zo_strformat( 'Parried <<1>>', abilityName ), area, false
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
            return zo_strformat( '<<1>> Kill You.', sourceName ), PSBT_AREAS.STATIC, true
        elseif ( IsPlayer( sourceType, sourceName ) ) then
            return zo_strformat( 'Killing Blow <<1>>!', targetName ), PSBT_AREAS.STATIC, true
        end

        return nil, nil, false
    end,
    [ EVENT_ALLIANCE_POINT_UPDATE ] = function(value, sound, diff)
        local area = nil
        if ( diff > 0 ) then
            area = PSBT_AREAS.INCOMING
        else
            area = PSBT_AREAS.OUTGOING
        end

        return zo_strformat( '<<1>> AP', diff ), area, false
    end,
    [ EVENT_RANK_POINT_UPDATE ] = function( tag , value, diff )
        if (tag == "player") then
            local area = nil
            if ( diff > 0 ) then
                area = PSBT_AREAS.INCOMING
            else
                area = PSBT_AREAS.OUTGOING
            end

            return zo_strformat( '<<1>> RP', diff ), area, false
        end
    end,
    [ EVENT_BATTLE_TOKEN_UPDATE ] = function( value, sound, diff )
        local area = nil
        if ( diff > 0 ) then
            area = PSBT_AREAS.INCOMING
        else
            area = PSBT_AREAS.OUTGOING
        end

        return zo_strformat( '<<1>> BT', diff ), area, false
    end,
    [ EVENT_EXPERIENCE_GAIN ] = function( value )
        return zo_strformat( '+<<1>> XP', value ), PSBT_AREAS.INCOMING, false
    end,
    [ EVENT_EXPERIENCE_GAIN_DISCOVERY ] = function( areaName, value )
        return zo_strformat( '+<<1>> XP', value ), PSBT_AREAS.INCOMING, false 
    end,

    [ ACTION_RESULT_POWER_DRAIN ] = function( abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, mechanicValue )
        local mechanicName = GetString( 'SI_COMBATMECHANICTYPE', mechanicValue )
        return zo_strformat( '-<<1>> (<<2>>)', hitValue, mechanicName ), PSBT_AREAS.OUTGOING, false
    end,
    ---------------------------------------------
    --[[[ ACTION_RESULT_POWER_ENERGIZE ]            = nil,
    [ ACTION_RESULT_EFFECT_GAINED_DURATION ]    = nil,
    [ ACTION_RESULT_EFFECT_GAINED ]             = nil,
    [ ACTION_RESULT_EFFECT_FADED ]              = nil,
    [ ACTION_RESULT_DEBUFF ]                    = nil, 
    [ ACTION_RESULT_CASTER_DEAD ]               = nil,
    [ ACTION_RESULT_COMPLETE ]                  = nil,
    [ ACTION_RESULT_BUFF ]                      = nil,
    [ ACTION_RESULT_BUSY ]                      = nil,
    [ ACTION_RESULT_CANNOT_USE ]                = nil,
    [ ACTION_RESULT_BEGIN_CHANNEL ]             = nil,
    [ ACTION_RESULT_BAD_TARGET ]                = nil,
    [ ACTION_RESULT_ABILITY_ON_COOLDOWN ]       = nil,
    [ ACTION_RESULT_BEGIN ]                     = nil,
    [ ACTION_RESULT_POWER_DRAIN ]               = nil,
    [ ACTION_RESULT_RESURRECT ]                 = nil,
    [ ACTION_RESULT_DIED ]                      = nil,
    [ ACTION_RESULT_DIED_XP ]                   = nil,]]
}


function PSBT_Combat:Initialize( ... )
    PSBT_Module.Initialize( self, ... )

    self._buffer    = ZO_CircularBuffer:New( DEFAULT_MAX_BUFFERED_EVENTS )
    self._index     = 1
    self._free      = nil

    for i=1,GetNumAbilities() do
        local name, icon = GetAbilityInfoByIndex( i )
        self._iconRegistry[ name ] = icon
    end

    self:RegisterForEvent( EVENT_COMBAT_EVENT, function( event, ... ) self:OnCombatEvent( ... ) end )
end

function PSBT_Combat:OnCombatEvent( ... )
    local result        = select( 1, ... )
    if ( not combat_events[ result ] ) then 
        return
    end

    -- did we get hit or do something?
    if ( IsPlayer( select( 7, ... ), select( 6, ... ) ) or IsPlayer( select( 9, ... ), select( 8, ... ) ) ) then
        if ( self._free ) then
            local argCount = select( "#", ... )
            for i = 1, argCount do
                self._free[ i ] = select( i, ... )
            end
            
            for i = #self._free,argCount + 1, -1 do
                self._free[ i ] = nil
            end
            
            self._free = self._buffer:Add( self._free )
        else
            self._free = self._buffer:Add( { ... } )
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
        psbt:RegisterModule( PSBT_MODULES.COMBAT, PSBT_Combat:New( psbt ) )
    end)