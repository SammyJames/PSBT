------
-- First in First Out container
-- reference:
-- https://github.com/daurnimator/lomp2/blob/master/fifo.lua
------

local select , setmetatable = select , setmetatable

PSBT_Fifo = {} 
local mt =
{
    __index = PSBT_Fifo, 
    __newindex = function( f, k, v ) 
        if ( type( k ) == 'number' ) then
            return rawset( f, k, v )
        end
    end,
}

function PSBT_Fifo.New( ... )
    return setmetatable( { head = 1, tail = select( '#', ... ), ... }, mt )
end

function PSBT_Fifo:Size()
    return self.tail - self.head + 1
end

function PSBT_Fifo:Peek()
    return self[ self.head ]
end

function PSBT_Fifo:Push( value )
    self.tail = self.tail + 1
    self[ self.tail ] = value
end

function PSBT_Fifo:Pop()
    local head, tail = self.head, self.tail
    if ( head > tail ) then
        return nil
    end

    local value = self[ head ]
    self[ head ] = nil
    self.head = head + 1
    return value 
end

function PSBT_Fifo:Remove( index )
    local head, tail = self.head, self.tail

    if head + index > tail then 
        return
    end

    local position  = head + index - 1
    local value     = self[ position ]

    if ( position <= (head + tail) * 0.5 ) then
        for i = position, head, -1 do
            self[ i ] = self[ i - 1 ]
        end
        self.head = head + 1
    else
        for i = position, tail do
            self[ i ] = self[ i + 1 ]
        end
        self.tail = tail - 1
    end

    return value
end

local iterator = function( fifo, previous )
    local i = fifo.head + previous
    if ( i > fifo.tail ) then
        return nil
    end

    return previous + 1, fifo[ i ]
end

function PSBT_Fifo:Iterator()
    return iterator, self, 0
end

mt.__len = PSBT_Fifo.Size