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

local CBM               = CALLBACK_MANAGER
local PSBT_ScrollArea   = PSBT_ScrollArea
local PSBT_AREAS        = PSBT_AREAS
local PSBT_EVENTS       = PSBT_EVENTS
local PSBT_MODULES      = PSBT_MODULES

function PSBT:New( ... )
    local result = ZO_ObjectPool.New( self, PSBT.CreateLabel, function( ... ) self:ResetLabel( ... ) end )
    result:Initialize( ... )
    return result
end

function PSBT:Initialize( control )
    self.control = control

    self._areas[ PSBT_AREAS.INCOMING ]     = PSBT_ScrollArea:New( self.control, PSBT_AREAS.INCOMING,     BOTTOM )
    self._areas[ PSBT_AREAS.OUTGOING ]     = PSBT_ScrollArea:New( self.control, PSBT_AREAS.OUTGOING,     TOP )
    self._areas[ PSBT_AREAS.STATIC ]       = PSBT_ScrollArea:New( self.control, PSBT_AREAS.STATIC,       BOTTOM )
    self._areas[ PSBT_AREAS.NOTIFICATION ] = PSBT_ScrollArea:New( self.control, PSBT_AREAS.NOTIFICATION, TOP )

    self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( _, addon ) self:OnLoaded( addon ) end )
end


function PSBT:FormatFont( fontObject )
    local path, size, decoration = fontObject:GetFontInfo()
    local fmt = '%s|%d'
    if ( decoration ) then
        fmt = fmt .. '|%s'
    end

    return fmt:format( path, size, decoration ) 
end

function PSBT:OnLoaded( addon )
    if ( addon ~= 'PSBT' ) then
        return
    end

    print( 'Loading PSBT' )
    CBM:FireCallbacks( PSBT_EVENTS.LOADED, self )

    self.control:SetHandler( 'OnUpdate', function( _, frameTime ) self:OnUpdate( frameTime ) end )
end

function PSBT:OnUpdate( frameTime )
    for k,label in pairs( self:GetActiveObjects() ) do
        if ( label:IsExpired( frameTime ) ) then
            self:ReleaseObject( k )
        end
    end

    for k,v in pairs( self._modules ) do
        v:OnUpdate( frameTime )
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
    if ( not area ) then 
        return
    end

    if ( sticky ) then
        entry.label:SetFont( self:FormatFont( ZoFontCallout ) )
        entry.control:SetDrawTier( DT_HIGH )
    else
        entry.label:SetFont( self:FormatFont( ZoFontGameBold ) )
        entry.control:SetDrawTier( DT_LOW )
    end

    entry:SetExpire( -1 ) --pending
    entry:SetText( text ) 
    entry:SetTexture( icon )

    area:Push( entry, sticky )
end

-- LEAVE ME THE FUARK ALONE
function Initialized( control )
    _G.PSBT = PSBT:New( control )
end
