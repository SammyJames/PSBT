local PSBT_AnimationPool = PSBT_AnimationPool
PSBT_Fade = PSBT_AnimationPool:Subclass()

function PSBT_Fade:New( to, from )
    local result = PSBT_AnimationPool.New( self )
    result:Initialize( to, from )
    return result
end

function PSBT_Fade:Initialize( to, from )
    self._target    = to
    self._from      = from
end

function PSBT_Fade:Create()
    local anim = PSBT_AnimationPool.Create( self )
    anim:AlphaToFrom( self._from, self._target, 200 )
    return anim
end