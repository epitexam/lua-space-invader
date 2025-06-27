local listOfEnemy
local listOfBalls
local timer
local nextTriggerTime
local minDelay
local maxDelay
local player
local score
local frames

local moveIndex
local listOfMove = { "right", "down", "left", "up" }

function love.load()
    listOfEnemy = {}
    listOfBalls = {}

    moveIndex = 1
    frames = 0
    score = 0

    timer = 0
    nextTriggerTime = 0
    minDelay = 1
    maxDelay = 3

    player = {}

    player.x = 400
    player.y = 530
    player.width = 50
    player.height = 50
    player.speed = 350
    player.alive = true

    generateFirstsEnemies()
end

function checkCollision()
    for x, ball in ipairs(listOfBalls) do
        if ball.friendly then
            for z, enemy in ipairs(listOfEnemy) do
                if enemy.x <= ball.x + ball.width and ball.x <= enemy.x + enemy.width and enemy.y <= ball.y + ball.height and ball.y <= enemy.y + enemy.height then
                    if ball.friendly then
                        score = score + enemy.point
                        table.remove(listOfBalls, x)
                        table.remove(listOfEnemy, z)
                    end
                end
            end
        else

        end
    end
end

function generateFirstsEnemies()
    local enemy_x_pos = 150
    local enemy_y_pos = 50
    local stages = 5
    local enemy_per_stage = 10

    for i = 1, stages, 1 do
        for x = 1, enemy_per_stage, 1 do
            generateEnemy(enemy_x_pos, enemy_y_pos, i, (stages * enemy_per_stage))
            enemy_x_pos = enemy_x_pos + 50
        end
        enemy_x_pos = 150
        enemy_y_pos = enemy_y_pos + 50
    end
end

function cleanMunition(listOfBalls)
    for index, value in ipairs(listOfBalls) do
        if value.y < 0 or value.y > love.graphics.getHeight() then
            table.remove(listOfBalls, index)
        end
    end
end

function generateMunition(element, friendly, reverse)
    local ball = {}

    ball.x = element.x + (element.width / 2)
    ball.y = element.y
    ball.width = 5
    ball.height = 20

    if friendly then
        ball.speed = 550
    else
        ball.speed = 600
    end
    ball.friendly = friendly
    ball.reverse = reverse

    table.insert(listOfBalls, ball)
end

function generateEnemy(x, y, stage, point)
    local enemy = {}

    enemy.x = x
    enemy.y = y
    enemy.width = 30
    enemy.height = 30
    enemy.speed = 100
    enemy.stage = stage
    enemy.point = point * stage

    table.insert(listOfEnemy, enemy)
end

function resetTriggerTime()
    nextTriggerTime = love.math.random(minDelay, maxDelay)
    timer = 0 -- Réinitialise le timer
end

function love.keypressed(key)
    if key == "space" then
        generateMunition(player, true, false)
    end
end

function moveEnemies(move, padding)
    for index, value in ipairs(listOfEnemy) do
        if listOfEnemy[index] then
            if move == "left" then
                listOfEnemy[index].x = listOfEnemy[index].x - padding
            elseif move == "right" then
                listOfEnemy[index].x = listOfEnemy[index].x + padding
            elseif move == "up" then
                listOfEnemy[index].y = listOfEnemy[index].y - padding
            elseif move == "down" then
                listOfEnemy[index].y = listOfEnemy[index].y + padding
            end
        end
    end
end

function love.update(dt)
    frames = frames + 1
    for i, v in ipairs(listOfBalls) do
        if v.reverse then
            v.y = v.y + v.speed * dt
        else
            v.y = v.y - v.speed * dt
        end
    end

    timer = timer + dt

    if frames == 30 then
        moveEnemies(listOfMove[moveIndex], 15)

        if moveIndex > #listOfMove - 1 then
            moveIndex = 1
        else
            moveIndex = moveIndex + 1
        end

        frames = 0
    end

    if timer >= nextTriggerTime then
        for i = #listOfEnemy - 9, #listOfEnemy do
            if (listOfEnemy[i]) then
                generateMunition(listOfEnemy[i], false, true)
            end
        end
        resetTriggerTime()
    end

    if love.keyboard.isDown("right") then
        if player.x < (love.graphics.getWidth() - player.width) then
            player.x = math.max(0, player.x + player.speed * dt)
        end
    end

    if love.keyboard.isDown("left") then
        if player.x > 0 then
            player.x = math.max(0, player.x - player.speed * dt)
        end
    end

    checkCollision()
    cleanMunition(listOfBalls)
end

function love.draw(dt)
    love.graphics.print("Player Y: " .. player.y, 50, 10)
    love.graphics.print("Player X: " .. player.x, 50, 20)
    love.graphics.print("Number of munitions shot: " .. #listOfBalls, 50, 30)
    love.graphics.print("Number of enemies: " .. #listOfEnemy, 50, 40)
    love.graphics.print("Score : " .. score, 60, 550)
    love.graphics.print("Temps restant avant le prochain déclenchement: " .. math.floor(nextTriggerTime - timer) .. "s",
        50, 50)
    love.graphics.print("Next move: " .. listOfMove[moveIndex], 50, 80)

    for i, v in ipairs(listOfEnemy) do
        if v.x and v.y and v.width and v.height then
            love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
        else
            love.graphics.print("Invalid enemy data at index " .. i, 200, 200)
        end
    end

    for i, v in ipairs(listOfBalls) do
        love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
    end

    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end
