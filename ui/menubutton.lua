local menu_button = {}

function menu_button.new(text, id, func)
  local o = ui.component.new()

  o:setSprite(sprites["ui/button_white_" .. id or 1])
  if not spookmode then
    o:setText(text)
    o:setColor(0.25, 0.5, 1)
    o:setHoverColor(0.15, 0.4, 0.9)
  else
    o:setText(math.random(1,100) == 1 and "stop it" or "help")
    o:setTextColor(0, 0, 0)
    o:setColor(0.5, 0.5, 0.5)
    o:setHoverColor(0.4, 0.4, 0.4)
  end
  o:setFont(ui.fonts.default)
  o:setPivot(0.5, 0.5)
  o:onHovered(function() playSound("mous hovvr") end)
  if func then
    o:onReleased(func)
  end

  function o:preDraw()
    if self:hovered() then
      if self:pressed() or self:down() then
        self:setScale(0.9)
      else
        self:setScale(1.1)
      end
      self:setRotation(0.05 * math.sin(love.timer.getTime()*3))
    else
      self:setScale(1)
      self:setRotation(0)
    end
  end

  return o
end

return menu_button