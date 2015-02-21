local PSBT          = PSBT
local AnimationPool = PSBT.AnimPoolProto
local Translate     = AnimationPool:Subclass()

function Translate:New( Duration )
    local result = AnimationPool.New( self )
    result:Initialize( Duration )
    return result
end

function Translate:Initialize( Duration )
    self._duration = Duration
end

function Translate:Create()
    local anim = AnimationPool.Create( self )
    anim:TranslateToFrom( 0, 0, 0, 0, self._duration )

    return anim
end

function Translate:Apply( Control, From, To )
    local Result = AnimationPool.Apply( self, Control )
    local Timeline = Result.timeline

    local Translate = Timeline:GetFirstAnimation()
    Translate:SetStartOffsetX( From.X )
    Translate:SetStartOffsetY( From.Y )
    Translate:SetEndOffsetX( To.X )
    Translate:SetEndOffsetY( To.Y )

    return Result
end

PSBT.TranslateProto = Translate

