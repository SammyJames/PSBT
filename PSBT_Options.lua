local LAM = LibStub( 'LibAddonMenu-1.0' )
if ( not LAM ) then return end

local LMP = LibStub( 'LibMediaProvider-1.0' )
if ( not LMP ) then return end

local PSBT_Module       = PSBT_Module
local PSBT_Options      = PSBT_Module:Subclass()
local CBM               = CALLBACK_MANAGER

local PSBT_MODULES      = PSBT_MODULES
local PSBT_EVENTS       = PSBT_EVENTS

local decorations = { 'none', 'soft-shadow-thin', 'soft-shadow-thick', 'shadow' }

function PSBT_Options:Initialize( root )
    PSBT_Module.Initialize( self, root ) 
    self:InitialzeControlPanel()
end

function PSBT_Options:InitialzeControlPanel()
    self.config_panel = LAM:CreateControlPanel( '_psbt', 'PSBT' )
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED, 
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.OPTIONS, PSBT_Options:New( psbt ) )
    end)