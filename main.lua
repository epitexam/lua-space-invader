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
        if player.cooldown == 0 then
            player.cooldown = config.PLAYER_COOLDOWN
            player.shootStatus = false
        else
            player.cooldown = player.cooldown - 1
        end
    end
    if config.GAME_STATE == "play" then
        game.frames = game.frames + 1

        if game.frames == config.MAX_FRAME then
            moveEnemies(game.currentMove, config.ENEMY_HORIZONTAL_MOVE)
            game.frames = 0

            if game.moveDown then
                moveEnemies("down", config.ENEMY_VERTICAL_MOVE)
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
        enemyReachedPlayer()
    end
end

function love.draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", config.MESSAGE_Y - 10, config.MESSAGE_Y - 10, 250, 80)

    love.graphics.setColor(1, 1, 1, 1)
    local y = config.MESSAGE_Y
    local dy = 20
    love.graphics.print("Ennemis restants : " .. #game.enemies, config.MESSAGE_Y, y); y = y + dy
    love.graphics.print("Score : " .. game.score, config.MESSAGE_Y, y); y = y + dy
    love.graphics.print("FPS: " .. love.timer.getFPS(), config.MESSAGE_Y, y); y = y + dy

    if config.GAME_STATE == "play" or config.GAME_STATE == "pause" then
        for _, v in ipairs(game.balls) do
            if v.friendly then
                love.graphics.setColor(0.2, 0.8, 1)
            else
                love.graphics.setColor(1, 0.2, 0.2)
            end
            love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
        end

        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

        for _, enemy in ipairs(game.enemies) do
            love.graphics.setColor(1, 1, 0.2)
            love.graphics.rectangle("line", enemy.x, enemy.y, enemy.width, enemy.height)
        end
    end

    if config.GAME_STATE == "pause" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Jeu en pause\nAppuyez sur 'P' pour continuer", 0, screenHeight / 2 - 20, screenWidth,
            "center")
    elseif config.GAME_STATE == "dead" then
        love.graphics.setColor(1, 0.4, 0.4)
        love.graphics.printf("Vous avez perdu\nAppuyez sur 'R' pour recommencer", 0, screenHeight / 2 - 20, screenWidth,
            "center")
    end

    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
    handleKeyPress(key)
end
