local balls
local colors
local selected
local line

local objs

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

  build()
end

local function insideCircle(x1, y1, x2, y2, r)
  return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) <= r * r
end

function mousepressed(x, y, button)
  if button == 'l' then
    for v in pairs(buttons) do
      local b = buttons[v]
      if contains(x, y, b) then
        b.action()
      end
    end
    x = x - W/2

    for _, obj in ipairs(objs) do
      if insideCircle(obj.pos[1], obj.pos[2], x, y, 10) then
        selected = obj.name
        return
      end
    end

    local i = math.floor((x - 20) / 60) + 1
    local j = math.floor((y - 50) / 60) + 1
    if i > 0 and i < 7 and j > 0 and j < 7 and insideCircle(x, y, 60 * i - 10, 20 + 60 * j, 20) then
      line = {i, j}
    end
  end
end

function mousereleased(x, y, button)
  if button ~= 'l' then return end
  x = x - W/2
  local i = math.floor((x - 20) / 60) + 1
  local j = math.floor((y - 50) / 60) + 1
  if selected then
    if insideCircle(x, y, 60 * i - 10, 20 + 60 * j, 20) then
      balls[i][j].name = selected
    end
    selected = nil
  elseif line then
    local di = i - line[1]
    local dj = j - line[2]
    if math.abs(di) <= 1 and math.abs(dj) <= 1 and di * dj == 0 and di ~= dj and insideCircle(x, y, 60 * i - 10, 20 + 60 * j, 20) then
      local d = di == 1 and 1 or dj == 1 and 2 or di == -1 and 3 or 4
      balls[line[1]][line[2]].dirs[d] = true
    end
    line = nil
  end
end

local im = love.graphics.newImage "assets/arrow.png"
function draw (graphics, width, height)
  graphics.print("Craft", width/2, 12)
  
  for v in pairs(buttons) do
    drawButton(graphics, buttons[v])
  end

  local g = graphics

  for i = 1, 6 do
    for j = 1, 6 do
      g.setColor(30, 30, 30)
      g.circle("line", 60 * i - 10, 20 + 60 * j, 11)
      if balls[i][j].name then
        g.setColor(unpack(colors[balls[i][j].name]))
        g.circle("fill", 60 * i - 10, 20 + 60 * j, 10)
      end
      for d = 1, 4 do 
        if balls[i][j].dirs[d] then
          g.setColor(255, 255, 255)
          g.draw(im, 60 * i - 10, 20 + 60 * j, (d - 1) * 3.14159652 / 2, .1, .1, 0, im:getHeight()/2)
        end
      end
    end
  end

  for _, obj in ipairs(objs) do
    g.setColor(unpack(colors[obj.name]))
    g.circle("fill", obj.pos[1], obj.pos[2], 10)
  end

  if selected then
    g.setColor(unpack(colors[selected]))
    g.circle("fill", love.mouse.getX() - W/2, love.mouse.getY(), 10)
  end

  g.setColor(255, 255, 255)
end

function build()
  balls = {}

  for i = 1, 6 do
    balls[i] = {}
    for j = 1, 6 do
      balls[i][j] = {dirs = {}}
    end
  end

  for i = 1, 6 do
    balls[6][i].name = "output"
  end

  balls[1][1].name = "generator"

  colors = {
    generator = {255, 255, 0},
    fire = {255, 0, 0},
    dash = {255, 255, 255},
    shield = {30, 30, 200},
    health = {30, 200, 30},
    output = {0, 0 ,0}
  }

  objs = {}
  local i = 1
  for k in pairs(colors) do
    objs[i] = {
      name = k,
      pos = {60 * i - 10, H - 120}
    }
    i = i + 1
  end

end