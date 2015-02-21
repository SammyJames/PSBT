local PSBT          = PSBT
local ZO_Object     = ZO_Object
local Label         = ZO_Object:Subclass()

local CENTER                    = CENTER
local PSBT_SCROLL_DIRECTIONS    = PSBT.SCROLL_DIRECTIONS
local PSBT_ICON_SIDE            = PSBT.ICON_SIDE
local unpack                    = unpack

function Label:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function Label:Initialize()
    self.control = CreateControlFromVirtual( 'PSBT_Label', PSBT.control, 'PSBT_Label', PSBT.LabelFactory:GetNextControlId() )
    self.label   = self.control:GetNamedChild( '_Name' )
    self.icon    = self.control:GetNamedChild( '_Icon' )
    self.expire  = 0
    self.moving  = false
    self.direction = PSBT_SCROLL_DIRECTIONS.UP
    self.iconPos = PSBT_ICON_SIDE.LEFT
end

function Label:SetMoving( set )
    self.moving = set
end

function Label:IsMoving()
    return self.moving
end

function Label:SetExpire( expire )
    self.expire = expire
end

function Label:GetExpire()
    return self.expire
end

function Label:WillExpire( frameTime )
    return frameTime > self.expire
end

function Label:IsExpired( frameTime )
    if ( self.expire == -1 ) then
        return false
    end

    if ( self.moving ) then
        return false
    end

    return frameTime > self.expire
end

function Label:Finalize()
    self:SetText( '' )
    self:SetTexture( 0 )
    self:SetExpire( 0 )
    self:SetMoving( false )
    self.control:ClearAnchors()
    self.control:SetScale( 1.0 )
end

function Label:SetText( text )
    self.label:SetText( text )
end

function Label:SetColor( color )
    self.label:SetColor( unpack( color ) )
end

function Label:SetIconPosition( side )
    self.iconPos = side

    if ( side ~= PSBT_ICON_SIDE.NONE ) then
        local height = self:GetHeight()
        self.icon:SetWidth( height )
        self.icon:SetHeight( height )

        local xpos = 0
        if ( side == PSBT_ICON_SIDE.LEFT ) then
            xpos = ( self:GetWidth() * -0.5 ) - self.icon:GetWidth()
        else
            xpos = ( self:GetWidth() * 0.5 ) + self.icon:GetWidth()
        end

        self.icon:SetAnchor( CENTER, self.control, CENTER, xpos, 0 )
    else
        self.icon:SetHidden( true )
    end
end

function Label:SetTexture( texture )
    if ( type( texture ) == 'string' and not self.iconPos ~= PSBT_ICON_SIDE.NONE ) then
        self.icon:SetHidden( false )
        self.icon:SetTexture( texture )
    else
        self.icon:SetHidden( true )
    end
end

function Label:GetWidth()
    local textWidth = self.label:GetTextDimensions()
    return textWidth
end

function Label:GetHeight()
    local _, textHeight = self.label:GetTextDimensions()
    return textHeight
end

PSBT.LabelProto = Label


