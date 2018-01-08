
-- 參考CORONA範例程式，進行更改


-- Hide Status Bar
display.setStatusBar(display.HiddenStatusBar)

-- Physics
local physics = require('physics')
physics.start()
physics.setGravity(0, 0)

-- [Title View]
local bg
local title
local startB
local start1
local titleView

-- [Game View]
local live
local livesTF
local scoreTF
local alertScore
local blocks
local player
local gameView

-- Variables
local moveSpeed = 2
local lives = 5  -- 生命值(3->5)
local score = 0
local blockTimer
local liveTimer

-- Functions
local Main = {}
local addTitleView = {}
local initialListeners = {}
local gameView = {}
local addInitialBlocks = {}
local addPlayer = {}
local movePlayer = {}
local addBlock = {}
local addLive = {}
local gameListeners = {}
local update = {}
local collisionHandler = {}
local showAlert = {}

-- addTitleView   -- 更改封面及人物
function addTitleView()
	bg = display.newImage('images/bg.png')
	title = display.newImage('images/titleBg.png')
	startB = display.newImage('images/1.jpg')
	startB.x = display.contentCenterX
	startB.y = 400
	startB.name = 'startB'
  start1 = display.newImage('images/3.jpg')
	start1.x = display.contentCenterX
	start1.y = 150
  start1.name = 'start1'
	titleView = display.newGroup()
	titleView:insert(title)
	titleView:insert(startB)
  titleView:insert(start1)
	startB:addEventListener('tap', gameView)
end

-- game View
function gameView()
	-- Remove MenuView
	transition.to(titleView, {time = 500, y = -titleView.height, 
	                                     onComplete = 
	                                     function()
	                                       display.remove(titleView) 
	                                       titleView = nil 
	                                       addInitialBlocks(5)
	                                     end})
	-- Score Text -- 更改字體顏色
	scoreTF = display.newText('0', 290, 22, system.nativeFont, 25)
	scoreTF:setTextColor(255, 228, 225)
	-- Lives Text
	livesTF = display.newText('x5', 290, 56, system.nativeFont, 25)
	livesTF:setTextColor(240, 248, 255)
end

-- add Initial Blocks
function addInitialBlocks(n)
	blocks = display.newGroup()
	for i = 1, n do 
		local block = display.newImage('images/block.png')
		block.x = math.floor(math.random() * (display.contentWidth - block.width))
		block.y = (display.contentHeight * 0.5) + 
		           math.floor(math.random() * (display.contentHeight * 0.5))
		physics.addBody(block, {density = 1, bounce = 0})
		block.bodyType = 'static'
		blocks:insert(block)
	end
	addPlayer()
end

-- add Player
function addPlayer()
	player = display.newImage('images/player1.png')
	player.x = (display.contentWidth * 0.5)
	player.y = player.height
	physics.addBody(player, {density = 1, friction = 0, bounce = 0})
	player.isFixedRotation = true
	gameListeners('add')
end

-- Accelerometer
function movePlayer:accelerometer(e)
	-- Accelerometer Movement
		player.x = display.contentCenterX + (display.contentCenterX * (e.xGravity*4)) -- 重力變四倍
	-- Left Border
	if((player.x - player.width * 0.5) < 0) then
		player.x = player.width * 0.5
	-- Right Border	
	elseif((player.x + player.width * 0.5) > display.contentWidth) then
		player.x = display.contentWidth - player.width * 0.5
	end
end

-- add Block
function addBlock()
	local r = math.floor(math.random() * 4)
	if(r ~= 0) then
		local block = display.newImage('images/block.png')
		block.x = math.random() * (display.contentWidth - (block.width * 0.5))
		block.y = display.contentHeight + block.height
		physics.addBody(block, {density = 1, bounce = 0})
		block.bodyType = 'static'
		blocks:insert(block)
	else
		local badBlock = display.newImage('images/badBlock.png')
		badBlock.name = 'bad'
		physics.addBody(badBlock, {density = 1, bounce = 0})
		badBlock.bodyType = 'static'
		badBlock.x = math.random() * (display.contentWidth - (badBlock.width * 0.5))
		badBlock.y = display.contentHeight + badBlock.height
		blocks:insert(badBlock)
	end
end

-- add Live
function addLive()
	live = display.newImage('images/live.png')
	live.name = 'live'
	live.x = blocks[blocks.numChildren - 1].x
	live.y = blocks[blocks.numChildren - 1].y - live.height
	physics.addBody(live, {density = 1, friction = 0, bounce = 0})
end

-- game Listeners
function gameListeners(action)
	if(action == 'add') then
		Runtime:addEventListener('accelerometer', movePlayer)
		Runtime:addEventListener('enterFrame', update)
		blockTimer = timer.performWithDelay(1000, addBlock, 0)
		liveTimer = timer.performWithDelay(8000, addLive, 0)
		player:addEventListener('collision', collisionHandler)
	else
		Runtime:removeEventListener('accelerometer', movePlayer)
		Runtime:removeEventListener('enterFrame', update)
		timer.cancel(blockTimer)
		timer.cancel(liveTimer)
		blockTimer = nil
		liveTimer = nil
		player:removeEventListener('collision', collisionHandler)
	end
end

-- update
function update(e)
  -- Left Borders
	if(player.x <= 0) then 
		player.x = 0
	-- Right Borders
	elseif(player.x >= (display.contentWidth - player.width))then 
		player.x = (display.contentWidth - player.width)
	end
	-- Player Movement
	player.y = player.y + moveSpeed
	for i = 1, blocks.numChildren do
		blocks[i].y = blocks[i].y - moveSpeed
	end
	
	-- Score 
	score = score + 1
	scoreTF.text = score
	-- Lose Lives 
	if(player.y > display.contentHeight or player.y < -5) then
		player.x = blocks[blocks.numChildren - 1].x
		player.y = blocks[blocks.numChildren - 1].y - player.height
		lives = lives - 1
		livesTF.text = 'x' .. lives
	end
	-- Check for Game Over 
	if(lives < 0) then
	  showAlert()
	end
	-- Levels  -- 難度門檻變高(500->600)
	if(score > 600 and score < 602) then
		moveSpeed = 3   -- 移動速度變快
	end
end

-- collisionHandler
function collisionHandler(e)
	-- Grab Lives
	if(e.other.name == 'live') then
		display.remove(e.other)
		e.other = nil
		lives = lives + 1
		livesTF.text = 'x' .. lives
	end
	-- Bad Blocks
	if(e.other.name == 'bad') then
		lives = lives - 1
		livesTF.text = 'x' .. lives
	end
end

-- show Alert
function showAlert()
	gameListeners('rmv')
	local alert = display.newImage('images/alertBg.png', 40, 140)
	
	alertScore = display.newText(scoreTF.text , 140, 240,
	                                 native.systemFontBold, 30)
	livesTF.text = ''
	transition.from(alert, {time = 200, xScale = 0.8})
end

addTitleView()

