local LAM = LibStub( 'LibAddonMenu-2.0' )
if ( not LAM ) then return end

local LMP = LibStub( 'LibMediaProvider-1.0' )
if ( not LMP ) then return end

local PSBT              = PSBT
local ModuleProto       = PSBT.ModuleProto
local PSBT_Options      = ModuleProto:Subclass()
local CBM               = CALLBACK_MANAGER

local PSBT_MODULES      = PSBT_MODULES
local PSBT_EVENTS       = PSBT_EVENTS
local PSBT_SETTINGS     = PSBT_SETTINGS
local PSBT_ICON_SIDE    = PSBT_ICON_SIDE

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
            name = 'Layout',
            width = 'full',
        },
        [ 2 ] = 
        {
            type = 'button',
            name = 'Edit Layout',
            width = 'full',
            func = function() 
                CBM:FireCallbacks( PSBT_EVENTS.CONFIG, not self.config_mode )
                self.config_mode = not self.config_mode
                end,
        },
        [ 3 ] = 
        {
            type = 'button',
            name = 'Demo',
            width = 'full',
            func = function()
                CBM:FireCallbacks( PSBT_EVENTS.DEMO )
                end,
        },
        [ 4 ] = 
        {
            type = 'button',
            name = 'Debug',
            width = 'full',
            func = function()
                self._root.DebugMode = not self._root.DebugMode
                end,
        },
        [ 5 ] =
        {
            type = 'header',
            name = 'Colors',
            width = 'full',
        },
        [ 6 ] =
        {
            type = 'colorpicker',
            name = 'Healing',
            getFunc = function() return unpack( self._root:GetSetting( PSBT_SETTINGS.healing_color ) ) end,
            setFunc = function( r, g, b, a )
                self._root:SetSetting( PSBT_SETTINGS.healing_color, { r, g, b, a } )
                end,
        },
        [ 7 ] = 
        {
            type = 'colorpicker',
            name = 'Damage',
            getFunc = function() return unpack( self._root:GetSetting( PSBT_SETTINGS.damage_color ) ) end,
            setFunc = function( r, g, b, a ) 
                self._root:SetSetting( PSBT_SETTINGS.damage_color, { r, g, b, a } )
                end,
        },
        [ 8 ] =
        {
            type = 'colorpicker',
            name = 'Normal',
            getFunc = function() return unpack( self._root:GetSetting( PSBT_SETTINGS.normal_color ) ) end,
            setFunc = function( r, g, b, a )
                self._root:SetSetting( PSBT_SETTINGS.normal_color, { r, g, b, a } )
                end,
        },
        [ 9 ] = 
        {
            type = 'header',
            name = 'Normal Font',
            width = 'full',
            reference = 'PSBT_Config_NormalFont',
        },
        [ 10 ] =
        {
            type = 'dropdown',
            name = 'Font',
            choices = LMP:List( LMP.MediaType.FONT ),
            getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.normal_font ).face end,
            setFunc = function( choice ) 
                local current = self._root:GetSetting( PSBT_SETTINGS.normal_font )
                current.face = tostring( choice )
                self._root:SetSetting( PSBT_SETTINGS.normal_font, current )
                end,
        },
        [ 11 ] = 
        {
            type = 'editbox',
            name = 'Size',
            textType = TEXT_TYPE_NUMERIC,
            getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.normal_font ).size end,
            setFunc = function( size ) 
                local current = self._root:GetSetting( PSBT_SETTINGS.normal_font )
                current.size = tonumber( size )
                self._root:SetSetting( PSBT_SETTINGS.normal_font, current )
                end,
        },
        [ 12 ] =
        {
            type = 'dropdown',
            name = 'Decoration',
            choices = decorations,
            getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.normal_font ).deco end,
            setFunc = function( choice ) 
                local current = self._root:GetSetting( PSBT_SETTINGS.normal_font )
                current.deco = tostring( choice )
                self._root:SetSetting( PSBT_SETTINGS.normal_font, current )
                end,
        },
        [ 13 ] =
        {
            type = 'header',
            name = 'Sticky Font',
            width = 'full',
            reference = 'PSBT_Config_StickyFont',
        },
        [ 14 ] =
        {
            type = 'dropdown',
            name = 'Font',
            choices = LMP:List( LMP.MediaType.FONT ),
            getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.sticky_font ).face end,
            setFunc = function( choice ) 
                local current = self._root:GetSetting( PSBT_SETTINGS.sticky_font )
                current.face = tostring( choice )
                self._root:SetSetting( PSBT_SETTINGS.sticky_font, current )
                end,
        },
        [ 15 ] = 
        {
            type = 'editbox',
            name = 'Size',
            textType = TEXT_TYPE_NUMERIC,
            getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.sticky_font ).size end,
            setFunc = function( size ) 
                local current = self._root:GetSetting( PSBT_SETTINGS.sticky_font )
                current.size = tonumber( size )
                self._root:SetSetting( PSBT_SETTINGS.sticky_font, current )
                end,
        },
        [ 16 ] =
        {
            type = 'dropdown',
            name = 'Decoration',
            choices = decorations,
            getFunc = function() return self._root:GetSetting( PSBT_SETTINGS.sticky_font ).deco end,
            setFunc = function( choice ) 
                local current = self._root:GetSetting( PSBT_SETTINGS.sticky_font )
                current.deco = tostring( choice )
                self._root:SetSetting( PSBT_SETTINGS.sticky_font, current )
                end,
        },
        [ 17 ] =
        {
            type = 'submenu',
            name = 'Incoming',
            controls = 
            {
                [ 1 ] = 
                {
                    type = 'slider',
                    name = 'Arc',
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
                    name = 'Icon Position',
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
                    name = 'Direction',
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
        [ 18 ] =
        {
            type = 'submenu',
            name = 'Outgoing',
            controls = 
            {
                [ 1 ] = 
                {
                    type = 'slider',
                    name = 'Arc',
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
                    name = 'Icon Position',
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
                    name = 'Direction',
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
        [ 19 ] =
        {
            type = 'submenu',
            name = 'Static',
            controls = 
            {
                [ 1 ] =
                {
                    type = 'dropdown',
                    name = 'Icon Position',
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
                    name = 'Direction',
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
        [ 20 ] =
        {
            type = 'submenu',
            name = 'Notification',
            controls = 
            {
                [ 1 ] =
                {
                    type = 'dropdown',
                    name = 'Icon Position',
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
                    name = 'Direction',
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
        psbt:RegisterModule( PSBT_MODULES.OPTIONS, PSBT_Options:New( psbt ), kVersion )
    end )