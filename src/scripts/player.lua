
--player code

Player = class('Player')

Player.abilities = {
	divination = function(r,c,dtroops)
		local success,dukeRow,dukeCol = game.board:findDuke(game.players[game.myIndex].color)
		local adj = game.board.troops[dukeRow][dukeCol]:getAdjacentSpots(true,true)
		if next(adj) and #game.player.bag > 0 then
			game.referee:interrupt()
			game.referee.status = ''
			game.player.divinedTroops = (dtroops or {})
			if r and c then game.player.divinedTroops.r = r game.player.divinedTroops.c = c end
			local keeper
			for i = 1,3 do			--draw one to three troops
				if #game.player.bag >= 1 then
					table.insert(game.player.divinedTroops,{troop = Troop(table.remove(game.player.bag), game.players[game.myIndex].color, (game.cam.targetRotation or 0) )})
				end
			end
			for i,t in ipairs(game.player.divinedTroops) do
				t.troop:setScale(0.25)
				local x,y = (i-.5)*(sw/#game.player.divinedTroops+1),	sh*.35
				x,y = game.cam.lens:toWorld(x,y)
				t.troop.x = x
				t.troop.y = y
			end
			game.player.obs.release = beholder.observe('mousereleased', function(x,y,button)
				local index
				for i,v in ipairs(game.player.divinedTroops) do
					if v.troop:isHoveredOver(x,y) then index = i break end
				end
				local t = game.player.divinedTroops[index]
				if button=='l' and t then
					for j,otherTroop in ipairs(game.player.divinedTroops) do if j~=index then otherTroop.keep = nil end end		--can't keep more than one troop
					t.discard = nil
					if not t.keep then t.keep = true else t.keep = nil if keeper == t.troop then keeper = nil end end	--toggle keep
					keeper = t.troop
				elseif button=='r' and t then
					if keeper == t.troop then keeper = nil end
					t.keep = nil
					if not t.discard then t.discard = true else t.discard = nil end	--toggle keep
				end
			end)
			game.player.obs.keypress = beholder.observe('keypressed', function(key,isrepeat)
				if keeper and key==' ' then
					--discard or replace troops then shuffle bag
					for j,otherTroop in ipairs(game.player.divinedTroops) do 
						if otherTroop.discard then
							table.insert(game.graveyards[game.myIndex],otherTroop.troop)
						elseif keeper~=otherTroop.troop then
							table.insert(game.player.bag,otherTroop.troop.name)
						end
					end
					game.player.bag = table.shuffle(game.player.bag)	--shuffle
					beholder.stopObserving(game.player.obs.keypress)
					beholder.stopObserving(game.player.obs.release)
					game.player.obs.keypress = nil
					game.referee.highlight = adj
					game.player.divinedTroops = nil
					--let player choose where to place chosen divined troops
					game.player.obs.release = beholder.observe('mousereleased', function(x,y,button)
						local r2,c2 = game.board:getRowCol(x,y)
						if button=='l' and r2 and c2 then
							local orders = {}
							orders[1] = {name = 'place', troop = keeper.name, color = keeper.color, rotation = keeper.rotation, r = r2, c = c2}
							orders[2] = {name = 'flip', r = r or game.player.divinedTroops.r, c = c or game.player.divinedTroops.c}
							beholder.stopObserving(game.player.obs.release)
							game.player.obs.release = nil
							game.referee:executeTurn(orders,true)
							game.player.divinedTroops = nil
						end
					end)
				end
			end)
		end
	end,
	summon = function(r,c)
		local success,dukeRow,dukeCol = game.board:findDuke(game.players[game.myIndex].color)
		local adj = game.board.troops[dukeRow][dukeCol]:getAdjacentSpots(true,true)
		if next(adj) then
			game.referee:interrupt()
			game.referee.highlight = adj
			game.referee.status = 'Choose a spot to summon the tile to.'
			game.player.obs.release = beholder.observe('mousereleased', function(x,y,button)
				local r2,c2 = game.board:getRowCol(x,y)
				if button=='l' and r2 and c2 then
					if table.find(adj,{r2,c2}) then
						local orders = {}
						orders[#orders+1] = {name = 'flip', r = dukeRow, c = dukeCol}
						-- if not flags[1] then flags[1] = 1 else flags[1] = flags[1] + 1 end
						-- if not tostring(game.board.troops[r][c]):find('Troop') then error('no troop ' .. flags[1]) end
						orders[#orders+1] = {name = 'move', r = r, c = c, r2 = r2, c2 = c2}
						beholder.stopObserving(game.player.obs.release)
						game.player.obs.release = nil
						game.referee:executeTurn(orders,true)
					end
				else
					beholder.stopObserving(game.player.obs.release)
					game.player.obs.release = nil
					game.referee:interrupt()
					game.referee:promptMove()
				end
			end)
		end
	end
}

function Player:initialize()
	local p = game.players[game.myIndex]
	self.name,self.color,self.address = p.name,p.color,p.address
	self.bag = table.deepcopy(tilebags[1])
	self.obs = {}
end

function Player:update(dt)
	--check to see if player can use ability
	self.status = nil
	if game.turn==game.myIndex and not self.hand and game.referee.obs.press then
		local r,c = game.board:getRowCol(lmo.getPosition())
		if r and c then
			local spot = game.board.troops[r][c]
			if tostring(spot):find('Troop') then
				if spot.skill and spot.color==game.players[game.myIndex].color then
					if spot.skill[spot.facing] then
						self.status = 'Press spacebar to activate the ' .. spot.displayName .. "'s " .. spot.skill[spot.facing] .. ' ability.'
						if lk.isDown(' ') then
							Player.abilities[spot.skill[spot.facing]](r,c)
						end
					end
				end
			end
		end
	end

end

function Player:draw()
	local mx,my = game.cam.lens:toWorld(lmo.getPosition())
	if self.hand then
		self.hand.x = mx
		self.hand.y = my
		self.hand:draw()
	end
end

function Player:grabFromBag(name)
	local i
	if name then i = table.find(self.bag,name) end
	if #self.bag~=0 then
		if not i then i = lm.random(1,#self.bag) end	--get random tile if can't find named tile
		self.hand = Troop(self.bag[i], game.players[game.myIndex].color, (game.cam.targetRotation or 0))
		self.hand.scale = ((game.board.gridWidth*game.board.scale)/self.hand.size)*1.1
		table.remove(self.bag,i)
	end
end

function Player:drawDivined()
	if self.divinedTroops then
		for i,tbl in ipairs(self.divinedTroops) do
			tbl.troop:draw()
			if tbl.keep then lg.setColor(white) lg.draw(img.lifeSeal,tbl.troop.x,tbl.troop.y,(game.cam.targetRotation or 0),tbl.troop.scale,tbl.troop.scale,img.lifeSeal:getWidth()/2,img.lifeSeal:getHeight()/2) end
			if tbl.discard then lg.setColor(white) lg.draw(img.deathSeal,tbl.troop.x,tbl.troop.y,(game.cam.targetRotation or 0),tbl.troop.scale,tbl.troop.scale,img.deathSeal:getWidth()/2,img.deathSeal:getHeight()/2) end
		end
	end
end











