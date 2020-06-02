push =require ("push")
Class=require("class")

require("Paddle")
require("Ball")

WINDOW_HEIGHT=720
WINDOW_WIDTH=1280

VIRTUAL_WIDTH=432
VIRTUAL_HEIGHT=243

PADDLE_SPEED=100

function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")

    font=love.graphics.newFont("font.TTF",8)
    scoreFont=love.graphics.newFont("font.TTF",32)
    victoryFont=love.graphics.newFont("font.TTF",24)
   
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT, WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen=false,
        vsync=true,
        resizable=true
    })

    sounds={
        ["paddle_hit"]=love.audio.newSource("paddle_hit.wav","static"),
        ["point_hit"]=love.audio.newSource("point_hit.wav","static"),
        ["wall_hit"]=love.audio.newSource("wall_hit.wav","static")
    }
    
    player1Score=0
    player2Score=0

    math.randomseed(os.time())
    servingPlayer=math.random(2)==1 and 1 or 2
    winningPlayer=0
    winningScore=2

    paddle1=Paddle(5,20,5,20)
    paddle2=Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT-40,5,20)

    ball=Ball(VIRTUAL_WIDTH/2-2,VIRTUAL_HEIGHT/2-2,5,5)

    if servingPlayer==1 then
        ball.dx=100
    else
        ball.dx=-100
    end        

    gameState="start"

end 


function love.resize(width,height)
    push:resize(width,height)
end
function love.update(dt)

    --[[  for paddle  ]]
    paddle1:update(dt)
    paddle2:update(dt)
    --[[ for paddle 1  ]]
    if love.keyboard.isDown("w") then
        paddle1.dy=-PADDLE_SPEED
    elseif love.keyboard.isDown("s") then
        paddle1.dy=PADDLE_SPEED
    else 
        paddle1.dy=0        
    end   

    --[[ for ball   ]]
    if gameState=="play" then
        ball:update(dt)
     
        paddle2.y=math.min(ball.y,VIRTUAL_HEIGHT-paddle2.height)
                           --[[ for collision   ]]
        --[[  for collision through paddle ]]
        if ball:collide(paddle1) then
            ball.dx = - ball.dx
            sounds["paddle_hit"]:play()
        end
        
        if ball:collide(paddle2) then
            ball.dx = - ball.dx
            sounds["paddle_hit"]:play()
        end
            --[[ for collision through upper and lower edges ]]
        if ball.y <=0 then
            ball.dy = -ball.dy 
            ball.y=0
            sounds["wall_hit"]:play()
        end
        
        if ball.y + ball.height >= VIRTUAL_HEIGHT then 
            ball.dy = - ball.dy
            ball.y=VIRTUAL_HEIGHT- ball.height
            sounds["wall_hit"]:play()
        end    
    
        if ball.x <=0 then
            player2Score= player2Score +1
            servingPlayer=1
            sounds["point_hit"]:play()
            if player2Score ==winningScore then
                gameState="victory"
                winningPlayer=2
            else 
                gameState="serve"
            end    
            
            ball:reset()
            ball.dx=100
        end
        
        if ball.x >=VIRTUAL_WIDTH-4 then
            player1Score=player1Score +1
            servingPlayer=2
            sounds["point_hit"]:play()
            if player1Score ==winningScore then
                gameState="victory"
                winningPlayer=1
            else 
                gameState="serve"
            end    

            ball:reset()
            ball.dx=-100
        end   
    end 

end    

function love.keypressed(key)
    if key=="escape" then
        love.event.quit()
    elseif key=="enter" or key=="return" then
        if gameState=="start"    then
            gameState="serve"
        elseif gameState=="serve"  then
            gameState="play"
        elseif gameState=="victory" then
            gameState="start"  
            player1Score=0
            player2Score=0  
        end    
    end        
end    

function love.draw()
    push:apply("start")
        
    love.graphics.clear(40/255,45/255,52/255,1)
    
    love.graphics.setFont(scoreFont)

    --[[   for players score    ]]
    displayScore()

    --[[     for ball   ]]
    ball:render()

    --[[     for player bars    ]]
    paddle1:render()
    paddle2:render()

    
    love.graphics.setFont(font)

    if gameState=="start" then
        love.graphics.printf("Welcome to Pong!",0,20,VIRTUAL_WIDTH,"center")
        love.graphics.printf("Press Enter to start",0,30,VIRTUAL_WIDTH,"center")
    end    

    if gameState=="serve" then
        love.graphics.printf("Player:"..servingPlayer.."'s turn",0,20,VIRTUAL_WIDTH,"center")
        love.graphics.printf("Press Enter to serve",0,30,VIRTUAL_WIDTH,"center")
    end    

    if gameState=="victory" then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player:"..winningPlayer.." wins",0,20,VIRTUAL_WIDTH,"center")
        love.graphics.setFont(font)
        love.graphics.printf("Press Enter to start again",0,50,VIRTUAL_WIDTH,"center")
    end    

    love.window.setTitle("Pong")

    displayFPS()
    push:apply("end")

end

function displayFPS()
    love.graphics.setColor(0,1,0,1)
    love.graphics.print("FPS: "..love.timer.getFPS(),30,5)    
    love.graphics.setColor(1,1,1,1)
end    

function displayScore()
    love.graphics.print(player1Score,VIRTUAL_WIDTH/2-50,VIRTUAL_HEIGHT/3)    
    love.graphics.print(player2Score,VIRTUAL_WIDTH/2+30,VIRTUAL_HEIGHT/3)
    
end    
