
local W, H

local buttons = {}

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

function load()
  W = love.graphics.getWidth()
  H = love.graphics.getHeight()
  local i = 0

  for _,name in pairs(viewnames) do
    if name ~= "craft" then
      table.insert(buttons, newButton(25+i*(25+BUTTON_WIDTH), H-100, name, views[name].play))
      i = i + 1
    end
  end
end

function mousepressed(x, y, button)
  if button == 'l' then
    for v in pairs(buttons) do
      local b = buttons[v]
      if contains(x, y, b) then
        b.action()
      end
    end
  end
end

function draw (graphics, width, height)
  graphics.print("Craft", width/2, height/2)
  
  for v in pairs(buttons) do
    drawButton(graphics, buttons[v])
  end
end
