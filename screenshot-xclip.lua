-- screenshot-xclip.lua
--
-- Take a screenshot and use `xclip` to copy the image file to clipboard.
--
-- https://github.com/Arnesfield/mpv-screenshot-xclip

-- Requires `file` in `PATH` to get the image file mime type.
-- Requires `xclip` in `PATH` to copy image files to clipboard.

mp.msg = require('mp.msg')
mp.options = require('mp.options')

local options = {
  disable_osd_messages = ''
}

mp.options.read_options(options, 'screenshot-xclip')

-- parse disable_osd_messages
local disabled_osd_log_level = { info = false, error = false }
for log_level in string.gmatch(options.disable_osd_messages, '([^,]+)') do
  if log_level == 'info' or log_level == 'error' then
    disabled_osd_log_level[log_level] = true
  end
end

---@param file_path string
local function get_mime_type(file_path)
  local result = mp.command_native({
    name = 'subprocess',
    capture_stdout = true,
    playback_only = false,
    args = { 'file', '-b', '--mime-type', file_path }
  })

  -- trim stdout, fallback to png
  return result.status == 0 and result.stdout:gsub('[\r\n]+$', '') or 'image/png'
end

---@param file_path string
local function run_xclip_async(file_path)
  local mime_type = get_mime_type(file_path)
  local args      = {
    'xclip',
    '-selection', 'clipboard',
    '-target', mime_type,
    '-i', file_path
  }

  mp.msg.info('Running:', table.concat(args, ' '))

  mp.command_native_async({
    name = 'subprocess',
    capture_stderr = true,
    capture_stdout = true,
    playback_only = false,
    args = args,
  }, function(success, result)
    -- only report errors since xclip doesn't exit to preserve the image in clipboard
    if not success or result.status ~= 0 then
      mp.msg.error(string.format("Screenshot (xclip exit code %d): '%s'", result.status, file_path))
    end
  end)
end

---@param arg string|nil
local function screenshot_xclip(arg)
  local cmd = { 'screenshot' };
  if arg then
    table.insert(cmd, arg)
  end

  mp.command_native_async(cmd, function(success, result, error)
    if not success then
      local message = 'Screenshot failed: ' .. tostring(error)

      mp.msg.error(message)
      if not disabled_osd_log_level.error then
        mp.osd_message(message)
      end
    elseif result and result.filename then
      -- result can be nil (e.g., for 'each-frame' flag)
      local message = string.format("Screenshot: '%s'", result.filename)

      mp.msg.info(message)
      if not disabled_osd_log_level.info then
        mp.osd_message(message)
      end

      run_xclip_async(result.filename)
    end
  end)
end

mp.register_script_message('screenshot-xclip', screenshot_xclip)
