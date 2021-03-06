local PSBT          = PSBT
local ZO_Object     = ZO_Object
local ScrollArea    = ZO_Object:Subclass()

local CBM           = CALLBACK_MANAGER
local tinsert       = table.insert
local tremove       = table.remove
local NUM_STICKY    = 4
local NUM_STANDARD  = 25
local STANDARD_INTERVAL = 0.5
local CENTER        = CENTER
local TOP           = TOP
local BOTTOM        = BOTTOM
local PSBT_EVENTS               = PSBT.EVENTS
local PSBT_SCROLL_DIRECTIONS    = PSBT.SCROLL_DIRECTIONS
local PSBT_AREAS                = PSBT.AREAS

function ScrollArea:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function ScrollArea:Initialize( super, areaName, settings, fadeIn, fadeOut, displayName )
    self.name           = areaName
    self.control        = super:GetNamedChild( areaName )
    self.background     = self.control:GetNamedChild( '_BG' )
    self.label          = self.control:GetNamedChild( '_Name' )
    self.sticky         = self.control:GetNamedChild( '_Sticky' ) 
    self.label:SetText( displayName )
    self._newSticky     = false
    self._height        = self.control:GetHeight()
    self._sticky        = {}
    self._pendingSticky = {}
    self._normal        = {}
    self._pendingNormal = {}
    self._fadeIn        = fadeIn
    self._fadeOut       = fadeOut
    self._waitTill      = 0
    self._stickyPool    = PSBT.TranslateProto:New( 200 )

    self:SetSettings( settings )
    self:SetConfigurationMode( false )
    self.control:SetHandler( 'OnUpdate', function( event, ... ) self:OnUpdate( ... ) end )

    CBM:RegisterCallback( PSBT_EVENTS.CONFIG, function( ... ) self:SetConfigurationMode( ... ) end )
end

function ScrollArea:SetConfigurationMode( enable )
    self.control:SetMovable( enable )
    self.control:SetMouseEnabled( enable )
    self.label:SetHidden( not enable )
    if ( enable ) then
        local anim = self._fadeIn:Apply( self.background )
        anim:Play()
    else
        local anim = self._fadeOut:Apply( self.background )
        anim:Play()
    end
end

function ScrollArea:Position( settings )
    self.control:SetAnchor( settings.to, self.control:GetParent(), settings.from, settings.x, settings.y )
end

function ScrollArea:GetAnchorOffsets()
    local _, point, _, relPoint, offsX, offsY = self.control:GetAnchor( 0 )
    return point, relPoint, offsX, offsY
end

function ScrollArea:GetAnchorPoint()
    if ( self.name == PSBT_AREAS.INCOMING or self.name == PSBT_AREAS.OUTGOING ) then
        return TOP
    else
        return ( self._direction == PSBT_SCROLL_DIRECTIONS.UP ) and TOP or BOTTOM
    end
end

function ScrollArea:AnchorChild( control, sticky )
    local rel = CENTER
    local from = CENTER
    if ( not sticky ) then
        rel = self:GetAnchorPoint()
    end

    control:SetAnchor( from, sticky and self.sticky or self.control, rel, 0, 0 )
    control:SetAlpha( 0.0 )
end

function ScrollArea:Push( entry, sticky )
    self:AnchorChild( entry.control, sticky )

    entry:SetIconPosition( self._iconSide )

    if ( sticky ) then
        tinsert( self._pendingSticky, entry )
    else
        tinsert( self._pendingNormal, entry )
    end
end

function ScrollArea:SetSettings( settings )
    self._iconSide       = settings.icon
    self._direction      = settings.dir
    if ( self.name == PSBT_AREAS.INCOMING or self.name == PSBT_AREAS.OUTGOING ) then
        self._animation = PSBT.ParabolaProto:New( self.control:GetHeight(), settings.arc, 50, self._direction )
    else 
        self._animation = PSBT.TranslateProto:New( 3000 )
    end
    self:Position( settings )
end

function ScrollArea:OnUpdate( frameTime )
    if ( not #self._sticky and
        not #self._normal and
        not #self._pendingNormal and
        not #self._pendingSticky ) then
        return
    end

    while ( #self._sticky > NUM_STICKY ) do
        local old = tremove( self._sticky, 1 )
        old:SetMoving( false )
        old:SetExpire( frameTime )
        self._newSticky = true
    end

    if ( frameTime >= self._waitTill and #self._pendingNormal and #self._normal < NUM_STANDARD ) then
        local newEntry = tremove( self._pendingNormal, 1 )
        if ( newEntry ) then
            newEntry:SetExpire( frameTime + 3 )

            local anim = self._fadeIn:Apply( newEntry.control )
            anim:Play()

            tinsert( self._normal, newEntry )

            if ( #self._pendingNormal > 0 ) then
                self._waitTill = frameTime + STANDARD_INTERVAL
            else
                self._waitTill = 0
            end
        end
    end

    if ( #self._pendingSticky ) then
        local newEntry = tremove( self._pendingSticky, 1 )
        if ( newEntry ) then
            newEntry:SetExpire( frameTime + 5 )

            local anim = self._fadeIn:Apply( newEntry.control )
            anim:Play()

            tinsert( self._sticky, newEntry )
            self._newSticky = true
        end
    end

    local i = 1
    local entry = nil

    while ( i <= #self._normal ) do
        entry = self._normal[ i ]

        if ( entry:WillExpire( frameTime + 0.5 ) ) then
            local anim = self._fadeOut:Apply( entry.control )
            anim:Play()

            entry:SetMoving( false )
            tremove( self._normal, i )
        else
            if ( not entry:IsMoving() ) then

                local anim = self:Apply( self._animation, entry.control )
                anim:Play()
                entry:SetMoving( true )
            end
            i = i + 1
        end
    end


    i = 1
    local top = 0

    while ( i <= #self._sticky ) do
        entry = self._sticky[ i ]
        if ( entry:WillExpire( frameTime + 0.5 ) ) then
            local anim = self._fadeOut:Apply( entry.control )
            anim:Play()

            tremove( self._sticky, i )
            self._newSticky = true
        else
            if ( self._newSticky ) then
                local anim = self:Apply( self._stickyPool, entry.control, top )
                anim:Play()
                --entry.control:SetAnchor( CENTER, self.control, CENTER, 0, top )

                if ( self._direction == PSBT_SCROLL_DIRECTIONS.UP ) then
                    top = top - entry:GetHeight()
                else
                    top = top + entry:GetHeight()
                end
            end
            i = i + 1
        end
    end

    self._newSticky = false
end

function ScrollArea:Apply( Pool, Control, NewY )
    if ( NewY == nil ) then
        NewY = ( self._direction == PSBT_SCROLL_DIRECTIONS.UP ) and self.control:GetHeight() or -1.0 * self.control:GetHeight()
    end

    local _, _, _, _, offsX, offsY = Control:GetAnchor( 0 )

    local From = { X = offsX or 0, Y = offsY or 0 }
    local To = { X = offsX, Y = NewY }

    return Pool:Apply( Control, From, To )
end

PSBT.ScrollAreaProto = ScrollArea

