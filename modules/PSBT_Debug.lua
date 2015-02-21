local PSBT                  = PSBT
local ModuleProto           = PSBT.ModuleProto
local PSBT_Debug            = ModuleProto:Subclass()
PSBT_Debug._ticker          = 0.0
local CBM                   = CALLBACK_MANAGER
local kVerison              = 1.0

local PSBT_EVENTS           = PSBT.EVENTS
local PSBT_AREAS            = PSBT.AREAS
local PSBT_MODULES          = PSBT.MODULES

function PSBT_Debug:Initialize( ... )
    ModuleProto.Initialize( self, ... )
end

function PSBT_Debug:OnUpdate( tick )
    if ( self._root.DebugMode and tick - self._ticker >= 5 ) then
        local label_factory     = self._root.LabelFactory
        local incoming          = self._root._areas[ PSBT_AREAS.INCOMING ]
        local outgoing          = self._root._areas[ PSBT_AREAS.OUTGOING ]
        local static            = self._root._areas[ PSBT_AREAS.STATIC ]
        local notifcation       = self._root._areas[ PSBT_AREAS.NOTIFICATION ]

        local active_labels     = label_factory:GetTotalObjectCount()
        local fade_in_count     = self._root._fadeIn:GetTotalObjectCount()
        local fade_out_count    = self._root._fadeOut:GetTotalObjectCount()

        local incoming_count    = incoming._parabola:GetTotalObjectCount()
        local outgoing_count    = outgoing._parabola:GetTotalObjectCount()
        local static_count      = static._parabola:GetTotalObjectCount()
        local notifcation_count = notifcation._parabola:GetTotalObjectCount()

        local total_parabola = incoming_count + outgoing_count + static_count + notifcation_count
        local total_fade = fade_in_count + fade_out_count

        local total_objects = active_labels + total_parabola + total_fade

        d( '================= PSBT DEBUG =============== \n' ..
            'Total Parabola: ' .. total_parabola .. '\n' ..
            'Total Fade: ' .. total_fade .. '\n' ..
            'Total Labels: ' .. active_labels .. '\n' ..
            'Total: ' .. total_objects .. '\n' )

        self._ticker = tick
    end
end

CBM:RegisterCallback( PSBT_EVENTS.LOADED,
    function( psbt )
        psbt:RegisterModule( PSBT_MODULES.DEBUG, PSBT_Debug, kVerison )
    end )