-----------------------------------------------------------------------------------------
--
-- be_still.lua
-- a poem
-- A poem that falls apart if you move while reading it.
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local TextCandy = require("lib_text_candy")
local scene = storyboard.newScene()

local be_still = "Just hold it together, kid. Relax, sweetheart. Hush, baby. Calm down. Take a deep breath. Slow down. Stop. Think. Feel."

--------------------------------------------

-- forward declaration
local background, top_background, story_title, home_button, bs_text, deform_text

local deform_counter = 1

local function deform_text(reset)
    if reset == true then
        deform_counter = 0
        bs_text:removeDeform()
    else
        deform_counter = deform_counter + 1
        if deform_counter > 4 then
            deform_counter = 0
        end
        -- interpret shake of device (for testing purposes)
        bs_text:applyDeform({
            type        = TextCandy.DEFORM_SHAKE,
            angleVariation  = 5 * (math.sin(deform_counter)*-1),
            scaleVariation  = 5 * (math.sin(deform_counter)*-1),
            xVariation  = 5 * (math.sin(deform_counter)*-1),
            yVariation  = 5 * (math.sin(deform_counter)*-1)
            })
    end

end
-- Touch listener function for background object
local function onBackgroundTouch( self, event )
    if event.phase == "ended" or event.phase == "cancelled" then
        deform_text()
        return true -- indicates successful touch
    end
end

-----------------------------------------------------------
-- Hardware Events
-----------------------------------------------------------

-- event.xGravity is the acceleration due to gravity in the x-direction
-- event.yGravity
-- event.yGravity is the acceleration due to gravity in the y-direction
-- event.zGravity
-- event.zGravity is the acceleration due to gravity in the z-direction
-- event.xInstant
-- event.xInstant is the instantaneous acceleration in the x-direction
-- event.yInstant
-- event.yInstant is the instantaneous acceleration in the y-direction
-- event.zInstant
-- event.zInstant is the instantaneous acceleration in the z-direction
-- event.isShake
-- event.isShake is true when the user shakes the device

-- Called for Accelerator events
--
-- Update the display with new values
-- If shake detected, make sound and display message for a few seconds
--
local function onAccelerate( event )

    -- Format and display the Accelerator values
    --

    frameUpdate = false     -- update done

    -- Move our object based on the accelerator values
    --
    bs_text:setProperties({
        x = display.contentCenterX + (display.contentCenterX * event.xGravity),
        y = display.contentCenterY + (display.contentCenterY * event.yGravity * -1),
    })
    deform_text()

    -- reset deformation on shake
    if event.isShake == true then
        -- str, location, scrTime, size, color, font
        deform_text(true)
        bs_text:setProperties({
            x = display.contentCenterX,
            y = display.contentCenterY,
        })
    end
end

-- Function called every frame
-- Sets update flag to time our color changes
--
local function onFrame()
    frameUpdate = true
end




-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
--
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
--
-----------------------------------------------------------------------------------------
local goToHome = function()
    storyboard.gotoScene( "title", "slideRight", 800 )
end

local draw_bs_text = function ()
    -- Body Text
    TextCandy.AddVectorFont ("HoeflerText-Regular", "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'*@():,$.!-%+?;#/_\"\n", 28)
    local par_options = {
        fontName    = "HoeflerText-Regular",
        x       = display.contentCenterX,
        y       = display.contentCenterY,
        text        = '.',
        originX     = "CENTER",
        originY     = "CENTER",
        textFlow    = "LEFT",
        fontSize        = 38,
        Color           = {.1,.1,.1,1, .4,.4,.4,1, "down"},
        wrapWidth   = display.contentWidth * 0.8,
        charBaseLine    = "BOTTOM",
        lineSpacing = 25,
        charSpacing = 3,
        showOrigin  = false,
    }
    bs_text = TextCandy.CreateText(par_options)
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	local group = self.view

    -- create background
    background = display.newImageRect( group, "linenback.png", display.contentWidth, display.contentHeight )
    background.anchorX = 0
    background.anchorY = 0
    background.x, background.y = 0, 0

    top_background = display.newImageRect( group, "linenback.png", display.contentWidth, 120 )
    top_background.anchorX = 0
    top_background.anchorY = 0
    top_background.x, top_background.y = 0, 0
    top_background:setFillColor(0)

    local title_options = {
        parent = group,
        text = "Be Still",
        font = "HoeflerText-Black",
        fontSize = 64,
        x = display.contentWidth * 0.5,
        y = (display.contentHeight * 0.1) * 0.5,
        width = display.contentWidth * 0.8,
        height = 0,
        isVisible = true,
        align = "right",
    }
    story_title = display.newEmbossedText( title_options )
    story_title:setFillColor( 1, 1, 1 )
    story_title.anchorX = 0.5
    story_title.anchorY = 0.5
    story_title.x = display.contentWidth * 0.5
    story_title.y = (display.contentHeight * 0.1) * 0.5

    local home_button_opts = {
        parent = group,
        text = "~ Home",
        font = "HoeflerText-Regular",
        fontSize = 42,
        width = display.contentWidth * 0.3,
        height = 0,
        isVisible = true,
        align = "left",
    }
    home_button = display.newEmbossedText( home_button_opts )
    home_button:setFillColor( 1, 1, 1 )
    home_button.anchorX = 0
    home_button.anchorY = 0.5
    home_button.x = 20
    home_button.y = (display.contentHeight * 0.1) * 0.5

    draw_bs_text()
    bs_text:setText(be_still)

	-- all display objects must be inserted into group
	group:insert( background )
	group:insert(top_background )
	--group:insert( title_back )
	group:insert( story_title )
	group:insert( home_button )
    group:insert( bs_text )

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
    bs_text:removeDeform()
	background.touch = onBackgroundTouch
	background:addEventListener( "touch", background )
    home_button.touch = goToHome
    home_button:addEventListener('touch', home_button)
    -- Set up the accelerometer to provide measurements 60 times per second.
    -- Note that this matches the frame rate set in the "config.lua" file.
    system.setAccelerometerInterval( 15 )

    -- Add runtime listeners
    --
    Runtime:addEventListener ("accelerometer", onAccelerate);
    Runtime:addEventListener ("enterFrame", onFrame);
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
    home_button:removeEventListener( "touch", home_button )
	background:removeEventListener( "touch", background )
    Runtime:removeEventListener ("accelerometer", onAccelerate);
    Runtime:removeEventListener ("enterFrame", onFrame);
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
    bs_text:delete()
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
