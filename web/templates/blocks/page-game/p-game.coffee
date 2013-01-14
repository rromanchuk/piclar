# @require 'js/rAF.polyfill.js'

(($) ->
    if not Date.now
        Date.now = () ->
            return +new Date()

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
                points: -50
                lives: -1
            heart:
                class: 'heart'
                chance: .001
                num: 1
                points: 30
                lives: 1

    # =========================================
    # UTILITY
    # =========================================
    log = ()->
        if (options.debug && window.console?)
            if (arguments.length > 1) then console.log(Array::slice.call(arguments)) else console.log(arguments[0])

    leadZeros = (num) ->
        if (num < 10)
            return '00' + num

        if (num < 100)
            return '0' + num

        return '' + num

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
            log('game::screens::intro')

        showOver = () ->
            els.filter('.active').removeClass('active')
            els.filter('.game-over').addClass('active')
            block.trigger('game::over')
            log('game::screens::over')

        showGame = () ->
            els.filter('.active').removeClass('active')
            els.filter('.game-mainscreen').addClass('active')
            block.trigger('game::started')
            log('game::screens::game')

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

    game = (() ->
        defaults =
            active: false

            score: 0
            lives: options.lives

            objects: []
            activeObjects: {}

            player: null

            time: Date.now()

            width: block.width()
            height: block.height()

        defaults.reset = () ->
            game.active = false

            game.score = 0
            game.lives = options.lives

        return defaults
        )()

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

            @offset = parseInt($(@el).css('margin-top'))

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
        livesEl = block.find('.game-lives')
        scoreEl = block.find('.game-score')
        pauseEl = block.find('.game-paused')

        frame = null

    # --------------------------
    # INITIALIZING
    # --------------------------
        initObjects = () ->
            for type, obj of options.objects
                game.activeObjects[type] = 0
                for [1..obj.num]
                    game.objects.push(new Entity(type, obj))


            game.player = new Player()

        appendObjects = () ->
            for obj in game.objects
                el.append(obj.el)

        initEngine = () ->
            initObjects()
            appendObjects()

            block.on('game::started', startEngine)
            block.on('game::intro', stopEngine)
            block.on('game::over', stopEngine)

            pauseEl.on('click', togglePause)

            log('game::engine::initialized')

        resetObjects = () ->
            for obj in game.objects
                obj.deactivate()


    # --------------------------
    # LOGIC
    # --------------------------
        handleKeys = (e) ->
            switch e.keyCode
                when 27
                    # ESC
                    togglePause()                  

                when 37
                    # LEFT
                    game.player.move(-options.step)

                # when 38
                #     # UP
                #     game.player.move(-options.step)

                when 39
                    # RIGHT
                    game.player.move(options.step)

                # when 0
                    # SPACEBAR

        togglePause = () ->
            if game.active
                pauseEngine()
            else
                resumeEngine() 

        collision = (obj) ->
            if obj.lives
                game.lives = Math.min(game.lives + obj.lives, options.lives)
                livesEl.attr('data-lives', game.lives)

                if game.lives <= 0
                    gameOver()

            if obj.points
                game.score = Math.max(game.score + obj.points, 0)
                scoreEl.html(leadZeros(game.score))

            # collided, remove to avoid consecutive calls
            obj.deactivate()

        checkCollisions = (obj) ->
            if ((obj.y + obj.height >= game.player.y + game.player.offset) and (obj.y <= game.player.y + game.player.offset)) or
            ((obj.y >= game.player.y + game.player.offset) and (obj.y <= game.player.y + game.player.offset + game.player.height))
            # Collided by Y

                if ((obj.x <= game.player.x) and (obj.x + obj.width >= game.player.x)) or
                ((obj.x >= game.player.x) and (obj.x <= game.player.x + game.player.width))
                # Collided by both X and Y
                    collision(obj)

        render = () ->
            game.player.render()

            for ent in game.objects
                checkCollisions(ent)
                ent.render()

        gameLoop = () ->
            frame = requestAnimationFrame(gameLoop)
            if game.active
                render()

        stopLoop = () ->
            cancelAnimationFrame(frame)

        gameOver = () ->
            stopEngine()
            screens.over()


    # --------------------------
    # CONTROLS
    # --------------------------
        startEngine = () ->
            doc.on('keydown keypress', handleKeys)

            game.reset()
            game.active = true

            game.player.reset()
            gameLoop()

            log('game::engine::started')

        stopEngine = () ->
            doc.off('keydown keypress', handleKeys)
            game.active = false
            stopLoop()

            log('game::engine::stopped')

        pauseEngine = () ->
            el.addClass('paused')
            stopLoop()
            game.active = false

            log('game::engine::paused')

        resumeEngine = () ->
            el.removeClass('paused')
            gameLoop()
            game.active = true

            log('game::engine::resumed')

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
    engine.init()
)(jQuery)
