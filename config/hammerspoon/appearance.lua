local function isDarkModeEnabled()
  local _, res = hs.osascript.javascript([[
        Application("System Events").appearancePreferences.darkMode()
    ]])
  return res == true
end

local function buildFZFCommand(isDarkMode)
  local latte = " \
--color=bg+:#CCD0DA,spinner:#DC8A78,hl:#D20F39 \
--color=fg:#4C4F69,header:#D20F39,info:#8839EF,pointer:#DC8A78 \
--color=marker:#7287FD,fg+:#4C4F69,prompt:#8839EF,hl+:#D20F39 \
--color=selected-bg:#BCC0CC \
--color=border:#CCD0DA,label:#4C4F69"
  local mocha = " \
--color=bg+:#313244,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#313244,label:#CDD6F4"
  local frappe = " \
--color=bg+:#414559,spinner:#F2D5CF,hl:#E78284 \
--color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
--color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
--color=selected-bg:#51576D \
--color=border:#414559,label:#C6D0F5"

  local configContent = isDarkMode and frappe or latte
  local configFilePath = os.getenv("HOME") .. "/.config/fzf/fzfrc"

  -- Escape special characters for Zsh
  local escapedContent = configContent:gsub("([%s])", "\n")

  return string.format(
    [[
        echo '%s' > %s
    ]],
    escapedContent,
    configFilePath
  )
end

local function buildBordersCommand(isDarkMode)
  -- local activecolor = isdarkmode and "0xffca9ee6" or "0xff8839ef"
  local inactiveColor = "false"
  local activeColor = isDarkMode and "0xffdc8a78" or "0xffb3d5a4"
  -- local inactiveColor = "0xff4c4f69"
  local filePath = os.getenv("HOME") .. "/.config/borders/bordersrc"

  return string.format(
    [[
        sed -i '' \
            -e 's/active_color=0x[0-9a-fA-F]*/active_color=%s/' \
            -e 's/inactive_color=0x[0-9a-fA-F]*/inactive_color=%s/' \
            %s && borders  active_color=%s inactive_color=%s &
    ]],
    activeColor,
    inactiveColor,
    filePath,
    activeColor,
    inactiveColor
  )
end

-- local function buildBatCommand(isDarkMode)
-- 	local theme = isDarkMode and "Catppuccin Frappe" or "Catppuccin Latte"
-- 	local escapedTheme = theme:gsub("([%s])", "\\%1")
-- 	local filePath = os.getenv("HOME") .. "/.config/bat/config"
-- 	return string.format([[sed -i '' 's/theme=".*"/theme="\"%s\""/' %s]], escapedTheme, filePath)
-- end

local function buildYaziCommand(isDarkMode)
  local theme = isDarkMode and "catppuccin-frappe" or "catppuccin-latte"
  local filePath = os.getenv("HOME") .. "/.config/yazi/theme.toml"
  return string.format([[sed -i '' 's/use = ".*"/use = "\"%s\""/' %s]], theme, filePath)
end

local function buildTmuxCommand(isDarkMode)
  local search = isDarkMode and "'latte'" or "'frappe'"
  local replace = isDarkMode and "'frappe'" or "'latte'"
  local filePath = os.getenv("HOME") .. "/.config/tmux/tmux.conf"
  return string.format([[sed -i '' 's/%s/%s/' %s]], search, replace, filePath)
end

local function buildKittyCommand(isDarkMode)
  local catppuccinTheme = isDarkMode and "frappe" or "latte"

  local capitalizedTheme = catppuccinTheme:sub(1, 1):upper() .. catppuccinTheme:sub(2)

  return "kitty +kitten themes --reload-in=all --config-file-name themes.conf --cache-age=-1 Catppuccin-"
      .. capitalizedTheme
end

local function executeCommand(command, appName)
  print(appName .. ": command: " .. command)
  local output, status, type, rc = hs.execute(command, true)
  if status then
    print(appName .. ": succeeded")
  else
    print(appName .. ": failed")
    print("Error: " .. tostring(output))
  end
end

local appConfigs = {
  -- { name = "kitty", builder = buildKittyCommand },
  { name = "yazi", builder = buildYaziCommand },
  -- { name = "bat", builder = buildBatCommand },
  { name = "fzf",  builder = buildFZFCommand },
  -- { name = "tmux", builder = buildTmuxCommand },
  -- { name = "borders", builder = buildBordersCommand },
}

local function updateThemes()
  local isDarkMode = isDarkModeEnabled()
  print("Theme changed. Dark mode: " .. tostring(isDarkMode))

  for _, config in ipairs(appConfigs) do
    local command = config.builder(isDarkMode)
    executeCommand(command, config.name)
    if config.callback then
      config.callback()
    end
  end
end

local notificationName = "AppleInterfaceThemeChangedNotification"
local appearanceWatcher = hs.distributednotifications.new(updateThemes, notificationName, nil)
appearanceWatcher:start()

-- Sync once at startup: theme may have changed while the watcher wasn't running
updateThemes()
