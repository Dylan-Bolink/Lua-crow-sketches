-- JF with transpose and first sequence combined

length = {}
rhythm = {}
notes  = {}
step   = {}
bits   = {}
scale  = { {0,2,4,7,9}, {0,2,4,5,7,9,11} }
decay  = 0.4
attack = 2

function set_d(t) decay = (t-1)/8 + 0.05 end
function set_a(t) attack = (t-1)/64 + 0.003 end

function play(out,ix)
  if rhythm[ix][ step[ix] ] & 8 == 8 then
    if ix == 1 then set_d(t[ix]) else set_a(t[ix]) end
    t[ix] = 0
    output[out+1]()
  end
  if rhythm[ix+2][ step[ix+2] ] & 8 == 8 then
    n1 = notes[ix][ step[ix+2] ]
    n2 = notes[ix][ step[ix] ]
    abs = math.abs(input[2].volts)/5
    note = n1 + abs*(n2-n1)
    note = math.floor(note * (abs*3 + 0.1))
    s = scale[input[2].volts > -0.04 and 1 or 2]
    nn = s[ note%(#s) + 1 ]
    oct = math.floor(note/12)
    output[out].volts = nn/12 + oct
  end
  step[ix] = (step[ix] % length[ix]) + 1
  step[ix+2] = (step[ix+2] % length[ix+2]) + 1
end

sd = 0
function lcg(seed)
  local s = seed or sd
  sd = (1103515245*s + 12345) % (1<<31)
  return sd
end

function get_d() return decay end
function get_a() return attack end

t = {0,0}
function env(count)
  for i=1,2 do t[i] = t[i] + 1 end
end

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

    play(1,1)
    play(3,2)
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
    jfMode = 0
    input[1].mode('change', 1, 0.1, 'rising')
      lcg(unique_id())
      lcg()
      lcg()
      lcg()

  for i=1,4 do
    length[i] = lcg()%19 + 6
    rhythm[i] = {}
    for n=1,32 do
      rhythm[i][n] = lcg()
    end
    step[i] = 1
  end

  -- notes
  for i=1,4 do
    notes[i] = {0}
    for n=1,31 do
      notes[i][n+1] = notes[i][n] + (lcg() % 7) -3
    end
  end

  -- out params
  output[1].slew   = 0
  output[1].volts  = 0
  output[2].action = ar(get_a,get_d)
  output[3].slew   = 0.01
  output[3].volts  = 0
  output[4].action = ar(get_a,get_d)

  -- start sequence!
  dec = metro.init{ event = env, time = 0.1 }
  dec:start()

  tmetro = metro.init{ event = trans, time = 0.03 }
end