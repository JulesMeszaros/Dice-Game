local AnimationUtils = require("src.utils.scripts.Animations")
local TriggerAnimations = {}

function TriggerAnimations.mult(diceface, duration)
  -- Phase 1 : montée lente
  diceface.animator:addGroup({
    {
      property = "scaleX",
      from = 1,
      targetValue = 1.3,
      duration = duration * 0.4,
      easing = AnimationUtils.Easing.outQuad,
    },
    {
      property = "scaleY",
      from = 1,
      targetValue = 1.3,
      duration = duration * 0.4,
      easing = AnimationUtils.Easing.outQuad,
    },
  })
  -- Phase 2 : écrasement violent
  diceface.animator:addGroup({
    {
      property = "scaleX",
      from = 1.4,
      targetValue = 1.8,
      duration = duration * 0.15,
      easing = AnimationUtils.Easing.inCubic,
    },
    {
      property = "scaleY",
      from = 1.4,
      targetValue = 0.4,
      duration = duration * 0.15,
      easing = AnimationUtils.Easing.inCubic,
    },
    {
      property = "rotation",
      from = 0,
      targetValue = 0.15,
      duration = duration * 0.15,
      easing = AnimationUtils.Easing.inCubic,
    },
  })
  -- Phase 3 : récupération courte
  diceface.animator:addGroup({
    {
      property = "scaleX",
      from = 1.8,
      targetValue = 1,
      duration = duration * 0.25,
      easing = AnimationUtils.Easing.easeOutBack,
    },
    {
      property = "scaleY",
      from = 0.4,
      targetValue = 1,
      duration = duration * 0.25,
      easing = AnimationUtils.Easing.easeOutBack,
    },
    {
      property = "rotation",
      from = 0.15,
      targetValue = 0,
      duration = duration * 0.25,
      easing = AnimationUtils.Easing.easeOutBack,
    },
  })
end

function TriggerAnimations.baseReverse(diceface, duration)
  diceface.animator:addGroup({
    {
      property = "scaleX",
      from = 1.8,
      targetValue = 1,
      duration = duration,
      easing = AnimationUtils.Easing.easeOutBack,
    },
    {
      property = "scaleY",
      from = 1.8,
      targetValue = 1,
      duration = duration,
      easing = AnimationUtils.Easing.easeOutBack,
    },
    {
      property = "rotation",
      from = -0.8,
      targetValue = 0,
      duration = duration,
      easing = AnimationUtils.Easing.easeOutBack,
    },
  })
end

function TriggerAnimations.upgrade(diceface, duration)
  --Premier agrandissement
  diceface.animator:addGroup({
    {
      property = "scaleX",
      from = 1,
      targetValue = 1.3,
      duration = duration / 3,
      easing = AnimationUtils.Easing.inQuad,
    },
    {
      property = "scaleY",
      from = 1,
      targetValue = 1.3,
      duration = duration / 3,
      easing = AnimationUtils.Easing.inQuad,
    },
  })
  --Deuxieme agrandissement
  diceface.animator:addGroup({
    {
      property = "scaleX",
      from = 1.8,
      targetValue = 1,
      duration = 2 * duration / 3,
      easing = AnimationUtils.Easing.easeOutBack,
    },
    {
      property = "scaleY",
      from = 1.8,
      targetValue = 1,
      duration = 2 * duration / 3,
      easing = AnimationUtils.Easing.easeOutBack,
    },
    {
      property = "rotation",
      from = -0.4,
      targetValue = 0,
      duration = 2 * duration / 3,
      easing = AnimationUtils.Easing.outBounce,
    },
  })
end

function TriggerAnimations.base(diceface, duration)
  diceface.animator:addGroup({
    {
      property = "scaleX",
      from = 1.8,
      targetValue = 1,
      duration = duration,
      easing = AnimationUtils.Easing.easeOutBack,
    },
    {
      property = "scaleY",
      from = 1.8,
      targetValue = 1,
      duration = duration,
      easing = AnimationUtils.Easing.easeOutBack,
    },
    {
      property = "rotation",
      from = 0.4,
      targetValue = 0,
      duration = duration,
      easing = AnimationUtils.Easing.easeOutBack,
    },
  })
end

return TriggerAnimations
