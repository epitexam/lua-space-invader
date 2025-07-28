game = {
    enemies = {},
    balls = {},
    score = 0,
    frames = 0,
    stages = 5,
    enemiesPerStage = 10,
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
    player.y = love.graphics.getHeight() - config.ELEMENT_SPACING
    player.alive = true

    generateEnemies()

    config.GAME_STATE = "play"
end