local PSBT              = PSBT
local AnimationPool     = PSBT.AnimPoolProto
local Sticky            = AnimationPool:Subclass()

function Sticky:New( duration )
    local result = AnimationPool.New( self )
    result:Initialize( duration )
    return result
end

function Sticky:Initialize( duration )
    self._duration = duration
end

function Sticky:Create()
    local anim = AnimationPool.Create( self )
    anim:TranslateToFrom( 0, 0, 0, 0, self._duration )
    return anim
end

function Sticky:Apply( control, from, to )
    local result = AnimationPool.Apply( self, control )
    local timeline = result.timeline  

    local translate = timeline:GetFirstAnimation()
    translate:SetStartOffsetX( from.x )
    translate:SetStartOffsetY( from.y )
    translate:SetEndOffsetX( to.x )
    translate:SetEndOffsetY( to.y )

    return result
end

PSBT.StickyProto = Sticky