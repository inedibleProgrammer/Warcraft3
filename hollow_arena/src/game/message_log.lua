local MessageLog = {}

function MessageLog.new()
  local self = {
    messages = {},
  }

  return self
end

function MessageLog:add(message)
  local text = tostring(message)

  self.messages[#self.messages + 1] = text

  return text
end

function MessageLog:addMany(messages)
  for _, message in ipairs(messages) do
    self:add(message)
  end
end

function MessageLog:count()
  return #self.messages
end

function MessageLog:get(index)
  return self.messages[index]
end

function MessageLog:getMessages()
  local copy = {}

  for index, message in ipairs(self.messages) do
    copy[index] = message
  end

  return copy
end

function MessageLog:clear()
  self.messages = {}
end

return MessageLog
