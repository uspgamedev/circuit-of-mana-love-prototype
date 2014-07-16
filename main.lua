
local W, H

local current

local MAX_MANA = 100

local mana
local manaGrowth = 30

function love.load ()
  W = love.window.getWidth()
  H = love.window.getHeight()
  viewnames = { 'platformer', 'topdown', 'isometric', 'craft' }
  current = 1
  views = {}
  love.graphics.setBackgroundColor(100,100,100)
  for _,viewname in ipairs(viewnames) do
    local chunk = assert(love.filesystem.load(viewname..".lua"))
    local env = setmetatable({}, { __index = getfenv() })
    setfenv(chunk, env) ()
    views[viewname] = env
  end
  mana = 0
  for _,names in pairs(viewnames) do
    views[names].load()
  end
end

function love.mousepressed(x, y, button)
  views.craft.mousepressed(x, y, button)
end

function love.keypressed (key)
  if key == 'escape' then
    love.event.push 'quit'
  elseif tonumber(key) then
    current = tonumber(key)
  end
end

function love.draw ()
  local g = love.graphics
  -- Draw the divisory line
  g.line(W/2, 0, W/2, H)
  -- Draw the current view
  do
    g.push()
    local view = views[viewnames[current]]
    view.draw(g, W/2, H)
    g.pop()
  end
  -- Draw the crafting panel
  do
    g.push()
    g.translate(W/2, 0)
    views.craft.draw(g, W/2, H)
    drawMana(g)
    g.pop()
  end
end

function love.update (dt)
  mana = mana + manaGrowth * dt
  mana = mana > 100 and 100 or mana
  views.craft.update(dt)
  views[viewnames[current]].update(dt)
end

function drawMana (g)
  g.print(string.format("Mana: %.0f", mana), 10, 10)
  g.setColor(200, 30, 30)
  g.rectangle("line", 9, 29, MAX_MANA + 2, 12)
  g.setColor(30, 200, 30)
  g.rectangle("fill", 10, 30, mana, 10)
  g.setColor(255, 255, 255)
end
