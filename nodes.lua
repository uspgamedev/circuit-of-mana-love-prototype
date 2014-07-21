
local function accumulator(n)
  local total = 0
  return function (mana)
    total = total + mana.amount
    if total >= n then
      total = 0
      return { type = 'substance:mana', amount = n }
    end
  end
end

local colors = {
  mana = {255, 255, 255},
  fire = {255, 0, 0},
  antimagic = {0, 0, 255}
}

local function projectile(substance)
  return function (avatars)
    local hero = avatars[1]
    local t, s = substance.type:match "(%w+):(%w+)"
    local proj = {
      tag = "projectile",
      pos = { hero.pos[1], hero.pos[2] },
      sprite = love.graphics.newImage "assets/fireball00.png",
      color = (t == 'substance' and colors[s]),
      magic = true
    }
    table.insert(avatars, proj)
    for i=1,100 do
      avatars = coroutine.yield()
      proj.pos[1] = proj.pos[1] + 0.1
    end
    coroutine.yield()
    local idx
    for i,avatar in ipairs(avatars) do
      if avatar == proj then
        idx = i
      end
    end
    if idx then
      table.remove(avatars, idx)
    end
    return true
  end
end

local function laser(substance)
  return function (avatars)
    local hero = avatars[1]
    local t, s = substance.type:match "(%w+):(%w+)"
    local lazor = {
      tag = "laser",
      pos = { hero.pos[1], hero.pos[2] },
      sprite = 'laser',
      color = (t == 'substance' and colors[s]),
      magic = true
    }
    table.insert(avatars, lazor)
    coroutine.yield()
    avatars = coroutine.yield()
    local idx
    for i,avatar in ipairs(avatars) do
      if avatar == lazor then
        idx = i
      end
    end
    table.remove(avatars, idx)
    return true
  end
end

local function impulse(mana)
  return function (avatars)
    local hero = avatars[1]
    for i=1,mana.amount/20 do
      avatars = coroutine.yield()
      hero.pos[1] = hero.pos[1] + 0.5
    end
    return true
  end
end

local function dist (obj1, obj2)
  local x1,y1 = unpack(obj1.pos)
  local x2,y2 = unpack(obj2.pos)
  return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

local function field(substance)
  return function (avatars)
    local hero = avatars[2]
    local t, s = substance.type:match "(%w+):(%w+)"
    local field = {
      tag = "field",
      pos = { hero.pos[1], hero.pos[2] },
      sprite = 'field',
      color = (t == 'substance' and colors[s]),
      magic = s
    }
    table.insert(avatars, field)
    avatars = coroutine.yield()
    if field.magic == 'antimagic' then
      local removed = {}
      for i,avatar in ipairs(avatars) do
        if avatar ~= field and avatar.magic and avatar.magic ~= 'antimagic' and dist(avatar, field) <= 2 then
          table.insert(removed, i)
        end
      end
      for i=#removed,1,-1 do
        table.remove(avatars, removed[i])
      end
    end
    avatars = coroutine.yield()
    local idx
    for i,avatar in ipairs(avatars) do
      if avatar == field then
        idx = i
      end
    end
   table.remove(avatars, idx)
    return true
  end
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
    name = "Antimagic",
    action = function (mana)
      mana.type = 'substance:antimagic'
      return mana
    end
  },
  {
    name = "Projectile",
    action = function (mana)
      return coroutine.wrap(projectile(mana))
    end
  },
  {
    name = "Laser",
    action = function (mana)
      return coroutine.wrap(laser(mana))
    end
  },
  {
    name = "Impulse",
    action = function (mana)
      return coroutine.wrap(impulse(mana))
    end
  },
  {
    name = "Field",
    action = function (mana)
      return coroutine.wrap(field(mana))
    end
  }
}