Entity = Object:extend()

function Entity:new(x, y, image_path, imageScale)
    self.imageScale = imageScale
    self.x = x
    self.y = y
    self.image = love.graphics.newImage(image_path)
    self.width = self.image:getWidth() * self.imageScale
    self.height = self.image:getHeight() * self.imageScale

    self.last = {}
    self.last.x = self.x
    self.last.y = self.y

    self.strength = 0
    self.tempStrength = 0
    self.gravity = 0
    self.weight = 400
end

function Entity:update(dt)
    self.last.x = self.x
    self.last.y = self.y
    self.tempStrength = self.strength
    self.gravity = self.gravity + self.weight * dt * 2
    self.y = self.y + self.gravity * dt
end

function Entity:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.imageScale, self.imageScale)
end

function Entity:checkCollision(e)
    return self.x + self.width > e.x
    and self.x < e.x + e.width
    and self.y + self.height > e.y
    and self.y < e.y + e.height
end

function Entity:wasVerticallyAligned(e)
    return self.last.y < e.last.y + e.height and self.last.y + self.height > e.last.y
end

function Entity:wasHorizontallyAligned(e)
    return self.last.x < e.last.x + e.width and self.last.x + self.width > e.last.x
end

function Entity:resolveCollision(e)
    if self.tempStrength > e.tempStrength then
        return e:resolveCollision(self)
    end
    if self:checkCollision(e) then
        self.tempStrength = e.tempStrength
        if self:wasVerticallyAligned(e) then
            if self.x + self.width/2 < e.x + e.width/2  then
                self:collide(e, "left")
            else
                self:collide(e, "right")
            end
        elseif self:wasHorizontallyAligned(e) then
            if self.y + self.height/2 < e.y + e.height/2 then
                self:collide(e, "above")
            else
                self:collide(e, "below")
            end
        end
        return true
    end
    return false
end

function Entity:collide(other, fromDirection)
    if fromDirection == "above" then
        local pushback = self.y + self.height - other.y
        self.y = self.y - pushback
        self.gravity = 0
    elseif fromDirection == "below" then
        local pushback = other.y + other.height - self.y
        self.y = self.y + pushback
    elseif fromDirection == "left" then
        local pushback = self.x + self.width - other.x
        self.x = self.x - pushback
    elseif fromDirection == "right" then
        local pushback = other.x + other.width - self.x
        self.x = self.x + pushback
    end
end