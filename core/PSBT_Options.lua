local LAM = LibStub( 'LibAddonMenu-2.0' )
if ( not LAM ) then return end

local LMP = LibStub( 'LibMediaProvider-1.0' )
if ( not LMP ) then return end

local PSBT              = PSBT
local ModuleProto       = PSBT.ModuleProto
local PSBT_Options      = ModuleProto:Subclass()
local CBM               = CALLBACK_MANAGER

local PSBT_MODULES      = PSBT.MODULES
local PSBT_STRINGS      = PSBT.STRINGS
local PSBT_EVENTS       = PSBT.EVENTS
local PSBT_SETTINGS     = PSBT.SETTINGS
local PSBT_ICON_SIDE    = PSBT.ICON_SIDE
local PSBT_AREAS        = PSBT.AREAS
local PSBT_SCROLL_DIRECTIONS = PSBT.SCROLL_DIRECTIONS

local kVersion          = 1.0

local decorations       = { 'none', 'outline', 'thin-outline', 'thick-outline', 'soft-shadow-thin', 'soft-shadow-thick', 'shadow' }
local iconside          = { PSBT_ICON_SIDE.NONE, PSBT_ICON_SIDE.LEFT, PSBT_ICON_SIDE.RIGHT }
local direction         = { PSBT_SCROLL_DIRECTIONS.UP, PSBT_SCROLL_DIRECTIONS.DOWN }

function PSBT_Options:Initialize( root )
    ModuleProto.Initialize( self, root ) 
    self:InitializeControlPanel()
end

function PSBT_Options:InitializeControlPanel()

    LAM:RegisterAddonPanel( 'PSBT_Config', 
        { 
            type = 'panel', 
            name = 'PSBT', 
            author = '|cFF66CCPawkette|r', 
            version = '100010', 
            slashCommand = '/psbt', 
            registerForRefresh = true,
            registerForDefaults = true 
        } )

    self.config_mode = false

    local options = 
    {
        [ 1 ] = 
        {
            type = 'header',
            name = GetString( _G[ PSBT_STRINGS.HEADER_GENERAL ] ),
            width = 'full',
        },
        [ 2 ] = 
        {
            type = 'button',
            name = GetString( _G[ PSBT_STRINGS.BTN_EDIT_LAYOUT ] ),
            width = 'full',
            func = function() 
                CBM:FireCallbacks( PSBT_EVENTS.CONFIG, not self.config_mode )
                self.config_mode = not self.config_mode
                end,
        },
        [ 3 ] = 
        {
            type = 'button',
            name = GetString( _G[ PSBT_STRINGS.BTN_DEMO ] ),
            width = 'full',
            func = function()
                CBM:FireCallbacks( PSBT_EVENTS.DEMO )
                end,
        },
        [ 4 ] = 
        {
            type = 'button',
            name = GetString( _G[ PSBT_STRINGS.MODULE_DEBUG ] ),
            width = 'full',
            func = function()
                self._root.DebugMode = not self._root.DebugMode
                end,
            disabled = function() return not self._root:GetSetting( PSBT_MODULES.DEBUG ) end,
        },
        [ 5 ] = 
        {
            type = 'submenu',
            name = GetString( _G[ PSBT_STRINGS.HEADER_MODULES ] ),
            controls = 
            {
                [ 1 ] = 
                {
                    type = 'checkbox',
                    name = GetString( _G[ PSBT_STRINGS.MODULE_COOLDOWNS ] ),
                    getFunc = function() return self._root:GetSetting( PSBT_MODULES.COOLDOWNS ) end,
                    setFunc = function( toggle )
                        self._root:SetSetting( PSBT_MODULES.COOLDOWNS, toggle )
                        self._root:ToggleModule( PSBT_MODULES.COOLDOWNS )
                        end,
                },
                [ 2 ] = 
                {
                    type = 'checkbox',
                    name = GetString( _G[ PSBT_STRINGS.MODULE_COMBAT ] ),
                    getFunc = function() return self._root:GetSetting( PSBT_MODULES.COMBAT ) end,
                    setFunc = function( toggle ) 
                        self._root:SetSetting( PSBT_MODULES.COMBAT, toggle )
                        self._root:ToggleModule( PSBT_MODULES.COMBAT )
                        end,
                },
                [ 3 ] = 
                {
                    type = 'checkbox',
                    name = GetString( _G[ PSBT_STRINGS.MODULE_AURAS ] ),
                    getFunc = function() return self._root:GetSetting( PSBT_MODULES.AURAS ) end,
                    setFunc = function( toggle )
                        self._root:SetSetting( PSBT_MODULES.AURAS, toggle )
                        self._root:ToggleModule( PSBT_MODULES.AURAS )
                        end,
                },
                [ 4 ] = 
                {
                    type = 'checkbox',
                    name = GetString( _G[ PSBT_STRINGS.MODULE_XP ] ),
                    getFunc = function() return self._root:GetSetting( PSBT_MODULES.XP ) end,
                    setFunc = function( toggle )  
                        self._root:SetSetting( PSBT_MODULES.XP, toggle )
                        self._root:ToggleModule( PSBT_MODULES.XP )
                        end,
                },
                [ 5 ] = 
                {
                    type = 'checkbox',
                    name = GetString( _G[ PSBT_STRINGS.MODULE_LOW ] ),
                    getFunc = function() return self._root:GetSetting( PSBT_MODULES.LOW ) end,
                    setFunc = function( toggle )
                        self._root:SetSetting( PSBT_MODULES.LOW, toggle )
                        self._root:ToggleModule( PSBT_MODULES.LOW )
                        end,
                },
                [ 6 ] = 
                {
                    type = 'checkbox',
                    name = GetString( _G[ PSBT_STRINGS.MODULE_ULTIMATE ] ),
                    getFunc = function() return self._root:GetSetting( PSBT_MODULES.ULTIMATE ) end,
                    setFunc = function( toggle )
                        self._root:SetSetting( PSBT_MODULES.ULTIMATE, toggle )
                        self._root:ToggleModule( PSBT_MODULES.ULTIMATE )
                        end,
                },
                [ 7 ] = 
                {
                    type = 'checkbox',
                    name = GetString( _G[ PSBT_STRINGS.MODULE_DEBUG ] ),
                    getFunc = function() return self._root:GetSetting( PSBT_MODULES.DEBUG ) end,
                    setFunc = function( toggle )
                        self._root:SetSetting( PSBT_MODULES.DEBUG, toggle )
                        self._root:ToggleModule( PSBT_MODULES.DEBUG )
                        end,
                },
            },
        },
        [ 6 ] =
        {
            type = 'submenu',
            name = GetString( _G[ PSBT_STRINGS.HEADER_COLORS ] ),
            controls =
            {
                [ 1 ] =
                {
                    type = 'colorpicker',
                    name = GetString( _G[ PSBT_STRINGS.COLOR_HEALING ] ),
                    getFunc = function() return unpack( self._root:GetSetting( PSBT_SETTINGS.healing_color ) ) end,
                    setFunc = function( r, g, b, a )
                        self._root:SetSetting( PSBT_SETTINGS.healing_color, { r, g, b, a } )
                        end,
                },
                [ 2 ] = 
                {
                    type = 'colorpicker',
                    name = GetString( _G[ PSBT_STRINGS.COLOR_DAMAGE ] ),
                    getFunc = function() return unpack( self._root:GetSetting( PSBT_SETTINGS.damage_color ) ) end,
                    setFunc = function( r, g, b, a ) 
                        self._root:SetSetting( PSBT_SETTINGS.damage_color, { r, g, b, a } )
                        end,
                },
                [ 3 ] =
                {
                    type = 'colorpicker',
                    name = GetString( _G[ PSBT_STRINGS.COLOR_NORMAL ] ),
                    getFunc = function() return unpack( self._root:GetSetting( PSBT_SETTINGS.normal_color ) ) end,
                    setFunc = function( r, g, b, a )
                        self._root:SetSetting( PSBT_SETTINGS.normal_color, { r, g, b, a } )
                        end,
                },
            },
        },
        [ 7 ] = 
        {
            type = 'submenu',
            name = GetString( _G[ PSBT_STRINGS.HEADER_NORMAL_FONT ] ),
            reference = 'PSBT_Config_NormalFont',
            controls =
            {
                [ 1 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.FONT_FACE ] ),
                    choices = LMP:List( LMP.MediaType.FONT ),
                    getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.normal_font ).face end,
                    setFunc = function( choice ) 
                        local current = self._root:GetSetting( PSBT_SETTINGS.normal_font )
                        current.face = tostring( choice )
                        self._root:SetSetting( PSBT_SETTINGS.normal_font, current )
                        end,
                },
                [ 2 ] = 
                {
                    type = 'editbox',
                    name = GetString( _G[ PSBT_STRINGS.FONT_SIZE ] ),
                    textType = TEXT_TYPE_NUMERIC,
                    getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.normal_font ).size end,
                    setFunc = function( size ) 
                        local current = self._root:GetSetting( PSBT_SETTINGS.normal_font )
                        current.size = tonumber( size )
                        self._root:SetSetting( PSBT_SETTINGS.normal_font, current )
                        end,
                },
                [ 3 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.FONT_DECORATION ] ),
                    choices = decorations,
                    getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.normal_font ).deco end,
                    setFunc = function( choice ) 
                        local current = self._root:GetSetting( PSBT_SETTINGS.normal_font )
                        current.deco = tostring( choice )
                        self._root:SetSetting( PSBT_SETTINGS.normal_font, current )
                        end,
                },
            },
        },
        [ 8 ] =
        {
            type = 'submenu',
            name = GetString( _G[ PSBT_STRINGS.HEADER_STICKY_FONT ] ),
            reference = 'PSBT_Config_StickyFont',
            controls = 
            {
                [ 1 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.FONT_FACE ] ),
                    choices = LMP:List( LMP.MediaType.FONT ),
                    getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.sticky_font ).face end,
                    setFunc = function( choice ) 
                        local current = self._root:GetSetting( PSBT_SETTINGS.sticky_font )
                        current.face = tostring( choice )
                        self._root:SetSetting( PSBT_SETTINGS.sticky_font, current )
                        end,
                },
                [ 2 ] = 
                {
                    type = 'editbox',
                    name = GetString( _G[ PSBT_STRINGS.FONT_SIZE ] ),
                    textType = TEXT_TYPE_NUMERIC,
                    getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.sticky_font ).size end,
                    setFunc = function( size ) 
                        local current = self._root:GetSetting( PSBT_SETTINGS.sticky_font )
                        current.size = tonumber( size )
                        self._root:SetSetting( PSBT_SETTINGS.sticky_font, current )
                        end,
                },
                [ 3 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.FONT_DECORATION ] ),
                    choices = decorations,
                    getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.sticky_font ).deco end,
                    setFunc = function( choice ) 
                        local current = self._root:GetSetting( PSBT_SETTINGS.sticky_font )
                        current.deco = tostring( choice )
                        self._root:SetSetting( PSBT_SETTINGS.sticky_font, current )
                        end,
                },
            },
        },
        [ 9 ] =
        {
            type = 'submenu',
            name = GetString( _G[ PSBT_STRINGS.AREA_INCOMING ] ),
            controls = 
            {
                [ 1 ] = 
                {
                    type = 'slider',
                    name = GetString( _G[ PSBT_STRINGS.SCROLL_ARC ] ),
                    min = -300,
                    max = 300, 
                    step = 5, 
                    getFunc = function() return self._root:GetSetting( PSBT_AREAS.INCOMING ).arc end,
                    setFunc = function( arc )
                        local current = self._root:GetSetting( PSBT_AREAS.INCOMING )
                        current.arc = tonumber( arc )
                        self._root:SetSetting( PSBT_AREAS.INCOMING, current )
                        end,
                },
                [ 2 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.SCROLL_ICON_POS ] ),
                    choices = iconside,
                    getFunc = function() return self._root:GetSetting( PSBT_AREAS.INCOMING ).icon end,
                    setFunc = function( side )
                        local current = self._root:GetSetting( PSBT_AREAS.INCOMING )
                        current.icon = tostring( side )
                        self._root:SetSetting( PSBT_AREAS.INCOMING, current )
                        end,
                },
                [ 3 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.SCROLL_DIRECTION ] ),
                    choices = direction,
                    getFunc = function() return self._root:GetSetting( PSBT_AREAS.INCOMING ).dir end,
                    setFunc = function( direction )
                        local current = self._root:GetSetting( PSBT_AREAS.INCOMING )
                        current.dir = tostring( direction )
                        self._root:SetSetting( PSBT_AREAS.INCOMING, current )
                        end,
                },
            },
        },
        [ 10 ] =
        {
            type = 'submenu',
            name = GetString( _G[ PSBT_STRINGS.AREA_OUTGOING ] ),
            controls = 
            {
                [ 1 ] = 
                {
                    type = 'slider',
                    name = GetString( _G[ PSBT_STRINGS.SCROLL_ARC ] ),
                    min = -300,
                    max = 300, 
                    step = 5, 
                    getFunc = function() return self._root:GetSetting( PSBT_AREAS.OUTGOING ).arc end,
                    setFunc = function( arc )
                        local current = self._root:GetSetting( PSBT_AREAS.OUTGOING )
                        current.arc = tonumber( arc )
                        self._root:SetSetting( PSBT_AREAS.OUTGOING, current )
                        end,
                },
                [ 2 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.SCROLL_ICON_POS ] ),
                    choices = iconside,
                    getFunc = function() return self._root:GetSetting( PSBT_AREAS.OUTGOING ).icon end,
                    setFunc = function( side )
                        local current = self._root:GetSetting( PSBT_AREAS.OUTGOING )
                        current.icon = tostring( side )
                        self._root:SetSetting( PSBT_AREAS.OUTGOING, current )
                        end,
                },
                [ 3 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.SCROLL_DIRECTION ] ),
                    choices = direction,
                    getFunc = function() return self._root:GetSetting( PSBT_AREAS.OUTGOING ).dir end,
                    setFunc = function( direction )
                        local current = self._root:GetSetting( PSBT_AREAS.OUTGOING )
                        current.dir = tostring( direction )
                        self._root:SetSetting( PSBT_AREAS.OUTGOING, current )
                        end,
                },
            },
        },
        [ 11 ] =
        {
            type = 'submenu',
            name = GetString( _G[ PSBT_STRINGS.AREA_STATIC ] ),
            controls = 
            {
                [ 1 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.SCROLL_ICON_POS ] ),
                    choices = iconside,
                    getFunc = function() return self._root:GetSetting( PSBT_AREAS.STATIC ).icon end,
                    setFunc = function( side )
                        local current = self._root:GetSetting( PSBT_AREAS.STATIC )
                        current.icon = tostring( side )
                        self._root:SetSetting( PSBT_AREAS.STATIC, current )
                        end,
                },
                [ 2 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.SCROLL_DIRECTION ] ),
                    choices = direction,
                    getFunc = function() return self._root:GetSetting( PSBT_AREAS.STATIC ).dir end,
                    setFunc = function( direction )
                        local current = self._root:GetSetting( PSBT_AREAS.STATIC )
                        current.dir = tostring( direction )
                        self._root:SetSetting( PSBT_AREAS.STATIC, current )
                        end,
                },
            },
        },
        [ 12 ] =
        {
            type = 'submenu',
            name = GetString( _G[ PSBT_STRINGS.AREA_NOTIFICATION ] ),
            controls = 
            {
                [ 1 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.SCROLL_ICON_POS ] ),
                    choices = iconside,
                    getFunc = function() return self._root:GetSetting( PSBT_AREAS.NOTIFICATION ).icon end,
                    setFunc = function( side )
                        local current = self._root:GetSetting( PSBT_AREAS.NOTIFICATION )
                        current.icon = tostring( side )
                        self._root:SetSetting( PSBT_AREAS.NOTIFICATION, current )
                        end,
                },
                [ 2 ] =
                {
                    type = 'dropdown',
                    name = GetString( _G[ PSBT_STRINGS.SCROLL_DIRECTION ] ),
                    choices = direction,
                    getFunc = function() return self._root:GetSetting( PSBT_AREAS.NOTIFICATION ).dir end,
                    setFunc = function( direction )
                        local current = self._root:GetSetting( PSBT_AREAS.NOTIFICATION )
                        current.dir = tostring( direction )
                        self._root:SetSetting( PSBT_AREAS.NOTIFICATION, current )
                        end,
                },
            },
        },
    }   

    LAM:RegisterOptionControls( 'PSBT_Config', options )
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.OPTIONS, PSBT_Options, kVersion )
    end )