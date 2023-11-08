----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.consoleOnTop(true)
hs.dockIcon(false)
hs.menuIcon(false)
hs.uploadCrashData(false)

hs.window.animationDuration = 0

configWatcher = hs.pathwatcher.new(hs.configdir, hs.reload)
configWatcher:start()

local moonlanderMode = false
local maximizeMode = false

----------------------------------------------------------------------------------------------------
-- Utilities
----------------------------------------------------------------------------------------------------

local modifier = {
    cmd = "cmd",
    shift = "shift",
    ctrl = "ctrl",
    option = "alt",
}

local modifiers = {
    hyper = { modifier.cmd, modifier.shift, modifier.ctrl, modifier.option },
    window = { modifier.ctrl, modifier.option },
    clipboard = { modifier.ctrl, modifier.cmd }
}

local bundleID = {
    activityMonitor = "com.apple.ActivityMonitor",
    finder = "com.apple.finder",
    firefox = "org.mozilla.firefox",
    emacs = "org.gnu.emacs",
    iterm = "com.googlecode.iterm2",
    orion = "com.kagi.kagimacOS",
    safariTechnologyPreview = "com.apple.SafariTechnologyPreview",
    spotify = "com.spotify.client",
    bitwarden = "com.bitwarden.desktop",
    teams = "com.microsoft.teams",
    faclieThings = "com.electron.nativefier.facilethings-nativefier-cf88de",
    timeular = "com.timeular.zei",
    logseq = "com.electron.logseq"
}

local usbDevice = {
    moonlander = "Moonlander Mark I"
}

local function languageIsGerman() return hs.host.locale.preferredLanguages()[1]:sub(0, 2) == "de" end


----------------------------------------------------------------------------------------------------
-- Menu
----------------------------------------------------------------------------------------------------

local function menuItems()
    return {
        {
            title = "Hammerspoon " .. hs.processInfo.version,
            disabled = true
        },
        { title = "-" },
        {
            title = "Moonlander Mode",
            checked = moonlanderMode,
            fn = function() moonlanderDetected(not moonlanderMode) end
        },
        {
            title = "Maximize Mode",
            checked = maximizeMode,
            fn = function() maximizeMode = not maximizeMode end
        },
        { title = "-" },
        {
            title = "Reload",
            fn = hs.reload
        },
        {
            title = "Console...",
            fn = hs.openConsole
        },
        { title = "-" },
        {
            title = "Quit",
            fn = function() hs.application.get(hs.processInfo.processID):kill() end
        }
    }
end

menu = hs.menubar.new()
menu:setMenu(menuItems)

----------------------------------------------------------------------------------------------------
-- Moonlander Detection
----------------------------------------------------------------------------------------------------

local moonlanderModeConfig = {
    [false] = {
        keyboardLayout = "Colemak DH ISO copy",
        icon = hs.configdir .. "/assets/statusicon_off.tiff"
    },
    [true] = {
        keyboardLayout = "EurKEY v1.2",
        icon = hs.configdir .. "/assets/statusicon_on.tiff"
    }
}

local function isDeviceMoonlander(device) return device.productName == usbDevice.moonlander end

function moonlanderDetected(connected)
    moonlanderMode = connected
    hs.keycodes.setLayout(moonlanderModeConfig[connected].keyboardLayout)
    menu:setIcon(moonlanderModeConfig[connected].icon)
end

local function searchMoonlander()
    local usbDevices = hs.usb.attachedDevices()
    local moonlanderConnected = hs.fnutils.find(usbDevices, isDeviceMoonlander) ~= nil

    moonlanderDetected(moonlanderConnected)
end

searchMoonlander()

usbWatcher = hs.usb.watcher.new(function(event)
    if event.productName == usbDevice.moonlander then
        moonlanderDetected(event.eventType == "added")
    end
end)
usbWatcher:start()

caffeinateWatcher = hs.caffeinate.watcher.new(function(event)
    if event == hs.caffeinate.watcher.systemDidWake then
        searchMoonlander()
    end
end)
caffeinateWatcher:start()

----------------------------------------------------------------------------------------------------
-- Window Management
----------------------------------------------------------------------------------------------------

hs.window.filter.ignoreAlways = {
    ["Mail Web Content"] = true,
    ["Mail-Webinhalt"] = true,
    ["QLPreviewGenerationExtension (Finder)"] = true,
    ["Reeder Web Content"] = true,
    ["Reeder-Webinhalt"] = true,
    ["Safari Web Content (Cached)"] = true,
    ["Safari Web Content (Prewarmed)"] = true,
    ["Safari Web Content"] = true,
    ["Safari Technology Preview Web Content (Cached)"] = true,
    ["Safari Technology Preview Web Content (Prewarmed)"] = true,
    ["Safari Technology Preview Web Content"] = true,
    ["Safari-Webinhalt (im Cache)"] = true,
    ["Safari-Webinhalt (vorgeladen)"] = true,
    ["Safari-Webinhalt"] = true,
    ["Strongbox (Safari)"] = true,
}
windowFilter = hs.window.filter.new({
    "App Store",
    "Code",
    "DataGrip",
    "Firefox",
    "Fork",
    "Fotos",
    "Google Chrome",
    "Vivaldi",
    "IntelliJ IDEA",
    "Mail",
    "Emacs",
    "Microsoft Outlook",
    "Microsoft Teams",
    "Music",
    "Musik",
    "Photos",
    "Postman",
    "Reeder",
    "Safari",
    "Safari Technology Preview",
    "Spotify",
    "Strongbox",
    "BitWarden",
    "Logseq",
    "Timeular",
    "Tower",
})
windowFilter:subscribe({ hs.window.filter.windowCreated, hs.window.filter.windowFocused }, function(window)
    if maximizeMode and window ~= nil and window:isStandard() and window:frame().h > 500 then
        window:maximize()
    end
end)

----------------------------------------------------------------------------------------------------
-- Keyboard Shortcuts
----------------------------------------------------------------------------------------------------

function showHideBundleId(bundleId)
    local focusedWindow = hs.window.focusedWindow()
    if focusedWindow ~= nil and focusedWindow:application():bundleID() == bundleId then -- window is focused
        focusedWindow:close() -- hide
    else
        hs.application.launchOrFocusByBundleID(bundleId)
        hs.window.focusedWindow():centerOnScreen(hs.mouse.getCurrentScreen())
    end
end

-- hs.loadSpoon("MiroWindowsManager")
-- hs.window.animationDuration = 0
-- spoon.MiroWindowsManager:bindHotkeys({
--   up = {modifiers.window, "up"},
--   right = {modifiers.window, "right"},
--   down = {modifiers.window, "down"},
--   left = {modifiers.window, "left"},
--   fullscreen = {modifiers.window, "return"},
--   nextscreen = {modifiers.hyper, "right"}
-- })


hs.hotkey.bind(modifiers.hyper, hs.keycodes.map.delete, function() hs.caffeinate.lockScreen() end)
hs.hotkey.bind(modifiers.hyper, "a", function() showHideBundleId(bundleID.activityMonitor) end)
hs.hotkey.bind(modifiers.hyper, "o", function() showHideBundleId(bundleID.orion) end)
hs.hotkey.bind(modifiers.hyper, "f", function() showHideBundleId(bundleID.faclieThings) end)
hs.hotkey.bind(modifiers.hyper, "p", function() showHideBundleId(bundleID.timeular) end)
hs.hotkey.bind(modifiers.hyper, "b", function() showHideBundleId(bundleID.bitwarden) end)
hs.hotkey.bind(modifiers.hyper, "t", function() showHideBundleId(bundleID.iterm) end)

----------------------------------------------------------------------------------------------------
-- Mouse Shortcuts
----------------------------------------------------------------------------------------------------

local function handleMouse4()
        hs.eventtap.keyStroke({ modifier.cmd }, "left")
end

local function handleMouse5()
        hs.eventtap.keyStroke({ modifier.cmd }, "right")
end

-- bind mouse3/4 to back and forward
mouseTap = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
    if event:getButtonState(3) then
        handleMouse4()
        return true
    elseif event:getButtonState(4) then
        handleMouse5()
        return true
    end
    return false
end)
mouseTap:start()
