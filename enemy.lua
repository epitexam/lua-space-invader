function generateEnemies()
    local spacingX, spacingY = 55, 50
    local screenWidth = love.graphics.getWidth()
    local totalWidth = (game.enemiesPerStage - 1) * spacingX

    local startX = (screenWidth / 2) - (totalWidth / 2)
    local startY = 50

    for col = 0, game.enemiesPerStage - 1 do
        for row = 0, game.stages - 1 do
            local ex       = startX + col * spacingX
            local ey       = startY + row * spacingY
            local newEnemy = createEnemy(ex, ey, row, col)
            table.insert(game.enemies, newEnemy)
        end
    end
end

function createEnemy(x, y, row, col)
    local enemy = createEntity(x, y, 30, 30, 20 + (row - 1) * 10)
    enemy.row = row
    enemy.col = col
    enemy.point = (row == 0 and 30) or (row <= 2 and 20) or 10
    return enemy
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

    for _, enemy in ipairs(game.enemies) do
        enemy.x = enemy.x + dx
        enemy.y = enemy.y + dy
    end
end

function enemiesMovementBehavior()
    local leftLimit, rightLimit = config.MESSAGE_Y, love.graphics.getWidth() - config.MESSAGE_Y

    for _, enemy in ipairs(game.enemies) do
        if enemy then
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
    local shooters = getLowestEnemiesByColumn()
    for _, enemy in pairs(shooters) do
        generateBall(enemy, false)
    end
end

function getLowestEnemiesByColumn()
    local lowestByCol = {}

    for _, enemy in ipairs(game.enemies) do
        local col = enemy.col
        if not lowestByCol[col] or enemy.y > lowestByCol[col].y then
            lowestByCol[col] = enemy
        end
    end

    return lowestByCol
end

function checkEnemyCollisions()
    for i = #game.balls, 1, -1 do
        local ball = game.balls[i]
        if ball.friendly then
            for j = #game.enemies, 1, -1 do
                local enemy = game.enemies[j]
                if collision(ball, enemy) then
                    game.score = game.score + enemy.point
                    table.remove(game.enemies, j)
                    table.remove(game.balls, i)
                    break
                end
            end
        end
    end
end
