module("wire", package.seeall)

local lines = {}

local THRESHOLD = 5
local offset

function load(x_offset)
  offset = x_offset
end

local function contains(line, x, y)
  local x1, x2, y1, y2 = line.x1, line.x2, line.y1, line.y2
  x = x + offset
  return ((y > y1 - THRESOLD and y < y1 + THRESOLD) and 
    (x > math.min(x1, x2) and x < math.max(x1, x2))) or 
    ((x > x1 - THRESHOLD and x < x1 + THRESOLD) and 
    (y > math.min(y1, y2) and y < math.max(y1, y2)))
end

local function newLine(_x1, _y1, _x2, _y2, _in)
  local inst = {x1 = _x1, y1 = _y1, x2 = _x2, y2 = _y2, output = nil, input = _in}
  return inst
end

function create(x1, y1, x2, y2, input)
  return newLine(x1, y1, x2, y2, input)
end

function draw(graphics, width, height)
  graphics.setColor(255, 255, 255)
  for v in pairs(lines) do
    local l = lines[v]
    if math.abs(l.x1-l.x2) > math.abs(l.y1-l.y2) then
      graphics.line(l.x1, l.y1, l.x2, l.y1, l.x2, l.y2)
    else
      graphics.line(l.x1, l.y1, l.x1, l.y2, l.x2, l.y2)
    end
  end
end

function update(dt)
  for v in pairs(lines) do
    local c = lines[v]
    if c.input and c.output then
      c.x1, c.y1, c.x2, c.y2 = c.input.x, c.input.y, c.output.x, c.output.y
    end
  end
end

function register(wire)
  table.insert(lines, wire)
end

function remove(x, y)
  local i = 1
  if y then
    for v in pairs(lines) do
      local l = lines[v]
      if contains(l, x, y) then
        print "yello"
        table.remove(lines, i)
      end
      i = i + 1
    end
  else
    for v in pairs(lines) do
      if lines[v] == x then
        table.remove(lines, i)
      end
      i = i + 1
    end
  end
end