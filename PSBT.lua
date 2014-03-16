------------------------------------------------
-- Pawkette's Scrolling Battle Text
--
-- @classmod PSBT
-- @author Pawkette ( pawkette.heals@gmail.com )
--[[
The MIT License (MIT)

Copyright (c) 2014 Pawkette

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
------------------------------------------------
local PSBT = ZO_ObjectPool:Subclass()
PSBT._modules  = {}
PSBT._areas    = {}

local CBM = CALLBACK_MANAGER

function PSBT:New( ... )
    local result = ZO_ObjectPool.New( self, PSBT.CreateLabel, function( ... ) self:ResetLabel( ... ) end )
    result:Initialize( ... )
    return result
end

function PSBT:Initialize( control )
    self.control = control
    self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( _, addon ) self:OnLoaded( addon ) end )
end

function PSBT:OnLoaded( addon )
    if ( addon ~= 'PSBT' ) then
        return
    end

    print( 'Loading PSBT' )


    self._areas[ PSBT_AREAS.INCOMING ]     = self.control:GetNamedChild( PSBT_AREAS.INCOMING )
    self._areas[ PSBT_AREAS.OUTGOING ]     = self.control:GetNamedChild( PSBT_AREAS.OUTGOING )
    self._areas[ PSBT_AREAS.STATIC ]       = self.control:GetNamedChild( PSBT_AREAS.STATIC )
    self._areas[ PSBT_AREAS.NOTIFICATION ] = self.control:GetNamedChild( PSBT_AREAS.NOTIFICATION )

    print( self._areas )
    for k,v in pairs( self._areas ) do
        print( tostring( k ) .. ' = ' ..tostring( v ) )
    end


    CBM:FireCallbacks( PSBT_EVENTS.LOADED, self )

    self.control:SetHandler( 'OnUpdate', function( _, frameTime ) self:OnUpdate( frameTime ) end )
end

function PSBT:OnUpdate( frameTime )
    for k,v in pairs( self._modules ) do
        v:OnUpdate( frameTime )
    end

    for k,label in pairs( self:GetActiveObjects() ) do
        if ( not label:IsVisible() ) then
            self:ReleaseObject( k )
        end
    end
end

function PSBT:CreateLabel()
    return PSBT_Label:New( self )
end

function PSBT:ResetLabel( label )
    label:Finalize()
end

function PSBT:RegisterModule( identity, class )
    if ( self._modules[ identity ] ) then
        return
    end

    print ( 'PSBT:RegisterModule %s', identity )
    self._modules[ identity ] = class
end

function PSBT:GetModule( identity )
    if ( not self._modules[ identity ] ) then
        return nil
    end

    return self._modules[ identity ]
end

function PSBT:GetSetting( name )
    local settings = self:GetModule( PSBT_MODULES.SETTINGS )
    return settings:GetSetting( name )
end

function PSBT:SetSetting( name, value )
    local settings = self:GetModule( PSBT_MODULES.SETTINGS )
    settings:SetSetting( name, value )
end

function PSBT:RegisterForEvent( event, callback )
    self.control:RegisterForEvent( event, callback )
end

function PSBT:UnregisterForEvent( event, callback )
    self.control:UnregisterForEvent( event, callback )
end

function PSBT:NewEvent( scrollArea, sticky, icon, text )
    local entry = self:AcquireObject()

    local area = self._areas[ scrollArea ]

    local height = area:GetHeight()
    local duration = 1
    local relativePoint = nil
    if ( scrollArea == PSBT_AREAS.NOTIFICATION ) then
        relativePoint = TOP
        duration = height * 20
    elseif ( scrollArea == PSBT_AREAS.INCOMING ) then
        relativePoint = BOTTOM
        height = height * -1
    elseif ( scrollArea == PSBT_AREAS.OUTGOING ) then
        relativePoint = TOP
    elseif ( scrollArea == PSBT_AREAS.STATIC ) then
        relativePoint = BOTTOM
        duration = height * 50
        height = height * -1
    end

    entry.control:SetAnchor( CENTER, area, relativePoint )

    entry:SetText( text ) 
    entry:SetTexture( icon )
    entry:Play( height, duration )
end

-- LEAVE ME THE FUARK ALONE
function Initialized( control )
    _G.PSBT = PSBT:New( control )
end
