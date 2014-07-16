
local interpreter = require 'interpreter'

local scenario = love.graphics.newImage "assets/scenario_iso.png"
local avatars = {
  {
    pos = {-8, 0},
    sprite = love.graphics.newImage "assets/chara00.png"
  },
  {
    pos = {16, 8},
    sprite = love.graphics.newImage "assets/chara01.png"
  }
}

function load()

end

function play(circuit, nodes)
  interpreter.cast(circuit, nodes)
end

function update(dt)

end

local function draw_avatar (graphics, avatar)
  local x,y = unpack(avatar.pos)
  local w,h = avatar.sprite:getDimensions()
  graphics.push()
  graphics.translate(2*x - 2*y, -x + -y)
  graphics.draw(
    avatar.sprite,
    0, 0, 0, 1, 1, w/2, 3*h/4
  )
  graphics.pop()
  graphics.setColor(255, 255, 255, 255)
end

function draw (graphics, width, height)
  graphics.translate(width/2, height/2)
  graphics.draw(
    scenario,
    0, 0,
    0, 1, 1,
    scenario:getWidth()/2, scenario:getHeight()/2
  )
  for _,avatar in ipairs(avatars) do
    draw_avatar(graphics, avatar)
  end
end
