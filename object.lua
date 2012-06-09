require 'field'

JUMP_STRENGTH = 4
GRAV_STRENGTH = 2
AIR_ACCEL = 1
FLOOR_SPEED = 1

function object(cx, cy, xrad, yrad, img, z)
    local o = {}
    o.cx = cx
    o.cy = cy
    o.xrad = xrad
    o.yrad = yrad
    o.img = img
    o.z = z or 0
    
    function o:update() return self end
    
    function o:render()
        render:add(textures[o.img], (o.cx - o.xrad - 1) * 128, (o.cy - o.yrad - 1) * 128, o.z, 255)
    end
    
    return o
end

function rigidbody(cx, cy, xrad, yrad, img, z, velx, vely, weight, grav)
    local o = object(cx, cy, xrad, yrad, img, z)
    o.rigid = true
    o.velx = velx or 0
    o.vely = vely or 0
    o.weight = weight or 1
    o.grav = grav or DOWN
    
    o.update = function(self, dt)
        local ax, ay = dirtodxy(o.grav)
        o.velx = o.velx + GRAV_STRENGTH * ax * dt
        o.vely = o.vely + GRAV_STRENGTH * ay * dt
        
        -- TODO: CHECK HERE IF WE TRAVERSE THROUGH A PORTAL
        o.cx = o.cx + o.velx * dt
        o.cy = o.cy + o.vely * dt
        
        return self
    end

    return o
end

function makeplayer(cx, cy)
    local p = rigidbody(cx, cy, 0.25, 0.25, "player.png", 999, 0, 0, 2, DOWN);
    
    p.onfloor = true
    --p.cx, p.cy = 2.5, 2.5
    --p.xrad, p.yrad = 0.25, 0.25
    --p.velx, p.vely = 0,0
    --p.weight = 2
    --p.grav = DOWN
    --p.z = 999
    --p.img = "player.png"
    
    
    -- TODO: KEY TO GRAB CRATE
    function p:move(dt)
        if kb.isDown('up') and self.onfloor then
            self.vely = self.vely - JUMP_STRENGTH/self.weight
            self.onfloor = false
        end 
        --if kb.isDown('down') then self.cy = self.cy + dt end
        if kb.isDown('left') then
            if self.onfloor then self.cx = self.cx - dt * AIR_ACCEL
            else self.velx = self.velx - dt * FLOOR_SPEED
            end
        end
        if kb.isDown('right') then
            if self.onfloor then self.cx = self.cx + dt * AIR_ACCEL
            else self.velx = self.velx + dt * FLOOR_SPEED
            end
        end
    end

    return p
end

player = makeplayer(2.5, 2.5)

o1 = rigidbody(3.5, 1.5, 0.0625, 0.0625, "crate.png", 1, 0, 0, 1, DOWN)
o2 = rigidbody(3.5, 3.5, 0.0625, 0.0625, "crate.png", 1, 0, 0, 1, UP)
o3 = object(2.5, 1.5, 0.0625, 0.0625, "crate.png", 1)

objects = {player, o1, o2, o3}

function collide(r1, r2)
    if (r1.rigid and r2.rigid) then
    
        if (math.abs(r1.cx - r2.cx) <= r1.xrad + r2.xrad and math.abs(r1.cy - r2.cy) <= r1.yrad + r2.yrad) then

            local xoffset = (math.abs(r1.cx - r2.cx) - (r1.xrad + r2.xrad))/2 -- is negative
            local yoffset = (math.abs(r1.cy - r2.cy) - (r1.yrad + r2.yrad))/2 -- is negative

            --print(xoffset, yoffset)

            if math.abs(xoffset) < math.abs(yoffset) then       
                local v = (r1.weight * r1.velx + r2.weight * r2.velx) / (r1.weight + r2.weight)
                r1.velx = v
                r2.velx = v

                if r1.cx < r2.cx then
                    r1.cx = r1.cx + xoffset -- cx gets decreased (moves left)
                    if r1.grav == RIGHT then r1.onfloor = true end
                    r2.cx = r2.cx - xoffset -- cx gets increased (moves right)
                    if r2.grav == LEFT then r2.onfloor = true end
                end
            else
                local v = (r1.weight * r1.vely + r2.weight * r2.vely) / (r1.weight + r2.weight)
                r1.vely = v
                r2.vely = v

                if r1.cy < r2.cy then
                    r1.cy = r1.cy + yoffset -- cy gets decreased (moves up)
                    if r1.grav == DOWN then r1.onfloor = true end
                    r2.cy = r2.cy - yoffset -- cy gets increased (moves down)
                    if r2.grav == UP then r2.onfloor = true end
                end
            end
        end
    end
end

fieldInit()
wurstfield = field

function collidecell(r, nx, ny)
    
    local curcell = wurstfield:get(nx,ny)
    
    if curcell.colTop == true then
        local wall = rigidbody(nx+0.5, ny, 0.5, 0.03125, "crate.png", 0, 0, 0, 99999999, DOWN)
        collide(r,wall)
    end

    if curcell.colLeft == true then
        local wall = rigidbody(nx, ny+0.5, 0.03125, 0.5, "crate.png", 0, 0, 0, 99999999, DOWN)
        collide(r,wall)
    end
end

function collidewall(r)
    local wx = math.floor(r.cx)
    local wy = math.floor(r.cy)
    
    -- TODO: TAKE NEW ORIENTATION INTO ACCOUNT
    collidecell(r, wx, wy)
    nx,ny = wurstfield:go(wx,wy,DOWN)
    collidecell(r, nx, ny)
    nx,ny = wurstfield:go(wx,wy,UP)
    collidecell(r, nx, ny)
    nx,ny = wurstfield:go(wx,wy,LEFT)
    collidecell(r, nx, ny)
    nx,ny = wurstfield:go(wx,wy,RIGHT)
    collidecell(r, nx, ny)
    nx,ny = wurstfield:go(wx,wy,RIGHT)
    nx,ny = wurstfield:go(nx,ny,UP)
    collidecell(r, nx, ny)
    nx,ny = wurstfield:go(wx,wy,RIGHT)
    nx,ny = wurstfield:go(nx,ny,DOWN)
    collidecell(r, nx, ny)
    nx,ny = wurstfield:go(wx,wy,LEFT)
    nx,ny = wurstfield:go(nx,ny,DOWN)
    collidecell(r, nx, ny)
    nx,ny = wurstfield:go(wx,wy,LEFT)
    nx,ny = wurstfield:go(nx,ny,UP)
    collidecell(r, nx, ny)
    
end
