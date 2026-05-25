local M = {}


--- 从.internal/editor.port文件读取编辑器端口
--- 此函数读取Defold编辑器的HTTP API端口以便进行通信
---@return number|nil port 编辑器端口号，如果未找到则为nil
local function get_editor_port()
	local port_file_path = ".internal/editor.port"
	local port_file = io.open(port_file_path, "r")
	if not port_file then
		return nil
	end

	local port_str = port_file:read("*a")
	port_file:close()

	if not port_str then
		return nil
	end

	-- Trim whitespace
	port_str = string.match(port_str, "%s*(.-)%s*$")
	local port = tonumber(port_str)
	return port
end


--- 调用编辑器HTTP API命令
--- 此函数向Defold编辑器发送HTTP请求以执行特定命令
---@param command string 命令名称（例如："fetch-libraries"）
---@return boolean success 如果请求成功发送则为True
function M.call_editor_command(command)
	if not command or command == "" then
		return false
	end

	local port = get_editor_port()
	if not port then
		print("Asset Store: Could not read editor port from .internal/editor.port")
		return false
	end

	local url = string.format("http://localhost:%d/command/%s", port, command)

	-- Fire and forget - send POST request to editor API
	pcall(function()
		local response = http.request(url, {
			method = "POST",
			headers = { ["Accept"] = "application/json" }
		})
	end)

	return true
end

return M
