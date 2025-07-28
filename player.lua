player = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() - config.ELEMENT_SPACING,
    width = 20,
    height = 20,
    speed = 350,
    alive = true,
    cooldown = config.PLAYER_COOLDOWN,
    shootStatus = false
}

function updatePlayer(dt)
    local dx = 0
    if love.keyboard.isDown("left") then
        dx = -player.speed * dt
    elseif love.keyboard.isDown("right") then
        dx = player.speed * dt
    end

    player.x = math.max(0, math.min(player.x + dx, love.graphics.getWidth() - player.width))
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

function handleKeyPress(key)
    if key == "space" then
        if not player.shootStatus then
            generateBall(player, true)
            player.shootStatus = true
        end
    elseif key == "p" then
        if config.GAME_STATE == "play" then
            config.GAME_STATE = "pause"
        else
            config.GAME_STATE = "play"
        end
    elseif key == "r" and config.GAME_STATE == "dead" then
        resetGame()
    end
end
