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
    ENEMY_MOVE_FRAME = 6,
    FRAME_LIMIT = 60,
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
    lives = 3,
    alive = true
}

function love.load()
    generateFirstsEnemies()
end

function collision(a, b)
    return not (a.x > b.x + b.width or
               b.x > a.x + a.width or
               a.y > b.y + b.height or
               b.y > a.y + a.height)
end

function checkEnemyCollisions()
    local toRemoveBalls = {}
    local toRemoveEnemies = {}
    
    for i, ball in ipairs(game.balls) do
        if ball.friendly then
            for j, enemy in ipairs(game.enemies) do
                if collision(ball, enemy) then
                    table.insert(toRemoveBalls, i)
                    table.insert(toRemoveEnemies, j)
                    game.score = game.score + enemy.point
                    break
                end
            end
        end
    end

    for i = #toRemoveEnemies, 1, -1 do
        table.remove(game.enemies, toRemoveEnemies[i])
    end

    for i = #toRemoveBalls, 1, -1 do
        table.remove(game.balls, toRemoveBalls[i])
    end
end

function checkPlayerCollisions()
    for i, ball in ipairs(game.balls) do
        if not ball.friendly and collision(ball, player) then
            player.alive = false
            table.remove(game.balls, i)
            break
        end
    end
end

function generateFirstsEnemies()
    local startX = 150
    local startY = 50
    local spacingX = 55
    local spacingY = 50
    local totalEnemies = game.stages * game.enemiesPerStage

    for row = 0, game.stages - 1 do
        for col = 0, game.enemiesPerStage - 1 do
            local x = startX + col * spacingX
            local y = startY + row * spacingY
            local stage = row + 1
            generateEnemy(x, y, stage, totalEnemies)
        end
    end
end

function cleanMunition()
    for i = #game.balls, 1, -1 do
        if game.balls[i].y < 0 or game.balls[i].y > love.graphics.getHeight() then
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

function generateBall(element, friendly, reverse)
    local ball = createEntity(friendly and (element.x + element.width / 2) or (element.x + element.width / 3), element.y,5, 20, friendly and 200 or 140)
    ball.friendly = friendly
    ball.reverse = reverse

    table.insert(game.balls, ball)
end

function generateEnemy(x, y, stage, point)
    local enemy = createEntity(x, y, 30, 30, 20 + (stage - 1) * 10)
    enemy.stage = stage
    enemy.point = 10 * stage

    table.insert(game.enemies, enemy)
end

function love.keypressed(key)
    if key == "space" then
        generateBall(player, true, false)
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
    
    for i = 1, #game.enemies do
        local enemy = game.enemies[i]
        enemy.x = enemy.x + dx
        enemy.y = enemy.y + dy
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
    local windowWidth = love.graphics.getWidth()
    local margin = config.MESSAGE_Y

    for _, enemy in ipairs(game.enemies) do
        if enemy.x <= margin then
            game.currentMove = "right"
            game.moveDown = true
            break
        elseif enemy.x >= (windowWidth - margin) then
            game.currentMove = "left"
            game.moveDown = true
            break
        end
    end
end

function enemiesShootBehavior()
end

function love.update(dt)

    game.frames = game.frames + 1

    if game.frames == config.MAX_FRAME then  
        moveEnemies(game.currentMove, 5)
        game.frames = 0

        if game.moveDown then
            game.moveDown = false
            moveEnemies("down", 10)
        end
    end

    enemiesShootBehavior()
    enemiesMovementBehavior()
    updatePlayer(dt)
    updateBalls(dt)
    checkEnemyCollisions()
    checkPlayerCollisions()
    cleanMunition()
end

function love.draw()
    love.graphics.print("Player Y: " .. player.y, config.MESSAGE_Y, 10)
    love.graphics.print("Player X: " .. player.x, config.MESSAGE_Y, 30)
    love.graphics.print("Number of munitions shot: " .. #game.balls, config.MESSAGE_Y, 50)
    love.graphics.print("Number of enemies: " .. #game.enemies, config.MESSAGE_Y, 70)
    love.graphics.print("Score : " .. game.score, 40, 550)
    love.graphics.print("Current Move: " .. game.currentMove, config.MESSAGE_Y, 110)
    love.graphics.print("limitFrame: " .. config.FRAME_LIMIT, config.MESSAGE_Y, 130)
    love.graphics.print("config.ENEMY_MOVE_FRAME: " .. config.ENEMY_MOVE_FRAME, config.MESSAGE_Y, 150)
    love.graphics.print("percentage of enemies left : " .. (#game.enemies / game.stages * game.enemiesPerStage) .. "%", config.MESSAGE_Y, 170)
    love.graphics.print("Player is alive ? : " .. tostring(player.alive), config.MESSAGE_Y, 190)
    love.graphics.print("FPS: " .. love.timer.getFPS(), config.MESSAGE_Y, 210)

    for i, v in ipairs(game.enemies) do
        if v.x and v.y and v.width and v.height then
            love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
        else
            love.graphics.print("Invalid enemy data at index " .. i, 200, 200)
        end
    end

    for i, v in ipairs(game.balls) do
        love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
    end

    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end
