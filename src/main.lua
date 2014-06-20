
--libraries
class = require 'scripts/libs/middleclass'
tween = require 'scripts/libs/tween'
stateful = require 'scripts/libs/stateful'
inspect = require 'scripts/libs/inspect'
gamera = require 'scripts/libs/gamera'
-- anim8 = require 'scripts/libs/anim8'
cron = require 'scripts/libs/cron'
beholder = require 'scripts/libs/beholder'
require 'scripts/libs/TSerial'
require "enet"

--auxiliary code
require 'scripts/auxilliary'

Game = class('Game'):include(stateful)
function Game:initialize()
	function love.textinput(t)
		if t==' ' then return end
		if not self.text then self.text = t else self.text = self.text .. t end
	end
	function love.keypressed(key,isrepeat)
		if (key=='backspace' or key=='delete') and self.text then self.text = self.text:sub(1,-2) end
		if key=='return' or key=='kpenter' and self.text then self:gotoState('Lobby') end
		if key==' ' then
			if self.loopback then self.loopback = nil else self.loopback = true end
		end
	end
	if not lfs.isDirectory('banners') then lfs.createDirectory('banners') end
end

function Game:update(dt)
	
end

function Game:draw()
	lg.regPrint("Type 'host' to start a game or enter an IP address to join one: ",10,10)
	if self.text then lg.regPrint(self.text,410,10) end
	if self.loopback then lg.regPrint('loopback',410,30) end
end

--class files
require 'scripts/lobby'
require 'scripts/play'
require 'scripts/mysocket'
require 'scripts/board'
require 'scripts/player'
require 'scripts/tilebag'
require 'scripts/troop'
require 'scripts/referee'
require 'scripts/cam'
require 'scripts/monocle'
require 'scripts/graveyard'

function love.load()
	if not img.sword then error('really bad') end
	color = {
		{212,210,208},
		{193,155,114},
		{198,197,128},
		{172,214,181},
		{169,190,190},
		{152,151,208},
		{185,149,184},
		{198,121,131},
	}

	function color.lightness (color,value)	--color must be a table value with 3 to 4 numbers 
		local r,g,b,a = color[1],color[2],color[3],color[4] or 255
		return {love.math.clamp(0,r+value,255), love.math.clamp(0,g+value,255), love.math.clamp(0,b+value,255), 255}
	end
	
	flags = {}
	
	game = Game()
end

function love.update(dt)
	game:update(dt)
end

function love.draw()
	game:draw()
	for i,f in ipairs(flags) do
		lg.regPrint(f,20,18*i)
	end
end

function love.resize(w,h)
	sw,sh = w,h
	beholder.trigger('resize',w,h)
end

function love.mousepressed(x,y,button)
	beholder.trigger('mousepressed',x,y,button)
end

function love.mousereleased(x,y,button)
	beholder.trigger('mousereleased',x,y,button)
end

function love.quit()
	if game.socket then game.socket:die() end
end




