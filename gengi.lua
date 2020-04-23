-- gengi
-- vcvcvc_val
-- llllllll.co/t/gengi-norns-game-framework
-- 
-- (pronounced:
--   'gaen-ghee')
--
-- E1 -> change game screen
-- K1 -> clock a frame
--
-- encoders/keys 2+3 depend on
--  the selected screen...
--
-- unimplemented stuff is logged
--  in the repl and on screen :)


-- includes
util = require 'util'
freshmaker = include('lib/freshmaker')
g = include('lib/game'); 

-- user supplied 'assets'
my_game = {} -- a place for the game table
my_freshmaker,my_idle = {},{} -- timing and drawing, etc

-- basic example assets
my_screens = { -- used to generate the game table
  {
    name = "title",
    enc = function(self,n,d) end,
    key = function(self,n,z) 
      local logg = logg or print
      if z == 1 then
        if n == 2 then self:event(false)
        elseif n == 3 then self:event(true)
        end
      end
    end,
    event = function(self,bool) 
        if bool then logg("start game") 
        else logg("quit")
        end
    end, draw = function(self)
      screen.font_face(3); screen.font_size(12)
      screen.level(12)
      screen.move(20,40); screen.text("screen: "..self.name)
    end,
  },{
    name = "menu",
    enc = function(self,n,d) 
      if d > 0 then logg("scroll up")   
      else logg("scroll down")
      end
    end,
    key = function(self,n,z) 
      local logg = logg or print
      if z == 1 then
        if n == 3 then 
          self:event(true)
        elseif n == 2 then 
          self:event(false) 
        end
      end
    end,
    event = function(self,bool) 
      if bool then logg("yes") 
      else logg("no")
      end
    end, draw = function(self)
      screen.font_face(3); screen.font_size(12)
      screen.level(12)
      screen.move(20,40); screen.text("screen: "..self.name)
    end,
  }
}

-- global funcs and their values (and a logging thing)
-- TODO: make these part of the freshmaker table instance
screen_dirty = true
last_return = ""
logg = function(str) print(str); last_return = str end

function init() 
  my_game = g.new(my_screens)  
  
  my_idle = freshmaker.newIdle(1200) -- frames to wait until going idle
  my_freshmaker = freshmaker.new(22) -- fps
  
  my_freshmaker.event = function()
    redraw()
    my_idle:check()
  end
  my_freshmaker:start()
end

function redraw()
  if screen_dirty == false then return end
  
  t1 = os.clock() -- TIMER 1
  screen.clear()
  
  -- engine watermark
  screen.level(3)
  screen.font_size(8); screen.font_face(1)
  screen.move(128,8); screen.text_right("Game ENGIne")
  screen.move(128,60); screen.text_right(last_return)
  
  -- selected screen
  my_game.screen[my_game.screen.selected]:draw()
  
  screen.update()
  t2 = os.clock() -- TIMER 2
  
  -- TIMER LOGIC
  if my_freshmaker.timer == true then
    local result = string.format("%.6f", t2 - t1)
    logg("frame time: " .. result.."s")
    my_freshmaker.timer = false
  end
end

function enc(n,d)
  -- use encs to wake a sleeping script
  if my_idle.is_idle then
    my_idle:whack()
    screen_dirty = true
  else my_idle:whack() end
 
  local state = my_game.screen.selected
  if n == 1 then -- change game screen
    my_game.screen.selected = util.clamp(state+d,1,#my_game.screen)
  else 
    my_game.screen[my_game.screen.selected]:enc(n,d)
  end
end

function key(n,z)
  -- use keys to wake a sleeping script
  if my_idle.is_idle then
    my_idle.whack()
    screen_dirty = true
  else my_idle:whack() end
  
  if n == 1 then -- K1 triggers debugging utilities
    my_freshmaker.timer = my_freshmaker.timer_state[z+1] -- not working :/
  else -- K2/K3 depend on game state
    my_game.screen[my_game.screen.selected]:key(n,z)
  end
end
