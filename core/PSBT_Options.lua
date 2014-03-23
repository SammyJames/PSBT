local LAM = LibStub( 'LibAddonMenu-1.0' )
if ( not LAM ) then return end

local LMP = LibStub( 'LibMediaProvider-1.0' )
if ( not LMP ) then return end

local PSBT_Module       = PSBT_Module
local PSBT_Options      = PSBT_Module:Subclass()
local CBM               = CALLBACK_MANAGER

local PSBT_MODULES      = PSBT_MODULES
local PSBT_EVENTS       = PSBT_EVENTS
local PSBT_SETTINGS     = PSBT_SETTINGS
local PSBT_ICON_SIDE    = PSBT_ICON_SIDE

local kVersion          = 1.0

local decorations = { 'none', 'soft-shadow-thin', 'soft-shadow-thick', 'shadow' }
local iconside = { PSBT_ICON_SIDE.NONE, PSBT_ICON_SIDE.LEFT, PSBT_ICON_SIDE.RIGHT }
local direction = { PSBT_SCROLL_DIRECTIONS.UP, PSBT_SCROLL_DIRECTIONS.DOWN }

function PSBT_Options:Initialize( root )
    PSBT_Module.Initialize( self, root ) 
    self:InitializeControlPanel()
end

function PSBT_Options:InitializeControlPanel()
    self.config_panel = LAM:CreateControlPanel( '_psbt', 'PSBT' )
    self.config_mode = false

    LAM:AddHeader( self.config_panel, '_psbt_layout', 'Layout' )
    LAM:AddButton( self.config_panel, '_psbt_editlayout_btn', 'Edit Layout', '', 
        function() 
            CBM:FireCallbacks( PSBT_EVENTS.CONFIG, not self.config_mode )
            self.config_mode = not self.config_mode
        end )

    -- normal font
    local normal_font = LAM:AddHeader( self.config_panel, '_psbt_normal_font_header', 'Normal Font' ):GetNamedChild( 'Label' )
    normal_font:SetFont( self._root:FormatFont( self._root:GetSetting( PSBT_SETTINGS.normal_font ) ) )
    LAM:AddDropdown( self.config_panel, '_psbt_normal_font_dd', 'Font:', '', LMP:List( LMP.MediaType.FONT ), 
        function() 
            return self._root:GetSetting( PSBT_SETTINGS.normal_font ).face 
        end, 
        function( selection )  
            local current = self._root:GetSetting( PSBT_SETTINGS.normal_font )
            current.face = selection
            self._root:SetSetting( PSBT_SETTINGS.normal_font, current )
            normal_font:SetFont( self._root:FormatFont( current ) )
        end )

    LAM:AddSlider( self.config_panel, '_psbt_normal_font_slider', 'Size:', '', 5, 50, 1, 
        function() 
            return self._root:GetSetting( PSBT_SETTINGS.normal_font ).size
        end, 
        function( size ) 
            local current = self._root:GetSetting( PSBT_SETTINGS.normal_font )
            current.size = size
            self._root:SetSetting( PSBT_SETTINGS.normal_font, current )
            normal_font:SetFont( self._root:FormatFont( current ) )
        end )

    LAM:AddDropdown( self.config_panel, '_psbt_normal_font_deco_dd', 'Decoration:', '', decorations,
        function() 
            return self._root:GetSetting( PSBT_SETTINGS.normal_font ).deco end,
        function( selection ) 
             local current = self._root:GetSetting( PSBT_SETTINGS.normal_font )
            current.deco = selection
            self._root:SetSetting( PSBT_SETTINGS.normal_font, current )
            normal_font:SetFont( self._root:FormatFont( current ) )
        end )

    -- sticky
    local sticky_font = LAM:AddHeader( self.config_panel, '_psbt_sticky_font_header', 'Sticky Font' ):GetNamedChild( 'Label' )
    sticky_font:SetFont( self._root:FormatFont( self._root:GetSetting( PSBT_SETTINGS.sticky_font ) ) )
    LAM:AddDropdown( self.config_panel, '_psbt_sticky_font_dd', 'Font:', '', LMP:List( LMP.MediaType.FONT ), 
        function() 
            return self._root:GetSetting( PSBT_SETTINGS.sticky_font ).face 
        end, 
        function( selection )  
            local current = self._root:GetSetting( PSBT_SETTINGS.sticky_font )
            current.face = selection
            self._root:SetSetting( PSBT_SETTINGS.sticky_font, current )
            sticky_font:SetFont( self._root:FormatFont( current ) )
        end )

    LAM:AddSlider( self.config_panel, '_psbt_sticky_font_slider', 'Size:', '', 5, 50, 1, 
        function() 
            return self._root:GetSetting( PSBT_SETTINGS.sticky_font ).size
        end, 
        function( size ) 
            local current = self._root:GetSetting( PSBT_SETTINGS.sticky_font )
            current.size = size
            self._root:SetSetting( PSBT_SETTINGS.sticky_font, current )
            sticky_font:SetFont( self._root:FormatFont( current ) )
        end )

    LAM:AddDropdown( self.config_panel, '_psbt_sticky_font_deco_dd', 'Decoration:', '', decorations,
        function() 
            return self._root:GetSetting( PSBT_SETTINGS.sticky_font ).deco end,
        function( selection ) 
            local current = self._root:GetSetting( PSBT_SETTINGS.sticky_font )
            current.deco = selection
            self._root:SetSetting( PSBT_SETTINGS.sticky_font, current )
            sticky_font:SetFont( self._root:FormatFont( current ) )
        end )

    -- INCOMING
    LAM:AddHeader( self.config_panel, '_psbt_incoming', 'Incoming' )

    LAM:AddSlider( self.config_panel, '_psbt_incoming_arc_slider', 'Arc: ', 'How much should the text curve?', 
        -300, 300, 5, 
        function() 
            return self._root:GetSetting( PSBT_AREAS.INCOMING ).arc 
        end,
        function( selection )
            local current = self._root:GetSetting( PSBT_AREAS.INCOMING )
            current.arc = selection
            self._root:SetSetting( PSBT_AREAS.INCOMING, current )
        end )

    LAM:AddDropdown( self.config_panel, '_psbt_incoming_iconside_dd', 'Icon Side:', '', iconside,
        function() 
            return self._root:GetSetting( PSBT_AREAS.INCOMING ).icon end,
        function( selection ) 
            local current = self._root:GetSetting( PSBT_AREAS.INCOMING )
            current.icon = selection
            self._root:SetSetting( PSBT_AREAS.INCOMING, current )
        end )

    LAM:AddDropdown( self.config_panel, '_psbt_incoming_direction_dd', 'Direction:', '', direction,
        function() 
            return self._root:GetSetting( PSBT_AREAS.INCOMING ).dir end,
        function( selection ) 
            local current = self._root:GetSetting( PSBT_AREAS.INCOMING )
            current.dir = selection
            self._root:SetSetting( PSBT_AREAS.INCOMING, current )
        end )

    -- OUTGOING
    LAM:AddHeader( self.config_panel, '_psbt_outgoing', 'Outgoing' )

    LAM:AddSlider( self.config_panel, '_psbt_outgoing_arc_slider', 'Arc: ', 'How much should the text curve?', 
        -300, 300, 5, 
        function() 
            return self._root:GetSetting( PSBT_AREAS.OUTGOING ).arc 
        end,
        function( selection )
            local current = self._root:GetSetting( PSBT_AREAS.OUTGOING )
            current.arc = selection
            self._root:SetSetting( PSBT_AREAS.OUTGOING, current )
        end )
    
    LAM:AddDropdown( self.config_panel, '_psbt_outgoing_iconside_dd', 'Icon Side:', '', iconside,
        function() 
            return self._root:GetSetting( PSBT_AREAS.OUTGOING ).icon end,
        function( selection ) 
            local current = self._root:GetSetting( PSBT_AREAS.OUTGOING )
            current.icon = selection
            self._root:SetSetting( PSBT_AREAS.OUTGOING, current )
        end )


    LAM:AddDropdown( self.config_panel, '_psbt_outgoing_direction_dd', 'Direction:', '', direction,
        function() 
            return self._root:GetSetting( PSBT_AREAS.OUTGOING ).dir end,
        function( selection ) 
            local current = self._root:GetSetting( PSBT_AREAS.OUTGOING )
            current.dir = selection
            self._root:SetSetting( PSBT_AREAS.OUTGOING, current )
        end )

    -- STATIC
    LAM:AddHeader( self.config_panel, '_psbt_static', 'Static' )
    LAM:AddDropdown( self.config_panel, '_psbt_static_iconside_dd', 'Icon Side:', '', iconside,
        function() 
            return self._root:GetSetting( PSBT_AREAS.STATIC ).icon end,
        function( selection ) 
            local current = self._root:GetSetting( PSBT_AREAS.STATIC )
            current.icon = selection
            self._root:SetSetting( PSBT_AREAS.STATIC, current )
        end )

    LAM:AddDropdown( self.config_panel, '_psbt_static_direction_dd', 'Direction:', '', direction,
        function() 
            return self._root:GetSetting( PSBT_AREAS.STATIC ).dir end,
        function( selection ) 
            local current = self._root:GetSetting( PSBT_AREAS.STATIC )
            current.dir = selection
            self._root:SetSetting( PSBT_AREAS.STATIC, current )
        end )

    -- NOTIFICATIONS
    LAM:AddHeader( self.config_panel, '_psbt_notifications', 'Notifications' )
    LAM:AddDropdown( self.config_panel, '_psbt_notifications_iconside_dd', 'Icon Side:', '', iconside,
        function() 
            return self._root:GetSetting( PSBT_AREAS.NOTIFICATION ).icon end,
        function( selection ) 
            local current = self._root:GetSetting( PSBT_AREAS.NOTIFICATION )
            current.icon = selection
            self._root:SetSetting( PSBT_AREAS.NOTIFICATION, current )
        end )

    LAM:AddDropdown( self.config_panel, '_psbt_notifications_direction_dd', 'Direction:', '', direction,
        function() 
            return self._root:GetSetting( PSBT_AREAS.NOTIFICATION ).dir end,
        function( selection ) 
            local current = self._root:GetSetting( PSBT_AREAS.NOTIFICATION )
            current.dir = selection
            self._root:SetSetting( PSBT_AREAS.NOTIFICATION, current )
        end )


end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.OPTIONS, PSBT_Options:New( psbt ), kVersion )
    end)