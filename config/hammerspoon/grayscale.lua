local M = {}

local function setGrayscale(enabled)
	local shortcut = enabled and "Grayscale On" or "Grayscale Off"
	hs.shortcuts.run(shortcut)
end

local appWatcher = hs.application.watcher.new(function(name, event, _)
	if name == "Firefox" then
		if event == hs.application.watcher.activated then
			setGrayscale(true)
		elseif event == hs.application.watcher.deactivated then
			setGrayscale(false)
		end
	end
end)

function M.start()
	appWatcher:start()
end

function M.stop()
	appWatcher:stop()
end

return M
