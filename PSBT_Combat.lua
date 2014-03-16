local PSBT_Combat = PSBT_Module:Subclass()
PSBT_Combat._iconRegistry = setmetatable( {}, { __mode = 'kv' } )

local CBM = CALLBACK_MANAGER

local MAX_EVENTS = 25

function PSBT_Combat:Initialize( ... )
    PSBT_Module.Initialize( self, ... )

    self._playernameRaw = GetRawUnitName( 'player' )
    self._playernameClean = GetUnitName( 'player' )
    self._buffer = ZO_CircularBuffer:New( DEFAULT_MAX_BUFFERED_EVENTS )
    self._index = 1

    for i=1,GetNumAbilities() do
        local name, icon = GetAbilityInfoByIndex( i )
        self._iconRegistry[ name ] = icon
    end

    self:RegisterForEvent( EVENT_COMBAT_EVENT, function( eventCode, ... ) self:OnCombatEvent( ... ) end )
end

function PSBT_Combat:OnCombatEvent( ... )
    local sourceType = select( 7, ... )
    local targetType = select( 9, ... )

    if ( sourceType == COMBAT_UNIT_TYPE_PLAYER 
        or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET 
        or targetType == COMBAT_UNIT_TYPE_PLAYER 
        or targetType == COMBAT_UNIT_TYPE_PLAYER_PET ) then

        self._buffer:Add( { ... } )
        self._index = self._index - 1
    end
end

function PSBT_Combat:OnUpdate( frameTime )
    if ( self._index <= 0 ) then
        self._index = 1
    end
    
    local size = self._buffer:Size()
    local stop = zo_min( self._index + MAX_EVENTS, size )
    for i=self._index,stop do
        local iterator = self._buffer:At( i )
        if ( iterator ) then
            self:DispatchEvent( unpack( iterator ) )
        end
    end

    if ( stop <= size ) then
        self._index = stop + 1
    end
end

function PSBT_Combat:DispatchEvent( ... )
    local sourceType = select( 7, ... )
    local targetType = select( 9, ... )
    local ability = select( 3, ... )
    local value = select( 10, ... )

    d( GetString("SI_DAMAGETYPE", select( 11, ... ) ) )
    d( GetString("SI_COMBATMECHANICTYPE", select( 11, ... ) ) )

    local icon = self._iconRegistry[ ability ]
    if ( not icon ) then
        icon = [[/esoui/art/icons/icon_missing.dds]]
    end

    local area = nil
    if ( targetType == COMBAT_UNIT_TYPE_PLAYER or 
         targetType == COMBAT_UNIT_TYPE_PLAYER_PET ) then 
        area = PSBT_AREAS.INCOMING
    else
        area = PSBT_AREAS.OUTGOING 
    end

    self:NewEvent( area, false, icon, value )
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.COMBAT, PSBT_Combat:New( psbt ) )
    end)