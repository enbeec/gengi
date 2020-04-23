local freshmaker = {}

function freshmaker.new(rate)
  re=metro.init()
  re.timer = true 
  re.timer_state = {false,true}
	re.time = 1.0/rate
  return re
end

function freshmaker.newIdle(timeout)
  return  {
    MAX = timeout or 1200,
    count = 1, is_idle = false,
    check = function(self)
      if self.count >= self.MAX then
        if self.is_idle == false then
          print("idle")
          self.is_idle = true
        end
        screen_dirty = false
      else self.count = self.count + 1 end
    end,
    whack = function(self)
      self.count = 1
      self.is_idle = false
    end,
  }
end

return freshmaker