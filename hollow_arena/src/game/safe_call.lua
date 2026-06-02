local SafeCall = {}

local function defaultScreenPrint(message)
  print(message)
end

local function writeMessage(message, options)
  local screenPrint = options.screenPrint or defaultScreenPrint
  local log = options.log
  local text = tostring(message)

  screenPrint(text)

  if log ~= nil then
    log:add(text)
  end
end

local function buildErrorHandler(label, options)
  return function(errorMessage)
    local message = "Error"

    if label ~= nil and label ~= "" then
      message = message .. " in " .. tostring(label)
    end

    message = message .. ": " .. tostring(errorMessage)

    writeMessage(message, options)

    if options.traceback ~= nil then
      local traceback = options.traceback(errorMessage)

      if traceback ~= nil and traceback ~= "" then
        writeMessage(traceback, options)
        return message .. "\n" .. traceback
      end
    end

    return message
  end
end

function SafeCall.try(label, fn, options)
  options = options or {}

  local ok, result = xpcall(fn, buildErrorHandler(label, options))

  if not ok then
    return false, result
  end

  return true, result
end

return SafeCall
