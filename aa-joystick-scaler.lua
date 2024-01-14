-- Joystick scaler with Lorenz attractor
-- Input 1: Joystick X
-- Input 2: Joystick Y
-- Output 1: X scaled to -5 to 5
-- Output 2: Y scaled to -5 to 5
-- Output 3: 0 to 5 Y
-- Output 4: 0 to 5 Y inverted

input[1].stream = function(s)
    output[1].volts  = (input[1].volts - 2.5) * 2
end

input[2].stream  = function(s)
    output[2].volts = (input[2].volts - 2.5) * 2
    output[3].volts = math.abs((input[2].volts - 2.5) * 2)
    output[4].volts = math.abs(((input[2].volts - 2.5) * 2) * -1)
end

function init()
    input[1].mode('stream',0.001)
    input[2].mode('stream',0.001)
end
