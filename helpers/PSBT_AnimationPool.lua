local ZO_ObjectPool = ZO_ObjectPool
local LibAnim = LibStub( 'LibAnimation-1.0' )

PSBT_AnimationPool = ZO_ObjectPool:Subclass()

function PSBT_AnimationPool:New( create, reset )
    return ZO_ObjectPool.New( self, self.Create, function( ... ) self:Reset( ... ) end )
end

function PSBT_AnimationPool:Create()
    return LibAnim:New()
end

function PSBT_AnimationPool:Reset( animation )
    animation:Stop()
end

function PSBT_AnimationPool:Apply( control )
    local anim, key = self:AcquireObject()
    anim:SetUserData( key )
    anim:Apply( control )
    anim:SetHandler( 'OnStop', 
        function( animation ) 
            self:ReleaseObject( anim:GetUserData() ) 
        end )

    return anim
end