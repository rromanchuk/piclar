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

        step: 10
        
        accel: 1

        modeTimer: 1000 * 30
        modes: [5, 8, 12, 16, 23, 25]

        accelerated: 3
        randomized: 6

        transform: S.utils.supports('transform')

        objects:
            banana:
                class: 'banana'
                chance: .25
                num: 5
                points: 10
                lives: 0
                accel: 1
            bomb:
                class: 'bomb'
                chance: .005
                num: 2
                points: -50
                lives: -1
                accel: 2
            heart:
                class: 'heart'
                chance: .0001
                num: 1
                points: 30
                lives: 1
                accel: 3

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

            mode: 0

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
            
            game.mode = 0

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
            @accelerated = 0

            @factor = 0
            @randomized = 0

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

            @x = Math.random() * (game.width - @width)
            @y = -Math.random() * @height

        deactivate: () ->
            @x = 0
            @y = 0

            @active = false

            @velocity = 0
            @factor = 0
            @el.removeClass('active')
            game.activeObjects[@type]--

        move: () ->
            if (game.mode >= options.accelerated - 1)
                if (game.time - @accelerated > 150)
                    @velocity += @options.accel
                    @accelerated = game.time

            if (game.mode >= options.randomized - 1)
                if (game.time - @randomized > 50)
                    @factor += if Math.random() < .5 then @options.accel else -@options.accel
                    @randomized = game.time

                @x = Math.min(Math.max(0, @x + @factor), game.width - @width)

            @y += options.modes[game.mode] + @velocity

            if (@y >= game.height)
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

            @velocity = 0
            @moved = 0

            @offset = parseInt($(@el).css('margin-top'))

        reset: () ->
            @width = @el.width()
            @height = @el.height()

            @x = (((game.width / 2) - (@el.width() / 2)) | 0)
            
            @move(0, 0)

        move: (x, y) ->
            if x?
                if (game.time - @moved < 100)
                    @velocity += if (x > 0) then options.accel else -options.accel
                else 
                    @velocity = 0

                @x = Math.min(Math.max(0, @x + x + @velocity), game.width - @width)
                @moved = game.time

            # if y?
            #     @y = Math.min(Math.max(0, @y + y), game.height - @height)

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

        modeStarted = Date.now()
        modesNum = options.modes.length - 1

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

        changeMode = () ->
            modeStarted = Date.now()
            game.mode++
            log('game::engine::mode')

        render = () ->
            game.player.render()

            for ent in game.objects
                checkCollisions(ent)
                ent.render()

        gameLoop = () ->
            frame = requestAnimationFrame(gameLoop)
            if game.active
                game.time = Date.now()
                if (game.time - modeStarted > options.modeTimer and modesNum > game.mode) then changeMode()

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

            livesEl.attr('data-lives', game.lives)
            scoreEl.html(leadZeros(game.score))

            modeStarted = Date.now()

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
