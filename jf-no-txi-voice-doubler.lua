-- JF with transpose and voice doubler out

function trans(count)
    transpose = input[2].volts - lastNote
    if (transpose > 0.008 or transpose < -0.008) then
        ii.jf.transpose(transpose - 2)
    else
        ii.jf.transpose(-2)
    end
end

input[2].stream  = function(s)
  transpose = input[2].volts - lastNote
  if (transpose > 0.008 or transpose < -0.008) and jfMode == 1 then
      ii.jf.transpose(transpose - 2)
  elseif jfMode == 0 then
      ii.jf.transpose(0)
  else
      ii.jf.transpose(-2)
  end
end

input[1].change = function(s)
    getters()

    if speed > 0 and tsc == 1.0 then
        tmetro:start()
        ii.jf.mode(1)
        jfMode = 1
        lastNote = input[2].volts
        noteCount = noteCount + 1
        delay( 0.003, function() ii.jf.play_note(input[2].volts,5) lastNote = input[2].volts end )
    elseif speed > 0 and noteCount > 5 then
        lastNote = input[2].volts
        delay( 0.003, function() ii.jf.play_note(input[2].volts,5) lastNote = input[2].volts end )
    else
        jfMode = 0
        noteCount = 0
        ii.jf.mode(0)
        tmetro:stop()
    end

    doubleCount = doubleCount + 1
    if doubleCount % 2 == 1 then
      output[1](true)
      output[2].volts = input[2].volts
    else
      output[3](true)
      output[4].volts = input[2].volts
    end
end

function getters()
    ii.jf.get('speed')
    ii.jf.get('tsc')

    ii.jf.event = function(e, value)
        if e.name == 'speed' then
            speed = value
        elseif e.name == 'tsc' then
            tsc = value
        end
    end
end

function init()
  getters()
  lastNote = 0
  noteCount = 0
  doubleCount = 0
  jfMode = 0
  input[1].mode('change', 1, 0.1, 'rising')

  -- out params
  output[1].action = adsr(0, 0.02, 0)
  output[2].volts  = 0
  
  output[3].action = adsr(0, 0.02, 0)
  output[4].volts  = 0

  tmetro = metro.init{ event = trans, time = 0.03 }
end