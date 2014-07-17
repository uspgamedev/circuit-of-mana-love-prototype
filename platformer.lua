
local avatars = {
  {
    pos = {-2, 0},
    sprite = love.graphics.newImage "assets/chara00.png"
  },
  {
    pos = {2, 0},
    sprite = love.graphics.newImage "assets/chara01.png"
  }
}

function load()

end

function play()
  local m = views.craft.getMagic()
  if not m then return end
  if m.type == "Bullet" then
    print "pew pew pew"
  elseif m.type == "Laser" then
    print "bzzzzzzz, or something like that"
  elseif m.type == "Trap" then
    print "Wait for it.... BOOM"
  end
  print "Effects:"
  for _, eff in ipairs(m.effects) do
    io.write("  ", eff, "\n")
  end
end

local function draw_avatar (graphics, avatar)
  local x,y = unpack(avatar.pos)
  local w,h = avatar.sprite:getDimensions()
  graphics.push()
  graphics.translate(24*x, 24*y)
  graphics.draw(
    avatar.sprite,
    0, 0, 0, 1, 1, w/2, 0.9*h
  )
  graphics.pop()
  graphics.setColor(255, 255, 255, 255)
end

function draw (graphics, width, height)
  graphics.translate(width/2, height/2)
  graphics.setColor(115, 130, 105, 255)
  graphics.rectangle(
    'fill',
    -width/4, 0,
    width/2, height/8
  )
  graphics.setColor(255, 255, 255, 255)
  for _,avatar in ipairs(avatars) do
    draw_avatar(graphics, avatar)
  end
end
