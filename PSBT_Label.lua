PSBT_Label = ZO_Object:Subclass()

local CENTER = CENTER

function PSBT_Label:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function PSBT_Label:Initialize( objectPool )
    self.objectPool = objectPool
    self.control = CreateControlFromVirtual( 'PSBT_Label', self.objectPool.control, 'PSBT_Label', self.objectPool:GetNextControlId() )
    self.label   = self.control:GetNamedChild( '_Name' )
    self.icon    = self.control:GetNamedChild( '_Icon' )
    self.expire  = 0
    self.moving  = false

    self.control:SetAlpha( 0.0 )
end

function PSBT_Label:SetMoving( set )
    self.moving = set
end

function PSBT_Label:IsMoving()
    return self.moving
end

function PSBT_Label:SetExpire( expire )
    self.expire = expire
end

function PSBT_Label:WillExpire( frameTime )
    return frameTime > self.expire
end

function PSBT_Label:IsExpired( frameTime )
    if ( self.expire == -1 ) then
        return false
    end

    if ( self.moving ) then
        return false
    end

    return frameTime > self.expire
end

function PSBT_Label:Finalize()
    self:SetText( '' )
    self:SetTexture( 0 )
    self:SetExpire( 0 )
    self:SetMoving( false )
end

function PSBT_Label:SetText( text )
    self.label:SetText( text )

    local textWidth = self.label:GetTextDimensions()
    self.icon:SetAnchor( CENTER, self.control, CENTER, ( textWidth * -0.45 ) - self.icon:GetWidth(), 0 )
end

function PSBT_Label:SetTexture( texture )
    if ( type( texture ) == 'string' ) then
        self.icon:SetHidden( false )
        self.icon:SetTexture( texture )
    else
        self.icon:SetHidden( true )
    end
end