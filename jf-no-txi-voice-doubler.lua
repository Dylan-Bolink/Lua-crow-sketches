-- JF with transpose and voice doubler out

input[1].change = function(s)
    getters()

    if speed > 0 and tsc == 1.0 then
        ii.jf.mode(1)
        jfMode = 1
        lastNote = input[2].volts
        noteCount = noteCount + 1
        playVoice()
    elseif speed > 0 and noteCount > 5 then
        playVoice()
    else
        jfMode = 0
        noteCount = 0
        ii.jf.mode(0)
    end
end

function playVoice()
    lastNote = input[2].volts
    ii.jf.play_note(input[2].volts,5) lastNote = input[2].volts
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
    -- public params is this good?
    -- for n=1,4 do public.view.output[n]() end
    getters()
    lastNote = 0
    noteCount = 0

    jfMode = 0
    speed = 0
    tsc = 0
    input[1].mode('change', 1, 0.1, 'rising')
    input[2].mode('stream', 0.05)
    --stream was 0.1 but that gave stability issues see if this is better

end