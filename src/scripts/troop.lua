
--troop code
--first, init the troops table from file OR init table and make file
if not lfs.isFile('troops.dat') then
	local file = lfs.newFile('troops.dat')
	troops = {
		blank = {
			front = {
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0}
			},
			back = {
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0}
			},
			dname = '',
			banner = ''
		},
		duke = {
			front = {
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,'sl','start','sr',0},
				{0,0,0,0,0},
				{0,0,0,0,0}
				
			},
			back = {
				{0,0,0,0,0},
				{0,0,'su',0,0},
				{0,0,'nonstart',0,0},
				{0,0,'sd',0,0},
				{0,0,0,0,0}
			},
			dname = 'Duke',
			banner = 'duke',
			duke = true
		},
		footman = {
			front = {
				{0,0,0,0,0},
				{0,0,'m',0,0},
				{0,'m','start','m',0},
				{0,0,'m',0,0},
				{0,0,0,0,0}
			},
			back = {
				{0,0,'m',0,0},
				{0,'m',0,'m',0},
				{0,0,'nonstart',0,0},
				{0,'m',0,'m',0},
				{0,0,0,0,0}
			},
			dname = 'Footman',
			banner = 'footman'
		},
		pikeman = {
			front = {
				{'m',0,0,0,'m'},
				{0,'m',0,'m',0},
				{0,0,'start',0,0},
				{0,0,0,0,0},
				{0,0,0,0,0}
			},
			back = {
				{0,'s',0,'s',0},
				{0,0,'m',0,0},
				{0,0,'nonstart',0,0},
				{0,0,'m',0,0},
				{0,0,'m',0,0}
			},
			dname = 'Pikeman',
			banner = 'pikeman'
		},
		priest = {
			front = {
				{0,0,0,0,0},
				{0,'sul',0,'sur',0},
				{0,0,'start',0,0},
				{0,'sdl',0,'sdr',0},
				{0,0,0,0,0}
			},
			back = {
				{'j',0,0,0,'j'},
				{0,'m',0,'m',0},
				{0,0,'nonstart',0,0},
				{0,'m',0,'m',0},
				{'j',0,0,0,'j'}
			},
			dname = 'Priest',
			banner = 'priest'
		},
		champion = {
			front = {
				{0,0,'j',0,0},
				{0,0,'m',0,0},
				{'j','m','start','m','j'},
				{0,0,'m',0,0},
				{0,0,'j',0,0}
			},
			back = {
				{0,0,'j',0,0},
				{0,0,'s',0,0},
				{'j','s','nonstart','s','j'},
				{0,0,'s',0,0},
				{0,0,'j',0,0}
			},
			dname = 'Champion',
			banner = 'champion'
		},
		bowman = {
			front = {
				{0,0,0,0,0},
				{0,0,'m',0,0},
				{'j','m','start','m','j'},
				{0,0,0,0,0},
				{0,0,'j',0,0}
			},
			back = {
				{0,0,'s',0,0},
				{0,'s','m','s',0},
				{0,0,'nonstart',0,0},
				{0,'m',0,'m',0},
				{0,0,0,0,0}
			},
			dname = 'Bowman',
			banner = 'bowman'
		},
		longbowman = {
			front = {
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,'m',0,0},
				{0,'m','start','m',0},
				{0,0,'m',0,0}
			},
			back = {
				{0,0,'s',0,0},
				{0,0,'s',0,0},
				{0,0,0,0,0},
				{0,0,'nonstart',0,0},
				{0,'m',0,'m',0}
			},
			dname = 'Longbowman',
			banner = 'longbowman'
		},
		wizard = {
			front = {
				{0,0,0,0,0},
				{0,'m','m','m',0},
				{0,'m','start','m',0},
				{0,'m','m','m',0},
				{0,0,0,0,0}
			},
			back = {
				{'j',0,'j',0,'j'},
				{0,0,0,0,0},
				{'j',0,'nonstart',0,'j'},
				{0,0,0,0,0},
				{'j',0,'j',0,'j'}
			},
			dname = 'Wizard',
			banner = 'wizard'
		},
		seer = {
			front = {
				{0,0,'j',0,0},
				{0,'m',0,'m',0},
				{'j',0,'start',0,'j'},
				{0,'m',0,'m',0},
				{0,0,'j',0,0}
			},
			back = {
				{'j',0,0,0,'j'},
				{0,0,'m',0,0},
				{0,'m','nonstart','m',0},
				{0,0,'m',0,0},
				{'j',0,0,0,'j'}
			},
			dname = 'Seer',
			banner = 'seer'
		},
		dragoon = {
			front = {
				{'s',0,'s',0,'s'},
				{0,0,0,0,0},
				{0,'m','start','m',0},
				{0,0,0,0,0},
				{0,0,0,0,0}
			},
			back = {
				{0,'j','m','j',0},
				{0,0,'m',0,0},
				{0,0,'nonstart',0,0},
				{0,'sdl',0,'sdr',0},
				{0,0,0,0,0}
			},
			dname = 'Dragoon',
			banner = 'dragoon'
		},
		general = {
			front = {
				{0,'j',0,'j',0},
				{0,0,'m',0,0},
				{'m',0,'start',0,'m'},
				{0,0,'m',0,0},
				{0,0,0,0,0}
			},
			back = {
				{0,'j',0,'j',0},
				{0,0,'m',0,0},
				{'m',{'m','c'},'nonstart',{'m','c'},'m'},
				{0,'c','c','c',0},
				{0,0,0,0,0}
			},
			dname = 'General',
			banner = 'general'
		},
		duchess = {
			front = {
				{0,0,0,0,0},
				{0,0,0,0,0},
				{'c',{'m','c'},'start',{'m','c'},'c'},
				{0,0,0,0,0},
				{0,0,'c',0,0}
			},
			back = {
				{0,0,0,0,0},
				{0,0,0,0,0},
				{'c',{'m','c'},'nonstart',{'m','c'},'c'},
				{0,0,0,0,0},
				{0,0,'c',0,0}
			},
			dname = 'Duchess',
			banner = 'duchess',
			skill = {top = 'summon', bottom = 'summon'}
		},
		oracle = {
			front = {
				{0,0,0,0,0},
				{0,'m',0,'m',0},
				{0,0,'start',0,0},
				{0,'m',0,'m',0},
				{0,0,0,0,0}
			},
			back = {
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,'nonstart',0,0},
				{0,0,0,0,0},
				{0,0,0,0,0}
			},
			dname = 'Oracle',
			banner = 'oracle',
			skill = {bottom = 'divination'}
		},
		knight = {
			front = {
				{0,'j',0,'j',0},
				{0,0,0,0,0},
				{0,'m','start','m',0},
				{0,0,'m',0,0},
				{0,0,'m',0,0}
			},
			back = {
				{0,0,0,0,0},
				{0,0,'su',0,0},
				{0,0,'nonstart',0,0},
				{0,'m',0,'m',0},
				{'m',0,0,0,'m'}
			},
			dname = 'Knight',
			banner = 'knight'
		},
		ranger = {
			front = {
				{0,'j',0,'j',0},
				{'j',0,'su',0,'j'},
				{0,0,'start',0,0},
				{0,0,'sd',0,0},
				{0,0,0,0,0}
			},
			back = {
				{0,0,0,0,0},
				{0,'sul',0,'sur',0},
				{0,0,'nonstart',0,0},
				{0,0,0,0,0},
				{0,'j',0,'j',0}
			},
			dname = 'Ranger',
			banner = 'ranger'
		},
		assassin = {
			front = {
				{0,0,'zu',0,0},
				{0,0,0,0,0},
				{0,0,'start',0,0},
				{0,0,0,0,0},
				{'zdl',0,0,0,'zdr'}
			},
			back = {
				{'zul',0,0,0,'zur'},
				{0,0,0,0,0},
				{0,0,'nonstart',0,0},
				{0,0,0,0,0},
				{0,0,'zd',0,0}
			},
			dname = 'Assassin',
			banner = 'assassin'
		},
		marshall = {
			front = {
				{'j',0,0,0,'j'},
				{0,0,0,0,0},
				{0,'sl','start','sr',0},
				{0,0,0,0,0},
				{0,0,'j',0,0}
			},
			back = {
				{0,0,0,0,0},
				{0,{'m','c'},{'m','c'},{'m','c'},0},
				{'m','m','nonstart','m','m'},
				{0,'m',0,'m',0},
				{0,0,0,0,0}
			},
			dname = 'Marshall',
			banner = 'marshall'
		}
	}
	file:open('w')
	file:write(TSerial.pack(troops))
	file:close()
else
	local contents = lfs.read('troops.dat')
	troops = TSerial.unpack(contents)
end

Troop = class('Troop')

function Troop:initialize(name,clr,rotation)
	self.name = name
	self.size = 384
	self.scale = 1
	self.rotation = rotation or 0
	self.alpha = 255
	self.facing = 'top'
	self.color = game.player.color
	if clr then self.color = clr end
	
	self.tweens = {}
	--init data from troop database
	local db = troops[name]
	if not db then error(name) end
	self.front, self.back, self.banner, self.displayName,self.skill = db.front,db.back,db.banner,db.dname,table.deepcopy(db.skill)
	if db.duke then self.duke = true end
	self.top, self.bottom = self:makeImages(self.size)
end

function Troop:draw()
	local r,g,b = unpack(color[self.color])
	
	local r,g,b
	if self:isHoveredOver(lmo.getPosition()) and self.color==game.players[game.myIndex].color then r,g,b = unpack(color.lightness(color[self.color],35)) else r,g,b = unpack(color[self.color]) end
	
	lg.setColor(r,g,b,self.alpha)
	lg.draw(self[self.facing], self.x, self.y, self.rotation, self.scale, self.scale,self.size/2,self.size/2)
end

function Troop:makeImages(sizev)
	local top = lg.newCanvas(sizev,sizev)
	local bottom = lg.newCanvas(sizev,sizev)
	local gridWidth = (1/8)*sizev
	
	local function drawSymbols(side)
		local offset = 0.083*sizev
		local symbSz = sizev/512
		for i,r in ipairs(troops[self.name][side]) do
			for j,c in ipairs(r) do
				if type(c)=='string' then
					local x = offset+gridWidth*(j-1)
					local y = offset+gridWidth*(i-1)
					lg.draw(img.symbols[c],	x,y,0,symbSz,symbSz,32,32)
				elseif type(c)=='table' then
					for k,move in ipairs(c) do
						local x = offset+gridWidth*(j-1)
						local y = offset+gridWidth*(i-1)
						lg.draw(img.symbols[move],	x,y,0,symbSz,symbSz,32,32)
					end
				end
			end
		end
	end
	
	local function drawGrid(lWidth,sz)
		lg.setLineWidth(lWidth)
		local x1,y1,x2,y2 = 0.02*sz,0.02*sz,0.98*sz,0.02*sz
		--draw horiz lines
		lg.line(x1,y1,x2,y2)
		y1,y2 = (1/8)*sz+y1,(1/8)*sz+y2
		x2 = 0.64*sz
		lg.line(x1,y1,x2,y2)
		y1,y2 = (1/8)*sz+y1,(1/8)*sz+y2
		lg.line(x1,y1,x2,y2)
		y1,y2 = (1/8)*sz+y1,(1/8)*sz+y2
		lg.line(x1,y1,x2,y2)
		y1,y2 = (1/8)*sz+y1,(1/8)*sz+y2
		lg.line(x1,y1,x2,y2)
		y1,y2 = (1/8)*sz+y1,(1/8)*sz+y2
		lg.line(x1,y1,x2,y2)
		y1,x2,y2 = 0.98*sz,0.98*sz,0.98*sz
		lg.line(x1,y1,x2,y2)
		--draw vertical lines
		y1,x2 = 0.02*sz,0.02*sz
		lg.line(x1,y1,x2,y2)
		x1,x2,y2 = (1/8)*sz+x1, (1/8)*sz+x2, 0.64*sz
		lg.line(x1,y1,x2,y2)
		x1,x2 = (1/8)*sz+x1, (1/8)*sz+x2
		lg.line(x1,y1,x2,y2)
		x1,x2 = (1/8)*sz+x1, (1/8)*sz+x2
		lg.line(x1,y1,x2,y2)
		x1,x2 = (1/8)*sz+x1, (1/8)*sz+x2
		lg.line(x1,y1,x2,y2)
		x1,x2,y2 = (1/8)*sz+x1, (1/8)*sz+x2, 0.98*sz
		lg.line(x1,y1,x2,y2)
		x1,x2 = 0.98*sz,0.98*sz
		lg.line(x1,y1,x2,y2)
	end
	
	local function both(sizev)
		--draw bg color and texture
		lg.setColor(white)
		lg.rectangle('fill',0,0,sizev,sizev)
		--draw grid
		lg.setColor(black)
		drawGrid(6,sizev)
		--draw banner
		lg.draw(img.banners[self.banner],(0.65)*sizev,(1/45)*sizev,0,(0.314*sizev)/89,(0.96*sizev)/297)
		--draw name
		lg.setFont(lg.newFont(sizev*0.09))
		lg.printf(self.displayName,(1/45)*sizev,gridWidth*6,gridWidth*5,'center')
	end
	
	lg.setCanvas(top)
		both(sizev)
		drawSymbols('front')
	lg.setCanvas(bottom)
		both(sizev)
		drawSymbols('back')
	lg.setCanvas()
	
	return top,bottom
end

function Troop:getCommandSpots()
	local function checkForC(tbl,r,c)
		local s = self:symbolAt(r,c)
		if type(s)=='table' then
			if table.find(s,'c',2) then table.insert(tbl,{r,c}) end
		else
			s = tostring(s)
			if s=='c' then table.insert(tbl,{r,c}) end
		end
	end
	
	local tbl = {}
	for r,_ in ipairs(game.board.troops) do
		for c,spot in ipairs(game.board.troops[r]) do
			if tostring(spot):find('Troop') then
				if spot.color==self.color then else checkForC(tbl,r,c) end
			else
				checkForC(tbl,r,c)
			end
		end
	end
	return tbl
end

function Troop:mapToSymb(r,c) --translates map coordinates to symbol set coordinates, (returns r,c)
	assert(type(r)=='number' and type(c)=='number', 'r and c values must be numbers')
	
	local function handleRotation(dr,dc)
		local rot = game.cam.targetRotation
		if rot then
			if rot==math.pi/2 then
				return -dc,dr
			elseif rot==math.pi then
				return -dr,-dc
			elseif rot==-math.pi/2 then
				return dc,-dr
			end
		end
		return dr,dc
	end
	
	local symbols,symbRef		--symbol bank for troop and 'start' or 'nonstart' symbol position
	if self.facing=='top' then symbols = table.deepcopy(self.front) symbRef = {table.find(symbols,'start',2)} else symbols = table.deepcopy(self.back) symbRef = {table.find(symbols,'nonstart',2)} end
	local dr,dc = handleRotation(r - self.row, c - self.col)
	local sr,sc = symbRef[1] + dr,symbRef[2] + dc
	if sr < 1 or sr > 5 or sc < 1 or sc > 5 then return nil else return sr,sc end
end

function Troop:symbolAt(r,c)	--given board coords, return symbol for corresponding spot
	assert(type(r)=='number' and type(c)=='number', 'r and c values must be numbers')
	local sr,sc = self:mapToSymb(r,c)
	if not sr or not sc then return nil end
	if self.facing=='top' then
		return self.front[sr][sc]
	else
		return self.back[sr][sc]
	end
end

function Troop:flip()
	if self.facing=='top' then self.facing='bottom' else self.facing = 'top' end
end

function Troop:fade()
	game.board.troops[self.row][self.col] = 1
	table.insert(game.board.fading,self)
	self.tweens.alpha = tween(4,self,{alpha = 0})
end

function Troop:isHoveredOver(mx,my)
	local mx,my = game.cam.lens:toWorld(mx,my)
	local gw = self.size*self.scale
	return coll.pointBox(mx,my,{self.x - gw/2, self.y - gw/2 , gw, gw})
end

function Troop:getAdjacentSpots(cullFriendlies,cullEnemies)
	if not self.row and not self.col then return {} end
	local tbl,r,c,board = {},self.row,self.col,game.board.troops
	local function func(dr,dc)
		if board[r+dr] then
			if board[r+dr][c+dc] then
				local tile = board[r+dr][c+dc]
				if tostring(tile):find('Troop') then
					if tile.color==self.color then
						if not cullFriendlies then tbl[#tbl+1] = {r+dr,c+dc} end
					else
						if not cullEnemies then tbl[#tbl+1] = {r+dr,c+dc} end
					end
				else
					if tile~=0 then tbl[#tbl+1] = {r+dr,c+dc} end
				end
			end
		end
	end
	func(1,0)
	func(-1,0)
	func(0,-1)
	func(0,1)
	return tbl
end

function Troop:setScale(perc)	--percentage of the width of the screen troop should fill	(0.25 = 25%)
	self.scale = (perc*sw)/self.size
end

