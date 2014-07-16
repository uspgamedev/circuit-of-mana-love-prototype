
local function accumulator(n)
  local total = 0
  return function (mana)
    total = total + mana.amount
    if total >= n then
      total = 0
      return { type = 'substance:mana', amount = 10 }
    end
  end
end

local function projectile (avatars, dt)
  local hero = avatars[1]
  local proj = {
    pos = { hero.pos[1], hero.pos[2]-0.3 },
    sprite = love.graphics.newImage "assets/fireball00.png"
  }
  table.insert(avatars, proj)
  for i=1,1200 do
    avatars, dt = coroutine.yield()
    proj.pos[1] = proj.pos[1] + dt*5
  end
  return true
end

return {
  {
    name = "Accumulator",
    action = accumulator(100)
  },
  {
    name = "Fire",
    action = function (mana)
      mana.type = 'substance:fire'
      return mana
    end
  },
  {
    name = "Projectile",
    action = function (mana)
      return coroutine.wrap(projectile)
    end
  }
}