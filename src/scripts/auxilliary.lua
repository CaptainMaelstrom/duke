--aliases (helper variables)
----------------------------

lg = love.graphics
la = love.audio
lfs = love.filesystem
li = love.image
lm = love.math
lmo = love.mouse
lf = love.font
lk = love.keyboard
lt = love.timer
lw = love.window
lj = love.joystick
sw = love.window.getWidth()
sh = love.window.getHeight()

lk.setKeyRepeat(true)
math.randomseed(os.time())
math.random()
math.random()
math.random()
lm.setRandomSeed(os.time())
lm.random()
lm.random()
lm.random()

white = {255,255,255}
black = {0,0,0,255}


--helper functions
------------------
--resource management/loading function

function loadResources(a, b)
    local base_folder, resource_table
    if type(a) == 'string' then
        base_folder = a
    elseif type(b) == 'string' then
        base_folder = b
    else
        base_folder = ''
    end
    if type(a) == 'table' then
        resource_table = a
    elseif type(b) == 'table' then
        resource_table = b
    else
        resource_table = _G
    end
    local function load_directory(folder, place)
        for _, item in pairs(love.filesystem.getDirectoryItems(folder)) do
            local path = folder..'/'..item
            if love.filesystem.isFile(path) then
                local name, ext = item:match('(.+)%.(.+)$')
                if ext == 'png' or ext == 'bmp' or ext == 'jpg' or ext == 'jpeg' or ext == 'gif' or ext == 'tga' then
                    place[name] = love.graphics.newImage(path)
                elseif ext == 'ogg' or ext == 'mp3' or ext == 'wav' or ext == 'xm' or ext == 'it' or ext == 's3m' then
                    place[name] = love.audio.newSource(path)
                end
            else
                place[item] = {}
                load_directory(path, place[item])
            end
        end
    end
    load_directory(base_folder, resource_table)
end

coll = {}
color = {}
sort = {}
img = {}
fnt = {}
snd = {}
loadResources(img,"images")
loadResources(fnt,"fonts")
loadResources(snd,"sounds")

fnt.default = lg.getFont()
fnt.d48 = lg.newFont(48)

--math

function love.math.order(x)		--get orders of magnitude
	if x == 0 then return x end
	if x < 0 then x = x*-1 end
	for i = 1, 1000 do
		if x < 10^i then return i end
	end
	return 1001
end

function love.math.sign(x)
	if x==0 then return 0 end
	if x<0 then return -1 end
	return 1
end

function love.math.round(x)
	if x%1 >= .5 then return math.ceil(x) else return math.floor(x) end
end

function love.math.clamp(low,val,high)
	if val >= low and val <= high then return val end
	if val < low then return low end
	if val > high then return high end
end

function love.math.modclamp(low,val,high)
	if val > high then
		return low
	elseif val < low then
		return high
	else
		return val
	end
end

--graphics

function love.graphics.radiusRectangle( mode, x, y, w, h, rx, ry )
	rx = rx or 1
	ry = ry or rx
	local pts = {}
	local precision = math.floor( 0.2 * ( rx + ry ) )
	local  hP =  math.pi / 2
	rx = rx >= w / 2 and w / 2 - 1 or rx
	ry = ry >= h / 2 and h / 2 - 1 or ry
	local sin, cos = math.sin, math.cos
	for i = 0, precision do   -- upper right
		local a = ( i / precision - 1 ) * hP
		pts[#pts+1] = x + w - rx * ( 1 -  cos(a) )
		pts[#pts+1] = y + ry * ( 1 +  sin(a) )
	end
	for i = 2 * precision + 2 , 1, -2 do   -- lower right
		pts[#pts+1] = pts[i-1]
		pts[#pts+1] = 2 * y - pts[i] + h
	end
	for i = 1, 2 * precision + 2, 2 do   -- lower left
		pts[#pts+1] = -pts[i] + 2 * x + w
		pts[#pts+1] = 2 * y - pts[i+1] + h
	end
	for i = 2 * precision+2 , 1, -2 do   -- upper left
		pts[#pts+1]   = -pts[i-1] + 2 * x + w
		pts[#pts+1]   = pts[i]
	end
	love.graphics.polygon( mode, pts )
end

function love.graphics.regPrint(text,x,y)
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(fnt.default)
	love.graphics.print(text,x,y)
end

--collision

function coll.pointCircle(x,y,circle)
	local cx,cy,r = circle[1],circle[2],circle[3]
	return ((x-cx)^2+(y-cy)^2)^0.5 < r
end

function coll.segmenttIntersect(px,py,rx,ry,qx,qy,sx,sy)
	local d = (rx*sy - ry*sx)
	if d == 0 then return false end	--collinear or disjoint
	local t = ((qx-px)*sy - (qy-py)*sx) / d
	local u = ((qx-px)*ry - (qy-py)*rx) / d
	if t < 0 or t > 1 or u < 0 or u > 1 then return false end
	return qx+u*sx,qy+u*sy
end

function coll.boxBox(a,b)
	return a[1] < b[1]+b[3]
		and b[1] < a[1]+a[3]
		and a[2] < b[2]+b[4]
		and b[2] < a[2]+a[4]
end

function coll.pointBox(x,y,box)
	assert(type(x)=='number' and type(y)=='number' and type(box)=='table', "Bad inputs")
	if x > box[1] and x < box[1]+box[3] and y > box[2] and y < box[2] + box[4] then
		return true
	end
	return false
end

--tables

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.find(tbl,val,depth)
	assert(type(tbl)=='table' ,"First argument must be a table")
	assert(val ,"Second argument (value to find) must not be nil.")
	local depth = depth or 1		--how deep to go recursively
	local j
	if type(val)~='table' then
		for i,v in pairs(tbl) do
			if type(v)~='table' or depth==1 then
				if val==v then return i end
			else
				j = {table.find(tbl[i],val,depth-1)}
				if j then
					if next(j) then return i,unpack(j) end
				end
			end
		end
	else
		for k,v in pairs(tbl) do
			if type(v)=='table' then
				if table.equal(v,val) then
					return k
				else
					if depth > 1 then
						j = {table.find(v,val,depth-1)}
					end
					if j then
						if next(j) then return k,unpack(j) end
					end
				end
			end
		end
	end
	return nil
end

function table.equal(a,b)
	assert(type(a)=='table' and type(b)=='table', 'Input values must be tables')
	for k,v in pairs(a) do
		if b[k] ~= v then return false end
	end
	return true
end

function table.save(tbl,filename)
  local charS,charE = "   ","\n"
  local file,err = io.open( filename, "wb" )
  if err then return err end

  -- initiate variables for save procedure
  local tables,lookup = { tbl },{ [tbl] = 1 }
  file:write( "return {"..charE )

  for idx,t in ipairs( tables ) do
	 file:write( "-- Table: {"..idx.."}"..charE )
	 file:write( "{"..charE )
	 local thandled = {}

	 for i,v in ipairs( t ) do
		thandled[i] = true
		local stype = type( v )
		-- only handle value
		if stype == "table" then
		   if not lookup[v] then
			  table.insert( tables, v )
			  lookup[v] = #tables
		   end
		   file:write( charS.."{"..lookup[v].."},"..charE )
		elseif stype == "string" then
		   file:write(  charS..exportstring( v )..","..charE )
		elseif stype == "number" then
		   file:write(  charS..tostring( v )..","..charE )
		end
	 end

	 for i,v in pairs( t ) do
		-- escape handled values
		if (not thandled[i]) then
		
		   local str = ""
		   local stype = type( i )
		   -- handle index
		   if stype == "table" then
			  if not lookup[i] then
				 table.insert( tables,i )
				 lookup[i] = #tables
			  end
			  str = charS.."[{"..lookup[i].."}]="
		   elseif stype == "string" then
			  str = charS.."["..exportstring( i ).."]="
		   elseif stype == "number" then
			  str = charS.."["..tostring( i ).."]="
		   end
		
		   if str ~= "" then
			  stype = type( v )
			  -- handle value
			  if stype == "table" then
				 if not lookup[v] then
					table.insert( tables,v )
					lookup[v] = #tables
				 end
				 file:write( str.."{"..lookup[v].."},"..charE )
			  elseif stype == "string" then
				 file:write( str..exportstring( v )..","..charE )
			  elseif stype == "number" then
				 file:write( str..tostring( v )..","..charE )
			  end
		   end
		end
	 end
	 file:write( "},"..charE )
  end
  file:write( "}" )
  file:close()
end

function table.load(sfile)
  local ftables,err = loadfile( sfile )
  if err then return _,err end
  local tables = ftables()
  for idx = 1,#tables do
	 local tolinki = {}
	 for i,v in pairs( tables[idx] ) do
		if type( v ) == "table" then
		   tables[idx][i] = tables[v[1]]
		end
		if type( i ) == "table" and tables[i[1]] then
		   table.insert( tolinki,{ i,tables[i[1]] } )
		end
	 end
	 -- link indices
	 for _,v in ipairs( tolinki ) do
		tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
	 end
  end
  return tables[1]
end

function table.shuffle(tbl) 	--returns shuffled copy of table tbl
	local rt = {}
	local k = 0
	while #tbl > 0 do
		k = math.random(1,#tbl)
		table.insert(rt,tbl[k])
		table.remove(tbl,k)
	end
	return rt
end

function prev(t,key)
	local pk
	for k,v in pairs(t) do
		if key == k then
			return pk
		end
		pk = k
	end
	return pk
end

function table.hole(tbl)
	local i = 0
	while true do
		i = i+1
		if not tbl[i] then return i end
	end
end

--string

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

--sorting

function sort.IP(a,b)		--sorts low to high, so 192.168.1.1 < and comes before 192.168.1.2
	if a.address then
		a,b = a.address,b.address
	else
		a,b = tostring(a),tostring(b)
	end
	
	local p1 = a:find('%.')
	local p2 = a:find('%.',p1+1)
	local p3 = a:find('%.',p2+1)
	local colon = a:find('%:')
	local a1,a2,a3,a4,aport = a:sub(1,p1-1),a:sub(p1+1,p2-1),a:sub(p2+1,p3-1),a:sub(p3+1,colon-1),a:sub(colon+1)

	p1 = b:find('%.')
	p2 = b:find('%.',p1+1)
	p3 = b:find('%.',p2+1)
	colon = b:find('%:')
	local b1,b2,b3,b4,bport = b:sub(1,p1-1),b:sub(p1+1,p2-1),b:sub(p2+1,p3-1),b:sub(p3+1,colon-1),b:sub(colon+1)
	
	if tonumber(a1) < tonumber(b1) then
		return true
	elseif tonumber(a1) > tonumber(b1) then
		return false
	elseif tonumber(a2) < tonumber(b2) then
		return true
	elseif tonumber(a2) > tonumber(b2) then
		return false
	elseif tonumber(a3) < tonumber(b3) then
		return true
	elseif tonumber(a3) > tonumber(b3) then
		return false
	elseif tonumber(a4) < tonumber(b4) then
		return true
	elseif tonumber(a4) > tonumber(b4) then
		return false
	elseif tonumber(aport) < tonumber(bport) then
		return true
	elseif tonumber(aport) > tonumber(bport) then
		return false
	end
	return true	--IP's the same
end

function getPaths(row1,col1,row2,col2)		--assumes jump or move as icon (return intermediate tiles)
	assert(type(row1)=='number' and type(col1)=='number' and type(row2)=='number' and type(col2)=='number',"Input values must be numbers")
	local dx,dy = col2-col1, row2-row1
	
	-- no intermediate steps
	if dx*lm.sign(dx)<=1 and dy*lm.sign(dy)<=1 then
		return nil
	end
	
	-- only one path, one straight line
	local path1 = {}
	if dx==0 then
		for y = lm.sign(dy) ,dy-lm.sign(dy),lm.sign(dy) do
			table.insert(path1,{row1+y,col1+0})
		end
		return path1
	end
	if dy==0 then
		for x = lm.sign(dx) ,dx-lm.sign(dx),lm.sign(dx) do
			table.insert(path1,{row1+0,col1+x})
		end
		return path1
	end
	
	-- straight (diagonal)
	if dx*lm.sign(dx)==dy*lm.sign(dy) then 		
		for x = lm.sign(dx) ,dx-lm.sign(dx),lm.sign(dx) do
			local y = x*lm.sign(dx)*lm.sign(dy)
			table.insert(path1,{row1+y,col1+x})
		end
		return path1
	end
	
	-- two paths
	local path2 = {}
	-- y first then x	(path 1)
	for x = lm.sign(dx), dx, lm.sign(dx) do
		table.insert(path1,{row1+0,col1+x})
	end
	for y = lm.sign(dy), dy-lm.sign(dy), lm.sign(dy) do
		table.insert(path1,{row1+y,col1+dx})
	end
	-- x first then y	(path 2)
	for y = lm.sign(dy), dy, lm.sign(dy) do
		table.insert(path2,{row1+y,col1+0})
	end
	for x = lm.sign(dx), dx-lm.sign(dx), lm.sign(dx) do
		table.insert(path2,{row1+dy,col1+x})
	end
	
	return path1,path2
end



