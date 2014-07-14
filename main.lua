
local W, H

local viewnames
local views

function love.load ()
  W = love.window.getWidth()
  H = love.window.getHeight()
  viewnames = { 'platformer', 'topdown', 'isometric', 'craft' }
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
  end
end

function love.draw ()
  local g = love.graphics
  g.line(W/2, 0, W/2, H)
  g.line(0, H/2, W, H/2)
  for i,viewname in pairs(viewnames) do
    local view = views[viewname]
    g.push()
    g.translate((W/2)*((i-1)%2), (H/2)*math.floor((i-1)/2))
    view.draw(g, W/2, H/2)
    g.pop()
  end
end
