-- a side effect only map
local function t_map(f,t)
  for _,v in pairs(t) do f(v) end
end

local game = {}
game.__index = game

function game.new(screens)
  -- screens = a table w/ keys: name,draw(self)
  local t = {
    over = false,
    -- player = include('lib/player'),
    screen = {
      -- world = include('lib/world'),
      selected = 1,
      _ws = 8,
      _wx = 128 / 8,
      _wy = 64 / 8,
    },
  }
  if screens ~= nil then
    local mt = {__index = v }
    for k,v in ipairs(screens) do
      t.screen[k] = setmetatable(v,mt)
    end
  end
  return setmetatable(t,game)
end



return game