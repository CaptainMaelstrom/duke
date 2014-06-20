
-- tilebag code
-- first init tilebags from file OR init table and save to file
-- if not lfs.isFile('tilebags.dat') then
	local file = lfs.newFile('tilebags.dat')
	tilebags = {	
		{
		'duke',
		'footman','footman', 'footman',
		'pikeman','pikeman','priest',
		'champion','wizard','seer','marshall',
		'general','bowman','longbowman',
		'knight','dragoon','assassin',
		'ranger','duchess','oracle',
		name = 'Standard'
		}
	}
	file:open('w')
	file:write(TSerial.pack(tilebags))
	file:close()
-- else
	-- local contents = lfs.read('tilebags.dat')
	-- tilebags = TSerial.unpack(contents)
-- end




