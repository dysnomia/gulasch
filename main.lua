require 'shortcut'
require 'render'
require 'textures'

function love.load()
    -- print("Test")
    loadTextures()
    isPaused = false
    
    ps = gr.newParticleSystem(textures["particle.png"], 32)
    ps:setEmissionRate(100)
    ps:setParticleLife(0.5,5)
    ps:setRadialAcceleration(100,500)
    ps:setTangentialAcceleration(100,400)
    ps:setSizeVariation(1)
    ps:setSpread(2*math.pi)
    ps:setSpeed(1,5)
    ps:setSpin(0,2*math.pi,1)
    ps:start()
end

function love.draw()
    gr.setBackgroundColor(0, 0, 0)
    gr.clear()
    gr.print(timer.getFPS(),10,10,0,1,1)
    --gr.print("Hello World", 400, 300)
    --gr.draw(ps, 100, 100)
   
    render:add(textures["particle.png"], 90, 90, 1, 200)
    render:add(textures["particle.png"], 100, 100, 0, 150)
    render:add(textures["particle.png"], 110, 110, -1, 255)
    --render:add(ps, 200, 200, 0, 1)
    render:draw()
end

cnt = 0

function love.update(dt)
    if isPaused then
        return
    end
    
    ps:update(dt)
    
    --if love.keyboard.isDown("up") then
        cnt = cnt + 1
        print(cnt)
    --end
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end

function love.keypressed(key, unicode)

end

function love.focus(f)
    isPaused = not f
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end
