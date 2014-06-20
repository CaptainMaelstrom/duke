--Monocle class code

Monocle = class('Monocle'):include(stateful)

function Monocle:initialize()
	self.clocks = {}
	self.tweens = {}
	self.obs = beholder.observe('mousereleased', function(x,y,button)
		if button=='r' and not game.player.obs.release and not game.referee.obs.release and not self.troop then
			-- local x,y = game.cam.lens:toScreen(x,y)
			local r,c = game.board:getRowCol(x,y)
			if r and c then
				-- flags[1] = r .. ' ' .. c
				local t = game.board.troops[r][c]
				if tostring(game.board.troops[r][c]):find('Troop') then
					self.troop = Troop(t.name, t.color, 0)
					self:slideIn()
				end
			else
				local x,y = game.cam.lens:toWorld(x,y)
				-- flags[1] = x
				-- flags[2] = y
			end
		elseif self.troop and not next(self.tweens) then
			self:slideOut()
		end
	end)
end

function Monocle:draw()
	if self.troop then
		local t = self.troop
		lg.setLineWidth(4)
		lg.setColor(35,35,35,self.alpha)
		lg.line(self.x,0,self.x,sh)
		lg.setColor(10,10,10,self.alpha)
		lg.rectangle('fill',self.x + 2,0,sw+5-self.x,sh)
		lg.setColor(255,255,255,self.alpha)
		lg.draw(t.top, 		self.x + 0.6*t.scale*t.size, sh*.2, 	t.rotation, t.scale, t.scale,t.size/2,t.size/2)
		lg.draw(t.bottom, 	self.x + 0.6*t.scale*t.size, sh*.6,		t.rotation, t.scale, t.scale,t.size/2,t.size/2)
	end
end


function Monocle:slideIn()
	--calculate troop size
	local t = self.troop
	t.scale = (0.3*sh)/t.size
	local w = t.scale*t.size
	self.x = sw+5
	self.alpha = 100
	self.tweens[1] = tween(.18,self,{x = sw-w*1.2}, 'outQuad', function() tween.stop(self.tweens[1]) self.tweens[1] = nil end)
	self.tweens[1] = tween(.65,self,{alpha = 255}, 'outExpo', function() tween.stop(self.tweens[1]) self.tweens[1] = nil end)
end

function Monocle:slideOut()
	self.tweens[1] = tween(.45,self,{alpha = 0}, 'outExpo', function() tween.stop(self.tweens[1]) self.tweens[1] = nil self.x = nil self.alpha = nil self.troop = nil end)
end









