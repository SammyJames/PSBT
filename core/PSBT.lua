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
local LMP = LibStub( 'LibMediaProvider-1.0' )
if ( not LMP ) then return end

local PSBT = ZO_ObjectPool:Subclass()
PSBT._modules  = {}
PSBT._areas    = {}

local CBM               = CALLBACK_MANAGER
local PSBT_ScrollArea   = PSBT_ScrollArea
local PSBT_AREAS        = PSBT_AREAS
local PSBT_EVENTS       = PSBT_EVENTS
local PSBT_MODULES      = PSBT_MODULES
local PSBT_SETTINGS     = PSBT_SETTINGS

function PSBT:New( ... )
    local result = ZO_ObjectPool.New( self, PSBT.CreateLabel, function( ... ) self:ResetLabel( ... ) end )
    result:Initialize( ... )
    return result
end

function PSBT:Initialize( control )
    self.control = control
    self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( _, addon ) self:OnLoaded( addon ) end )
end

function PSBT:FormatFont( font )
    local face, size, decoration = font.face, font.size, font.deco
    local fmt = '%s|%d'
    if ( decoration and decoration ~= 'none' ) then
        fmt = fmt .. '|%s'
    end

    return fmt:format( LMP:Fetch( LMP.MediaType.FONT, face ), size, decoration ) 
end

function PSBT:OnLoaded( addon )
    if ( addon ~= 'PSBT' ) then
        return
    end

    print( 'Loading PSBT' )
    CBM:FireCallbacks( PSBT_EVENTS.LOADED, self )

    self._areas[ PSBT_AREAS.INCOMING ]     = PSBT_ScrollArea:New( self.control, PSBT_AREAS.INCOMING,     self:GetSetting( PSBT_AREAS.INCOMING ) )
    self._areas[ PSBT_AREAS.OUTGOING ]     = PSBT_ScrollArea:New( self.control, PSBT_AREAS.OUTGOING,     self:GetSetting( PSBT_AREAS.OUTGOING ) )
    self._areas[ PSBT_AREAS.STATIC ]       = PSBT_ScrollArea:New( self.control, PSBT_AREAS.STATIC,       self:GetSetting( PSBT_AREAS.STATIC ) )
    self._areas[ PSBT_AREAS.NOTIFICATION ] = PSBT_ScrollArea:New( self.control, PSBT_AREAS.NOTIFICATION, self:GetSetting( PSBT_AREAS.NOTIFICATION ) )

    CBM:RegisterCallback( PSBT_EVENTS.CONFIG, function( ... ) self:SetConfigurationMode( ... ) end )
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

function PSBT:SetConfigurationMode( mode )
    if ( not mode ) then
        for k,v in pairs( self._areas ) do
            self:SetSetting( k, v:GetAnchorOffsets() )
        end
    end
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

    if ( name == PSBT_AREAS.INCOMING or 
         name == PSBT_AREAS.OUTGOING or
         name == PSBT_AREAS.STATIC or 
         name == PSBT_AREAS.NOTIFICATION ) then
    
        self._areas[ name ]:SetSettings( value )    
    end
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
        entry.label:SetFont( self:FormatFont( self:GetSetting( PSBT_SETTINGS.sticky_font ) ) )
        entry.control:SetDrawTier( DT_HIGH )
    else
        entry.label:SetFont( self:FormatFont( self:GetSetting( PSBT_SETTINGS.normal_font ) ) )
        entry.control:SetDrawTier( DT_LOW )
    end

    entry:SetExpire( -1 )
    entry:SetText( text ) 
    entry:SetTexture( icon )

    area:Push( entry, sticky, direction )
end

-- LEAVE ME THE FUARK ALONE
function Initialized( control )
    _G.PSBT = PSBT:New( control )
end
