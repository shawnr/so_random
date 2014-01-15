-----------------------------------------------------------------------------------------
--
-- So Random - 2013 Edition
--
-----------------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local widget = require "widget"
local TextCandy = require("lib_text_candy")
local scene = storyboard.newScene()

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
--
-- NOTE: Code outside of listener functions (below) will only be executed once,
--       unless storyboard.removeScene() is called.
--
-----------------------------------------------------------------------------------------

-- forward declarations and other locals
local background, p1, p2, p3, p4, pageTween, p1Tween, p2Tween, p3Tween, p4Tween
local completeParTween, completeParTween, completeRemoveParTween, completePageClearTween
local pagination_text, currPage_text, nextPage_button, prevPage_button, story_title
local home_button, about_button, generate_tangent_pars, displayTangentText, displayRandomTangentText

-- story data
local paragraphs, tangents, narrators, page_text_container, background_texture

local par_rendered_count = 1
local par_removed_count = 1

local swipeThresh = 100     -- amount of pixels finger must travel to initiate page swipe
local tweenTime = 500
local currPage = 0
local nextPage = 1
local readyToContinue = false

-- function to show next animation
local function showNext(show_prev)
    print('showNext invoked')
    if show_prev == true then
        nextPage = currPage -1
    end
    if readyToContinue then
        print('ready to continue')
        readyToContinue = false
        currPage = nextPage

        grabParagraphText = function(par_index, salt)
            -- select a random narrator
            math.randomseed( (os.time() + salt) )
            local rand_narr_index = math.random(1, #narrators)
            print('rand narr index: '..rand_narr_index)
            local par_text = paragraphs[narrators[rand_narr_index]][par_index]
            par_text.narrator = narrators[rand_narr_index]
            return par_text
        end

        layoutParagraphs = function(par_obj)
            local x_bak, y_bak = page_text_container:getContentPosition()
            p1.y = 30
            p2.y = p1.height + 80
            p3.y = p1.height + p2.height + 120
            p4.y = p1.height + p2.height + p3.height + 170
            currPage_text.y = p1.height + p2.height + p3.height + p4.height + 270
            nextPage_button.y = p1.height + p2.height + p3.height + p4.height + 270
            prevPage_button.y = p1.height + p2.height + p3.height + p4.height + 270
            if currPage < 2 then
                prevPage_button.alpha = 0
            else
                prevPage_button.alpha = 1
            end
            if currPage > 2 then
                nextPage_button.alpha = 0
            else
                nextPage_button.alpha = 1
            end

            local new_scroll_height = p1.height + p2.height + p3.height + p4.height + currPage_text.height + 320
            page_text_container:setScrollHeight(new_scroll_height)
            if par_obj ~= nil then
                print('attempting to scroll to tangent text: '..y_bak..' and container height: '..page_text_container.height)
                if y_bak < page_text_container.height then
                    print('attempting to scroll to off-screen paragraph')
                    page_text_container:scrollToPosition({ y = y_bak, time=tweenTime,})
                end
            end
        end

        completeParTween =  function()
            print('drew 1 par')
            par_rendered_count = par_rendered_count + 1
            if par_rendered_count > 4 then
                print('drew 4 pars; completing page render')
                completePageTween()
                par_rendered_count = 1
            end
        end
        completePageTween = function()
            print('completed page draw')
            nextPage = currPage + 1
            if nextPage > 3 then nextPage = 1; end
            readyToContinue = true
        end

        completePageClearTween = function()
            print('completed page clear')
            replaceParagraphText()
        end

        completeRemoveParTween = function()
            par_removed_count = par_removed_count + 1
            if par_removed_count > 4 then
                print('removed 4 pars; completing page clear')
                completePageClearTween()
                par_rendered_count = 1
            end
        end

        local function replaceParagraphText()
            if currPage == 1 then
                p1Index = 1
                p2Index = 2
                p3Index = 3
                p4Index = 4
            elseif currPage == 2 then
                p1Index = 5
                p2Index = 6
                p3Index = 7
                p4Index = 8
            elseif currPage == 3 then
                p1Index = 9
                p2Index = 10
                p3Index = 11
                p4Index = 12
            end

            currPage_text.text = 'Page '..currPage..' of 3'

            p1.par_obj = grabParagraphText(p1Index, 1)
            p1:setText(p1.par_obj.text)
            p1.keyword = p1.par_obj.keyword
            generate_tangent_pars(p1)
            p2.par_obj = grabParagraphText(p2Index, 2)
            p2:setText(p2.par_obj.text)
            p2.keyword = p2.par_obj.keyword
            generate_tangent_pars(p2)
            p3.par_obj = grabParagraphText(p3Index, 3)
            p3:setText(p3.par_obj.text)
            p3.keyword = p3.par_obj.keyword
            generate_tangent_pars(p3)
            p4.par_obj = grabParagraphText(p4Index, 4)
            p4:setText(p4.par_obj.text)
            p4.keyword = p4.par_obj.keyword
            generate_tangent_pars(p4)

            layoutParagraphs()

            p1Tween = transition.to( p1, { time=tweenTime*0.5, alpha=1.0, onComplete = completeParTween } )
            p2Tween = transition.to( p2, { time=tweenTime*0.5, alpha=1.0, onComplete = completeParTween } )
            p3Tween = transition.to( p3, { time=tweenTime*0.5, alpha=1.0, onComplete = completeParTween } )
            p4Tween = transition.to( p4, { time=tweenTime*0.5, alpha=1.0, onComplete = completeParTween } )
        end

        if not currPage == 1 then
            p1Tween = transition.to( p1, { time=tweenTime*0.5, alpha=0, onComplete = completeRemoveParTween } )
            p2Tween = transition.to( p2, { time=tweenTime*0.5, alpha=0, onComplete = completeRemoveParTween } )
            p3Tween = transition.to( p3, { time=tweenTime*0.5, alpha=0, onComplete = completeRemoveParTween } )
            p4Tween = transition.to( p4, { time=tweenTime*0.5, alpha=0, onComplete = completeRemoveParTween } )
        else
            replaceParagraphText()
        end
        -- handle pagination etc.
        if currPage == 1 then
            -- todo
        elseif currPage == 2 then
            -- todo
        elseif currPage == 3 then
            -- todo
        end
    end
    return true
end

generate_tangent_pars = function(par_obj)
    -- load up the paragraphs with info about the tangents
    par_obj.tangents = tangents[par_obj.keyword]
    par_obj.tan_count = 0
    for k,v in pairs(par_obj.tangents) do
        par_obj.tan_count = par_obj.tan_count + 1
    end
    par_obj.currTangentID = 0
    par_obj.prevTangentID = 0 -- initialize previous to zero
    par_obj.tangentSwipes = 0
end

displayRandomTangentText = function(par_obj)
    print('displaying random swipe text')
    par_obj.alpha = 0
    par_obj.prevTangentID = par_obj.currTangentID
    par_obj.currTangentID = par_obj.currTangentID + 1
    par_obj.tangentSwipes = par_obj.tangentSwipes + 1
    print(par_obj.keyword..'tangent swipes: '..par_obj.tangentSwipes)
    print(par_obj.tan_count)
    local cycle_check = par_obj.tangentSwipes % par_obj.tan_count
    if cycle_check ~= 0 then
        print('displaying tangent')
        local tan_count = 0
        local tan_key = ''
        for k,v in pairs(par_obj.tangents) do
            print('loop')
            tan_count = tan_count + 1
            print(k)
            print(tan_count)
            if tan_count ~= par_obj.currTangentID then
                print('no key found')
            else
                tan_key = k
                print('tan_key found ')
            end
        end
        par_obj:setText(par_obj.tangents[tan_key].text)
    else
        print('cycling to original text')
        par_obj.currTangentID = 0
        par_obj:setText(par_obj.par_obj.text)
    end
    par_obj.x = display.contentWidth * 0.1
    layoutParagraphs(par_obj)
    transition.to(par_obj, { time=tweenTime, alpha=1, })
end

displayTangentText = function(par_obj)
    print('displaying swipe text')
    par_obj.alpha = 0
    par_obj.prevTangentID = par_obj.currTangentID
    par_obj.tangentSwipes = 1
    print(par_obj.keyword..'tangent swipes: '..par_obj.tangentSwipes)
    local cycle_check = par_obj.tangentSwipes % #par_obj.tangents
    if par_obj.text ~= par_obj.par_obj.text then
        print('restoring original paragraph text')
        par_obj.currTangentID = 0
        par_obj:setText(par_obj.par_obj.text)
        par_obj.tangentSwipes = 0
    else
        print('showing tangent')
        par_obj.currentTangentID = 'narr'
        par_obj:setText(par_obj.tangents[par_obj.par_obj.narrator].text)
    end
    par_obj.x = display.contentWidth * 0.1
    layoutParagraphs(par_obj)
    transition.to(par_obj, { time=tweenTime, alpha=1, })
end

local function onPageSwipe( self, event )
    print('touch detected')
    local phase = event.phase

    if phase == "began" then
        display.getCurrentStage():setFocus( self )
        self.isFocus = true
    elseif self.isFocus then
        local xdistance = event.x - event.xStart
        event.target.x = event.target.x + (xdistance * 0.2)
        transition.to(event.target, { time=tweenTime*0.2, alpha=0.5, })

        local ydistance = event.y - event.yStart
        if ydistance > swipeThresh or ydistance < (swipeThresh * -1) then
            transition.to(event.target, { time=tweenTime, alpha=1, x=display.contentWidth * 0.1, })
            page_text_container:takeFocus( event ) -- give event back to scrollview
        end

        if phase == "ended" or phase == "cancelled" then
            if xdistance > swipeThresh or xdistance < (swipeThresh * -1) then
                transition.to(event.target, { time=tweenTime, alpha=1, x=display.contentWidth * 0.1, })
                page_text_container:takeFocus( event ) -- give event back to scrollview
            end

            if xdistance > swipeThresh then
                print('swiped to right')
                -- SWIPED to right; go back to title page scene
                displayRandomTangentText(event.target)
            elseif xdistance < (swipeThresh * -1) then
                print('swiped to left')
                -- Touch and release; initiate next animation
                displayTangentText(event.target)
            else
                print('tapped')
                transition.to(event.target, { time=tweenTime, alpha=1, x=display.contentWidth * 0.1, })
            end
            display.getCurrentStage():setFocus( nil )
            self.isFocus = nil
        end
    end
    return true
end
local function renderPagination()
    print('drawing pagination')
    local currPage_text_opts = {
        parent = group,
        text = 'Page '..currPage..' of 3',
        font = "HoeflerText-Regular",
        fontSize = 34,
        x = display.contentWidth * 0.5,
        y = display.contentHeight + 100,
        width = display.contentWidth * 0.3,
        isVisible = true,
        align = "center",
    }
    currPage_text = display.newEmbossedText( currPage_text_opts )
    currPage_text:setFillColor( 0, 0, 0 )
    currPage_text.anchorX = 0.5
    currPage_text.anchorY = 0
    page_text_container:insert(currPage_text)

    local prev_button_opts = {
        parent = group,
        text = '<< Previous',
        font = "HoeflerText-Black",
        fontSize = 34,
        x = 20,
        y = display.contentHeight + 100,
        width = display.contentWidth * 0.3,
        isVisible = true,
        align = "left",
    }
    prevPage_button = display.newEmbossedText( prev_button_opts )
    prevPage_button:setFillColor( 0, 0, 0 )
    prevPage_button.anchorX = 0
    prevPage_button.anchorY = 0
    page_text_container:insert(prevPage_button)

    local next_button_opts = {
        parent = group,
        text = 'Next >>',
        font = "HoeflerText-Black",
        fontSize = 34,
        x = (display.contentWidth - 20),
        y = display.contentHeight + 100,
        width = display.contentWidth * 0.3,
        isVisible = true,
        align = "right",
    }
    nextPage_button = display.newEmbossedText( next_button_opts )
    nextPage_button:setFillColor( 0, 0, 0 )
    nextPage_button.anchorX = 1
    nextPage_button.anchorY = 0
    page_text_container:insert(nextPage_button)

    if currPage > 1 then
        -- draw previous text
        prevPage_button.alpha = 1
    else
        prevPage_button.alpha = 0
    end
    if currPage < 3 then
        -- draw next text
        nextPage_button.alpha = 1
    else
        nextPage_button.alpha = 0
    end
end

local scrollToTop = function()
    page_text_container:scrollTo( "top", { time=500, } )
    return true
end

local goToHome = function()
    storyboard.gotoScene( "title", "slideRight", 800 )
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
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
        text = "So Random",
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

    -- set up paragraph container
    -- ScrollView listener
    local function scrollListener( event )

        local phase = event.phase
        if ( phase == "began" ) then print( "Scroll view was touched" )
        elseif ( phase == "moved" ) then print( "Scroll view was moved" )
        elseif ( phase == "ended" ) then print( "Scroll view was released" )
        end

        -- In the event a scroll limit is reached...
        if ( event.limitReached ) then
            if ( event.direction == "up" ) then print( "Reached top limit" )
            elseif ( event.direction == "down" ) then print( "Reached bottom limit" )
            elseif ( event.direction == "left" ) then print( "Reached left limit" )
            elseif ( event.direction == "right" ) then print( "Reached right limit" )
            end
        end

        return true
    end
    local page_text_options = {
        horizontalScrollDisabled = true,
        height = display.contentHeight * 0.90,
        width = display.contentWidth,
        top = display.contentHeight * 0.10,
        left = 0,
        scrollHeight = display.contentHeight * 4,
        hideBackground = true,
        --backgroundColor = { 0.8, 0.8, 0.8 },
        listener = scrollListener
    }
    page_text_container = widget.newScrollView( page_text_options )
    page_text_container.anchorChildren = true
    -- TextCandy version
    TextCandy.AddVectorFont ("HoeflerText-Regular", "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'*@():,$.!-%+?;#/_\"\n", 28)
    local par_options = {
        fontName    = "HoeflerText-Regular",
        x       = display.contentWidth*.1,
        y       = 0,
        text        = "figuring things out",
        originX     = "LEFT",
        originY     = "TOP",
        textFlow    = "LEFT",
        fontSize        = 38,
        Color           = {.1,.1,.1,1, .4,.4,.4,1, "down"},
        wrapWidth   = display.contentWidth * 0.8,
        charBaseLine    = "BOTTOM",
        lineSpacing = 25,
        charSpacing = 3,
        showOrigin  = false,
    }
    p1 = TextCandy.CreateText(par_options)
    -- end TextCandy vesion
    -- create paragraphs
    -- local par_options = {
    --     parent = group,
    --     text = "tk",
    --     font = "HoeflerText-Regular",
    --     fontSize =48,
    --     x = display.contentWidth * 0.1,
    --     y = 0,
    --     width = display.contentWidth * 0.8,
    --     height = 0,
    --     isVisible = true,
    --     align = "left",
    -- }
    -- p1 = display.newEmbossedText( par_options )
    -- p1:setFillColor( 0, 0, 0 )
    -- p1.alpha = 0
    -- p1.anchorX = 0
    -- p1.anchorY = 0
    page_text_container:insert(p1)

    p2 = TextCandy.CreateText(par_options)
    -- p2.y = p1.height + 10
    -- p2:setFillColor( 0, 0, 0 )
    -- p2.alpha = 0
    -- p2.anchorX = 0
    -- p2.anchorY = 0
    page_text_container:insert(p2)


    p3 = TextCandy.CreateText(par_options)
    -- p3.y = p1.height + p2.height + 20
    -- p3:setFillColor( 0, 0, 0 )
    -- p3.alpha = 0
    -- p3.anchorX = 0
    -- p3.anchorY = 0
    page_text_container:insert(p3)


    p4 = TextCandy.CreateText(par_options)
    -- p4.y = p1.height + p2.height + p3.height + 30
    -- p4:setFillColor( 0, 0, 0 )
    -- p4.alpha = 0
    -- p4.anchorX = 0
    -- p4.anchorY = 0
    page_text_container:insert(p4)

    -- Add in pagination
    renderPagination()
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

    currPage = 0
    nextPage = 1
    readyToContinue = true
    showNext()

    -- assign touch event to background to monitor page swiping
    background.touch = onPageSwipe
    background:addEventListener( "touch", background )
    p1.touch = onPageSwipe
    p1:addEventListener('touch', p1)
    p2.touch = onPageSwipe
    p2:addEventListener('touch', p2)
    p3.touch = onPageSwipe
    p3:addEventListener('touch', p3)
    p4.touch = onPageSwipe
    p4:addEventListener('touch', p4)
    home_button.touch = goToHome
    home_button:addEventListener('touch', home_button)
    story_title.touch = scrollToTop
    story_title:addEventListener('touch', story_title)
    nextPage_button.touch = showNext
    nextPage_button:addEventListener('touch', nextPage_button)
    local show_prev = function () return showNext(true) end
    prevPage_button.touch = show_prev
    prevPage_button:addEventListener('touch', prevPage_button)

    page_text_container.isVisible = true

end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view

    -- remove touch event listener for background
    background:removeEventListener( "touch", background )
    p1:removeEventListener( "touch", p1 )
    p2:removeEventListener( "touch", p2 )
    p3:removeEventListener( "touch", p3 )
    p4:removeEventListener( "touch", p4 )
    prevPage_button:removeEventListener( "touch", prevPage_button )
    nextPage_button:removeEventListener( "touch", nextPage_button )
    home_button:removeEventListener( "touch", home_button )
    story_title:removeEventListener( "touch", story_title )

    -- cancel page animations (if currently active)
    if p1.tween then transition.cancel( p1.tween ); p1.tween = nil; end
    if p2.tween then transition.cancel( p2.tween ); p2.tween = nil; end
    if p3.tween then transition.cancel( p3.tween ); p3.tween = nil; end
    if p3.tween then transition.cancel( p4.tween ); p4.tween = nil; end

    page_text_container.isVisible = false
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
    local group = self.view

    -- INSERT code here (e.g. remove listeners, remove widgets, save state variables, etc.)
end

-- [[ STORY DATA STRUCTURES ]]
narrators = {
    [1] = 'julian',
    [2] = 'conchita',
    [3] = 'theresa',
}
paragraphs = {
    julian = {
        [1] = {
            text = "I got one lady, she's like the day I learned to drive: Everytime I see her it just makes my day. She might ride once, twice in a week, in the mornings. She works at some hospice up the road, I think. She's got a face like a nurse, walks like a nurse, wears a pen on a little rope around her neck like a nurse.",
            keyword = "bus",
        },
        [2] = {
            text = "So I pick up Nurse Lady one day and everything is normal, right. Chuckie's in the co-pilot seat and there's some kids on the back going to school, but mostly the bus is kind of empty and pretty quiet. Nurse Lady gets on at the corner of Kenmore and Colvin, and I guess in hindsight I might have seen something coming because the box wouldn't take her bill. I just waived her on and said she could catch up with me next time. She was one of my favorites.",
            keyword = "work",
        },
        [3] = {
            text = "We're rolling down Kenmore Westbound and I notice this guy on the bus, with a Sabres sweatshirt on, and he's kind of yelling towards this girl who might be, what, 15 or something? She's one of them kids with the white headphones and her pants aren't tall enough. I don't try to be judging and all, but you just notice things. Like this guy is harrassing this girl and she's pretending not to hear him. She can hear him. I know if I called her stop, even without them new signs, she'd hear me.",
            keyword = "girl",
        },
        [4] = {
            text = "I get on the intercom and tell Sabres that he's got to settle down. 'Settle down there,' I say, 'Settle down and leave that gal alone. She don't need no bother.'",
            keyword = "reality",
        },
        [5] = {
            text = "Sabres moves back down the aisle towards them schoolboys who was back there. They get rowdy sometimes, but mostly they are good boys. They all ride the bus all the way to some after-school program out by the university, I think. They seem fine and all.",
            keyword = "fiction",
        },
        [6] = {
            text = "I get up to Elmwood and Delaware and I've picked up maybe three or four more fares. Some guy who rides pretty regular but keeps to himself. He always carries this bright yellow bag. I notice it because it's really yellow. It gets Chuckie all excited everytime he rides, and Chuckie gets all excited over all kinds of things, but I gotta say, this guy keeps his bag mighty yellow. It don't ever seem to fade or get dirty.",
            keyword = "localcolor",
        },
        [7] = {
            text = "'Wow! That bag is yellow,' Chuckie says. 'Where did you get it?'\n\nThe guy with the yellow bag just moves on past Chuckie like he always does.\n\n'Wow, Julian. Did you see that? Wow!'\n\nI gotta laugh because that man's bag is just so yellow. \n\n'I'm gonna find out where he got that bag. I gotta get a bag like that. Wow!' Chuckie gets up to follow the guy back.\n\n'Chuckie, you leave that man be. Your stop is coming up soon here.'",
            keyword = "random",
        },
        [8] = {
            text = "We make the turn onto Niagara and I notice the Sabres guy is still standing in the back talking to the boys. The girl is looking out the window; she doesn't get off until Riverside. And mostly everything is pretty quiet.",
            keyword = "reality",
        },
        [9] = {
            text = "We get to Chuckie's stop at the Goodwill and he gets off. Just as he's leaving the bus I hear a scream and I see in the mirror the Sabres guy and he's on the floor in the aisle. Nurse Lady is hollerin' for me to stop the bus. So I do.",
            keyword = "hurt",
        },
        [10] ={
            text = "I don't know nothing about first aid, and the Nurse Lady was there, so I just called into dispatch and told them to get an ambulance to us. The Nurse Lady actually took care of him real well. She got him laying down. I guess he was breathing, because I don't recall that she gave him mouth-to-mouth or anything.",
            keyword = "work",
        },
        [11] ={
            text = "It worked out OK, I guess. I helped the paramedics get him off the bus. The other fares sat until the D came up and they all got vouchers so they seemed pretty happy. I remember seeing Chuckie in the parking lot for awhile, just standing and looking at the bus, but by the time the ambulance got there he was gone.",
            keyword = "home",
        },
        [12] ={
            text = "Sabres recovered. It wasn't a heart attack - it was some kind of head thing, I think. Like brain thing. But apparently it wasn't too bad, which seems to me like any brain thing would be pretty bad, but whatever they say. I ain't seen him around, so I don't know.",
            keyword = "fiction",
        },
    },
    conchita = {
        [1] = {
            text = "Oh my god, I can't believe this guy won't leave me alone. He started out like across the aisle from me and he should stay there. What the hell? It's like, just go away!",
            keyword = "bus",
        },
        [2] = {
            text = "It's so random how people just do things sometimes, y'know? It's like this kid at school this one time back in fifth grade. God, it seems so long ago, y'know? Like four years. Anyways, he like flipped out one day and just started humming real low. He just sat there humming. Totally random. Humming? What the hell is that? Who hums?",
            keyword = "random",
        },
        [3] = {
            text = "I love how when I have my headphones on, it's like I'm in another world. Like nobody knows I'm listening to them, like it's all just me and my music, but I can see them and they can't see me. Like they think I can't hear them, but I can, if I want, and then I'm like way in charge.",
            keyword = "fiction",
        },
        [4] = {
            text = "This guy will not shut up. What the hell? Go away, mister. No, I will not give you a quarter. I do not have a quarter for you. Now I'm really getting pissed, dude, so just like go away and leave me alone. Can't anyone else see this shit going on? What the hell? Jeezus.",
            keyword = "reality",
        },
        [5] = {
            text = "God, finally that guy is gone. I swear to God if he comes back here I'm going to smack him with my Math book. Can you even believe that? I can't even believe it. I wonder why he left?",
            keyword = "hurt",
        },
        [6] = {
            text = "I turn down my headphones to hear what that guy is saying. He's talking to that group of guys back there. A couple of them are pretty cute, but I'm a taken woman, and so I'm, like, not even interested. God, I can't believe he needs a quarter so bad. Like is the bus driver going to chase him out the door? What the hell?",
            keyword = "localcolor",
        },
        [7] = {
            text = "I wonder if Jimmy is back from practice? He had to sit out for like six weeks because of his fracture, even though it was just a hair line. That's gotta be pretty small. Jimmy said he didn't even realize it until he went in for his school physical and he only did that because you got to. So it was like totally random that this thing just picked up on this teeny tiny hairline fracture. And then it took like six weeks to heal.",
            keyword = "random",
        },
        [8] = {
            text = "Christ. OK, this guy has hassled everybody on the bus, I think. Now he's messing with this weirdo guy who kind of looks like a rat. But not mean, but, you know - like he's got a real long face with big teeth. Like a rat. That sounds mean. I like his bag, though.",
            keyword = "hurt",
        },
        [9] = {
            text = "But the beggar guy, he's like wearing this nasty old Sabres sweatshirt. Oh my God, it is so nasty. And he finally begs a quarter off the guy who looks like a rat (but not in a mean way) and then he taps me on the shoulder. I can't believe it. I jump and get ready to smack him with my textbook, but he kind of straightens up and shows me the quarter like to see that he got one. What the hell?",
            keyword = "random",
        },
        [10] ={
            text = "He goes to walk down the aisle and then like stops and stares at this lady. I'm just like, whatever, and hoping he doesn't come back around me again. I look out the window and I can see the cutest jacket in the window of the Goodwill. It's like this orange hoody with rainbow stripes across it. It's got to be from like, I dunno, the '90s.",
            keyword = "girl",
        },
        [11] ={
            text = "And that's when I notice this guy laying on the ground. He's like face-down and the woman is yelling at the bus driver to stop. What's totally random is that, like, the bus isn't even moving, but this woman keeps yelling for the driver to stop. She's like screaming at him and he's just like standing there looking down at her but she doesn't see him. He gets his radio and calls for help, then he opens the door and tells us to get off.\n\nI go into the Goodwill and grab that jacket. It's like five dollars. I can't believe it. I have to hurry, and the lady is distracted because she wants to know what happened on the bus. I tell her some crackhead fainted and she takes that.",
            keyword = "fiction",
        },
        [12] ={
            text = "The D bus gets here and picks us all up who have somewhere else to go. The bus driver and the lady who was helping that guy stick around to help I guess, but the paramedics are there and the guy doesn't look that bad off.\n\nI get home like 20 minutes later than I thought, but Jimmy still isn't back from practice. I guess they must be working extra hard for the game next week. I hope he didn't have another accident.",
            keyword = "home",
        },
    },
    theresa = {
        [1] = {
            text = "Oh my God, I can't believe the kind of bullshit that I have to go through every God damned day. I'm on my feet all day long, taking care of people's disgusting shit and piss and nastiness and all that nasty shit. And then I have to take the goddamned bus. I can't believe this shit.",
            keyword = "bus",
        },
        [2] = {
            text = "At least it's the good busdriver. Most of these idiots run so late you wouldn't believe it. You just want to scream at the top of your lungs, it's such bullshit.",
            keyword = "work",
        },
        [3] = {
            text = "I'm reading my paper and trying to think about what I'm going to have for dinner. I used to be able to eat those Lean Cuisine dinners like every night, but lately they've been shit. I don't know if it's me or the dinners, but one of us has been shit lately.",
            keyword = "home",
        },
        [4] = {
            text = "I can't really think about dinner because some man in a Sabres jersey is bothering this little girl sitting near me. She's pretending not to hear him, but she gotta hear him. He's almost yelling. What a fuckhead. I'm sorry, but that's a shitty way to behave.",
            keyword = "girl",
        },
        [5] = {
            text = "Just when he's asking her for like the twelfth time if she's got a quarter for the transfer, Bus Driver yells at him to sit down. He's a fuckhead, but he does go and turn his attention to some kids sitting in the back of the bus.",
            keyword = "reality",
        },
        [6] = {
            text = "The bus is getting crowded as more people get on. They all look like they're going to shitty jobs. Coming home from shitty jobs, I guess. Going to shitty homes. There's this retard who laughs real hard at this little guy getting on the bus. Not little like little people little, but you know, little like short and shit.",
            keyword = "localcolor",
        },
        [7] = {
            text = "The little guy looks real bothered by the retard. It's hilarious. He sits all close to the back, but then the Sabres guy starts harrassing him for a quarter. I watch the little man kind of quiver a little, and Sabres guy gets a weird look on his face. The little guy fumbles inside this God-awful fucking bag and pulls out a quarter. He hands it over to Sabers guy, but then drops it or something. I dunno, I wasn't watching.",
            keyword = "random",
        },
        [8] = {
            text = "Sabres guy bends over to pick up the quarter. He straightens up and then, I swear to fucking God, I saw him mouth the word 'shit' and then he just fell on his face. Straight forward into the ground, and I thought to myself, 'Shit. That must have hurt.'' You could hear his teeth crack together when he hit.",
            keyword = "hurt",
        },
        [9] = {
            text = "These things happen when you're a nurse. And it's time's like this that I just have to say to myself, Theresa, you are a nurse and you have a duty to help this person in front of you.",
            keyword = "random",
        },
        [10] ={
            text = "I scream at the bus driver to stop like a fool idiot. I pull the guy out of the aisle into the more open area up front. The retard had already gotten off, so there wasn't anybody else directly up front.",
            keyword = "reality",
        },
        [11] ={
            text = "Now, shit, I may be a nurse and all, but I'm not going to risk my life by giving some complete stranger CPR when I'm not on the clock and without a mouthpiece. Half the time those fuckers puke up on you anyway after that kind of shit, and who knows why he passed out? Let the paramedics deal with this shit.",
            keyword = "work",
        },
        [12] ={
            text = "Brian and Doug came out with the ambulance. They took care of that guy and I guess he was fine. I mean, how the fuck would I know? Actually, I checked in on him after all that shit happened and he at least got checked out alive. That's all I care about. He was an asshole anyway.",
            keyword = "fiction",
        },
    },
}
tangents = {
    bus = {
        julian = { text = "Some mornings start out real cold and you almost can't stand to open that door. I tell you, some mornings I'm just huddled up with a blanket wrapped around me in the seat. If I'm driving one of the replacement units, I gotta bring my little heater, too. It gets cold sometimes.", narr = 'julian', },
        julian1 = { text = "When I was a boy, I rode the bus to school, too. Back then it didn't cost no dollar fifty though. It was like a quarter. And we'd ride to school, then on the way home we'd transfer and head down to the river. In the warm weather we'd swim and fish, or in the winter we'd burn stuff in the little houses on the coast guard island. We never saw no coast guards.", narr = 'julian', },
        conchita = { text = "Once when Papi and I were waiting for the bus after he took me shopping on Elmwood for a new purse for my birthday, we were sitting on bench. I remember Papi looked so old at that moment, and for a second I thought he might be having a heart attack or some gas or something because his face screwed up all weird.", narr = 'conchita', },
        theresa = { text = "I remember the first time I rode the goddamned bus. I had to go across town so I could go to school at Holy Angels because my mama figured nobody ever got a good education at a public school, and she wouldn't have us in there after grade school. It was fun at first, riding the bus to school, like we were allowed to have some fucking control over our lives. We could go anywhere, and it was our choice to go to school each day.", narr = 'theresa', },
        theresa1 = { text = "My first boyfriend felt me up for the first time on the bus. No shittin'. We would hike up our skirts extra high when we got out of class, and we'd show off for the boys when we got on the bus.", narr = 'theresa', },
    },
    girl = {
        julian = { text = "The teenage girl rides the bus every day. I see her all the time. Her parents are nice folks who live out in Riverside. She gets on and has her headphones up so high everyone else can hear the music. Half the time she puts her pass backwards through the card swipe and don't even notice it don't beep. I figure it ain't worth it to hassle her about it.", narr = 'julian', },
        conchita = { text = "I think some of the most meaningful moments in my life have been accompanied by music. It's like as if I'm just in tune to the rhythm or something. Like if I'm angry and I listen to an angry song, then I, like, work it out through that, you know? Or if I'm trying to, you know, chill out and just be kind of zen then I have to get some kind of mellow music going on. I think I'm just like seriously in-tune with the musical wavelength.", narr = 'conchita', },
        theresa = { text = "I used to work with this Latino gal at the hospital looked a lot like that girl there. She wore these big hoop earrings said 'Jennie' across them.", narr = 'theresa', },
        theresa1 = { text = "I remember riding out to the hospital on the bus after school to visit Janie, and I'd see the Yellow Jacket in the parking lot. It would be sitting there like a beacon, shining in the middle of the parking lot. Mama saw the Yellow Jacket from the bus once, sittin in the hospital parking lot, when Janie weren't sick at all. ", narr = 'theresa', },
    },
    hurt = {
        julian = { text = "One time we were burning this fire in a house and one of my buddies had brought this roman candle with him. He was gonna shoot it out the window from the couch we were sitting on. We had played with roman candles out on the islands a lot. They were weak fireworks, usually, but not this time. The first blast came out of that thing like a canon shot, and this ball of green-blue fire got caught up in the curtain, which pretty much right then just melted to the floor, catching the carpet on fire, then crawling up the walls.", narr = 'julian', },
        julian1 = { text = "The roman candle was still shooting. Five shots in total. It was a crazy situation. My buddy wanted to drop the candle, but he was afraid it would spin around and shoot him. We ran to the doorway and screamed for him to toss it in the fireplace. We all got out OK, but that house burnt down.", narr = 'julian', },
        julian2 = { text = "After we burned down the one house, my buddies started thinking it would be fun to just load a house up with as many fireworks as possible and then set it off. So they did that. Then they got gallons and gallons of gasoline and turned another of the cabins into a giant bomb/bonfire. That time, the cabin really blew up some, and a random splinter of wood hit my friend, the one who had brought that first roman candle, in the ear. He went deaf and I don't know what else. I kind of fell away from those guys after awhile.", narr = 'julian', },
        conchita = { text = "It was so sad. Jimmy didn't even get a cast because of how small his fracture was, but it totally hurt way more than that. I like helped out with the pain by giving him a back and shoulder rub while I played him some Enya in the background from the LotR soundtrack. I think it was, like, totally soothing.", narr = 'conchita', },
        theresa = { text = "Janie was sick a lot. She had asthma and had to stay home a lot. Mama stayed home to take care of her, or sometimes my aunt would come in from Niagara Falls. She would always make us take her down to the Italian restaurant on the corner which used to be owned by mobsters, I think.", narr = 'theresa', },
    },
    home = {
        julian = { text = "Chuckie don't ever cause no problems. For the most part. Sometimes if he's not sure where he's going he can worry a bunch. And he takes a new route map every day. I ask him, 'Chuckie, what are you doing with all them route maps? You must have a million of them at home!' But I guess he loses them pretty much every day, too. I think he takes usually two buses to get to his job at the Goodwill, and who knows what else in between that or where else he goes. I don't know. All I know is he loves to ride the bus, and it's OK to have him in the co-pilot. At least I know he don't want nothing from me.", narr = 'julian', },
        conchita = { text = "Papi looked at me and asked me if I missed my mother. I said I did sometimes. He said, \"Well, you know that you are as old now as she was when we found out you were coming.\"  I knew that. I never met her, I mean, not that I remember, but Papi and Mami have told me about her. About how she looks like me. About how she thought she knew everything and if she wanted to she could have been a great woman like Madame Curie or Eva Peron.", narr = 'conchita', },
        theresa = { text = "That day Mama caught him with the nurse from the Pediatrics wing, he came home late that night. We didn't see him until the next day after school. And in the morning, when we leave for school, we notice the Yellow Jacket is gone. Never saw that fucking car ever again.", narr = 'theresa', },
        theresa1 = { text = "One day we came home and Daddy was gone, too. He left us a note and Mama said it was for the best. He just up and left. There weren't no reason for it. It was just out of the blue.", narr = 'theresa', },
    },
    work = {
        julian = { text = "One time I was working the night shift and that teenage girl was riding on the bus. She was with this big old hockey player type guy who kept sucking on her neck. She would giggle and tell him to stop, and I could tell there was some kind of something else going on, too.", narr = 'julian', },
        conchita = { text = "I got my first pair of headphones when I was 12. My Papi said that he thought I deserved to have my own headphones if I was going to ride the bus to school next year. I had to go across town because if I was going to get into City Honors I had to go to the best school in the city to prepare. And if that meant riding the bus for an hour each way, then that was OK with my Papi.", narr = 'conchita', },
        theresa = { text = "Once I was riding the bus, and this old man was on the bus. He started hacking and coughing and I thought he was going to eventually throw up or something, you know, it was real deep down inside him like that. And then I got to the hospital and I'm doing my rounds, and I walk into a room and there he is, the same motherfucker. He rode the bus to the hospital because he thought the ambulance was too expensive.", narr = 'theresa', },
        theresa1 = { text = "I hate being a nurse. I got pregnant when I was 17, and I didn't have much choice about what to do. I made it through nursing school and that has been a decent living. But I hate it. I hate working with sick people. Disgusting nastiness. I'm just so sad all the time after I get home.", narr = 'theresa', },
    },
    localcolor = {
        julian = { text = "We get past Niagara and go onto Vulcan proper and past all of the factories and some rundown taverns and pizza parlors. There used to be three pizza parlors and two bars on every corner, plus a liquor shop downstairs. I don't know. I suppose people might feel worse about things, except that nobody I know remembers when this area was doing any good. As far as I know, though, Riverside ain't the worst off. I seen worse on the Lower West Side. Can't say why some of these places go to hell and others stay OK even still.", narr = 'julian', },
        conchita = { text = "Once we were eating at the Manhatten Bagel on Elmwood and this homeless guy was, like, trying to perform for money outside the window where we were eating. He had this Freddy Krueger mask and was like sneaking up on people walking by. It was a beautiful day, so lots of people were out. He'd walk too close to them or hold their hand and they'd freak out. We kept thinking somebody would punch his lights out. He tried to beg some money off us, but we didn't have any. We never saw him again. It was, like, so totally random.", narr = 'conchita', },
        theresa = { text = "I cracked my teeth once on the curb one winter. I was running to catch the bus and I slipped on some fucking ice that I didn't see. It had gotten real warm that week, and everywhere there were big puddles where the snow used to be. Then over night it froze and the next morning there were spots where the ice was thin as paper and slick as snot.", narr = 'theresa', },
    },
    random = {
        julian = { text = "I remember the first time Chuckie got on my bus. He called me the DustBriver. I have no idea why. I told him to call me Julian. So that's what he calls me now.", narr = 'julian', },
        julian1 = { text = "Kenmore's got better bowling alleys than schools. I heard we might have a decent hockey team at the Boys' Club this year. Everyone heads down to the rink in the winter time, but I'm not so much for it. All that rowdiness and drinking. I went once and saw this kid, musta been about 12, bite off his lower lip getting all smashed up against the glass. I could see his teeth just dig into the flesh, and then blood exploded like he just laughed Kool Aid out his nose.", narr = 'julian', },
        conchita = { text = "I got Jimmy a card after he found out he'd have to sit out on the game. I made it in the computer and it had a picture of a kitten, all bandaged up and with a little crutch propped up next to him and a football laying at his feet, on the front and on the inside it said, \"Can't wait to have you back on the field, Tiger!\" We passed it around the school, and I signed it first, but by the time it got to Jimmy my signature was, like, totally unreadable and some slut wrote her phone number in it. Jimmy said it was OK and he knew it was from me. He's super sweet.", narr = 'conchita', },
        theresa = { text = "When I was a kid, my daddy drove a 1964 Chevy Impala that he painted bright yellow. It was the Yellow Jacket, that's what he called it. He was forever out with the Jacket working on it or cleaning it or just listening to the game on the car radio. That car helped make my daddy a big man in the neighborhood, and we all loved that car. The back seat was so big, I remember, I could lay all the way out and sleep when my sister wasn't with us.", narr = 'theresa', },
        theresa1 = { text = "I hate two things more than anything else in the world: blood and crap. I've had three kids and been a nurse for almost 30 years. I've seen too much blood and crap.", narr = 'theresa', },
    },
    reality = {
        julian = { text = "Once this other retarded girl got on the bus. She was kind of fat, and I had to drop the bus so she could step up the first step. I don't mind helping out like that. But even though she was kind of retarded, she wasn't ugly. You know, her head was kind of funny shaped and she didn't really look directly at me, but I noticed she looked at Chuckie when she walked by. And he looked like he might have known her. I tried to get him to ask her out but he wouldn't. He said she wouldn't go out with him. And I said you never know. 'Every dog has his day,' I said, 'It might happen.'", narr = 'julian', },
        conchita = { text = "Papi told me my mother had gone away to take a job. That's what he said at first. That she was so sorry she had to leave, but she would eventually maybe come back. I kept hoping for that. And I guess I still would be, except we heard like a couple years after that how she had been found in a squatter house in Niagara Falls. And it wasn't really so sad that she was dead, I mean, she wasn't ever around. But, like, what really weirds me out was thinking how I could have just taken the bus out to meet her anytime. I mean, if I had been old enough to take the bus back then.", narr = 'conchita', },
        theresa = { text = "I got no patience for hobos, bums, crackheads, panhandlers, or generally human annoyances. I saw one time, on the bus, this group of boys roll these two crackheads who kept hasselling them for money. Eventually they pissed off these kids, and they just turned out their pockets. They threw their shitty cigarettes and their crackpipes or whatever out the window, and they might have each taken a couple licks for fun. It was a fucking strange thing to witness. I mean, I wasn't sure what to do, but there was so many of them boys. I couldn't get involved. In the end them crackheads didn't seem much worse for the wear.", narr = 'theresa', },
    },
    fiction = {
        julian = { text = "The folks who sit in the co-pilot seat are usually pretty needy. Crazy folks, crackheads looking for transfer money, horny ladies after the busdriver. Oh yeah, I get that all the time. Well, I used to get it more, but you never know. I mean, I'm not much of one to flirt with any of them. I know that if they do it to me, they do it to every busdriver they ride with.", narr = 'julian', },
        conchita = { text = "\"Conchita\" \n\nHe looked at me and made it feel like this was a real serious moment, and he said, \"You know better, right? You will not go to fast. You are a smart girl.\"", narr = 'conchita', },
        theresa = { text = "I didn't do well in my nursing classes. I was usually tired from working the night shift at American Brass. Now that was a shitty job. At least nursing is better than that crap. Oh, it would drive me crazy, pulling the same lever, making a million little things that don't look like nothing. You know, like fucking eyelets for your sneakers and whatnot.", narr = 'theresa', },
    },
}

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


