function generateBall(source, friendly)
    local xOffset = friendly and source.width / 2 or source.width / 3
    local speed = friendly and 200 or 140

    local ball = createEntity(source.x + xOffset, source.y, 5, 20, speed)
    ball.friendly = friendly
    ball.reverse = not friendly
    table.insert(game.balls, ball)
end

function updateBalls(dt)
    for _, ball in ipairs(game.balls) do
        local direction = ball.reverse and 1 or -1
        ball.y = ball.y + direction * ball.speed * dt
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
