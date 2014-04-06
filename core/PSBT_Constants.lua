PSBT_MODULES =
{
    SETTINGS            = 'settings', -- saved variables 
    OPTIONS             = 'options',  -- options panel
    COOLDOWNS           = 'cooldowns',
    COMBAT              = 'combat',
    AURAS               = 'auras',
    XP                  = 'experience',
    LOW                 = 'lowsomething',
    ULTIMATE            = 'ultimate',
    LOCALE              = 'locale',
}

PSBT_AREAS = 
{
    NOTIFICATION        = '_Notifications',
    INCOMING            = '_Incoming',
    OUTGOING            = '_Outgoing',
    STATIC              = '_Static'
}

PSBT_SETTINGS =
{
    normal_font         = 'normal_font',
    sticky_font         = 'sticky_font',
    damage_color        = 'damage_color',
    healing_color       = 'healing_color',
    normal_color        = 'normal_color'
}

PSBT_EVENTS = 
{
    INITIALIZE          = 'PSBT_INITIALIZE',
    LOADED              = 'PSBT_LOADED',
    CONFIG              = 'PSBT_CONFIG', 
    REGISTER_ANIMATIONS = 'PSBT_REGISTER_ANIMATIONS',
}

PSBT_SCROLL_DIRECTIONS =
{
    UP                  = 'up',
    DOWN                = 'down',
}

PSBT_ICON_SIDE =
{
    NONE = 'none',
    LEFT = 'left',
    RIGHT = 'right',
}

PSBT_STRINGS = 
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