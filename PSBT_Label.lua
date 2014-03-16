PSBT_Label = ZO_Object:Subclass()

local LibAnim = LibStub( 'LibAnimation-1.0' )
if ( not LibAnim ) then return end

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
end

function PSBT_Label:Finalize()
    self.label:SetText( '' )
    self.icon:SetTexture( 0 )
    self.control:SetHidden( true )
end

function PSBT_Label:SetText( text )
    self.label:SetText( text )
end

function PSBT_Label:SetTexture( texture )
    if ( type( texture ) == 'string' ) then
        self.icon:SetWidth( self.control:GetHeight() )
        self.icon:SetTexture( texture )
    else
        self.icon:SetWidth( 0 )
    end
end

function PSBT_Label:IsVisible()
    return self.control:GetAlpha() > 0.001
end

function PSBT_Label:Play( height, duration )
    self.control:SetHidden( false )
    self.control:SetAlpha( 0.01 )

    local enter = LibAnim:New( self.control )
    enter:AlphaTo( 1.0, 500, nil, nil, ZO_LinearEase )
    enter:InsertCallback( function() self:OnEnterComplete( height, duration ) end, 500 )
    enter:Play()
end

function PSBT_Label:OnEnterComplete( height, duration ) 
    local leave = LibAnim:New( self.control )
    leave:AlphaTo( 0.0, duration, nil, nil, ZO_EaseOutCubic )
    leave:TranslateTo( 0, height, duration, nil, nil, ZO_EaseOutCubic )
    
    leave:Play()
end