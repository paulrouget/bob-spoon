local log = hs.logger.new('bob', 'debug')
local application = require("hs.application")
local axuielement = require("hs.axuielement")
local canvas = require("hs.canvas")

function dock()
  -- Maybe use hs.axuielement.observer.html
  local ret = nil
  local app = application.applicationsForBundleID("com.apple.dock")[1];
  local object = hs.axuielement.applicationElementForPID(app:pid());
  for i,v in ipairs(object) do
    for x,y in ipairs(v) do
      local label = y.AXStatusLabel
      if label then
        local title = y.AXTitle
        if ret then
          ret = ret .. " " .. title .. ":" .. label
        else
          ret = title .. ":" .. label
        end
      end
    end
  end
  if ret then
    return ret
  else
    return ""
  end
end

function battery()
  return math.floor(hs.battery.percentage()) .. "%"
end

function date()
  return os.date("%H:%M")
end

local mode = hs.screen.primaryScreen():currentMode();
local w = 400
local h = 12 
local x = 10
local y = 10

gCtx = canvas.new{x = mode.w - w - x, y = mode.h - h - y - h / 2, w = w, h = h + h}

gCtx:appendElements({
  action = "fill",
  fillColor = { red = 1.0, blue = 1.0, green = 1.0 },
  textAlignment = "right",
  text = "…",
  textSize = h,
  textFont = "courier",
  type = "text",
}):show()


function tick()
  local text = dock() .. " " .. battery() .. " " .. date()
  gCtx:elementAttribute(1, "text", text)
end

gTimer = hs.timer.doEvery(10, tick)

tick()

-- File reload ----------------------------------------

function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end
gWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/git/bob/", reloadConfig):start()
