PSBT_Parabola = {}

local PSBT_SCROLL_DIRECTIONS = PSBT_SCROLL_DIRECTIONS

local function _DOWN( height, progress )
    return height * progress
end

local function _UP( height, progress )   
    return height - _DOWN( height, progress )
end

function PSBT_Parabola:Calculate( height, width, points, direction )
        local result = {}
        local midpoint = height * 0.5
        local fourA = ( midpoint * midpoint ) / width
        local fn = nil
        if ( direction == PSBT_SCROLL_DIRECTIONS.UP ) then
            fn = _UP
        else
            fn = _DOWN
        end

        for i=1,points do
                result[ i ] = { x = 0, y = 0 }
                result[ i ].y = fn( height, i / points )
                
                local y = result[ i ].y - midpoint
                result[ i ].x = ( y * y ) / fourA
        end

        return result
end
