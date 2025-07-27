function generateEnemies()
    local startX, startY = 150, 50
    local spacingX, spacingY = 55, 50

    for x = 0, game.enemiesPerStage - 1 do
        local column = {}
        for y = 0, game.stages - 1 do
            local ex = startX + x * spacingX
            local ey = startY + y * spacingY
            generateEnemy(ex, ey, y, column)
        end
        table.insert(game.enemies, column)
    end
end

function generateEnemy(x, y, stage, list)
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

    for _, column in ipairs(game.enemies) do
        for _, enemy in ipairs(column) do
            enemy.x = enemy.x + dx
            enemy.y = enemy.y + dy
        end
    end
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

function checkEnemyCollisions()
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
