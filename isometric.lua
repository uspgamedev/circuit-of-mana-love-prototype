
local interpreter = require 'interpreter'

local scenario = love.graphics.newImage "assets/scenario_iso.png"
local avatars = {
  {
    tag = "hero 1",
    pos = {-1, 0},
    sprite = love.graphics.newImage "assets/chara00.png"
  },
  {
    tag = "hero 2",
    pos = {2, 1},
    sprite = love.graphics.newImage "assets/chara01.png"
  }
}

local tasks

function load()
  tasks = {}
end

function play(circuit, nodes)
  local new_tasks = interpreter.cast(circuit, nodes)
  if new_tasks then
    for _,task in ipairs(new_tasks) do
      tasks[task] = true
    end
  end
end

function keypressed (key)
  if key == 'up' then
    avatars[1].pos[2] = avatars[1].pos[2]+.2
  elseif key == 'down' then
    avatars[1].pos[2] = avatars[1].pos[2]-.2
  elseif key == 'right' then
    avatars[1].pos[1] = avatars[1].pos[1]+.2
  elseif key == 'left' then
    avatars[1].pos[1] = avatars[1].pos[1]-.2
  end
end

function update()
  local to_be_removed = {}
  for task,_ in pairs(tasks) do
    if task(avatars) then
      table.insert(to_be_removed, task)
    end
  end
  for _,removed in ipairs(to_be_removed) do
    tasks[removed] = nil
  end
end

local function draw_avatar (graphics, avatar)
  local x,y = unpack(avatar.pos)
  graphics.push()
  graphics.translate(12*(2*x - 2*y), 12*(-x + -y))
  if avatar.color then
    graphics.setColor(avatar.color)
  end
  if avatar.sprite == 'laser' then
    local old_width = graphics.getLineWidth()
    local tx, ty = x+10, y
    graphics.setLineWidth(10)
    graphics.line(x, y, 12*(2*tx - 2*ty), 12*(-tx + -ty))
    graphics.setLineWidth(old_width)
  elseif avatar.sprite == 'field' then
    graphics.circle('line', x, y, 50)
  else
    local w,h = avatar.sprite:getDimensions()
    graphics.draw(
      avatar.sprite,
      0, 0, 0, 1, 1, w/2, 3*h/4
    )
  end
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
