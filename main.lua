 require("config")
require("utils")
require("game")
require("player")
require("enemy")
require("projectile")

function love.load()
    generateEnemies()
    math.randomseed(os.time())
end

function love.update(dt)

    if player.shootStatus then
        if player.cooldown == 0  then
            player.cooldown = config.PLAYER_COOLDOWN
            player.shootStatus = false
        else
            player.cooldown =  player.cooldown - 1
        end
    end
    if config.GAME_STATE == "play" then
        game.frames = game.frames + 1

        if game.frames == config.MAX_FRAME then
            moveEnemies(game.currentMove, 5)
            game.frames = 0

            if game.moveDown then
                moveEnemies("down", 10)
                game.moveDown = false
            end
        end

        timeSinceLastCall = timeSinceLastCall + dt
        if timeSinceLastCall >= nextCallDelay then
            enemiesShootBehavior()
            timeSinceLastCall = 0
            nextCallDelay = math.random(config.MIN_SHOOT_DELAY, config.MAX_SHOOT_DELAY)
        end

        enemiesMovementBehavior()
        updatePlayer(dt)
        updateBalls(dt)
        checkEnemyCollisions()
        checkPlayerCollisions()
        removeOffscreenProjectiles()
    end
end

function love.draw()
    local y = config.MESSAGE_Y
    local dy = 20

    love.graphics.print("Ennemis restants : " .. #game.enemies, config.MESSAGE_Y, y); y = y + dy
    love.graphics.print("Score : " .. game.score, config.MESSAGE_Y, y); y = y + dy
    love.graphics.print("FPS: " .. love.timer.getFPS(), config.MESSAGE_Y, y); y = y + dy

    if config.GAME_STATE == "play" or config.GAME_STATE == "pause" then
        for i, v in ipairs(game.balls) do
            love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
        end

        love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

        for __, v in ipairs(game.enemies) do
            if v.x and v.y and v.width and v.height then
                love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
            end
        end
    end

    if config.GAME_STATE == "pause" then
        love.graphics.print("Le jeu est en pause, veuillez appuyer sur la touche 'P' pour continuer à jouer.",
            config.MESSAGE_Y, y)
    elseif config.GAME_STATE == "dead" then
        love.graphics.print("Vous avez perdu, veuillez appuyer sur R pour commencer une nouvelle partie.",
            config.MESSAGE_Y, y)
    end
end

function love.keypressed(key)
    handleKeyPress(key)
end
