local PSBT          = PSBT
local AnimationPool = PSBT.AnimPoolProto
local Fade          = AnimationPool:Subclass()

function Fade:New( to, from )
    local result = AnimationPool.New( self )
    result:Initialize( to, from )
    return result
end

function Fade:Initialize( to, from )
    self._target    = to
    self._from      = from
    self._ease      = ZO_EaseOutQuintic
    if ( self._from < self._target ) then
        self._ease = ZO_EaseInQuintic
    end
end

function Fade:Create()
    local anim = AnimationPool.Create( self )
    anim:AlphaToFrom( self._from, self._target, 200, 0, self._ease )
    return anim
end

PSBT.FadeProto = Fade

