
--Socket class code

Socket = class('Socket')
Socket:include(stateful)

local MAX_CONNECTIONS = 3

function Socket:initialize(text)
	self.peers = {}
	
	if game.loopback then
		if text=='18667' or text=='18668' or text=='18669' then
			self.host = enet.host_create("localhost:" .. text)
			self.host:connect('localhost:18666')
		else
			self.host = enet.host_create("localhost:18666")
		end
	else
		self.host = enet.host_create("*:18666")
		if text~='host' then self.host:connect(text .. ':18666') end
	end
	
	self.address = self.host:socket_get_address()
	local i,j = table.find(game.players,'',2)
	if i and j then game.players[i][j] = self.address end
	self.clocks = {}
	self.clocks[1] = cron.every(1, function()
		if game.players[game.myIndex].inGame then		--reject connecting players while in game
			for i,p in ipairs(self:getPeers()) do
				if not table.find(game.players,tostring(p),2) then p:disconnect_now() end
			end
		end
	end)
end

function Socket:update(dt)
	for i,c in ipairs(self.clocks) do c:update(dt) end
	if game.players[game.myIndex].inGame then		--reject connecting players while in game
		for i,p in ipairs(self:getPeers()) do
			if not table.find(game.players,tostring(p),2) then p:disconnect_now() end
		end
	end
	local event = self.host:service()
	if event then
		if event.type=='connect' then
			game.players.connecting = self.address
			self.host:broadcast('newptbl=' .. TSerial.pack(game.players))
			game.players.connecting = nil
		elseif event.type=='disconnect' then
			local tbl={}
			for i,p in ipairs(game.players) do
				if p.address==tostring(event.peer) then
					if game.referee then game.referee:killPlayer(p.color) end
					table.insert(tbl,i)
				end
			end
			for i=#tbl,1,-1 do
				table.remove(game.players,tbl[i])
			end
			game.myIndex = table.find(game.players,self.address,2)
		elseif event.type=='receive' then
			if event.data:sub(1,8) == 'newptbl=' and not game.players[game.myIndex].inGame then
				self:fixTables(event)
			elseif event.data:sub(1,6) == 'board=' then
				game.boardIndex = tonumber(event.data:sub(7))
				game.boardPreview = game:makeBoardPreview()
			elseif event.data:sub(1,8)=='gotoPlay' then
				game:gotoState('Play')
			elseif event.data:sub(1,6)=='spins=' and not game.turn then
				game.referee:spinSword(tonumber(event.data:sub(7)))
			elseif event.data:sub(1,8)=='execTurn' then
				local turn = TSerial.unpack(event.data:sub(9))
				game.referee:executeTurn(turn)
			elseif event.data:sub(1,11)=='backToLobby' then
				for i,p in ipairs(game.players) do
					if p.address==tostring(event.peer) then p.inGame = nil end
				end
			elseif event.data:sub(1,9)=='takeback=' then
				self:processTakebackPacket(event)
			end
		end
	end
end

function Socket:fixTables(ev)
	--if any players are missing from our table, add them in address sorted order	
	local newTable = TSerial.unpack(ev.data:sub(9))
	for i,n in ipairs(newTable) do
		local found = table.find(game.players,n.address,2)
		if not found then
			table.insert(game.players,n)
			table.sort(game.players,sort.IP)
			if newTable.connecting then		--add and connect if not connecting address
				if n.address~=newTable.connecting then self.host:connect(n.address) self.host:broadcast('newptbl=' .. TSerial.pack(game.players)) end
			else		--add/connect any
				self.host:connect(n.address)
			end
			game.myIndex = table.find(game.players,self.address,2)				--adjust our own index
			
		else
			game.players[i].color=n.color
			game.players[i].name = n.name
		end
	end
end

function Socket:getPeers(str)
	local tbl = {}
	for i = 1, MAX_CONNECTIONS do
		local p = self.host:get_peer(i)
		if tostring(p)~='0.0.0.0:0' then
			if str then tbl[#tbl+1] = tostring(p) else tbl[#tbl+1] = p end
		end
	end
	return tbl
end

function Socket:die()
	local peers = self:getPeers()
	for i,p in ipairs(peers) do p:disconnect_now() end
end

function Socket:processTakebackPacket(event)
	
	local function undoLastTurn()
		local orders = game.lastTurn
		for i = #orders,1,-1 do
			local order = orders[i]
			if order.name=='place' then
				-- game.board:placeTroop(Troop(order.troop,order.color),order.r,order.c)
				--INSERT--should be able to handle undoing setup at a later date
				if game.turn==game.myIndex then game.player.hand = game.board.troops[order.r][order.c] end
				game.board.troops[order.r][order.c] = 1
			elseif order.name=='flip' then
				game.board.troops[order.r][order.c]:flip()
			elseif order.name=='move' then
				game.board:placeTroop(game.board.troops[order.r2][order.c2],order.r,order.c)
				game.board.troops[order.r2][order.c2] = 1
			elseif order.name=='capture' then
				--if you killed a Duke, revive the team
				local t = game.graveyards[game.turn][#game.graveyards[game.turn]]
				if t.duke then
					for i,troop in ipairs(game.board.fading) do
						game.board:placeTroop(troop,troop.row,troop.col)
						troop.alpha = 255
					end
				else
					game.board:placeTroop(t,t.row,t.col)
				end
			end
		end
	end

	local lastPlayerIndex
	for i = 1,4 do
		if game.players[i].address == tostring(event.peer) then
			lastPlayerIndex = i
			break
		end
	end
	
	if event.data:sub(10)=='request' then
		--if I'm the current player, I can accept or decline
		game.referee:interrupt()
		if game.turn == game.myIndex then
			game.referee.drawTakeback = true
			game.referee.obs.tb = beholder.observe('keypressed', function(key,isrepeat)
			if key=='y' then
				self.host:broadcast('takeback=y')
				game.turn = lastPlayerIndex
				undoLastTurn()
				game.referee.drawTakeback = nil
			elseif key=='n' then
				event.peer:send('takeback=n')
				game.referee:promptMove()
				game.referee.drawTakeback = nil
			end
			end)
		else
			game.referee.status = 'Current player got a takeback request from ' .. game.players[lastPlayerIndex].name
		end
	elseif event.data:sub(10)=='n' then
		if game.referee.requesting then
			game.referee.status = 'Your takeback request was declined.'
		else
			game.referee.status = game.players[lastPlayerIndex].name .. "'s takeback request was declined."
		end
	elseif event.data:sub(10)=='y' then
		if game.referee.requesting then
			game.referee.status = 'Your takeback request was granted.'
			game.turn = game.myIndex
		else
			game.referee.status = game.players[lastPlayerIndex].name .. "'s takeback request was granted."
			game.turn = lastPlayerIndex
		end
		undoLastTurn()
		if game.referee.requesting then game.referee:promptMove() end
	end
end





