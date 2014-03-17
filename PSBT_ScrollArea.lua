local LibAnim = LibStub( 'LibAnimation-1.0' )
if ( not LibAnim ) then return end 

PSBT_ScrollArea     = ZO_Object:Subclass()
local CBM           = CALLBACK_MANAGER
local tinsert       = table.insert
local tremove       = table.remove
local NUM_STICKY    = 4

local PSBT_Fifo     = PSBT_Fifo
local CENTER        = CENTER

local PSBT_EVENTS   = PSBT_EVENTS

function PSBT_ScrollArea:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function PSBT_ScrollArea:Initialize( super, areaName, anchor, position )
    self.name           = areaName
    self.control        = super:GetNamedChild( areaName )
    self.background     = self.control:GetNamedChild( '_BG' )
    self.label          = self.control:GetNamedChild( '_Name' )
    self._anchor        = anchor
    self._animHeight    = nil
    self._newSticky     = false
    self._sticky        = PSBT_Fifo.New()
    self._pendingSticky = PSBT_Fifo.New()
    self._normal        = {}
    self._pendingNormal = PSBT_Fifo.New()

    if ( anchor == TOP ) then
        self._animHeight = self.control:GetHeight()
    else
        self._animHeight = -1 * self.control:GetHeight()
    end
    self:Position( unpack( position ) )
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

function PSBT_ScrollArea:Position( point, relPoint, x, y )
    self.control:SetAnchor( point, self.control:GetParent(), relPoint, x, y )
end

function PSBT_ScrollArea:GetAnchorOffsets()
    local _, point, _, relPoint, offsX, offsY = self.control:GetAnchor( 0 )
    return point, relPoint, offsX, offsY
end

function PSBT_ScrollArea:Push( entry, sticky )
    if ( sticky ) then
        entry.control:SetAnchor( CENTER, self.control, CENTER, 0, self.control:GetHeight() )
        self._pendingSticky:Push( entry )
        return
    end

    entry.control:SetAnchor( CENTER, self.control, self._anchor, 0, 0 )
    self._pendingNormal:Push( entry )
end

function PSBT_ScrollArea:OnUpdate( frameTime ) 
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
            anim:TranslateTo( 0, -200, 200 )
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
                anim:TranslateTo( 0, self._animHeight, 3000 )
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