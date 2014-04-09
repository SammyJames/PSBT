local PSBT          = PSBT
local ZO_ObjectPool = ZO_ObjectPool
local LibAnim       = LibStub( 'LibAnimation-1.0' )

local AnimationPool = ZO_ObjectPool:Subclass()

function AnimationPool:New()
    return ZO_ObjectPool.New( self, self.Create, function( ... ) self:Reset( ... ) end )
end

function AnimationPool:Create()
    return LibAnim:New()
end

function AnimationPool:Reset( animation )
    animation:Stop()
end

function AnimationPool:Apply( control )
    local anim, key = self:AcquireObject()
    anim:SetUserData( key )
    anim:Apply( control )
    anim:SetHandler( 'OnStop', 
        function( animation ) 
            self:ReleaseObject( anim:GetUserData() ) 
        end )

    return anim
end

PSBT.AnimPoolProto = AnimationPool