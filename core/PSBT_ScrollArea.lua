local LibAnim = LibStub( 'LibAnimation-1.0' )
if ( not LibAnim ) then return end 

PSBT_ScrollArea     = ZO_Object:Subclass()
local CBM           = CALLBACK_MANAGER
local tinsert       = table.insert
local tremove       = table.remove
local NUM_STICKY    = 4

local PSBT_Fifo     = PSBT_Fifo
local CENTER        = CENTER
local BOTTOM        = BOTTOM
local TOP           = TOP

local PSBT_EVENTS   = PSBT_EVENTS
local PSBT_SCROLL_DIRECTIONS = PSBT_SCROLL_DIRECTIONS

function PSBT_ScrollArea:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function PSBT_ScrollArea:Initialize( super, areaName, settings )
    self.name           = areaName
    self.control        = super:GetNamedChild( areaName )
    self.background     = self.control:GetNamedChild( '_BG' )
    self.label          = self.control:GetNamedChild( '_Name' )
    self._newSticky     = false
    self._height        = self.control:GetHeight()
    self._sticky        = PSBT_Fifo.New()
    self._pendingSticky = PSBT_Fifo.New()
    self._normal        = {}
    self._pendingNormal = PSBT_Fifo.New()
    self._direction     = settings.dir
    self._iconSide      = settings.icon

    self:Position( settings )
    self:SetConfigurationMode( false )
    self.control:SetHandler( 'OnUpdate', function( event, ... ) self:OnUpdate( ... ) end )

    CBM:RegisterCallback( PSBT_EVENTS.CONFIG, function( ... ) self:SetConfigurationMode( ... ) end )
end

function PSBT_ScrollArea:SetConfigurationMode( enable )
    self.control:SetMovable( enable )
    self.control:SetMouseEnabled( enable )
    self.label:SetHidden( not enable )
    if ( enable ) then
        local enter = LibAnim:New( self.background )
        enter:AlphaTo( 1.0, 500 )
        enter:Play() 
    else
        local exit = LibAnim:New( self.background )
        exit:AlphaTo( 0.0, 500 )
        exit:Play() 
    end
end

function PSBT_ScrollArea:Position( settings )
    self.control:SetAnchor( settings.to, self.control:GetParent(), settings.from, settings.x, settings.y )
end

function PSBT_ScrollArea:GetAnchorOffsets()
    local _, point, _, relPoint, offsX, offsY = self.control:GetAnchor( 0 )
    return { to = point, from = relPoint, x = offsX, y = offsY }
end

function PSBT_ScrollArea:AnchorChild( label, sticky )
    local relativeTo = CENTER
    if ( not sticky ) then
        if ( self._direction == PSBT_SCROLL_DIRECTIONS.UP ) then
            relativeTo = BOTTOM
        elseif ( self._direction == PSBT_SCROLL_DIRECTIONS.DOWN ) then
            relativeTo = TOP
        end
    end

    label.control:SetAnchor( CENTER, self.control, relativeTo, 0, 0 )
end

function PSBT_ScrollArea:Push( entry, sticky )
    self:AnchorChild( entry, sticky )

    entry:SetIconPosition( self._iconSide )

    if ( sticky ) then
        self._pendingSticky:Push( entry )
    else
        self._pendingNormal:Push( entry )
    end
end

function PSBT_ScrollArea:SetSettings( settings )
    self._iconSide = settings.icon
    self._direction = settings.dir
end

function PSBT_ScrollArea:OnUpdate( frameTime ) 
    if ( not self._sticky:Size() and 
         not #self._normal and 
         not self._pendingNormal:Size() and
         not self._pendingSticky:Size() ) then
        return
    end

    while ( self._sticky:Size() > NUM_STICKY ) do
        local old = self._sticky:Pop()
        local anim = LibAnim:New( old.control )
        anim:AlphaTo( 0.0, 200 )
        anim:Play()

        old:SetMoving( false )

        old:SetExpire( frameTime + 2 )
        self._newSticky = true
    end

    repeat 
        local entry = self._sticky:Peek()
        if ( entry and entry:WillExpire( frameTime + 2 ) ) then
            local anim = LibAnim:New( entry.control )
            anim:AlphaTo( 0.0, 200 )

            local ypos = 0
            if ( self._direction == PSBT_SCROLL_DIRECTIONS.UP ) then
                ypos = -100
            elseif ( self._direction == PSBT_SCROLL_DIRECTIONS.DOWN ) then
                ypos = 100
            end

            anim:TranslateTo( 0, ypos, 200 )
            anim:Play()

            entry:SetMoving( false )

            self._sticky:Pop()
            self._newSticky = true
        end
    until( not entry or not entry:WillExpire( frameTime + 2 )  )

    if ( self._pendingNormal:Size() ) then
        local newEntry = self._pendingNormal:Pop()
        if ( newEntry ) then
            newEntry:SetExpire( frameTime + 5 )

            local anim = LibAnim:New( newEntry.control )
            anim:AlphaTo( 1.0, 200 )
            anim:Play()

            tinsert( self._normal, newEntry )
        end
    end

    if ( self._pendingSticky:Size() ) then
        local newEntry = self._pendingSticky:Pop()
        if ( newEntry ) then
            newEntry:SetExpire( frameTime + 5 )

            local anim = LibAnim:New( newEntry.control )
            anim:AlphaTo( 1.0, 200 )
            anim:Play()

            self._sticky:Push( newEntry )
            self._newSticky = true
        end
    end

    local i = 1
    while ( i <= #self._normal ) do
        local entry = self._normal[ i ]

        if ( entry:WillExpire( frameTime + 2 ) ) then
            local anim = LibAnim:New( entry.control )
            anim:AlphaTo( 0.0, 200 )
            anim:Play()

            entry:SetMoving( false )

            tremove( self._normal, i )
        else
            if ( not entry:IsMoving() ) then
                local anim = LibAnim:New( entry.control )

                local targetY = 0
                if ( self._direction == PSBT_SCROLL_DIRECTIONS.UP ) then
                    targetY = self._height * -1
                else
                    targetY = self._height
                end


                anim:TranslateTo( 0, targetY, 3000 )
                anim:Play()

                entry:SetMoving( true )
            end
            i = i + 1
        end
    end

    local top = 0    
    for i, entry in self._sticky:Iterator() do
        if ( self._newSticky ) then
            local anim = LibAnim:New( entry.control )
            anim:TranslateTo( 0, top, 200 ) 
            anim:Play()

            entry:SetMoving( true )

            top = top + entry.control:GetHeight()
        end
    end

    self._newSticky = false
end