local Wc3LogReporter = {}

local DEFAULT_MESSAGES_PER_PAGE = 14

function Wc3LogReporter.new(log, screenPrint, messagesPerPage)
  local self = {
    log = log,
    screenPrint = screenPrint or print,
    messagesPerPage = messagesPerPage or DEFAULT_MESSAGES_PER_PAGE,
  }

  return setmetatable(self, { __index = Wc3LogReporter })
end

function Wc3LogReporter:getPageCount()
  local count = self.log:count()

  if count == 0 then
    return 1
  end

  return math.ceil(count / self.messagesPerPage)
end

function Wc3LogReporter:getPageMessages(pageNumber)
  local pageCount = self:getPageCount()
  local page = tonumber(pageNumber) or pageCount

  if page < 1 then
    page = 1
  end

  if page > pageCount then
    page = pageCount
  end

  local firstIndex = ((page - 1) * self.messagesPerPage) + 1
  local lastIndex = page * self.messagesPerPage

  local messages = {}

  for index = firstIndex, lastIndex do
    local message = self.log:get(index)

    if message ~= nil then
      messages[#messages + 1] = message
    end
  end

  return messages, page, pageCount
end

function Wc3LogReporter:printPage(pageNumber)
  local messages, page, pageCount = self:getPageMessages(pageNumber)

  self.screenPrint("Log page " .. tostring(page) .. "/" .. tostring(pageCount))

  for _, message in ipairs(messages) do
    self.screenPrint(message)
  end
end

function Wc3LogReporter:printLatestPage()
  self:printPage(self:getPageCount())
end

return Wc3LogReporter
