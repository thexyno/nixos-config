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

local log = hs.logger.new('init', 'debug')

configWatcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()


----------------------------------------------------------------------------------------------------
-- Moonlander Detection
----------------------------------------------------------------------------------------------------

function isDeviceMoonlander(device) 
  return device.productName == "Moonlander Mark I" 
end

function moonlanderDetected(connected)
  if connected then
    hs.keycodes.setLayout("EurKEY v1.2")
  else
    hs.keycodes.setLayout("Colemak DH ISO copy")
  end
end

function searchMoonlander()
  local usbDevices = hs.usb.attachedDevices()
  local moonlanderConnected = hs.fnutils.find(usbDevices, isDeviceMoonlander) ~= nil
  
  moonlanderDetected(moonlanderConnected)  
end

searchMoonlander()

usbWatcher = hs.usb.watcher.new(function(event)
  if event.productName == "Moonlander Mark I" then
    moonlanderDetected(event.eventType == "added")
  end
end):start()

caffeinateWatcher = hs.caffeinate.watcher.new(function(event)
  if event == hs.caffeinate.watcher.systemDidWake then
    searchMoonlander()
  end
end):start()


----------------------------------------------------------------------------------------------------
-- mount ds9 via tailscale
----------------------------------------------------------------------------------------------------
-- kaputti
--function mountDS9()
--  local ssid = hs.wifi.currentNetwork()
--  if ssid ~= nil and ssid ~= 'vim' then -- not at home
--    if os.execute("mount | grep //ragon@ds9._smb._tcp.local/data") == nil then -- check if mounted via mdns
--      os.execute("diskutil umount /Volumes/data") -- umount share if it exists
--      hs.osascript.applescript('mount volume "smb://ragon@ds9.ragon000.github.beta.tailscale.net/data"') -- mount share via tailscale
--    end
--  end
--end
--
--mountDS9()
--
--hs.wifi.watcher.new(function(watcher, message, interface)
--  mountDS9()
--end):start()

----------------------------------------------------------------------------------------------------
-- Scratchpad
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

local hyperModifier = {"cmd", "shift", "ctrl", "alt"}
hs.hotkey.bind(hyperModifier, "b", function() showHideBundleId("com.bitwarden.desktop") end)
hs.hotkey.bind(hyperModifier, "p", function() showHideBundleId("com.timeular.zei") end)
hs.hotkey.bind(hyperModifier, "l", function() showHideBundleId("com.electron.logseq") end)

----------------------------------------------------------------------------------------------------
-- Tiling
----------------------------------------------------------------------------------------------------
