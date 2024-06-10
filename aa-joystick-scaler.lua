-- Joystick scaler
-- Input 1: Joystick X
-- Input 2: Joystick Y
-- Output 1: X scaled to -5 to 5
-- Output 2: input 2 Y scaled to -5 to 5 else input 1 absolute value
-- Output 3: 0 to 5 Y
-- Output 4: 0 to 5 Y inverted

input[1].stream = function(s)
    baseScale = (input[1].volts - 3.5) * 1.42999
    output[1].volts  = baseScale

    if(inputTwoPresend == false) then
        output[2].volts = math.abs(baseScale)
    end

    output[3].volts = math.floor(baseScale, 0)
    output[4].volts = math.ceil(baseScale, 0) * -1
end

input[2].stream  = function(s)
    if(math.abs(input[2].volts) > 0.5 or inputTwoPresend) then
        inputTwoPresend = true
        output[2].volts = (input[2].volts - 3.5) * 1.42999
    end
end

function init()
    input[1].mode('stream',0.005)
    input[2].mode('stream',0.005)
    output[1].slew = 0.01
    output[2].slew = 0.01
    output[3].slew = 0.01
    output[4].slew = 0.01
    inputTwoPresend = false
end
