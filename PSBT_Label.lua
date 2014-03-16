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
        self.icon:SetTexture( texture )
    else
        print( 'SetTexture( %d )', texture )
    end
end

function PSBT_Label:IsVisible()
    return self.control:GetAlpha() > 0.001
end

function PSBT_Label:Play( height, duration )
    self.control:SetAlpha( 1.0 )
    self.control:SetHidden( false )

    local animation = LibAnim:New( self.control )
    animation:AlphaTo( 0.0, duration )
    animation:TranslateTo( 0, height, duration )
    
    animation:Play()
end