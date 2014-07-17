local balls
local colors
local selected
local line
local valid
local opts

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

local function insideRect(x1, y1, x2, y2, dx, dy)
  if x1 < x2 or x1 > x2 + dx then return false end
  if y1 < y2 or y1 > y2 + dy then return false end
  return true
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

    local s
    for _, opt in ipairs(opts) do
      if insideRect(x, y, opt.pos[1], opt.pos[2], opt.size[1], opt.size[2]) then
        s = opt
        break
      end
    end
    if s then
      for _, opt in ipairs(opts) do opt.selected = nil end
      s.selected = true
    end

    for _, obj in ipairs(objs) do
      if insideCircle(obj.pos[1], obj.pos[2], x, y, 10) then
        selected = obj.name
        break
      end
    end

    local i = math.floor((x - 20) / 60) + 1
    local j = math.floor((y - 50) / 60) + 1
    if i > 0 and i < 7 and j > 0 and j < 7 and insideCircle(x, y, 60 * i - 10, 20 + 60 * j, 20) then
      line = {i, j}
    end
  elseif button == 'r' then
    x = x - W/2
    local i = math.floor((x - 20) / 60) + 1
    local j = math.floor((y - 50) / 60) + 1
    if i > 0 and i < 7 and j > 0 and j < 7 and insideCircle(x, y, 60 * i - 10, 20 + 60 * j, 20) then
      balls[i][j].name = nil
    end
  end
end

function mousereleased(x, y, button)
  if button ~= 'l' then return end
  x = x - W/2
  local i = math.floor((x - 20) / 60) + 1
  local j = math.floor((y - 50) / 60) + 1
  if selected then
    if i > 0 and i < 7 and j > 0 and j < 7 and insideCircle(x, y, 60 * i - 10, 20 + 60 * j, 20) then
      balls[i][j].name = selected
    end
    selected = nil
  elseif line then
    local di = i - line[1]
    local dj = j - line[2]
    if i > 0 and i < 7 and j > 0 and j < 7 and math.abs(di) <= 1 and 
        math.abs(dj) <= 1 and di * dj == 0 and di ~= dj and insideCircle(x, y, 60 * i - 10, 20 + 60 * j, 20) then
      local d = di == 1 and 1 or dj == 1 and 2 or di == -1 and 3 or 4
      balls[line[1]][line[2]].dirs[d] = true
    end
    line = nil
  end
end

local im = love.graphics.newImage "assets/arrow.png"
function draw (graphics, width, height)
  graphics.print("Craft", width/2, 12)
  graphics.print("Circuit is " .. (valid and "valid" or "invalid"), width/2, 25)
  
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

  for _, opt in ipairs(opts) do
    g.setColor(40, opt.selected and 120 or 40, opt.selected and 20 or 70)
    g.rectangle("fill", opt.pos[1], opt.pos[2], opt.size[1], opt.size[2])
    g.setColor(255, 255, 255)
    g.printf(opt.text, opt.pos[1], opt.pos[2] + opt.size[2]/2 - 8, opt.size[1], "center")
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

  opts = {}
  for i, n in ipairs {"Bullet", "Laser", "Trap"} do
    opts[i] = {
      text = n,
      pos = {120 * i - 100, H - 190},
      size = {100, 40}
    }
  end
  opts[1].selected = true
end

local checked

local function isValid(i, j)
  if checked[i][j] then return false end
  checked[i][j] = true
  local any = balls[i][j].dirs[1] or balls[i][j].dirs[2] or balls[i][j].dirs[3] or balls[i][j].dirs[4]
  if (not any and balls[i][j].name ~= "output") or
      (any and balls[i][j].name == "output") then return false end
  if balls[i][j].dirs[1] and not isValid(i + 1, j) then return false end
  if balls[i][j].dirs[2] and not isValid(i, j + 1) then return false end
  if balls[i][j].dirs[3] and not isValid(i - 1, j) then return false end
  if balls[i][j].dirs[4] and not isValid(i, j - 1) then return false end
  return true
end

local function checkValidity()
  -- Starts in (1,1); doesn't matter where generators are
  -- no loops or joining for now
  checked = {}
  for i = 1, 6 do checked[i] = {} end
  valid = isValid(1, 1)
  return valid
end

local timeToCheck = 0
function update(dt)
  timeToCheck = timeToCheck + dt
  if timeToCheck > .4 then
    timeToCheck = timeToCheck - .4
    checkValidity()
  end
end

local function translateEffect(mana)
  return mana
end

local function gAux(i, j, manaType)
  local n = balls[i][j].name
  if n == "generator" then n = nil end
  if n == "output" then return {translateEffect(manaType)} end
  manaType = n or manaType
  local out = {}
  for d = 1, 4 do
    if balls[i][j].dirs[d] then
      local ni = d == 1 and i + 1 or d == 3 and i - 1 or i
      local nj = d == 2 and j + 1 or d == 4 and j - 1 or j
      local outs = gAux(ni, nj, manaType)
      for _, o in ipairs(outs) do
        if o ~= "bland" then
          out[#out + 1] = o
        end
      end
    end
  end

  return out
end

local function getEffects()
  return gAux(1, 1, "bland")
end

function getMagic()
  if not checkValidity() then return end
  local m = {}

  -- getting mode
  for _, opt in ipairs(opts) do
    if opt.selected then m.type = opt.text break end
  end

  m.effects = getEffects()
  m.selfUse = false
  return m
end