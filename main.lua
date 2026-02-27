-- screenshot-clipboard
--
-- Take a screenshot and copy the image file to clipboard.
--
-- https://github.com/Arnesfield/mpv-screenshot-clipboard

-- Requires `file` in `PATH` to get the image file mime type.
-- Requires `xclip` (or `wl-copy` for Wayland) in `PATH` to copy image files to clipboard.

mp.msg = require("mp.msg")
mp.options = require("mp.options")
mp.utils = require("mp.utils")

local options = {
  disable_osd_messages = "",
}

mp.options.read_options(options, "screenshot-clipboard")

-- parse disable_osd_messages
local disabled_osd_log_level = { info = false, error = false }
for log_level in string.gmatch(options.disable_osd_messages, "([^,]+)") do
  if log_level == "info" or log_level == "error" then
    disabled_osd_log_level[log_level] = true
  end
end

---@param message string
local function log_error(message)
  mp.msg.error(message)
  if not disabled_osd_log_level.error then
    mp.osd_message(message)
  end
end

---@param ... string
---@return string|nil
local function join_paths(...)
  ---@type string|nil
  local result

  for _, path in ipairs({ ... }) do
    if result == nil then
      result = path
    else
      result = mp.utils.join_path(result, path)
    end
  end

  return result
end

---@type string|nil
local bin_path
---@type string|nil
local script_dir = mp.get_script_directory()

if script_dir ~= nil then
  bin_path = join_paths(script_dir, "bin", "clipboard")
else
  mp.msg.error("Screenshot clipboard error: Unable to locate script.")
end

---@param file_path string
local function run_clipboard_async(file_path)
  if bin_path == nil then
    log_error("Screenshot clipboard error: Unable to locate script.")
    return
  end

  mp.command_native_async({
    name = "subprocess",
    capture_stderr = true,
    capture_stdout = true,
    playback_only = false,
    args = { bin_path, file_path },
  }, function(success, result)
    -- only report errors since the clipboard commands
    -- do not exit to preserve the image in clipboard
    if not success or result.status ~= 0 then
      log_error(
        string.format(
          "Screenshot clipboard error (exit code %d): '%s'",
          result.status,
          file_path
        )
      )
    end
  end)
end

---@param arg string|nil
local function screenshot_clipboard(arg)
  local cmd = { "screenshot" }
  if arg then
    table.insert(cmd, arg)
  end

  mp.command_native_async(cmd, function(success, result, error)
    if not success then
      log_error("Screenshot failed: " .. tostring(error))
    elseif result and result.filename then
      -- result can be nil (e.g., for 'each-frame' flag)
      local message = string.format("Screenshot: '%s'", result.filename)

      mp.msg.info(message)
      if not disabled_osd_log_level.info then
        mp.osd_message(message)
      end

      run_clipboard_async(result.filename)
    end
  end)
end

mp.register_script_message("screenshot-clipboard", screenshot_clipboard)
