local json = require("lib.dkjson")
local Constants = require("src.utils.Constants")
local http = require("socket.http")
local ltn12 = require("ltn12")

local ErrorHandler = {}

function ErrorHandler.sendBugReport(msg, trace)
  local path, line = msg:match("([%w%./_]+%.lua):(%d+)")
  local file = path and path:match("([^/]+%.lua)$") or "unknown"
  local payload = json.encode({
    version = Constants.GAME_VERSION,
    os = love.system.getOS(),
    message = tostring(msg),
    stacktrace = trace,
    metadata = {
      file = file,
      line = line,
      path = path,
    },
  })

  local response = {}

  local url = Constants.LOG_URL

  if Constants.DEBUG == true then
    url = "http://127.0.0.1:8000/log"
  end

  http.request({
    url = url,
    method = "POST",
    headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = tostring(#payload),
    },
    source = ltn12.source.string(payload),
    sink = ltn12.sink.table(response),
  })
end

return ErrorHandler
