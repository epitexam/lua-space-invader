local timeSinceLastCall = 0
local nextCallDelay = math.random(1, 3)

local game = {
    enemies = {},
    balls = {},
    score = 0,
    frames = 0,
    stages = 6,
    enemiesPerStage = 11,
    currentMove = "left",
    moveDown = false
}

local config = {
    GAME_STATE = "play",
    MAX_FRAME = 100,
    MIN_SHOOT_DELAY = 1,
    MAX_SHOOT_DELAY = 3,
    MESSAGE_Y = 50
}

local player = {
    x = love.graphics.getWidth() /2,
    y = love.graphics.getHeight() - 50,
    width = 20,
    height = 20,
    speed = 350,
    alive = true
}

function resetGame()
    game.enemies = {}
    game.balls = {}
    game.score =0 

    player.x = love.graphics.getWidth() /2
    player.y = love.graphics.getHeight() - 50
    player.alive = true

    generateEnemies()

    config.GAME_STATE = "play"
end

function love.load()
    generateEnemies()
    math.randomseed(os.time())
end

function collision(a, b)
    return not (a.x > b.x + b.width or
               b.x > a.x + a.width or
               a.y > b.y + b.height or
               b.y > a.y + a.height)
end

function checkEnemyCollisions()
    local toRemoveBalls = {}
    
    for i = #game.balls, 1, -1 do
        local ball = game.balls[i]
        if ball.friendly then
            for col = 1, #game.enemies do
                local column = game.enemies[col]
                for row = 1, #column do
                    local enemy = column[row]
                    if collision(ball, enemy) then
                        game.score = game.score + enemy.point
                        table.remove(column, row)
                        table.remove(game.balls, i)
                        break
                    end
                end
            end
        end
    end
end

function countRemainingEnemies()
    local count = 0
    for _, column in ipairs(game.enemies) do
        count = count + #column
    end
    return count
end


function checkPlayerCollisions()
    for i, ball in ipairs(game.balls) do
        if not ball.friendly and collision(ball, player) then
            player.alive = false
            config.GAME_STATE = "dead"
            table.remove(game.balls, i)
            break
        end
    end
end

function generateEnemies()
    local startX, startY = 150, 50
    local spacingX, spacingY = 55, 50

    for x = 0, game.enemiesPerStage - 1 do
        local column = {}
        for y = 0, game.stages - 1 do
            local ex = startX + x * spacingX
            local ey = startY + y * spacingY
            generateEnemy(ex, ey, y,column)
        end
        table.insert(game.enemies, column)
    end
end

function removeOffscreenProjectiles()
    local screenHeight = love.graphics.getHeight()
    for i = #game.balls, 1, -1 do
        local y = game.balls[i].y
        if y < -50 or y > screenHeight + 50 then
            table.remove(game.balls, i)
        end
    end
end

function createEntity(x, y, width, height, speed)
    return {
        x = x,
        y = y,
        width = width,
        height = height,
        speed = speed or 0
    }
end

function updateBalls(dt)
    for _, ball in ipairs(game.balls) do
        local direction = ball.reverse and 1 or -1
        ball.y = ball.y + direction * ball.speed * dt
    end
end

function generateBall(source, friendly)
    local xOffset = friendly and source.width / 2 or source.width / 3
    local speed = friendly and 200 or 140

    local ball = createEntity(source.x + xOffset, source.y, 5, 20, speed)
    ball.friendly = friendly
    ball.reverse = not friendly
    table.insert(game.balls, ball)
end
function generateEnemy(x, y, stage,list)
    local enemy = createEntity(x, y, 30, 30, 20 + (stage - 1) * 10)
    enemy.stage = stage
    
    if stage == 0 then
        enemy.point = 30
    elseif stage <= 2 then
        enemy.point = 20
    else
        enemy.point = 10
    end

    table.insert(list, enemy)
end

function love.keypressed(key)
    if key == "space" then
        generateBall(player, true)
    end

    if key == "p" then
        print(config.GAME_STATE)
        if config.GAME_STATE == "play" then
            config.GAME_STATE = "pause"
        else
            config.GAME_STATE = "play"
        end
    end

    if key == "r" then
        print(config.GAME_STATE)
        if config.GAME_STATE == "dead" then
            resetGame()
        end
    end
end

function moveEnemies(move, padding)
    local dx, dy = 0, 0
    
    if move == "left" then
        dx = -padding
    elseif move == "right" then
        dx = padding
    elseif move == "up" then
        dy = -padding
    elseif move == "down" then
        dy = padding
    end
    
    for _, enemiesColumn in ipairs(game.enemies) do
        for _, enemy in ipairs(enemiesColumn) do
            enemy.x = enemy.x + dx
            enemy.y = enemy.y + dy
        end
    end
end

function updatePlayer(dt)
    local dx = 0
    if love.keyboard.isDown("left") then
        dx = -player.speed * dt
    elseif love.keyboard.isDown("right") then
        dx = player.speed * dt
    end

    player.x = math.max(0, math.min(player.x + dx, love.graphics.getWidth() - player.width))
end

function enemiesMovementBehavior()
    local leftLimit, rightLimit = config.MESSAGE_Y, love.graphics.getWidth() - config.MESSAGE_Y

    for _, column in ipairs(game.enemies) do
        for _, enemy in ipairs(column) do
            if enemy.x <= leftLimit then
                game.currentMove = "right"
                game.moveDown = true
                return
            elseif enemy.x >= rightLimit then
                game.currentMove = "left"
                game.moveDown = true
                return
            end
        end
    end
end

function enemiesShootBehavior()
    for _, column in ipairs(game.enemies) do
        local shooter = column[#column]
        if shooter then
            generateBall(shooter, false)
        end
    end
end

function love.update(dt)
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

    love.graphics.print("Ennemis restants : " .. countRemainingEnemies(), config.MESSAGE_Y, y); y = y + dy
    love.graphics.print("Score : " .. game.score, config.MESSAGE_Y, y); y = y + dy
    love.graphics.print("FPS: " .. love.timer.getFPS(), config.MESSAGE_Y, y); y = y + dy


    if config.GAME_STATE == "play" or config.GAME_STATE == "pause" then
        for i, v in ipairs(game.balls) do
            love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
        end

        love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)


        for i, enemiesColumn in ipairs(game.enemies) do
            for y, v in ipairs(enemiesColumn) do
                if v.x and v.y and v.width and v.height then
                    love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
                end
            end
        end
    end

    if config.GAME_STATE == "pause" then
        love.graphics.print("Le jeu est en pause, veuillez appuyer sur la touche 'P' pour continuer à jouer.",config.MESSAGE_Y, y); y = y + dy
    end

    if config.GAME_STATE == "dead" then
        love.graphics.print("Vous avez perdu, veuillez appuyer sur R pour commencer une nouvelle partie.",config.MESSAGE_Y, y); y = y + dy
    end

end