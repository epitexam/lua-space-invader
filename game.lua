game = {
    enemies = {},
    balls = {},
    score = 0,
    frames = 0,
    stages = 6,
    enemiesPerStage = 11,
    currentMove = "left",
    moveDown = false
}

timeSinceLastCall = 0
nextCallDelay = math.random(1, 3)

function resetGame()
    game.enemies = {}
    game.balls = {}
    game.score = 0

    player.x = love.graphics.getWidth() /2
    player.y = love.graphics.getHeight() - 50
    player.alive = true

    generateEnemies()

    config.GAME_STATE = "play"
end

function countRemainingEnemies()
    local count = 0
    for _, column in ipairs(game.enemies) do
        count = count + #column
    end
    return count
end
