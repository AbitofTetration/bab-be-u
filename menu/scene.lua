local scene = {}
game = require '../game/scene'

local width = love.graphics.getWidth()
local height = love.graphics.getHeight()

local scrollx = 0
local scrolly = 0

local music_on = true

local oldmousex = 0
local oldmousey = 0

local buttons = {"play", "editor", "options", "exit"}

local options = false

local splash = love.timer.getTime() % 1

function scene.load()
  metaClear()
  clear()
  was_using_editor = false
  resetMusic("bab be u them REEEMAZTUR", 0.5)
  love.graphics.setBackgroundColor(0.10, 0.1, 0.11)
  local now = os.time(os.date("*t"))
  presence = {
    state = "main menu",
    details = "idling",
    largeImageKey = "titlescreen",
    largeimageText = "main menu",
    startTimestamp = now
  }
  nextPresenceUpdate = 0
  love.keyboard.setKeyRepeat(false)
end

function scene.draw(dt)
  local bgsprite = sprites["ui/menu_background"]

  local cells_x = math.ceil(love.graphics.getWidth() / bgsprite:getWidth())
  local cells_y = math.ceil(love.graphics.getHeight() / bgsprite:getHeight())

  if not spookmode then
    love.graphics.setColor(1, 1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/6, .4)
  else
    love.graphics.setColor(0.2,0.2,0.2,1)
  end

  for x = -1, cells_x do
    for y = -1, cells_y do
      local draw_x = scrollx % bgsprite:getWidth() + x * bgsprite:getWidth()
      local draw_y = scrolly % bgsprite:getHeight() + y * bgsprite:getHeight()
      love.graphics.draw(bgsprite, draw_x, draw_y)
    end
  end

  local buttonwidth, buttonheight = sprites["ui/button_1"]:getDimensions()

  local buttoncolor = {84/255, 109/255, 255/255} --terrible but it works so /shrug

  for i=1, #buttons do
    love.graphics.push()
    local rot = 0

    local buttonx = width/2-buttonwidth/2
    local buttony = height/2-buttonheight/2+(buttonheight+10)*i

    if rainbowmode then buttoncolor = hslToRgb((love.timer.getTime()/6+i/10)%1, .5, .5, .9) end

    if not spookmode then
      love.graphics.setColor(buttoncolor[1], buttoncolor[2], buttoncolor[3])
    else
      love.graphics.setColor(0.5,0.5,0.5)
    end
    if mouseOverBox(width/2-sprites["ui/button_1"]:getWidth()/2, height/2-buttonheight/2+(buttonheight+10)*i, buttonwidth, buttonheight) then
      love.graphics.setColor(buttoncolor[1]-0.1, buttoncolor[2]-0.1, buttoncolor[3]-0.1) --i know this is horrible
      love.graphics.translate(buttonx+buttonwidth/2, buttony+buttonheight/2)
      love.graphics.rotate(0.05 * math.sin(love.timer.getTime()*3))
      love.graphics.translate(-buttonx-buttonwidth/2, -buttony-buttonheight/2)
    end

    love.graphics.draw(sprites["ui/button_white_"..i%2+1], buttonx, buttony, rot, 1, 1)

    love.graphics.pop()

    if not spookmode then
      love.graphics.setColor(1,1,1)
    else
      love.graphics.setColor(0,0,0)
    end
    love.graphics.printf(spookmode and (math.random(1,100) == 1 and "stop it" or "help") or buttons[i], width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*i+5, buttonwidth, "center")
  end

  love.graphics.setColor(1, 1, 1)
  if mouseOverBox(10, height - sprites["ui/github"]:getHeight() - 10, sprites["ui/github"]:getWidth(), sprites["ui/github"]:getHeight()) then
    love.graphics.setColor(.7, .7, .7)
  end

  love.graphics.draw(sprites["ui/github"], 10, height-sprites["ui/github"]:getHeight() - 10)

  for _,pair in pairs({{1,0},{0,1},{1,1},{-1,0},{0,-1},{-1,-1},{1,-1},{-1,1}}) do
    local outlineSize = 2
    pair[1] = pair[1] * outlineSize
    pair[2] = pair[2] * outlineSize

    love.graphics.setColor(0,0,0)
    love.graphics.draw(sprites["ui/bab_be_u"], width/2 - sprites["ui/bab_be_u"]:getWidth() / 2 + pair[1], height/20 + pair[2])
  end

  if not spookmode then
    love.graphics.setColor(1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/3, .5)
    love.graphics.draw(sprites["ui/bab_be_u"], width/2 - sprites["ui/bab_be_u"]:getWidth() / 2, height/20)
  end
  
  -- Splash text here
  
  love.graphics.push()
  
  if string.find(build_number, "420") or string.find(build_number, "1337") or string.find(build_number, "666") or string.find(build_number, "69") then
    love.graphics.setColor(hslToRgb(love.timer.getTime()%1, .5, .5, .9))
    splashtext = "nice"
  end
  if is_mobile then
    splashtext = "4mobile!"
  elseif splash <= 0.5 then
    splashtext = "splash text!"
  elseif splash > 0.5 then
    splashtext = "splosh txt!"
  end
  
  local textx = width/2 + sprites["ui/bab_be_u"]:getWidth() / 2
  local texty = height/20+sprites["ui/bab_be_u"]:getHeight()

  love.graphics.translate(textx+love.graphics.getFont():getWidth(splashtext)/2, texty+love.graphics.getFont():getHeight()/2)
  love.graphics.rotate(0.7*math.sin(love.timer.getTime()*2))
  love.graphics.translate(-textx-love.graphics.getFont():getWidth(splashtext)/2, -texty-love.graphics.getFont():getHeight()/2)

  love.graphics.print(splashtext, textx, texty)
  
  love.graphics.pop()

  if build_number and not debug_view then
    love.graphics.setColor(1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/6, .6)
    --if haha number then make it rainbow anyways
    if string.find(build_number, "420") or string.find(build_number, "1337") or string.find(build_number, "666") or string.find(build_number, "69") then
      love.graphics.setColor(hslToRgb(love.timer.getTime()%1, .5, .5, .9))
    end
    love.graphics.print(spookmode and "error" or 'v'..build_number)
  end

  if is_mobile then
    local cursorx, cursory = love.mouse.getPosition()
    love.graphics.setColor(1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/6, .5)
    love.graphics.draw(system_cursor, cursorx, cursory)
  end
end

function scene.update(dt)
  if options then
    buttons = {"music: on", "stopwatch effect: on", "fullscreen", "exit"}
  else
    buttons = {"play", "editor", "options", "exit"}
  end
  
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  local buttonwidth, buttonheight = sprites["ui/button_1"]:getDimensions()

  local mousex, mousey = love.mouse.getPosition()

  scrollx = scrollx+dt*50
  scrolly = scrolly+dt*50
  
  for i=1, #buttons do
    if mouseOverBox(width/2-sprites["ui/button_1"]:getWidth()/2, height/2-buttonheight/2+(buttonheight+10)*i, buttonwidth, buttonheight) then
      if not pointInside(oldmousex, oldmousey, width/2-sprites["ui/button_1"]:getWidth()/2, height/2-buttonheight/2+(buttonheight+10)*i, buttonwidth, buttonheight) then
        -- im sorry
        playSound("mous hovvr")
        playSound("mous hovvr")
        playSound("mous hovvr")
      end
      if buttons[i] == "exit" and not options then
        love.mouse.setPosition(mousex, mousey-(buttonheight+10))
      end
    end

    if buttons[i] == "windowed" or buttons[i] == "fullscreen" then
      if not fullscreen then
        buttons[i] = "fullscreen"
      else
        buttons[i] = "windowed"
      end
    end
    if string.starts(buttons[i], "music") then
      buttons[i] = "music: " .. (settings["music_on"] and "on" or "off")
    end
    if string.starts(buttons[i], "stopwatch effect") then
      buttons[i] = "stopwatch effect: " .. (settings["stopwatch_effect"] and "on" or "off")
    end
  end

  oldmousex, oldmousey = love.mouse.getPosition()
end

function scene.mousePressed(x, y, button)
  if pointInside(x, y, 10, height - sprites["ui/github"]:getHeight() - 10, sprites["ui/github"]:getWidth(), sprites["ui/github"]:getHeight()) and button == 1 then
    love.system.openURL("https://github.com/lilybeevee/bab-be-u")
  end
end

function scene.mouseReleased(x, y, button)
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  local buttonwidth, buttonheight = sprites["ui/button_1"]:getDimensions()

  local mousex, mousey = love.mouse.getPosition()

  for i=1, #buttons do
    if mouseOverBox(width/2-sprites["ui/button_1"]:getWidth()/2, height/2-buttonheight/2+(buttonheight+10)*i, buttonwidth, buttonheight) then
      if button == 1 then
        if buttons[i] == "exit" and not options then
          love.event.quit()
        elseif buttons[i] == "exit" and options then
          options = false
        elseif buttons[i] == "options" then
          options = true
        elseif buttons[i] == "play" then
          switchScene("play")
        elseif buttons[i] == "editor" then
          switchScene("edit")
        elseif buttons[i] == "windowed" or buttons[i] == "fullscreen" then
          if fullscreen == false then
            if not love.window.isMaximized( ) then
              winwidth, winheight = love.graphics.getDimensions( )
            end
            love.window.setMode(0, 0, {borderless=false})
            love.window.maximize( )
            fullscreen = true
          elseif fullscreen == true then
            love.window.setMode(winwidth, winheight, {borderless=false, resizable=true, minwidth=705, minheight=510})
            love.window.maximize( )
            love.window.restore( )
            fullscreen = false
          end

          settings["fullscreen"] = fullscreen
          saveAll()
        elseif string.starts(buttons[i], "music") then
          settings["music_on"] = not settings["music_on"]
          saveAll()
        elseif string.starts(buttons[i], "stopwatch effect") then
          settings["stopwatch_effect"] = not settings["stopwatch_effect"]
          saveAll()
        end
      end
    end
  end
end

function scene.keyPressed(key)
  if key == "escape" and options then
    options = false
  end
end

return scene
