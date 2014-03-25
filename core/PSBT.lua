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
PSBT._events   = {}
PSBT.__DEBUG_UPDATE = 0
PSBT.__DEBUG = false

local PSBT_Fade         = PSBT_Fade

local CBM               = CALLBACK_MANAGER
local PSBT_ScrollArea   = PSBT_ScrollArea
local PSBT_AREAS        = PSBT_AREAS
local PSBT_EVENTS       = PSBT_EVENTS
local PSBT_MODULES      = PSBT_MODULES
local PSBT_SETTINGS     = PSBT_SETTINGS

local tinsert = table.insert
local tremove = table.remove

local _

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

    self._fadeIn    = PSBT_Fade:New( 1.0, 0.0 )
    self._fadeOut   = PSBT_Fade:New( 0.0, 1,0 )

    self._areas[ PSBT_AREAS.INCOMING ]     = PSBT_ScrollArea:New( self.control, PSBT_AREAS.INCOMING,     self:GetSetting( PSBT_AREAS.INCOMING ), self._fadeIn, self._fadeOut )
    self._areas[ PSBT_AREAS.OUTGOING ]     = PSBT_ScrollArea:New( self.control, PSBT_AREAS.OUTGOING,     self:GetSetting( PSBT_AREAS.OUTGOING ), self._fadeIn, self._fadeOut )
    self._areas[ PSBT_AREAS.STATIC ]       = PSBT_ScrollArea:New( self.control, PSBT_AREAS.STATIC,       self:GetSetting( PSBT_AREAS.STATIC ), self._fadeIn, self._fadeOut )
    self._areas[ PSBT_AREAS.NOTIFICATION ] = PSBT_ScrollArea:New( self.control, PSBT_AREAS.NOTIFICATION, self:GetSetting( PSBT_AREAS.NOTIFICATION ), self._fadeIn, self._fadeOut )

    CBM:RegisterCallback( PSBT_EVENTS.CONFIG, function( ... ) self:SetConfigurationMode( ... ) end )
    self.control:SetHandler( 'OnUpdate', function( _, frameTime ) self:OnUpdate( frameTime ) end )
end

function PSBT:OnUpdate( frameTime )
    if ( self.__DEBUG ) then
        if ( frameTime - self.__DEBUG_UPDATE > 2 ) then
            self.__DEBUG_UPDATE = frameTime
            d( '-------------- PSBT_DEBUG_UPDATE --------------')
            d( 'LABELS total = ' .. self:GetTotalObjectCount() .. ', active = ' .. self:GetActiveObjectCount() .. ', inactive = ' .. self:GetFreeObjectCount() )
            d( 'FADEIN total = ' .. self._fadeIn:GetTotalObjectCount() .. ', active = ' .. self._fadeIn:GetActiveObjectCount() .. ', inactive = ' .. self._fadeIn:GetFreeObjectCount() )
            d( 'FADEOUT total = ' .. self._fadeOut:GetTotalObjectCount() .. ', active = ' .. self._fadeOut:GetActiveObjectCount() .. ', inactive = ' .. self._fadeOut:GetFreeObjectCount() )
            d( 'INCOMING PARABOLAS total = ' .. self._areas[ PSBT_AREAS.INCOMING ]._parabola:GetTotalObjectCount() )
            d( 'OUTGOING PARABOLAS total = ' .. self._areas[ PSBT_AREAS.OUTGOING ]._parabola:GetTotalObjectCount() )
        end
    end

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
            local settings = self:GetSetting( k )
            local point, relPoint, offsX, offsY = v:GetAnchorOffsets()

            settings.to = point
            settings.from = relPoint
            settings.x = offsX
            settings.y = offsY

            self:SetSetting( k, settings )
        end
    end
end

function PSBT:RegisterModule( identity, class, version )
    if ( not version ) then
        version = -1
    end

    if ( self._modules[ identity ] and ( version < self._modules[ identity ].__version or 0 ) ) then
        return
    end

    print( 'PSBT module registered: ' .. identity .. ' @ ' .. version )

    self._modules[ identity ] = class
    self._modules[ identity ].__version = version
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
    if ( not self._events[ event ] ) then
        self._events[ event ] = {}
    end

    tinsert( self._events[ event ], callback )

    self.control:RegisterForEvent( event, function( ... ) self:OnEvent( ... ) end )
end

function PSBT:OnEvent( event, ... ) 
    if ( not self._events[ event ] ) then
        return
    end

    local callbacks = self._events[ event ]
    for _,v in pairs( callbacks ) do
        v( ... )
    end
end

function PSBT:UnregisterForEvent( event, callback )
    if ( not self._events[ event ] ) then
        return
    end

    local callbacks = self._events[ event ]
    local i = 1
    while( i <= #callbacks ) do
        if ( callbacks[ i ] == callback ) then
            tremove( callbacks, i )
        else
            i = i + 1
        end
    end

    if ( #callbacks == 0 ) then
        self.control:UnregisterForEvent( event, function( ... ) self:OnEvent( ... ) end )
    end
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

    SLASH_COMMANDS['/psbtdebug'] = function() _G.PSBT.__DEBUG = not _G.PSBT.__DEBUG end
end
