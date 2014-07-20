module("component", package.seeall)

local components = {}
local offset

--[[  Note to self:
        Elements = Mana "generators"
        Catalysers = Target type
        Fluxors = Effect type
        Modifiers = On-hit effect
        Behaviors = Offensive / Defensive
  ]]

local RADIUS = 10

function load(x_offset) 
  offset = x_offset
end

local function contains(comp, x, y)
  x = x - offset
  local dx, dy = comp.x - x, comp.y - y
  return dx*dx + dy*dy < RADIUS*RADIUS
end

local function calculate(comp)
  for v in pairs(comp.inputs) do
    local c = comp.inputs[v]
    if c.ctype ~= "elements" then 
      comp.value = c.action(comp.value)
    end
  end
end

local function newComponent(_type, _mod, _color)
  local inst = {inputs = {}, outputs = {}, wires = {}, ctype = _type, color = _color}
  
  if type(_mod) == "function" then
    inst.action = _mod
    inst.value = 0
  else
    inst.value = _mod
    inst.action = nil
  end

  return inst
end

function getComponent(x, y)
  for v in pairs(components) do
    local c = components[v]
    if contains(c, x, y) then
      return c
    end
  end
  return nil
end

function create(x, y, type, primitive)
  local inst = {}
  for i,v in pairs(type) do
    inst[i] = v
  end
  inst.x, inst.y = x, y

  if primitive then inst.primitive = true
  else inst.primitive = nil end

  return inst
end

function register(comp)
  table.insert(components, comp)
end

function remove(x, y)
  local i = 1
  for v in pairs(components) do
    local c = components[v]
    if contains(c, x, y) and not c.primitive then
      for v in pairs(c.wires) do
        wire.remove(c.wires[v])
      end
      table.remove(components, i)
    end
    i = i + 1
  end
end

function draw(graphics, width, height)
  for v in pairs(components) do
    local c = components[v]
    graphics.setColor(unpack(c.color))
    graphics.circle("fill", c.x, c.y, RADIUS, 100)
  end
end

WATER = newComponent("elements", 10, {63, 127, 210})
FIRE = newComponent("elements", 10, {206, 57, 57})

BOLT = newComponent("catalysers", function(val) return val end, {189, 102, 35})
LASER = newComponent("catalysers", function(val) return val/2 end, {52, 188, 70})
SELF = newComponent("catalysers", function(val) return 2*val end, {197, 199, 199})

SHIELD = newComponent("fluxors", function(val) return val end, {42, 166, 175})
AURA = newComponent("fluxors", function(val) return val end, {249, 249, 249})

EXPLOSIVE = newComponent("modifiers", function(val) return val-10 end, {152, 70, 53})
TRAP = newComponent("modifiers", function(val) return val+10 end, {46, 46, 46})

OFFENSIVE = newComponent("behaviors", function(val) return -math.abs(val) end, {255, 0, 0})
DEFENSIVE = newComponent("behaviors", function(val) return math.abs(val) end, {205, 63, 186})

local types = {"elements", "catalysers", "fluxors", "modifiers", "behaviors"}
