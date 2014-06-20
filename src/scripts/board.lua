
--board code
--first, init the boards table from file OR init table and make file
-- if not lfs.isFile('boards.dat') then
	local file = lfs.newFile('boards.dat')
	boards = {
		{
			{1,1,4,4,1,1},
			{1,1,1,1,1,1},
			{3,1,1,1,1,5},
			{3,1,1,1,1,5},
			{1,1,1,1,1,1},
			{1,1,2,2,1,1},
			name = 'The Field'
		},
		
		{
			{0,0,1,4,1,0,0},
			{0,1,1,4,1,1,0},
			{1,1,1,1,1,1,1},
			{3,3,1,1,1,5,5},
			{1,1,1,1,1,1,1},
			{0,1,1,2,1,1,0},
			{0,0,1,2,1,0,0},
			name = "Lion's Den"
		},
		
		{
			{0,1,1,1,1,1,0},
			{1,1,1,1,4,1,1},
			{1,3,3,0,4,1,1},
			{1,1,0,0,0,1,1},
			{1,1,2,0,5,5,1},
			{1,1,2,1,1,1,1},
			{0,1,1,1,1,1,0},
			name = "Crimson Garden"
		},
		
		{
			{1,1,1,1,4,1,1,1,1},
			{1,1,1,1,4,1,1,1,1},
			{3,3,0,0,0,0,0,5,5},
			{1,1,1,1,2,1,1,1,1},
			{1,1,1,1,2,1,1,1,1},
			name = 'Jousting Lanes'
		},

		{
			{0,0,4,4,0,0},
			{1,1,1,1,1,1},
			{1,1,1,1,1,1},
			{3,1,0,0,1,5},
			{3,1,0,0,1,5},
			{1,1,1,1,1,1},
			{1,1,1,1,1,1},
			{0,0,2,2,0,0},
			name = 'Royal Court'
		}
	}
	file:open('w')
	file:write(TSerial.pack(boards))
	file:close()
-- else
	-- local contents = lfs.read('boards.dat')
	-- boards = TSerial.unpack(contents)
-- end

Board = class('Board')

function Board:initialize(ind)
	self.index = ind or 1
	self.map = table.deepcopy(boards[self.index])
	self.troops = table.deepcopy(self.map)
	self.fading = {}
	self.name = boards[self.index].name
	self.x,self.y = sw/2,sh/2
	self.gridWidth = 128		--how big to draw each square on the board canvas
	self.screenRatio = 0.8		--what proportion of the screen should the board take up
	self.width = self.gridWidth*#self.map[1]
	self.height = self.gridWidth*#self.map
	self.scale = math.min(sw*self.screenRatio/self.width,sh*self.screenRatio/self.height)
	self.image = self:makeImage()
	
	
	self.resizeID = beholder.observe('resize',function(w,h)
		self.x,self.y = w/2,h/2
		self.scale = math.min(w*self.screenRatio/self.width,h*self.screenRatio/self.height)
		for r,_ in ipairs(self.troops) do
			for c,troop in ipairs(self.troops[r]) do
				if type(troop)=='table' then self:placeTroop(troop,troop.row,troop.col) end
			end
		end
		if game.player.hand then game.player.hand.scale = ((self.gridWidth*self.scale)/game.player.hand.size)*1.1 end
		self.tbl = nil
	end)
end

function Board:getOpenStartingTiles()
	local tbl = {}
	for r,_ in ipairs(self.troops) do
		for c,tile in ipairs(self.troops[r]) do
			if tile==2 or tile==3 or tile==4 or tile==5 then
				local good = true
				if self.troops[r-1] then if self.troops[r-1][c] then if type(self.troops[r-1][c])=='table' then good = false end end end
				if self.troops[r+1] then if self.troops[r+1][c] then if type(self.troops[r+1][c])=='table' then good = false end end end
				if self.troops[r][c+1] then if type(self.troops[r][c+1])=='table' then good = false end end
				if self.troops[r][c-1] then if type(self.troops[r][c-1])=='table' then good = false end end
				for i,t in ipairs(tbl) do
					if table.equal(t,{r,c}) then good = false end
				end
				if good then
					tbl[#tbl+1] = {r,c}
				end
			end
		end
	end
	return tbl
end

function Board:draw()
	lg.setColor(white)
	lg.draw(self.image, self.x, self.y, 0, self.scale, self.scale,self.width/2,self.height/2)
	for i,troop in ipairs(self.fading) do troop:draw() end
	for r,_ in ipairs(self.troops) do
		for c,spot in ipairs(self.troops[r]) do
			if tostring(spot):find('Troop') then
				spot:draw()
			-- else
				-- lg.regPrint(tostring(spot),self:getXY(r,c))
			end
		end
	end
	--debug board
	
end

function Board:getXY(row,col)
	assert(type(row)=='number' and type(col)=='number', 'Row and column values must be numbers')
	--return center x,y coords for a tile on the board
	if not row or not col then return nil end
	local rows,cols = #self.map,#self.map[1]
	local gw = self.gridWidth*self.scale
	local x,y
	x,y = self.x-gw*cols/2, self.y-gw*rows/2
	x,y = x+gw*(col-1/2), y+gw*(row-1/2)
	return x,y
end

function Board:getRowCol(xv,yv)
	assert(type(xv)=='number' and type(yv)=='number', 'x and y values must be numbers')
	local xv,yv = game.cam.lens:toWorld(xv,yv)
	local rows,cols = #self.map,#self.map[1]
	local gw = self.scale*self.gridWidth --scaled grid width
	for i,r in ipairs(self.map) do
		for j,c in ipairs(self.map[i]) do
		local x,y
		x,y = self.x-gw*cols/2, self.y-gw*rows/2
		x,y = x+gw*(j-1), y+gw*(i-1)
		if coll.pointBox(xv,yv,{x,y,gw,gw}) then if c~=0 then return i,j end end
		end
	end
	return nil
end

function Board:placeTroop(troop,rowv,colv)
	assert(tostring(troop):find('Troop'),'Not a valid troop.' .. ' ' .. tostring(troop))
	assert(type(rowv)=='number' and type(colv)=='number', 'Not valid column and/or row value(s)')
	local gw = self.scale*self.gridWidth						--scaled grid width
	troop.x,troop.y = self:getXY(rowv,colv)
	troop.x = troop.x+1
	troop.row,troop.col,troop.scale = rowv,colv,(gw-8)/troop.size		--the -8 is so the tile is a bit smaller than the spot it's in
	self.troops[rowv][colv] = troop
end

function Board:makeImage()
	local board = self.map
	local sz = self.gridWidth
	local canv = lg.newCanvas(#board[1]*sz+2,#board*sz+2)
	lg.setCanvas(canv)
		lg.setColor(20,15,15)
		lg.rectangle('fill',0,0,#board[1]*sz+2,#board*sz+2)
		lg.setLineWidth(4)
		lg.setColor(white)
		for i,r in ipairs(board) do
			for j,c in ipairs(board[i]) do
				if c~=0 then
					lg.rectangle('line',(j-1)*sz+1,(i-1)*sz+1,sz,sz)
				else
					lg.setColor(black)
					lg.rectangle('fill',(j-1)*sz+2,(i-1)*sz+2,sz,sz)
					lg.setColor(white)
				end
			end
		end
	lg.setCanvas()
	return canv
end

function Board:findDuke(colorv)
	local r,c
	for i,_ in ipairs(self.troops) do
		for j,troop in ipairs(self.troops[i]) do
			if type(troop)=='table' then
				if troop.duke and troop.color==colorv then
					r,c = i,j
					break
				end
			end
		end
	end
	if not r or not c then return false else return true, r, c end
end

function Board:captureTroop(r,c)
	assert(type(r)=='number' and type(c)=='number', 'Row and column values must be numbers')
	local spot = self.troops[r][c]
	if tostring(spot):find('Troop') then
		table.insert(game.graveyards[game.turn],spot)
		if spot.duke then		--killed a duke
			game.referee:killPlayer(spot.color)
		end
		self.troops[r][c] = 1		--doesn't matter if we replace with 1 or 2 at this point..
	end
end

function Board:destroy()
	beholder.stopObserving(self.resizeID)
	self = nil
end

function Board:setTroopScale(troop)
	local gw = self.scale*self.gridWidth
	troop.scale = (gw-8)/troop.size
end


