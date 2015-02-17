local PSBT          = PSBT
local Label         = PSBT.LabelProto
local ZO_ObjectPool = ZO_ObjectPool

local LabelFactory  = ZO_ObjectPool:Subclass()

function LabelFactory:New()
    local result = ZO_ObjectPool.New( self, function() return self:CreateLabel() end, function( ... ) self:ResetLabel( ... ) end )
    if ( result.m_Free ) then
        result.m_Free = setmetatable( {}, { __mode = 'v' } ) --cheat the garbage collector :)
    end

    return result
end

function LabelFactory:CreateLabel()
    return Label:New( self )
end

function LabelFactory:ResetLabel( label )
    label:Finalize()
end

function LabelFactory:OnUpdate( frameTime )
    for k,label in pairs( self:GetActiveObjects() ) do
        if ( label:IsExpired( frameTime ) ) then
            self:ReleaseObject( k )
        end
    end
end

PSBT.LabelFactory = LabelFactory:New()