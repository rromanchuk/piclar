# @require 'js/rAF.polyfill.js'
# @require 'js/hash/base64.js'
# @require 'js/hash/md5.js'


(($) ->
    if not Date.now
        Date.now = () ->
            return +new Date()

    # =========================================
    # LOAD HIGHSCORES
    # =========================================

    highscores = []
    highscore = 0

    $.ajax({
        url: '/api/v1.1/game/score.json'
        type: 'GET'
        success: (res) ->
            if res.length
                highscores = res
                highscore = highscores[0].score
        })

    # =========================================
    # GAME SETTINGS
    # =========================================

    options =
        debug: true
        lives: 6

        player:
            step: 10
            accel: 1

        modeTimer: 1000 * 20
        modes: [5, 8, 12, 16, 23, 25]

        accelerated: 3
        randomized: 6
        vector: 2

        sudden:
            active: true
            object: 'bomb'
            num: 10

        transform: S.utils.supports('transform')

        objects:
            banana:
                class: 'banana'
                chance: .25
                num: 5
                points: 1
                lives: 0
                accel: 1
            bomb:
                class: 'bomb'
                chance: .005
                num: 2
                points: -5
                lives: -2
                accel: 2
            heart:
                class: 'heart'
                chance: .0001
                num: 1
                points: 30
                lives: 2
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
    win = $(window)

    # =========================================
    # SCREENS MANAGEMENT
    # =========================================

    screens = (()->
        els = block.find('.game-screen')
        score = block.find('.game-results-final')
        scoreboard = block.find('.game-scoreboard')

        name = block.find('#game-player-name')

        showIntro = () ->
            els.filter('.active').removeClass('active')
            els.filter('.game-intro').addClass('active')
            block.trigger('game::intro')
            log('game::screens::intro')

        showOver = () ->
            els.filter('.active').removeClass('active')
            els.filter('.game-over').addClass('active')
            name.off('keypress keydown', limitNameToChars)
            block.trigger('game::over')
            log('game::screens::over')

        showHighScore = () ->
            score.html(game.score)
            els.filter('.active').removeClass('active')
            els.filter('.game-highscore').addClass('active')
            name.on('keypress keydown', limitNameToChars)
            block.trigger('game::highscore')
            log('game::screens::highscore')

        showGame = () ->
            els.filter('.active').removeClass('active')
            els.filter('.game-mainscreen').addClass('active')
            block.trigger('game::started')
            log('game::screens::game')

        updateScoreboard = () ->
            results = for item in highscores
                '<li>' + item.name + ' ' + item.score + '</li>'

            scoreboard.html(results)

        saveScore = () ->
            return unless (val = $.trim(name.val())).length
            result = 
                name: val
                score: game.score

            highscores.unshift(result)
            highscores.length = 10 unless highscores.length <= 10
            highscore = game.score

            json = JSON.stringify(result)

            $.ajax({
                url: '/api/v1.1/game/score.json'
                data:
                    signature: md5(json)
                    data: window.btoa(json)
                type: 'POST'
                success: (res) ->
                    highscores = res
                    highscore = highscores[0].score
                })

            updateScoreboard()
            showOver()

        limitNameToChars = (e) ->
            if (e.keyCode == 13)
                saveScore()
            else
                if (!/^[a-zA-Z]*$/.test(String.fromCharCode(e.keyCode)))
                    e.preventDefault()


        updateScoreboard()

        block.find('#game-start').on('click', showGame)
        block.find('#game-retry').on('click', showGame)
        block.find('#game-savescore').on('click', saveScore)

        {
            intro: showIntro
            over: showOver
            highscore: showHighScore
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

            offset: {}

        defaults.reset = () ->
            game.active = false

            game.score = 0
            game.lives = options.lives
            
            game.mode = 0

        calculateOffset = () ->
            pos = block.offset()
            defaults.offset.x = pos.left
            defaults.offset.y = pos.top

        calculateOffset()
        win.on('resize', calculateOffset)

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

            @vector = 0
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
            @vector = 0
            @el.removeClass('active')
            game.activeObjects[@type]--

        _randomVector: () ->
            return (if Math.random() < .5 then @options.accel else -@options.accel) * (Math.random() + 1)

        move: () ->
            if (game.mode >= options.accelerated - 1)
                if (game.time - @accelerated > 150)
                    @velocity += @options.accel
                    @accelerated = game.time

            if (game.mode >= options.vector - 1 and game.mode < options.randomized and not @vector)
                @vector = @_randomVector()

            if (game.mode >= options.randomized - 1)
                if (game.time - @randomized > 300)
                    @vector += @_randomVector() * 3
                    @randomized = game.time

            @y += options.modes[game.mode] + @velocity
            @x += @vector          

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

        move: (x, keyb) ->
            if x?
                if (keyb)
                    if (game.time - @moved < 100)
                        @velocity += if (x > 0) then options.player.accel else -options.player.accel
                    else 
                        @velocity = 0
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
                    ent = new Entity(type, obj)
                    game.objects.push(ent)
                    el.append(ent.el)

            game.player = new Player()

        initEngine = () ->
            initObjects()

            block.on('game::started', startEngine)
            block.on('game::intro', stopEngine)
            block.on('game::over', stopEngine)

            pauseEl.on('click', togglePause)

            log('game::engine::initialized')

        resetObjects = () ->
            for obj in game.objects
                obj.deactivate()

    # --------------------------
    # GAME LOOP
    # --------------------------
        collision = (obj) ->
            if obj.points
                game.score = Math.max(game.score + obj.points, 0)
                scoreEl.html(leadZeros(game.score))

            if obj.lives
                game.lives = Math.min(game.lives + obj.lives, options.lives)
                livesEl.attr('data-lives', game.lives)
                if game.lives <= 0
                    gameOver()

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
            log('game::engine::mode ' + (game.mode + 1))

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

    # --------------------------
    # CONTROLS
    # --------------------------
        handleKeys = (e) ->
            switch e.keyCode
                when 27
                    # ESC
                    togglePause()                  

                when 37
                    # LEFT
                    game.player.move(-options.player.step, true)

                # when 38
                #     # UP
                #     game.player.move(-options.player.step)

                when 39
                    # RIGHT
                    game.player.move(options.player.step, true)

                # when 0
                    # SPACEBAR

        handleMouse = (e) ->
            game.player.move(e.pageX - game.player.x - game.player.width / 2 - game.offset.x)

    # --------------------------
    # LOGIC
    # --------------------------
        gameOver = () ->
            stopEngine()

            if (game.score > highscore)
                screens.highscore()
            else
                screens.over()

        togglePause = () ->
            if game.active
                pauseEngine()
            else
                resumeEngine()

        startEngine = () ->
            doc.on('keydown keypress', handleKeys)
            doc.on('mousemove', handleMouse)
            win.on('blur', pauseEngine)
            # doc.on('focusout', pauseEngine)

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
            doc.off('mousemove', handleMouse)
            win.off('blur', pauseEngine)
            doc.off('focusout', pauseEngine)

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
