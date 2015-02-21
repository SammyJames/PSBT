local PSBT                  = PSBT
local AnimationPool         = PSBT.AnimPoolProto
local Parabola              = AnimationPool:Subclass()

local PSBT_SCROLL_DIRECTIONS = PSBT.SCROLL_DIRECTIONS

local function _DOWN( height, progress )
    return height * progress
end

local function _UP( height, progress )
    return height - _DOWN( height, progress )
end

function Parabola:New( height, width, points, direction )
    local result = AnimationPool.New( self )
    result:Initialize( height, width, points, direction )
    return result
end

function Parabola:Initialize( height, width, points, direction )
    self._parabolaPoints = {}

    local midpoint = height * 0.5
    local fourA = ( midpoint * midpoint ) / width
    local fn = nil
    if ( direction == PSBT_SCROLL_DIRECTIONS.UP ) then
        fn = _UP
    else
        fn = _DOWN
    end

    for i=1,points do
        self._parabolaPoints[ i ] = { x = 0, y = 0 }
        self._parabolaPoints[ i ].y = fn( height, i / points )

        local y = self._parabolaPoints[ i ].y - midpoint
        self._parabolaPoints[ i ].x = ( y * y ) / fourA
    end
end

function Parabola:Create()
    local anim = AnimationPool.Create( self )

    local points = self._parabolaPoints
    local x, y = points[1].x, points[1].y
    local point = nil
    local duration = 3000 / #points

    for i=1,#points do
        point = points[ i ]
        anim:TranslateToFrom( x, y, point.x, point.y, duration, (i - 1) * duration )

        x = point.x
        y = point.y
    end

    return anim
end

PSBT.ParabolaProto = Parabola

