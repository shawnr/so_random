-----------------------------------------------------------------------------------------
--
-- title.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

--------------------------------------------

-- forward declaration
local background, title_back, pageText, sr_mark

-- Touch listener function for background object
local function onBackgroundTouch( self, event )
	if event.phase == "ended" or event.phase == "cancelled" then
		-- go to page1.lua scene
		storyboard.gotoScene( "sorandom", "slideLeft", 800 )

		return true	-- indicates successful touch
	end
end

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
--
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
--
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-- display a background image
	background = display.newImageRect( group, "cover.jpg", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	sr_mark = display.newImageRect( group, "sr_mark.png", display.contentWidth*0.25, display.contentHeight*0.25 )
	sr_mark.anchorX = 0.5
	sr_mark.anchorY = 0.5
	sr_mark.x = display.contentWidth*0.25
	sr_mark.y = display.contentHeight*0.75
	-- background for title
	-- title_back = display.newRect( group, (display.contentWidth*0.1), (display.contentHeight*0.1), (display.contentWidth*0.8), 50)
	-- title_back.anchorY = 0
	-- title_back.anchorX = 0
	-- title_back:setFillColor(0.85, 0.65, 0.13)
	-- Add title text
	local title_options = {
        parent = group,
        text = "So Random",
        font = "HoeflerText-Black",
        fontSize = 106,
        x = display.contentWidth * 0.5,
        y = display.contentHeight  * 0.3,
        width = display.contentWidth * 0.8,
        height = 0,
        isVisible = true,
        align = "left",
    }
    pageText = display.newEmbossedText( title_options )
    pageText:setFillColor( 1, 1, 1 )
    pageText.anchorX = 0.5
    pageText.anchorY = 0.5

    local subtitle_options = {
        parent = group,
        text = "and other stories",
        font = "HoeflerText-Black",
        fontSize = 52,
        x = display.contentWidth * 0.5,
        y = pageText.y + (pageText.height * 0.4),
        width = display.contentWidth * 0.8,
        height = 0,
        isVisible = true,
        align = "left",
    }
    subtitle = display.newEmbossedText( subtitle_options )
    subtitle:setFillColor( 1, 1, 1 )
    subtitle.anchorX = 0.5
    subtitle.anchorY = 0

    local helptext_options = {
        parent = group,
        text = "[ Touch to continue. ]",
        font = "HoeflerText-Regular",
        fontSize = 44,
        x = display.contentWidth * 0.5,
        y = display.contentHeight - 50,
        width = display.contentWidth * 0.8,
        height = 0,
        isVisible = true,
        align = "center",
    }
    helptext = display.newEmbossedText( helptext_options )
    helptext:setFillColor( 1, 1, 1 )
    helptext.anchorX = 0.5
    helptext.anchorY = 0.5

	-- all display objects must be inserted into group
	group:insert( background )
	group:insert(sr_mark )
	--group:insert( title_back )
	group:insert( pageText )
	group:insert( subtitle )
	group:insert( helptext )

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	background.touch = onBackgroundTouch
	background:addEventListener( "touch", background )
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view

	-- remove event listener from background
	background:removeEventListener( "touch", background )
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view

	-- INSERT code here (e.g. remove listeners, remove widgets, save state variables, etc.)

end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene
