
--play state code

Play = Game:addState('Play')

function Play:enteredState()
	for i,p in ipairs(self.players) do
		if p.inGame then table.remove(self.players,i) end
	end
	self.referee = Referee()
	game.graveyards = {}
	for i,p in ipairs(self.players) do
		p.inGame = true
		game.graveyards[#game.graveyards+1] = Graveyard(i)
	end
	self.player = Player()
	self.board = Board(self.boardIndex)
	self.cam = Cam()
	self.monocle = Monocle()
	function love.keypressed(key,isrepeat) beholder.trigger('keypressed', key, isrepeat) 
		if key=='escape' then self:gotoState('Lobby') end
	end
end

function Play:exitedState()
	self.winner = nil
	self.turn = nil
	self.hasSetup = nil
	for i,p in ipairs(self.players) do
		p.dead = nil
	end
	self.referee:destroy()
	self.board:destroy()
	self.cam:destroy()
	self.players[self.myIndex].inGame = nil
	self.socket.host:broadcast('backToLobby')
	self.socket.host:flush()
end

function Play:update(dt)
	self.player:update(dt)
	self.referee:update(dt)
	self.socket:update(dt)
	self.cam:update(dt)
	tween.update(dt)
end

function Play:draw()
	self.cam.lens:draw(function(l,t,w,h)
		self.board:draw()
		self.referee:draw()
		self.player:draw()
		self.player:drawDivined()
		-- self.monocle:draw()
	end)
	self.monocle:draw()
	lg.setColor(0,0,0,220)
	lg.rectangle('fill',0,sh-40,sw,40)
	lg.regPrint(game.referee.status or '',100,sh-18)
	lg.regPrint(game.player.status or '',100,sh-36)
	if game.referee.drawTakeback then game.referee:drawTakebackRequest() end
end



