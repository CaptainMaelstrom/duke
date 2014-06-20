
--referee code

Referee = class('Referee')

function Referee:initialize()
	self.clocks = {}
	self.obs = {}
	self:initSword()	--initializes the sword spin to see who goes first
	self.status = 'Spin the sword to see who goes first...'
	
	self.obs.takeback = beholder.observe('keypressed', function(key,isrepeat)
		if key=='z' and (lk.isDown('lctrl') or lk.isDown('rctrl')) and game.lastTurn then
			--if it's directly the next person's turn, send request to next person
			local nextPlayerIndex
			for i = 1,3 do
				local index = lm.modclamp(1,game.myIndex+i,#game.players)
				if not game.players[index].dead then nextPlayerIndex = index break end
			end
			if game.turn==nextPlayerIndex and not self.requesting then
				self.requesting = true
				game.socket.host:broadcast('takeback=request')
				self.status = 'Takeback request was sent...'
			end
		end
	end)
end

function Referee:initSword()
	self.sword = {}
	self.sword.draw = true
	self.sword.r = math.pi/2
	self.sword.sz = 1/2
	self.sword.click = beholder.observe('mousepressed', function(x,y,button) if button=='l' and coll.pointBox(x,y,{sw/2-50,sh/2-220,100,440}) and not game.turn then self:spinSword() end end)
end

function Referee:spinSword(spins)
	self.status = ''
	local spins = spins or #game.players*6+lm.random(1,#game.players)
	game.socket.host:broadcast('spins=' .. spins)
	game.turn = spins%#game.players+1
	self.spinTween = tween(3.5, self.sword, {r = math.pi/2+(2*math.pi/#game.players)*spins},'outQuad',function() self.clocks.sword = cron.after(1.5,function()
		self.spinTween = nil
		self.sword.draw = false
		self.clocks.sword = nil
		beholder.stopObserving(self.sword.click)
		if game.turn==game.myIndex then
			self:promptSetup()
		else
			self.status = 'Waiting for ' .. game.players[game.turn].name .. ' to set up.'
		end
	end) end)
end

function Referee:promptSetup()
	local function rotateCam(r,c)
		local spot = game.board.map[r][c]
		if spot==2 then
			
		elseif spot==3 then
			game.cam:rotate(math.pi/2)
		elseif spot==4 then
			game.cam:rotate(math.pi,1)
		elseif spot==5 then
			game.cam:rotate(-math.pi/2)
		else
			error("Can't place duke on a non-starting tile")
		end
	end
	
	self.status = 'Place your Duke on a starting tile...'
	game.player:grabFromBag('duke')
	local orders = {}
	self.highlight = game.board:getOpenStartingTiles()
	self.obs.release = beholder.observe('mousereleased', function(x,y,button)		--if the player clicks a valid spot, place duke
		local r,c = game.board:getRowCol(x,y)
		if table.find(self.highlight,{r,c},3) and r and c then
			rotateCam(r,c)
			game.player.hand.rotation = game.cam.targetRotation
			game.board:placeTroop(game.player.hand,r,c)
			orders[#orders+1] = {name = 'place', troop = game.player.hand.name, color = game.player.hand.color, rotation = game.cam.targetRotation, r = r, c = c}
			game.player:grabFromBag('footman')
			self.status = 'Place your footman next to your Duke...'
			self.highlight = game.board.troops[r][c]:getAdjacentSpots(true,true)
			beholder.stopObserving(self.obs.release)
			self.obs.release = beholder.observe('mousereleased', function(x,y,button)			--place first footman
				local r,c = game.board:getRowCol(x,y)
				if table.find(self.highlight,{r,c},3) and r and c then
					game.board:placeTroop(game.player.hand,r,c)
					orders[#orders+1] = {name = 'place', troop = game.player.hand.name, color = game.player.hand.color, rotation = game.cam.targetRotation, r = r, c = c}
					game.player:grabFromBag('footman')
					local rem = table.find(self.highlight,{r,c},3)
					table.remove(self.highlight,rem)
					beholder.stopObserving(self.obs.release)
					self.obs.release = beholder.observe('mousereleased', function(x,y,button)		--place second footman, tell next player to setup
						local r,c = game.board:getRowCol(x,y)
						if table.find(self.highlight,{r,c},3) and r and c then
							game.board:placeTroop(game.player.hand,r,c)
							orders[#orders+1] = {name = 'place', troop = game.player.hand.name, color = game.player.hand.color, rotation = game.cam.targetRotation, r = r, c = c}
							game.hasSetup = true
							game.referee:executeTurn(orders,true,true)
						end
					end)
				end
			end)
		end
	end)
end

function Referee:promptMove()
	local grabPiece, badPlacement, attemptTroopPlace,watchForPlayerClick,attemptCommand,init,observeDrawPiecePlacement	--local function declarations
	
	function observeDrawPiecePlacement(adj)
		self.obs.release = beholder.observe('mousereleased',function(x,y,button)
			local r,c = game.board:getRowCol(x,y)
			if r and c then
				if table.find(adj,{r,c}) then
					local orders = {}
					local t = game.player.hand
					orders[#orders+1] = {name = 'place', troop = t.name, color = t.color, rotation = game.cam.rotation, r = r, c = c}
					game.player.hand = nil
					self:executeTurn(orders,true)
					beholder.stopObserving(self.obs.release)
					self.obs.release = nil
				end
			end
		end)
	end
	
	function attemptCommand(t,r,c)		--needs to return true or false, on top of doing the actual commanding
		local symb = t:symbolAt(r,c)
		local t2 = game.board.troops[r][c]
		if not tostring(t2):find('Troop') then return false end
		if t2.color~=t.color then return false end
		if type(symb)=='table' then
			if not table.find(symb,'c',2) then return false end
		else
			if tostring(symb)~='c' then return false end
		end
		
		--friendly commanding troop has been placed on top of a friendly troop in the commander's command zone
		game.board:placeTroop(t,t.row,t.col)
		self.status = 'Commanding the ' .. t2.displayName
		grabPiece(r,c)
		self.highlight = t:getCommandSpots()
		local i = table.find(self.highlight,{r,c},2)
		if i then table.remove(self.highlight,i) end
		beholder.stopObserving(self.obs.draw)
		self.obs.draw = nil
		beholder.stopObserving(self.obs.release)
		self.obs.release = beholder.observe('mousereleased', function(x,y,button)
				if button=='l' then
					local r2,c2 = game.board:getRowCol(x,y)
						if r2 and c2 then
							local good = true
							if r2==t2.row and c2==t2.col then badPlacement() return end			--put back in the same place
							local symb2 = t:symbolAt(r2,c2)
							if type(symb2)=='table' then
								if not table.find(symb2,'c',2) then
									badPlacement()
									good = false
								end
							else
								if tostring(symb2)~='c' then
									badPlacement()
									good = false
								end
							end
							if tostring(game.board.troops[r2][c2]):find('Troop') then		--don't capture friendlies
								if game.board.troops[r2][c2].color == t2.color then badPlacement() good = false end
							end
							if good then
								local orders = {}
								if tostring(game.board.troops[r2][c2]):find('Troop') then 
									orders[#orders+1] = {name = 'capture', r = r2, c = c2}
								end
								orders[#orders+1] = {name = 'flip', r = t.row, c = t.col}
								orders[#orders+1] = {name = 'move', r = t2.row, c = t2.col, r2 = r2, c2 = c2}
								game.board:placeTroop(game.player.hand,r,c)
								game.referee:executeTurn(orders,true)
							end
						else
							badPlacement()
						end
				elseif button=='r' then
					badPlacement()
				end
			end)
		return true
	end
	
	function grabPiece(r,c)
		assert(type(r)=='number' and type(c)=='number', 'Row and column values must be numbers')
		game.player.hand = game.board.troops[r][c]
		game.board.troops[r][c] = game.board.map[r][c]
		beholder.stopObserving(self.obs.press)				--can't grab another
	end
	
	function badPlacement()		--put troop back and wait for player to pick another or possibly draw a troop...
		local t = game.player.hand
		game.board:placeTroop(t,t.row,t.col)
		game.player.hand = nil
		self:interrupt()
		init()
	end
	
	function attemptTroopPlace(x,y)
		assert(type(x)=='number' and type(y)=='number', 'x and y values must be numbers')
		local t = game.player.hand
		local r,c = game.board:getRowCol(x,y)
		if r and c then							--clicked inside the board
			if r==t.row and c==t.col then
				badPlacement()
			else	--if legal, do move/capture (whichever is the case), else, replace troop and update status with reason why it was illegal.
				if self:isLegalMove(t,r,c) then
					local orders = {}
					game.board:placeTroop(t,t.row,t.col)		--return what was in your hand
					if tostring(game.board.troops[r][c]):find('Troop') then
						orders[#orders+1] = {name = 'capture', r = r, c = c}
					end
					if tostring(t:symbolAt(r,c))=='s' then
						orders[#orders+1] = {name = 'flip', r = t.row, c = t.col}
					else
						if not tostring(game.board.troops[t.row][t.col]):find('Troop') then error('no troop') end
						orders[#orders+1] = {name = 'move', r = t.row, c = t.col, r2 = r, c2 = c}
						orders[#orders+1] = {name = 'flip', r = r, c = c}
					end
					game.player.hand = nil
					game.referee:executeTurn(orders,true)
				else
					--check to see if it's a command move, if not, bad placement
					if not attemptCommand(t,r,c) then
						badPlacement()
					end
				end
			end
		else
			badPlacement()
		end
	end
	
	function watchForPlayerClick(x,y,button)
		if x and y and button=='l' then
			local r,c = game.board:getRowCol(x,y)
			if r and c then
				if type(game.board.troops[r][c])=='table' then		--clicked a troop
					if game.board.troops[r][c].color == game.players[game.myIndex].color and not game.player.hand then		--it's our troop and we don't already have a piece in hand (should never even happen)
						grabPiece(r,c)
						beholder.stopObserving(self.obs.draw)
						self.obs.draw = nil
						game.player.hand.clickedAt = {x,y}
						self.obs.release = beholder.observe('mousereleased',function(x,y,button)
								if math.abs((game.player.hand.clickedAt[1]-x)) > 5 or math.abs((game.player.hand.clickedAt[2]-y)) > 5 then
									beholder.stopObserving(self.obs.release)
									attemptTroopPlace(x,y)
								else
									beholder.stopObserving(self.obs.release)
									self.obs.release = beholder.observe('mousereleased',function(x,y,button) beholder.stopObserving(self.obs.release) self.obs.release = nil attemptTroopPlace(x,y) end)
								end
							end)
					end
				end
			end
		end
	end
	
	function init()
		--find duke tile
		local success, r, c = game.board:findDuke(game.players[game.myIndex].color)
		if not success then error("Prompted for move but couldn't find Duke") end
		local adj = game.board.troops[r][c]:getAdjacentSpots(true,true)
		
		--observe player and change status (to tell player what his/her options are)
		if next(adj) then		--if any spots next to the duke are open, offer player to draw a troop
			self.status = 'Press D to draw a tile from your bag, or move a troop...'
			self.obs.draw = beholder.observe('keypressed', function(key,isrepeat)		--self.obs.draw watches to see if player presses 'd', if so, acts accordingly
				if key=='d' then
					game.player:grabFromBag()
					self.highlight = adj
					beholder.stopObserving(self.obs.draw)
					beholder.stopObserving(self.obs.press)
					self.obs.press = nil
					self.obs.draw = nil
					observeDrawPiecePlacement(adj)
				end
			end)
		else
			self.status = 'Move a troop...'
		end
		
		--this observe function tracks if the player clicks to pick up troop or clicks and holds to pick troop up..
		self.obs.press = beholder.observe('mousepressed',function(x,y,button) watchForPlayerClick(x,y,button) end)
	end
	
	if game.player.interruptedDraw then
		--find duke tile
		local success, r, c = game.board:findDuke(game.players[game.myIndex].color)
		if not success then error("Prompted for move but couldn't find Duke") end
		local adj = game.board.troops[r][c]:getAdjacentSpots(true,true)
		self.highlight = adj
		game.player.hand = game.player.interruptedDraw
		game.player.interruptedDraw = nil
		game.board:setTroopScale(game.player.hand)
		observeDrawPiecePlacement(adj)
	elseif self.dTroops then
		game.player.divinedTroops = self.dTroops
		Player.divination(nil,nil,self.dTroops)
		self.dTroops = nil
	else
		init()
	end
	
end

function Referee:isLegalMove(troop,r,c)	--r and c refer to the row and column of the new spot
	--get troop's symbol for potential new spot
	local function nextSymbolIsJumpSlide(path)
		if not path[2] then
			return false
		else
			if tostring(troop:symbolAt(path[2][1],path[2][2])):sub(1,1)=='z' then return true end
		end
		return false
	end
	
	local function checkMoveSymbol()
		local paths = {getPaths(troop.row,troop.col,r,c)}
		for i,path in ipairs(paths) do
			for j,spot in ipairs(path) do
				if game.board.map[spot[1]][spot[2]]==0 then return false, "can't move through holes" end
				if type(game.board.troops[spot[1]][spot[2]])=='table' then return false, "can't move through troops" end
			end
		end
		return true			--path(s) clear
	end
	
	assert(type(r)=='number' and type(c)=='number', 'Row and column values must be numbers')
	assert(tostring(troop):find('Troop'),'troop argument must be a instance of class Troop')
	
	local symb = troop:symbolAt(r,c)
	
	if tostring(game.board.troops[r][c]):find('Troop') then
		if game.board.troops[r][c].color==troop.color then return false, "can't capture friendlies" end
	end
	
	if type(symb)=='table' then
		if table.find(symb,'m') then
			return checkMoveSymbol()
		else
			return false, "table symbol that wasn't move"
		end
	else
		symb = tostring(symb)
		if symb=='c' then return false end	--command is handled elsewhere.
		if tostring(game.board.troops[r][c]):find('Troop') then
			if symb=='s' then return true end		--troop is enemy, we already know
		end
		if symb=='s' then return false, "no enemy to strike" end		--no enemy there to capture
		
		if symb=='j' or (symb:sub(1,1)=='s' and symb:len() > 1) or symb:sub(1,1)=='z' then
			return true
		elseif symb=='m' then
			return checkMoveSymbol()
		elseif symb=='0' or symb=='nil' or not symb then
			local paths = {getPaths(troop.row,troop.col,r,c)}
			if #paths~=1 then
				return false, "not one path"
			else
				local found
				for i,path in ipairs(paths) do
					for j,spot in ipairs(path) do
						local spotSymb = tostring(troop:symbolAt(spot[1],spot[2]))
						if (spotSymb:sub(1,1)=='s' and spotSymb:len() > 1) or spotSymb:sub(1,1)=='z' then found = true end		--found a slide or jump slide on the path
						if game.board.map[spot[1]][spot[2]]==0 and found then return false, "ran into a hole along path" end
						if type(game.board.troops[spot[1]][spot[2]])=='table' and not nextSymbolIsJumpSlide(path) then return false, "ran into a troop along slide" end
					end
				end
				if found then return true else return false,"straight line path, no slide found" end
			end
		end
	end
	flags[1] = ("error--couldn't determine legality of--" .. 'symb: ' .. tostring(symb) .. ' of type: ' .. type(symb) .. ' from ' .. r .. ' to ' .. c)
	return false,"couldn't determine legality"
end

function Referee:takeTurn()		--checks to see if it's our turn, if so, prompt move or prompt setup
	if game.turn == game.myIndex then
		if not game.hasSetup then
			self:promptSetup()
		else
			if not game.players[game.myIndex].dead then
				self:promptMove()
			end
		end
	else
		self.status = 'Waiting on ' .. game.players[game.turn].name
	end
end

function Referee:draw()
	if self.sword.draw then self:drawSword() end
	if self.highlight then
		for i,spot in ipairs(self.highlight) do
			local x,y = game.board:getXY(spot[1],spot[2])
			local gw = game.board.scale*128*0.8
			lg.setColor(230,255,220,80)
			lg.rectangle('fill',x-gw/2+1,y-gw/2,gw,gw)
		end
	end
end

function Referee:update(dt)
	for i,c in pairs(self.clocks) do c:update(dt) end
end

function Referee:drawSword()
	lg.setColor(0,0,0,220)
	lg.rectangle('fill',0,0,sw,sh)
	lg.setColor(white)
	local mx,my = lmo.getPosition()
	if coll.pointBox(mx,my,{sw/2-50,sh/2-220,100,440}) then
		lg.setColor(255,150,150)
	end
	-- lg.rectangle('line',sw/2-50,sh/2-220,100,440)
	lg.draw(img.sword,sw/2,sh/2,self.sword.r,self.sword.sz,self.sword.sz,img.sword:getWidth()/2,img.sword:getHeight()/2)
	
	--draw player names
	lg.setColor(white)
	lg.setFont(fnt.d48)
	for i,p in ipairs(game.players) do
		local x,y,w,h = sw/2,sh/2, fnt.d48:getWidth(p.name), 42
		if i==1 then
			y = y+sh/4-h/2
			x = x - w/2
			lg.print(p.name,x,y)
		else
			x = x + math.cos(math.pi/2 + (i-1)*2*math.pi/#game.players)*sh/4 - w/2
			y = y + math.sin(math.pi/2 + (i-1)*2*math.pi/#game.players)*sh/4 - h/2
			lg.print(p.name,x,y)
		end
	end
end

function Referee:killPlayer(clr)
	--fade tiles out
	game.board.fading = {}
	for r,_ in ipairs(game.board.troops) do
		for c,troop in ipairs(game.board.troops[r]) do
			if tostring(troop):find('Troop') then
				if troop.color==clr then troop:fade() end
			end
		end
	end
	--change player table so player[i].dead = true
	local alive = 0
	for i,p in ipairs(game.players) do
		if p.color==clr then p.dead = true end
		if not p.dead then alive = alive+1 end
	end
	--if there's only one player left alive, flow control
	if alive == 1 then
		for i,p in ipairs(game.players) do
			if not p.dead then game.winner = i end
		end
		if game.myIndex==game.winner then
			self.status = 'You are the winner! Click anywhere to return to the lobby.'
		else
			self.status = game.players[game.winner].name .. ' is the winner! Click anywhere to return to the lobby.'
		end
		
		self.obs.toLobby = beholder.observe('mousepressed', function(x,y,button)
				game:gotoState('Lobby')
			end)
	end
end

function Referee:drawTakebackRequest()
	lg.setColor(0,0,0,220)
	lg.rectangle('fill',0,0,sw,sh)
	local lastPlayerIndex
	for i = 1,3 do
		local index = lm.modclamp(1,game.myIndex-i,#game.players)
		if not game.players[index].dead then lastPlayerIndex = index break end
	end
	local s = game.players[lastPlayerIndex].name .. ' has requested to take back their last move. Press Y to grant takeback or N to decline.'
	lg.regPrint(s, sw/2 - lg.getFont():getWidth(s)/2, sh/2-10)
end

function Referee:interrupt()
	--mostly for when receiving takeback requests / draw offers / forfeit, etc., clean up essentially
	local t = game.player.hand
	if t then
		if t.row and t.col then
			game.board:placeTroop(t,t.row,t.col)
		else
			game.player.interruptedDraw = t
		end
		game.player.hand = nil
	end
	if game.player.divinedTroops then
		self.dTroops = game.player.divinedTroops
		game.player.divinedTroops = nil
	end
	self.highlight = nil
	for name,func in pairs(self.obs) do
		if name~='takeback' and name~='toLobby' then
			beholder.stopObserving(func)
			self.obs[name] = nil
		end
	end
	game.player.status = nil
	if not self.status:find('winner') then self.status = '' end
end

function Referee:executeTurn(tbl,bcast,setup)
	if not setup then
		for i,order in ipairs(tbl) do
			if order.name=='place' then
				game.board:placeTroop(Troop(order.troop,order.color,order.rotation),order.r,order.c)
			elseif order.name=='flip' then
				game.board.troops[order.r][order.c]:flip()
			elseif order.name=='move' then
				game.board:placeTroop(game.board.troops[order.r][order.c],order.r2,order.c2)
				game.board.troops[order.r][order.c] = 1
			elseif order.name=='capture' then
				game.board:captureTroop(order.r,order.c)
			end
		end
	end
	self:interrupt()
	game.lastTurn = tbl
	if bcast then game.socket.host:broadcast('execTurn' .. TSerial.pack(tbl)) end
	if not game.winner then
		game.turn = lm.modclamp(1,game.turn + 1, #game.players)
		game.referee:takeTurn()
	end
	game.referee.requesting = nil
end

function Referee:destroy()
	beholder.stopObserving(self.obs.toLobby)
	self.obs.toLobby = nil
	beholder.stopObserving(self.obs.takeback)
	self.obs.takeback = nil
	self = nil
end







