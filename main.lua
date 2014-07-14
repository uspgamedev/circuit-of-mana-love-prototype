
local W, H

local viewnames
local views
local current

function love.load ()
  W = love.window.getWidth()
  H = love.window.getHeight()
  viewnames = { 'platformer', 'topdown', 'isometric', 'craft' }
  current = 1
  views = {}
  love.graphics.setBackgroundColor(100,100,100)
  for _,viewname in ipairs(viewnames) do
    local chunk = assert(loadfile(viewname..".lua"))
    local env = setmetatable({}, { __index = getfenv() })
    setfenv(chunk, env) ()
    views[viewname] = env
  end
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
    local view = views[viewnames[current]]
    view.draw(g, W/2, H)
  end
  -- Draw the crafting panel
  do
    g.push()
    g.translate(W/2, 0)
    views.craft.draw(g, W/2, H)
    g.pop()
  end
end
