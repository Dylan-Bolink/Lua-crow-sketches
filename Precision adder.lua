--- Precision adder
-- output 1: 1+2
-- output 2: 1-2
-- output 3: Bass one
-- output 4: Bass two

local inputOne = 0.0
local inputTwo = 0.0
local countOne = 0
local countTwo = 0

input[1].stream = function(volts) 
  if inputOne ~= math.floor(volts) then
    inputOne = math.floor(volts)
    countOne = countOne + 1
  end

  output[1].volts = inputOne + inputTwo
  output[2].volts = inputOne - inputTwo

  if countOne > 7 then
    output[3].volts = inputOne
    countOne = 0
  end

  if countTwo > 4 then
    output[4].volts = inputTwo
    countTwo = 0
  end
end

input[2].stream = function(volts)
  if inputTwo ~= math.floor(volts) then
    inputTwo = math.floor(volts)
    countTwo = countTwo + 1
  end
end

function init()
  input[1].mode('stream', 0.01)
  input[2].mode('stream', 0.01)
end
