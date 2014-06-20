--Cam class code

Cam = class('Cam')

function Cam:initialize()
	self.lens = gamera.new(-sw/2,-sh/2,2*sw,2*sh)
	self.obs = {}
	self.obs.resize = beholder.observe('resize', function(w,h)
		self.lens:setWorld(-w,-h/2,3*w,2*h)
		self.lens:setWindow(0,0,w,h)
		self.lens:setPosition(sw/2,sh/2)
		--INSERT--reposition depending on state (looking at graveyard area or looking at board)
	end)
	self.tweens = {}
	self.rotation = 0
	self.lens:setPosition(sw/2,sh/2)
	--debug
end

function Cam:destroy()
	for i,id in ipairs(self.obs) do
		beholder.stopObserving(id)
	end
	self = nil
end

function Cam:drawCoords()		--just for debugging
	local divs = 20
	for i = 1,divs do
		for j = 1,divs do
			local l,t,w,h = self.lens:getWorld()
			local x,y = w/divs*i+l, h/divs*j+t
			lg.setColor(white)
			lg.print(x .. ', ' .. y, x, y)
		end
	end
end

function Cam:update(dt)
	self.lens:setAngle(self.rotation)
	-- self.lens:setScale(0.5)
end

function Cam:rotate(rot,seconds)
	if self.tweens.rotation then tween.stop(self.tweens.rotation) end
	self.targetRotation = rot
	self.tweens.rotation = tween((seconds or 0.5), self, {rotation = rot}, 'outQuad', function() tween.stop(self.tweens.rotation) self.tweens.rotation = nil end)
end







