# @require 'js/rAF.polyfill.js'

# =========================================
# GAME SETTINGS
# =========================================

options =
    debug: true
    lives: 6

    accel: 5
    step: 5

    transform: S.utils.supports('transform')

    objects:
        banana:
            class: 'banana'
            chance: .5
            num: 3
            points: 10
            lives: 0
        bomb:
            class: 'bomb'
            chance: .005
            num: 1
            points: -10
            lives: 1
        heart:
            class: 'heart'
            chance: .001
            num: 1
            points: 20
            lives: 1

# =========================================
# UTILITY
# =========================================
log = ()->
    if (options.debug && window.console?)
        if (arguments.length > 1) then console.log(Array::slice.call(arguments)) else console.log(arguments[0])


block = $('.p-game')

# =========================================
# SCREENS MANAGEMENT
# =========================================

screens = (()->
    els = block.find('.game-screen')

    showIntro = () ->
        els.filter('.active').removeClass('active')
        els.filter('.game-intro').addClass('active')
        block.trigger('game::intro')

    showOver = () ->
        els.filter('.active').removeClass('active')
        els.filter('.game-over').addClass('active')
        block.trigger('game::over')

    showGame = () ->
        els.filter('.active').removeClass('active')
        els.filter('.game-mainscreen').addClass('active')
        block.trigger('game::started')

    els.find('#game-start').on('click', showGame)
    els.find('#game-retry').on('click', showGame)

    {
        intro: showIntro
        over: showOver
        game: showGame
    }
    )()

# =========================================
# GAME STATUS
# =========================================

game = 
    score: 0
    lives: options.lives

    objects: []
    activeObjects: {}

    player: null

    width: block.width()
    height: block.height()

# =========================================
# GAME OBJECTS
# =========================================
class Entity
    constructor: (type, settings) ->
        @type = type
        @options = settings       

        @points = @options.points
        @lives = @options.lives
        @chance = @options.chance

        @velocity = 0
        @accelerated = false

        @x = 0
        @y = 0

        @width = 0
        @height = 0

        @active = false

        @el = $('<span class="game-object ' + @options.class + '"></span>')

    getSizes: () ->
        @width = @el.width()
        @height = @el.height()

    activate: () ->
        @active = true
        @el.addClass('active')
        game.activeObjects[@type]++

        @getSizes() unless @width and @height

        @x = (Math.random() * (game.width - @width)) | 0
        @y = -(Math.random() * @height) | 0

    deactivate: () ->
        @x = 0
        @y = 0

        @active = false
        @el.removeClass('active')
        game.activeObjects[@type]--

    move: () ->
        if (this.accelerated)
            @velocity++
            @y += options.accel + @velocity / 2

        else
            @y += options.accel

        if (@y >= game.height)
            @velocity = 0
            @deactivate()

    render: () ->
        if (!@active)
            if game.activeObjects[@type] >= options.objects[@type].num
                return false
            
            if Math.random() < @chance or @chance == 1
                @activate()
            else 
                return false

        @move()

        if options.transform
            props = {}
            props[options.transform] = 'translate3d(' + @x + 'px, ' + @y + 'px, 0)'        
        else
            props =
                left: @x
                top: @y

        @el.css(props)
        
# =========================================
# PLAYER OBJECT
# =========================================
class Player
    constructor: () ->
        @x = 0
        @y = 0

        @el = block.find('.player')

        @width = 0
        @height = 0

    reset: () ->
        @width = @el.width()
        @height = @el.height()

        @x = (((game.width / 2) - (@el.width() / 2)) | 0)
        
        @move(0, 0)

    move: (x, y) ->
        if x? then @x = Math.min(Math.max(0, @x + x), game.width - @width)
        if y? then @y = Math.min(Math.max(0, @y + y), game.height - @height)

    render: () ->
        if options.transform
            props = {}
            props[options.transform] = 'translate3d(' + @x + 'px, ' + @y + 'px, 0)' 
        else
            props =
                left: @x
                top: @y

        @el.css(props)


# =========================================
# GAME ENGINE
# =========================================
engine = (()->
    doc = $(document)
    el = block.find('.game-mainscreen')
    pauseButton = block.find('.game-paused')

    active = false
    frame = null

    initObjects = () ->
        for type, obj of options.objects
            game.activeObjects[type] = 0
            for [1..obj.num]
                game.objects.push(new Entity(type, obj))


        game.player = new Player()

    appendObjects = () ->
        for obj in game.objects
            el.append(obj.el)

    handleKeys = (e) ->
        switch e.keyCode
            when 27
                # ESC
                togglePause()                  

            when 37
                # LEFT
                game.player.move(-options.step)

            when 39
                # RIGHT
                game.player.move(options.step)

            # when 0
                # SPACEBAR

    togglePause = () ->
        if active
            pauseEngine()
        else
            resumeEngine() 

    initEngine = () ->
        initObjects()
        appendObjects()

        block.on('game::started', startEngine)
        block.on('game::intro', stopEngine)
        block.on('game::over', stopEngine)

        pauseButton.on('click', togglePause)

    checkCollisions = () ->
        #no collisions haha

    render = () ->
        game.player.render()

        for ent in game.objects
            ent.render()

    gameLoop = () ->
        frame = requestAnimationFrame(gameLoop)
        if active
            checkCollisions()
            render()

    stopLoop = () ->
        cancelAnimationFrame(frame)

    startEngine = () ->
        doc.on('keypress', handleKeys)
        active = true

        game.player.reset()
        gameLoop()

    stopEngine = () ->
        doc.off('keypress', handleKeys)
        active = false
        stopLoop()

    pauseEngine = () ->
        el.addClass('paused')
        stopLoop()
        active = false

    resumeEngine = () ->
        el.removeClass('paused')
        gameLoop()
        active = true

    initEngine()

    {
        init: initEngine
        start: startEngine
        stop: stopEngine
        pause: startEngine
        resume: startEngine
    }
    )()

# =========================================
# ALL DONE
# =========================================
log('game::initialized')
