local listOfEnemy
local listOfBalls
local timer
local nextTriggerTime
local minDelay
local maxDelay
local player
local score
local frames
local limitFrames
local moveIndex
local stages
local enemy_per_stage
local moveFrame
local listOfMove = { "right", "right", "down", "down", "left", "left", "up", "up" }

function love.load()
    listOfEnemy = {}
    listOfBalls = {}

    moveIndex = 1
    frames = 0
    stages = 5
    enemy_per_stage = 10
    moveFrame = 6
    limitFrames = 60
    score = 0

    timer = 0
    nextTriggerTime = 0
    minDelay = 1
    maxDelay = 3

    player = {}
    player.x = 400
    player.y = 530
    player.width = 20
    player.height = 20
    player.speed = 350
    player.alive = true

    generateFirstsEnemies()
end

function collision(a, b)
    return a.x < b.x + b.width and
        b.x < a.x + a.width and
        a.y < b.y + b.height and
        b.y < a.y + a.height
end

function checkCollision()
    for i = #listOfBalls, 1, -1 do
        local ball = listOfBalls[i]
        if ball.friendly then
            for j = #listOfEnemy, 1, -1 do
                local enemy = listOfEnemy[j]
                if collision(ball, enemy) then
                    if player.alive then
                        score = score + enemy.point
                    end
                    table.remove(listOfBalls, i)
                    table.remove(listOfEnemy, j)
                    break
                end
            end
        else
            if collision(ball, player) then
                player.alive = false
            end
        end
    end
end

function generateFirstsEnemies()
    local startX = 150
    local startY = 50
    local spacingX = 55
    local spacingY = 50
    local totalEnemies = stages * enemy_per_stage

    for row = 0, stages - 1 do
        for col = 0, enemy_per_stage - 1 do
            local x = startX + col * spacingX
            local y = startY + row * spacingY
            local stage = row + 1
            generateEnemy(x, y, stage, totalEnemies)
        end
    end
end

function cleanMunition()
    for index, value in ipairs(listOfBalls) do
        if value.y < 0 or value.y > love.graphics.getHeight() then
            table.remove(listOfBalls, index)
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

function generateMunition(element, friendly, reverse)
    local ball = createEntity(friendly and (element.x + element.width / 2) or (element.x + element.width / 3), element.y,
        5, 20, friendly and 200 or 140)
    ball.friendly = friendly
    ball.reverse = reverse

    table.insert(listOfBalls, ball)
end

function generateEnemy(x, y, stage, point)
    local enemy = createEntity(x, y, 30, 30, 20 + (stage - 1) * 10)
    enemy.stage = stage
    enemy.point = point * stage

    table.insert(listOfEnemy, enemy)
end

function resetTriggerTime()
    nextTriggerTime = love.math.random(minDelay, maxDelay)
    timer = 0
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

    if frames == limitFrames * moveFrame then
        local totalEnemies = stages * enemy_per_stage

        if #listOfEnemy > 0 then
            local enemyRatio = #listOfEnemy / totalEnemies
            local minFrame = 1
            local maxFrame = 6
            moveFrame = math.max(minFrame, math.floor(minFrame + (maxFrame - minFrame) * enemyRatio))
        end

        moveEnemies(listOfMove[moveIndex], 20)
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
    cleanMunition()
end

function love.draw()
    love.graphics.print("Player Y: " .. player.y, 50, 10)
    love.graphics.print("Player X: " .. player.x, 50, 30)
    love.graphics.print("Number of munitions shot: " .. #listOfBalls, 50, 50)
    love.graphics.print("Number of enemies: " .. #listOfEnemy, 50, 70)
    love.graphics.print("Score : " .. score, 60, 550)
    love.graphics.print("Temps restant avant le prochain déclenchement: " .. math.floor(nextTriggerTime - timer) .. "s",
        50, 90)
    love.graphics.print("Next move: " .. listOfMove[moveIndex], 50, 110)
    love.graphics.print("limitFrame: " .. limitFrames, 50, 130)
    love.graphics.print("moveFrame: " .. moveFrame, 50, 150)
    love.graphics.print("percentage of enemies left : " .. (#listOfEnemy / stages * enemy_per_stage) .. "%", 50, 170)
    love.graphics.print("Player is alive ? : " .. tostring(player.alive), 50, 190)

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
