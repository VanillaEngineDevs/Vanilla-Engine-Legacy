local stageBack, stageFront, curtains

local gameCanvas, intensity

--[[ 
-- unable to add due to sprite atlas not being implemented :(
WEEKEND1_STATE_ARCING = 2
WEEKEND1_STATE_SHOT = 3
WEEKEND1_STATE_IMPACTED = 4
WEEKEND1_spawnedCans = {}
WEEKEND1_currentState = 1

WEEKEND1_LOSS = 0.5

function WEEKEND1_getNextCanWithState(state)
	for i = 1, #WEEKEND1_spawnedCans do
		local can = WEEKEND1_spawnedCans[i]
		local canState = WEEKEND1_currentState

		if canState == state then
			return can
		end
	end
end ]]

return {
	enter = function(self, from, songNum, songAppend, isErect)
		weeks:enter()

		stages["streets"]:enter()

		song = songNum
		difficulty = songAppend
		erectMode = isErect

		enemyIcon:animate("dad", false)

		if love.system.getOS() ~= "NX" then 
			gameCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())

			shaders["rain"]:send("uScale", 0.0075)
			--[[ shaders["rain"]:send("uIntensity", 0.1) ]]
			intensity = 0
		end

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["streets"]:load()

		if song == 4 then
			inst = love.audio.newSource("songs/blazin/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = nil
			voicesEnemy = nil
			rainShaderStartIntensity = 0.2
			rainShaderEndIntensity = 0.4
		elseif song == 3 then
			inst = love.audio.newSource("songs/2hot/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/2hot/Voices-pico" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/2hot/Voices-darnell" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			rainShaderStartIntensity = 0.2
			rainShaderEndIntensity = 0.4
		elseif song == 2 then
			inst = love.audio.newSource("songs/lit-up/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/lit-up/Voices-pico" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/lit-up/Voices-darnell" .. (erectMode and "-erect" or "") .. ".ogg", "stream")

			rainShaderStartIntensity = 0.1
			rainShaderEndIntensity = 0.2
		else
			inst = love.audio.newSource("songs/darnell/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/darnell/Voices-pico" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/darnell/Voices-darnell" .. (erectMode and "-erect" or "") .. ".ogg", "stream")

			rainShaderStartIntensity = 0
			rainShaderEndIntensity = 0.1
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()
		if song == 3 then
			weeks:generateNotes("data/songs/2hot/2hot-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/2hot/2hot-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/lit-up/lit-up-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/lit-up/lit-up-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/darnell/darnell-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/darnell/darnell-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		end
	end,

	update = function(self, dt)
		if love.system.getOS() ~= "NX" then 
			intensity = math.remapToRange(musicTime/1000, 0, inst:getDuration(), rainShaderStartIntensity, rainShaderEndIntensity)
			shaders["rain"]:send("uTime", love.timer.getTime())
			shaders["rain"]:send("uIntensity", intensity)
		end
		weeks:update(dt)
		stages["streets"]:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		-- The switch is too weak for shaders :(
		if love.system.getOS() ~= "NX" then love.graphics.setCanvas(gameCanvas) end
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stages["streets"]:draw()
		love.graphics.pop()
		if love.system.getOS() ~= "NX" then love.graphics.setCanvas() end

		if love.system.getOS() ~= "NX" then 
			love.graphics.setShader(shaders["rain"])
			love.graphics.draw(gameCanvas, 0, 0, 0, love.graphics.getWidth() / 1280, love.graphics.getHeight() / 720)
			love.graphics.setShader()
		end
		 
		if love.system.getOS() ~= "NX" then 
			love.graphics.push() -- canvas' fuck with the game so we need to do this lol
				love.graphics.scale(love.graphics.getWidth() / 1280, love.graphics.getHeight() / 720)
		end
			weeks:drawUI()
		if love.system.getOS() ~= "NX" then 
			love.graphics.pop()
		end
	end,

	leave = function(self)
		stages["streets"]:leave()

		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()
	end
}