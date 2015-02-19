local PSBT                   = PSBT
local ModuleProto            = PSBT.ModuleProto
local PSBT_Settings          = ModuleProto:Subclass()
local CBM                    = CALLBACK_MANAGER
local PSBT_MODULES           = PSBT.MODULES
local PSBT_EVENTS            = PSBT.EVENTS
local PSBT_AREAS             = PSBT.AREAS
local PSBT_ICON_SIDE         = PSBT.ICON_SIDE
local PSBT_SCROLL_DIRECTIONS = PSBT.SCROLL_DIRECTIONS
local ZO_SavedVars           = ZO_SavedVars
local RIGHT                  = RIGHT
local LEFT                   = LEFT
local CENTER                 = CENTER
local kVersion               = 3.2  

local defaults = 
{
    normal_font = 
    {
        face = 'Cooline',
        size = 14, 
        deco = 'shadow'
    },

    sticky_font = 
    {
        face = 'Adventure',
        size = 18,
        deco = 'shadow'
    },

    damage_color = 
    { 
        255, 255, 255, 1 
    },
    
    healing_color = 
    { 
        255, 255, 255, 1 
    },
    
    normal_color = 
    { 
        255, 255, 255, 1
    },

    [ PSBT_AREAS.INCOMING ] = 
    { 
        to      = RIGHT,  
        from    = CENTER, 
        x       = -300,  
        y       = 150,
        icon    = PSBT_ICON_SIDE.LEFT,
        dir     = PSBT_SCROLL_DIRECTIONS.UP,
        arc     = 150
    },
    
    [ PSBT_AREAS.OUTGOING ] = 
    { 
        to      = LEFT,   
        from    = CENTER, 
        x       = 300,   
        y       = 150,
        icon    = PSBT_ICON_SIDE.LEFT,
        dir     = PSBT_SCROLL_DIRECTIONS.DOWN,
        arc     = -150
    },

    [ PSBT_AREAS.STATIC ] = 
    { 
        to      = CENTER, 
        from    = CENTER, 
        x       = 0,
        y       = -300,
        icon    = PSBT_ICON_SIDE.LEFT,
        dir     = PSBT_SCROLL_DIRECTIONS.DOWN,
        arc     = 0
    },

    [ PSBT_AREAS.NOTIFICATION ] = 
    { 
        to      = CENTER, 
        from    = CENTER, 
        x       = 0,
        y       = 450,
        icon    = PSBT_ICON_SIDE.LEFT,
        dir     = PSBT_SCROLL_DIRECTIONS.UP,
        arc     = 0
    },

    [ PSBT_MODULES.COOLDOWNS ]  = true,
    [ PSBT_MODULES.COMBAT ]     = true,
    [ PSBT_MODULES.AURAS ]      = true,
    [ PSBT_MODULES.XP ]         = true,
    [ PSBT_MODULES.LOW ]        = true,
    [ PSBT_MODULES.ULTIMATE ]   = true,
    [ PSBT_MODULES.DEBUG ]      = false,
}

function PSBT_Settings:Initialize( ... )
    ModuleProto.Initialize( self, ... )

    self.db      = ZO_SavedVars:New( 'PSBT_DB', kVersion, nil, defaults )
    self.profile = self.db:GetInterfaceForCharacter( GetDisplayName(), GetUnitName( 'player' ) )
end

function PSBT_Settings:GetSetting( identity )
    if ( not self.profile[ identity ] ) then
        return nil
    end

    return self.profile[ identity ]
end

function PSBT_Settings:SetSetting( identity, value )
    self.profile[ identity ] = value
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.SETTINGS, PSBT_Settings, kVersion )
    end)