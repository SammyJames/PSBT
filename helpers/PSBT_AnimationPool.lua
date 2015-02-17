local PSBT          = PSBT
local ZO_ObjectPool = ZO_ObjectPool
local LibAnim       = LibStub( 'LibAnimation-1.0' )

local AnimationPool = ZO_ObjectPool:Subclass()

function AnimationPool:New()
    local result = ZO_ObjectPool.New( self, self.Create, function( ... ) self:Reset( ... ) end )
    if ( result.m_Free ) then
        result.m_Free = setmetatable( {}, { __mode = 'v' } ) --cheat the garbage collector :)
    end

    return result
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