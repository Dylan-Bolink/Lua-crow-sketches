-- JF with transpose
-- 1 press add -- 2 press slew -- 3 sample -- 4 sample slew

input[2].stream  = function(s)
    output[3].volts = input[2].volts + pressAdd
    output[4].volts = input[2].volts + pressAdd

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
    output[2].volts = input[2].volts
    output[1].volts = input[2].volts

    if jfMode == 1 then
        lastNote = input[2].volts
        ii.jf.play_note(input[2].volts,5) 
        if jfPoly == 3 then
            -- make in 4 a velocity changer for the subsequent notes
            delay(function () ii.jf.play_note(input[2].volts + jfOne, (5 - velocity)) end, jfDelay)
            delay(function () ii.jf.play_note(input[2].volts + jfTwo, (5 - velocity * 2)) end, (jfDelay * 2))
        elseif jfPoly == 2 then
            delay(function () ii.jf.play_note(input[2].volts + jfOne, (5 - velocity)) end, jfDelay)
        end
            
        lastNote = input[2].volts 
        -- end )
    end
end

function getters()
    ii.txi[1].get('param',1)
    ii.txi[1].get('param',2)
    ii.txi[1].get('param',3)
    ii.txi[1].get('param',4)

    ii.txi[1].get('in',1)
    ii.txi[1].get('in',2)
    ii.txi[1].get('in',3)
    -- ii.txi[1].get('in',4) -- whattodo....

    ii.txi.event = function(e, value) -- 'e' is a table of: { name, device, arg }
        if e.name == 'param' and e.arg == 1 then
            pressAdd = ((math.floor(value+0.5)-5)/2) + inOne
            jfDelay = value / 20
        elseif e.name == 'param' and e.arg == 2 then
            output[3].slew = (value / 2) + inTwo
            jfTwo = (value/5) - 1
        elseif e.name == 'param' and e.arg == 3 then
            output[1].slew = (value / 2)  + inThree
            jfOne = (value/5) - 1
        elseif e.name == 'param' and e.arg == 4 then
            if value > 2.5 and jfMode == 0 then
                print('JF mode on')
                jfMode = 1
                ii.jf.mode(1)
            elseif value < 2.5 and jfMode == 1 then
                print('JF mode off')
                jfMode = 0
                ii.jf.mode(0)
            end

            if value > 9 then
                jfPoly = 3
            elseif value > 7 then 
                jfPoly = 2
            else
                jfPoly = 1
            end
        elseif e.name == 'in' and e.arg == 1 then
            inOne = math.floor(value+0.5)/2
        elseif e.name == 'in' and e.arg == 2 then
            inTwo = value
        elseif e.name == 'in' and e.arg == 3 then
            inThree = value
        elseif e.name == 'in' and e.arg == 4 then
            velocity = value
        end
    end

end
 
function init()
    pressAdd = 0
    jfMode = 0
    jfPoly = 1
    lastNote = 0

    jfOne = 0
    jfTwo = 0
    jfDelay = 0

    -- txi input vars
    inOne = 0
    inTwo = 0
    inThree = 0
    velocity = 0

    print('initing')
    input[1].mode('change', 1, 0.1, 'rising')
    input[2].mode('stream', 0.01)

    -- out params
    output[1].slew  = 0
    output[1].volts  = 0
    output[2].volts = 0

    output[3].slew   = 0 -- press slew
    output[3].volts  = 0 -- press slew

    output[4].volts = 0 -- press add
 

    metro[1].event = function(c) getters() end
    metro[1].time  = 0.01
    metro[1]:start()
end
