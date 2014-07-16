
local W, H

local LAYER_NUM = 10
local NODE_PER_LAYER = 7

local buttons = {}

local circuit = {
  sources = {},
  sinks = {},
  layers = {},
}

local current_node
local current_layer
local current_column

local BUTTON_WIDTH = 100;
local BUTTON_HEIGHT = 50;

local BUTTON_COLOR = {100, 172, 235}
local TEXT_COLOR = {255, 255, 255}

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

local function contains2(x, y, box)
  x = x - W/2
  return (x > box.x and x < box.x + box.w) and
    (y > box.y and y < box.y + box.h)
end

function load()
  W = love.graphics.getWidth()
  H = love.graphics.getHeight()
  for i=1,LAYER_NUM do
    circuit.layers[i] = {}
  end
  local i = 0

  for _,name in pairs(viewnames) do
    if name ~= "craft" then
      table.insert(buttons, newButton(25+i*(25+BUTTON_WIDTH), H-80, name, views[name].play))
      i = i + 1
    end
  end
end

function mousepressed(x, y, button)
  if button == 'l' then
    for v in pairs(buttons) do
      local b = buttons[v]
      if contains(x, y, b) then
        b.action(circuit)
      end
    end
  end
  for i=1,20 do
    if contains2(x, y, {x=10, y=100+(i-1)*20, w=19, h=19}) then
      current_node = i
    end
  end
  for i=1,LAYER_NUM do
    for j=1,NODE_PER_LAYER do
      if contains2(x, y, {x=55 + (j-1)*40, y=105+(i-1)*40, w=30, h=30}) then
        current_layer = i
        current_column = j
      end
    end
  end
end

function draw (graphics, width, height)
  for v in pairs(buttons) do
    drawButton(graphics, buttons[v])
  end
  for i=1,20 do
    if i == current_node then
      graphics.setColor(80,50,50)
    else
      graphics.setColor(50,50,50)
    end
    graphics.rectangle('fill', 10, 100+(i-1)*20, 19, 19)
    graphics.setColor(255,255,255)
    graphics.print(i, 10, 100+(i-1)*20)
  end
  for i=1,LAYER_NUM do
    graphics.setColor(50,80,50)
    graphics.rectangle('fill', 50, 100+(i-1)*40, 300, 39)
    for j=1,NODE_PER_LAYER do
      if i == current_layer and j == current_column then
        graphics.setColor(80,50,80)
      else
        graphics.setColor(50,50,80)
      end
      graphics.rectangle('fill', 55 + (j-1)*40, 105+(i-1)*40, 30, 30)
    end
    graphics.setColor(255,255,255)
  end
end
