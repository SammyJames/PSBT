PSBT_Module             = ZO_Object:Subclass()

local CBM = CALLBACK_MANAGER

function PSBT_Module:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function PSBT_Module:Initialize( root )
    self._root = root
end

function PSBT_Module:RegisterForEvent( event, callback )
    self._root:RegisterForEvent( event, callback )
end

function PSBT_Module:UnregisterForEvent( event, callback )
    self._root:UnregisterForEvent( event, callback )
end

function PSBT_Module:OnUpdate( frametime )
    -- stub, implement if needed
end

function PSBT_Module:NewEvent( scrollArea, sticky, icon, text, color )
    self._root:NewEvent( scrollArea, sticky, icon, text, color )
end