local PSBT                  = PSBT
local ModuleProto           = PSBT.ModuleProto
local PSBT_Skills           = ModuleProto:Subclass()
local CBM                   = CALLBACK_MANAGER

local PSBT_EVENTS           = PSBT.EVENTS
local PSBT_MODULES          = PSBT.MODULES
local PSBT_AREAS            = PSBT.AREAS

local _

local kVerison              = 1.0

function PSBT_Skills:Initialize( ... )
    ModuleProto.Initialize( self, ... )

    self:RegisterForEvent( EVENT_SKILL_XP_UPDATE, 'OnSkillXPUpdate' )
end

function PSBT_Skills:Shutdown()
    self:UnregisterForEvent( EVENT_SKILL_XP_UPDATE, 'OnSkillXPUpdate' )

    ModuleProto.Shutdown( self )
end

function PSBT_Skills:OnSkillXPUpdate( SkillType, SkillIndex, Reason, Rank, PreviousXP, CurrentXP )
    local Line = GetSkillLineInfo( SkillType, SkillIndex )
    local _, NeedXP = GetSkillLineRankXPExtents( SkillType, SkillIndex, Rank )

    local Difference = CurrentXP - PreviousXP
    local Percent = math.floor( ( CurrentXP / NeedXP ) * 100.0 )

   self:NewEvent( PSBT_AREAS.NOTIFICATION, true, nil, '+' .. tostring( Difference ) .. ' ' .. Line .. ' (' .. Percent .. '%)' ) 
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.SKILLS, PSBT_Skills, kVerison )
    end )