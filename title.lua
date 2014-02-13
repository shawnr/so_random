-----------------------------------------------------------------------------------------
--
-- title.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

--------------------------------------------

-- forward declaration
local background, title_back, pageText, sr_mark, so_random_button, be_still_button

-- Touch listener function for background object
local function onStorySelect( self, event )
	storyboard.gotoScene( event.target.story_file, "slideLeft", 800 )

	return true	-- indicates successful touch
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

    local so_random_button_opts = {
        parent = group,
        text = "So Random",
        font = "HoeflerText-Black",
        fontSize = 56,
        x = display.contentWidth * 0.5,
        y = display.contentHeight * 0.6,
        width = display.contentWidth * 0.8,
        height = 0,
        isVisible = true,
        align = "right",
    }
    so_random_button = display.newEmbossedText( so_random_button_opts )
    so_random_button:setFillColor( 1, 1, 1 )
    so_random_button.anchorX = 0.5
    so_random_button.anchorY = 0.5
    so_random_button.story_file = 'sorandom'

    local be_still_button_opts = {
        parent = group,
        text = "Be Still",
        font = "HoeflerText-Black",
        fontSize = 56,
        x = display.contentWidth * 0.5,
        y = display.contentHeight * 0.6 + so_random_button.height + 10,
        width = display.contentWidth * 0.8,
        height = 0,
        isVisible = true,
        align = "right",
    }
    be_still_button = display.newEmbossedText( be_still_button_opts )
    be_still_button:setFillColor( 1, 1, 1 )
    be_still_button.anchorX = 0.5
    be_still_button.anchorY = 0.5
    be_still_button.story_file = 'be_still'

    local helptext_options = {
        parent = group,
        text = "[ Select a Story ]",
        font = "HoeflerText-Regular",
        fontSize = 42,
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
    group:insert( so_random_button )
    group:insert( be_still_button )

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	so_random_button.tap = onStorySelect
	so_random_button:addEventListener( "tap", so_random_button )

    be_still_button.tap = onStorySelect
    be_still_button:addEventListener( "tap", be_still_button )
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view

	-- remove event listener from background
	so_random_button:removeEventListener( "tap", so_random_button )

    be_still_button:removeEventListener( "tap", be_still_button )
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
