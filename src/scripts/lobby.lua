
--Lobby code

Lobby = Game:addState('Lobby')

function Lobby:enteredState()
	self.timer = lt.getTime()
	self.localPlayerName = ''
	if not self.myIndex then self.myIndex = 1 end
	if not self.players then self.players = {{name='New Player', color = lm.random(1,8), address = ''}} end
	if not self.socket then self.socket = Socket(self.text) end
	self.boardIndex = 1
	self.boardPreview = self:makeBoardPreview()
	function love.keypressed(key,isrepeat)
		if key=='backspace' or key=='delete' and self.localPlayerName~='' then
			self.localPlayerName = self.localPlayerName:sub(1,-2)
		elseif key=='return' or key=='kpenter' and self.localPlayerName~='' then
			self.players[self.myIndex].name = self.localPlayerName
			self.localPlayerName = ''
			self.socket.host:broadcast('newptbl=' .. TSerial.pack(game.players))
		elseif key=='up' then
			self.players[self.myIndex].color = lm.modclamp(1,self.players[self.myIndex].color+1,#color)
			self.socket.host:broadcast('newptbl=' .. TSerial.pack(self.players))
		elseif key=='down' then
			self.players[self.myIndex].color = lm.modclamp(1,self.players[self.myIndex].color-1,#color)
			self.socket.host:broadcast('newptbl=' .. TSerial.pack(self.players))
		elseif key=='left' then
			self.boardIndex = lm.modclamp(1,self.boardIndex-1, #boards)
			self.socket.host:broadcast('board=' .. tostring(self.boardIndex))
			self.boardPreview = self:makeBoardPreview()
		elseif key=='right' then
			self.boardIndex = lm.modclamp(1,self.boardIndex+1, #boards)
			self.socket.host:broadcast('board=' .. tostring(self.boardIndex))
			self.boardPreview = self:makeBoardPreview()
		elseif key=='s' and (lk.isDown('lctrl') or lk.isDown('rctrl')) then
			self.socket.host:broadcast('gotoPlay')
			self:gotoState('Play')
		end
	end
	function love.textinput(t)
		self.localPlayerName = self.localPlayerName .. t
	end
end

function Lobby:exitedState()
	local rem = {}
	for i,p in ipairs(self.players) do
		if p.inGame then rem[#rem+1] = i end
	end
	for i = #rem,1,-1 do
		local peers = self.socket:getPeers()
		for j,p in ipairs(peers) do
			if tostring(p)==self.players[rem[i]].address then p:disconnect_now() end
		end
		table.remove(self.players,rem[i])
	end
	self.myIndex = table.find(self.players,self.socket.address,2)
	self.localPlayerName = nil
	self.boardPreview = nil
	love.textinput = nil
end

function Lobby:update(dt)
	self.socket:update(dt)
end

function Lobby:makeBoardPreview(indv)
	local ind = indv or self.boardIndex
	local map = boards[ind]
	local gw = math.min((320)/#map,(650)/#map[1])
	local canv = lg.newCanvas(32+gw*#map[1],32+gw*#map)
	lg.setCanvas(canv)
	lg.setLineWidth(2)
	for r = 1,#map do
		for c = 1,#map[1] do
			if map[r][c]==1 then
				lg.setColor(white)
				lg.rectangle('line',16+(c-1)*gw,16+(r-1)*gw,gw,gw)
			elseif map[r][c]>=2 then
				lg.setColor(white)
				lg.rectangle('line',16+(c-1)*gw,16+(r-1)*gw,gw,gw)
				lg.setColor(135,155,115,100)
				lg.rectangle('fill',16+(c-1)*gw,16+(r-1)*gw,gw,gw)
			end
		end
	end
	lg.setCanvas()
	return canv
end

function Lobby:draw()
	local fntWidth = function(text) return lg.getFont():getWidth(text) end
	
	lg.setColor(white)
	lg.setFont(fnt.default)
	lg.print('Lobby',sw/2 - fntWidth('Lobby')/2 ,18*1)
	lg.print('Enter your name:',sw/2 - fntWidth('Enter your name:')/2 ,18*2)
	lg.print(self.localPlayerName,sw/2 - fntWidth(self.localPlayerName)/2 ,18*3)
	if (lt.getTime() - self.timer)%0.75 > 0.375 then lg.print('|',sw/2 + fntWidth(self.localPlayerName)/2 ,18*3-2) end
	lg.print('Players:',sw/2 - fntWidth('Players:')/2 ,18*4)
	--draw player names rows 5-8
	local i = 1
	for _,p in pairs(self.players) do
		if not p.inGame then
			-- lg.setColor(white)
			lg.setColor(color[p.color])
			if p.inGame then lg.setColor(120,120,120) end
			local str = p.name
			lg.print(str,sw/2 - fntWidth(str)/2,18*(4+i))
			
			-- lg.rectangle('fill',sw/2 + fntWidth(str)/2+12,18*(4+i),14,14)
			-- lg.setColor(white)
			-- lg.setLineWidth(1)
			-- lg.rectangle('line',sw/2 + fntWidth(str)/2+12,18*(4+i),14,14)
			i = i + 1
		end
	end
	lg.setColor(white)
	lg.print(boards[self.boardIndex].name,sw/2 - fntWidth(boards[self.boardIndex].name)/2,18*9)
	local w = self.boardPreview:getWidth()
	lg.draw(self.boardPreview,sw/2,18*10,0,1,1,w/2)
	
	lg.print('Press <- or -> to change map'		,sw/2 - fntWidth('Press <- or -> to change map')/2,sh-18*3)
	lg.print('Press ^ or v to change your color',sw/2 - fntWidth('Press ^ or v to change your color')/2,sh-18*2)
	lg.print('Press Ctrl+S to start game'		,sw/2 - fntWidth('Press Ctrl+S to start game')/2,sh-18*1)
end




