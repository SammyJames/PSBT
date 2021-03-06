local CBM           = CALLBACK_MANAGER
local CreateString  = ZO_CreateStringId
local PSBT_EVENTS   = PSBT.EVENTS
local PSBT_STRINGS  = PSBT.STRINGS

--[[
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
]]

CBM:RegisterCallback( PSBT_EVENTS.INITIALIZE, function() 

print( 'PSBT Locale: DE' )

CreateString( PSBT_STRINGS.FALL_DAMAGE,     '<<1>> rückläufig' )
CreateString( PSBT_STRINGS.CANNOT_SEE,      'Kann nicht siehst' )
CreateString( PSBT_STRINGS.DAMAGE_CRIT,     '<<1>> !' )
CreateString( PSBT_STRINGS.DAMAGE,          '<<1>>')
CreateString( PSBT_STRINGS.HEALING_CRIT,    '+<<1>> !')
CreateString( PSBT_STRINGS.HEALING,         '+<<1>>')
CreateString( PSBT_STRINGS.KILLING_BLOW,    '|cCC7D5E<<1>>|r gestorben !')
CreateString( PSBT_STRINGS.FALLING,         'Rückläufig')
CreateString( PSBT_STRINGS.INTERCEPTED,     'Abgehörte')
CreateString( PSBT_STRINGS.BUSY,            'Beschäftigt')
CreateString( PSBT_STRINGS.IMMUNE,          'Immun')
CreateString( PSBT_STRINGS.INTERRUPT,       'Unterbrechen')
CreateString( PSBT_STRINGS.ULTIMATE_GAIN,   '<<1>> letzte')
CreateString( PSBT_STRINGS.ULTIMATE_READY,  'Ultimative bereit !')
CreateString( PSBT_STRINGS.LOW_SOMETHING,   '<<1>> niedrig ! (<<2>>)')
CreateString( PSBT_STRINGS.AURA_GAINED,     '<<1>> gewonnene')
CreateString( PSBT_STRINGS.AURA_FADES,      '<<1>> fades')
CreateString( PSBT_STRINGS.ENERGIZE,        '+<<1>> (<<2>>)')
CreateString( PSBT_STRINGS.DRAIN,           '-<<1>> (<<2>>)')

end )