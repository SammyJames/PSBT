local PSBT = PSBT

PSBT.MODULES =
{
    SETTINGS            = 'settings', -- saved variables 
    OPTIONS             = 'options',  -- options panel
    COOLDOWNS           = 'cooldowns',
    COMBAT              = 'combat',
    AURAS               = 'auras',
    XP                  = 'experience',
    LOW                 = 'lowsomething',
    ULTIMATE            = 'ultimate',
    DEBUG               = 'debug',
    SKILLS              = 'skills',
}

PSBT.AREAS = 
{
    NOTIFICATION        = '_Notifications',
    INCOMING            = '_Incoming',
    OUTGOING            = '_Outgoing',
    STATIC              = '_Static'
}

PSBT.SETTINGS =
{
    normal_font         = 'normal_font',
    sticky_font         = 'sticky_font',
    damage_color        = 'damage_color',
    healing_color       = 'healing_color',
    normal_color        = 'normal_color'
}

PSBT.EVENTS = 
{
    INITIALIZE          = 'PSBT_INITIALIZE',
    LOADED              = 'PSBT_LOADED',
    CONFIG              = 'PSBT_CONFIG', 
    REGISTER_ANIMATIONS = 'PSBT_REGISTER_ANIMATIONS',
    DEMO                = 'PSBT_CONFIG_DEMO'
}

PSBT.SCROLL_DIRECTIONS =
{
    UP                  = 'up',
    DOWN                = 'down',
}

PSBT.ICON_SIDE =
{
    NONE = 'none',
    LEFT = 'left',
    RIGHT = 'right',
}

PSBT.STRINGS = 
{
    FALL_DAMAGE         = 'SI_PSBT_EVENT_FALL_DAMAGE',
    CANNOT_SEE          = 'SI_PSBT_EVENT_CANNOT_SEE',
    DAMAGE_CRIT         = 'SI_PSBT_EVENT_DAMAGE_CRIT',
    DAMAGE              = 'SI_PSBT_EVENT_DAMAGE',
    HEALING_CRIT        = 'SI_PSBT_EVENT_HEAL_CRIT',
    HEALING             = 'SI_PSBT_EVENT_HEAL',
    KILLING_BLOW        = 'SI_PSBT_EVENT_KILLING_BLOW',
    FALLING             = 'SI_PSBT_EVENT_FALLING',
    INTERCEPTED         = 'SI_PSBT_EVENT_INTERCEPTED',
    BUSY                = 'SI_PSBT_EVENT_BUSY',
    IMMUNE              = 'SI_PSBT_EVENT_IMMUNE',
    INTERRUPT           = 'SI_PSBT_EVENT_INTERRUPT',
    ULTIMATE_GAIN       = 'SI_PSBT_EVENT_ULTIMATE_GAIN',
    ULTIMATE_READY      = 'SI_PSBT_EVENT_ULTIMATE_READY',
    LOW_SOMETHING       = 'SI_PSBT_EVENT_LOW_SOMETHING',
    AURA_GAINED         = 'SI_PSBT_EVENT_AURA_GAINED',
    AURA_FADES          = 'SI_PSBT_EVENT_AURA_FADES',
    ENERGIZE            = 'SI_PSBT_EVENT_ENERGIZE',
    DRAIN               = 'SI_PSBT_EVENT_DRAIN',

    -- options in general
    HEADER_GENERAL      = 'SI_PSBT_HEADER_GENERAL',
    BTN_EDIT_LAYOUT     = 'SI_PSBT_BTN_EDIT_LAYOUT',
    BTN_DEMO            = 'SI_PSBTBTN_DEMO',
    HEADER_MODULES      = 'SI_PSBT_HEADER_MODULES',
    HEADER_COLORS       = 'SI_PSBT_HEADER_COLORS',
    COLOR_HEALING       = 'SI_PSBT_COLOR_HEALING',
    COLOR_DAMAGE        = 'SI_PSBT_COLOR_DAMAGE',
    COLOR_NORMAL        = 'SI_PSBT_COLOR_NORMAL',
    HEADER_NORMAL_FONT  = 'SI_PSBT_HEADER_NORMAL_FONT',
    HEADER_STICKY_FONT  = 'SI_PSBT_HEADER_STICKY_FONT',
    FONT_FACE           = 'SI_PSBT_FONT_FACE',
    FONT_SIZE           = 'SI_PSBT_FONT_SIZE',
    FONT_DECORATION     = 'SI_PSBT_FONT_DECORATION',

    SCROLL_ARC          = 'SI_PSBT_SCROLL_ARC',
    SCROLL_ICON_POS     = 'SI_PSBT_SCROLL_ICON_POS',
    SCROLL_DIRECTION    = 'SI_PSBT_SCROLL_DIRECTION',

    -- scroll areas
    AREA_INCOMING       = 'SI_PSBT_AREA_INCOMING',
    AREA_OUTGOING       = 'SI_PSBT_AREA_OUTGOING',
    AREA_STATIC         = 'SI_PSBT_AREA_STATIC',
    AREA_NOTIFICATION   = 'SI_PSBT_AREA_NOTIFICATION',

    -- Module names
    MODULE_COOLDOWNS    = 'SI_PSBT_MODULE_COOLDOWNS',
    MODULE_COMBAT       = 'SI_PSBT_MODULE_COMBAT',
    MODULE_AURAS        = 'SI_PSBT_MODULE_AURAS',
    MODULE_XP           = 'SI_PSBT_MODULE_XP',
    MODULE_LOW          = 'SI_PSBT_MODULE_LOW',
    MODULE_ULTIMATE     = 'SI_PSBT_MODULE_ULTIMATE',
    MODULE_DEBUG        = 'SI_PSBT_MODULE_DEBUG',
    MODULE_SKILLS       = 'SI_PSBT_MODULE_SKILLS',

    --- THESE DON'T REQUIRE LOCALIZATION
    ABSORED             = 'SI_SCT_EVENT_ABSORED',
    BLADE_TURN          = 'SI_SCT_EVENT_BLADE_TURN',
    BLOCK               = 'SI_SCT_EVENT_BLOCK',
    BLOCK_DAMAGE        = 'SI_SCT_EVENT_BLOCKED_DAMAGE',
    SHIELDED            = 'SI_SCT_EVENT_DAMAGE_SHIELDED',
    DEFENDED            = 'SI_SCT_EVENT_DEFENDED',
    DODGE               = 'SI_SCT_EVENT_DODGE',
    MISS                = 'SI_SCT_EVENT_MISS',
    PARRY               = 'SI_SCT_EVENT_PARRY',
    RESIST              = 'SI_SCT_EVENT_RESIST',
    RESIST_PARTIAL      = 'SI_SCT_EVENT_PARTIAL_RESIST',
    DISORIENTED         = 'SI_SCT_EVENT_DISORIENTED',
    DISARMED            = 'SI_SCT_EVENT_DISARMED',
    FEARED              = 'SI_SCT_EVENT_FEARED',
}
