function collision(a, b)
    return not (a.x > b.x + b.width or
               b.x > a.x + a.width or
               a.y > b.y + b.height or
               b.y > a.y + a.height)
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
