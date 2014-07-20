require "component"
require "wire"

local W, H

local buttons = {}

local BUTTON_WIDTH = 100;
local BUTTON_HEIGHT = 50;

local BUTTON_COLOR = {100, 172, 235}
local TEXT_COLOR = {255, 255, 255}

local phantom = nil
local active_wire = nil

local function newButton(px, py, txt, func)
	local inst = {x = px, y = py, text = txt, action = func}
	return inst
end

local function drawButton(graphics, button)
	graphics.setColor(unpack(BUTTON_COLOR))
	graphics.rectangle("fill", button.x, button.y, BUTTON_WIDTH, BUTTON_HEIGHT)

	local textWidth = graphics.getFont():getWidth(button.text)

	graphics.setColor(unpack(TEXT_COLOR))
	graphics.print(button.text, button.x + (BUTTON_WIDTH - textWidth)/2, 
    button.y + (BUTTON_HEIGHT - graphics.getFont():getHeight())/2)
end

local function contains(x, y, button)
  x = x - W/2
  return (x > button.x and x < button.x + BUTTON_WIDTH) and 
    (y > button.y and y < button.y + BUTTON_HEIGHT)
end

function load()
  W = love.graphics.getWidth()
  H = love.graphics.getHeight()
  local i = 0
  
  for _,name in pairs(viewnames) do
    if name ~= "craft" then
      table.insert(buttons, newButton(25+i*(25+BUTTON_WIDTH), H-60, name, views[name].play))
      i = i + 1
    end
  end

  component.load(W/2)

  component.register(component.create(50, H-100, component.WATER, true))
  component.register(component.create(100, H-100, component.BOLT, true))
  component.register(component.create(150, H-100, component.EXPLOSIVE, true))
  component.register(component.create(200, H-100, component.OFFENSIVE, true))
  component.register(component.create(250, H-100, component.DEFENSIVE, true))

  wire.load(W/2)
end

function mousepressed(x, y, button)
  if button == 'l' then
    for v in pairs(buttons) do
      local b = buttons[v]
      if contains(x, y, b) then
        b.action()
      end
    end

    local c = component.getComponent(x, y) 
    if c then
      if c.primitive then
        phantom = component.create(x, y, c)
        component.register(phantom)
      else
        if love.keyboard.isDown("rshift", "lshift") then
          active_wire = wire.create(c.x, c.y, x, y, c)
          wire.register(active_wire)
          table.insert(c.wires, active_wire)
        else
          phantom = c
        end
      end
    end
  elseif button == 'r' then
    component.remove(x, y)
  end
end

function mousereleased(x, y, button)
  if button == 'l' then
    if phantom then
      phantom = nil
    end
    if active_wire then
      local c = component.getComponent(x, y)
      if c and c ~= active_wire.input and not c.primitive then
        active_wire.x2, active_wire.y2 = c.x, c.y
        active_wire.output = c
        table.insert(c.wires, active_wire)
      else
        wire.remove(active_wire)
      end
      active_wire = nil
    end
  end
end

function draw (graphics, width, height)
  graphics.print("Craft", width/2, height/2)

  for v in pairs(buttons) do
    drawButton(graphics, buttons[v])
  end

  component.draw(graphics, width, height)
  wire.draw(graphics, width, height)
end

function update(dt)
  local mouse = love.mouse
  if mouse.isDown("l") then
    local x, y = mouse.getX(), mouse.getY()
    if x > W/2 then
      if phantom then 
        phantom.x, phantom.y = x-W/2, y
      elseif active_wire then
        active_wire.x2, active_wire.y2 = x-W/2, y
      end
    end
  end
  wire.update(dt)
end