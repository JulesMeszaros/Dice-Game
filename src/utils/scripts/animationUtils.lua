local AnimationUtils = {}

function AnimationUtils.osccilate(time, periode, amp) --Periode en secondes
    return (amp/2) + (amp/2) * math.sin(2 * math.pi * time / periode)
end

return AnimationUtils 