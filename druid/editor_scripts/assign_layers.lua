--- 基于纹理和字体为GUI节点分配图层的模块
--- 此模块用于自动化GUI场景中节点的图层分配

local defold_parser = require("druid.editor_scripts.defold_parser.defold_parser")
local system = require("druid.editor_scripts.defold_parser.system.parser_internal")

local M = {}


---创建文件备份
---此函数为指定文件创建备份副本以确保数据安全
---@param file_path string - 要备份的文件路径
---@return string|nil - 备份文件路径，如果备份失败则为nil
local function create_backup(file_path)
	local backup_path = file_path .. ".backup"
	print("Creating backup at:", backup_path)

	-- Read and write using system module
	local content, err_read = system.read_file(file_path)
	if not content then
		print("Error reading original file for backup:", err_read)
		return nil
	end

	local success, err_write = system.write_file(backup_path, content)
	if not success then
		print("Error creating backup file:", err_write)
		return nil
	end

	print("Backup created successfully")
	return backup_path
end


---从备份文件恢复
---此函数将备份文件的内容恢复到原始位置
---@param backup_path string - 备份文件的路径
---@param original_path string - 要恢复到的路径
---@return boolean - 如果恢复成功则为True
local function restore_from_backup(backup_path, original_path)
	print("Restoring from backup:", backup_path)

	-- Read backup file
	local content, err = system.read_file(backup_path)
	if not content then
		print("Error reading backup file:", err)
		return false
	end

	-- Write to original file
	local success, err = system.write_file(original_path, content)
	if not success then
		print("Error restoring from backup:", err)
		return false
	end

	print("Restored successfully from backup")
	return true
end


---移除备份文件
---此函数删除指定的备份文件以清理磁盘空间
---@param backup_path string - 要删除的备份文件路径
local function remove_backup(backup_path)
	-- Check file exists and remove it
	local file = io.open(backup_path, "r")
	if file then
		file:close()
		os.remove(backup_path)
		print("Backup file removed successfully")
	end
end

---基于纹理和字体为GUI节点分配图层
---此函数分析GUI资源并根据纹理和字体为节点分配合适的图层
---@param gui_resource string - 要处理的GUI资源
---@return table - 重新加载资源的编辑器命令
function M.assign_layers(gui_resource)
	local gui_path = editor.get(gui_resource, "path")
	print("Setting up layers for", gui_path)

	-- Get the absolute path to the file
	local absolute_project_path = editor.external_file_attributes(".").path
	if not absolute_project_path:match("[\\/]$") then
		absolute_project_path = absolute_project_path .. "/"
	end
	local clean_gui_path = gui_path
	if clean_gui_path:sub(1, 1) == "/" then
		clean_gui_path = clean_gui_path:sub(2)
	end
	local gui_absolute_path = absolute_project_path .. clean_gui_path

	-- Create a backup before modifying the file
	local backup_path = create_backup(gui_absolute_path)
	if not backup_path then
		print("Failed to create backup, aborting...")
		return {}
	end

	-- Parse the GUI file using defold_parser
	print("Parsing GUI file...")
	local gui_data = defold_parser.load_from_file(gui_absolute_path)
	if not gui_data then
		print("Error: Failed to parse GUI file")
		return {}
	end

	-- Collect all textures and fonts
	print("Collecting all available textures and fonts...")
	local all_textures = {}
	local all_fonts = {}

	-- Get textures
	if gui_data.textures then
		for _, texture in ipairs(gui_data.textures) do
			print("Found texture:", texture.name)
			all_textures[texture.name] = true
		end
	end

	-- Get fonts
	if gui_data.fonts then
		for _, font in ipairs(gui_data.fonts) do
			print("Found font:", font.name)
			all_fonts[font.name] = true
		end
	end

	-- Track which textures and fonts are actually used by nodes
	print("Finding used textures and fonts...")
	local used_layers = {}

	-- First pass: find all used textures and fonts
	if gui_data.nodes then
		for _, node in ipairs(gui_data.nodes) do
			if node.texture then
				local layer_name = node.texture:match("([^/]+)")
				if layer_name and all_textures[layer_name] then
					used_layers[layer_name] = true
					print("Node", node.id, "uses texture:", layer_name)
				end
			elseif node.font then
				local layer_name = node.font
				if all_fonts[layer_name] then
					used_layers[layer_name] = true
					print("Node", node.id, "uses font:", layer_name)
				end
			end
		end
	end

	-- Create a set of existing layer names for faster lookup
	print("Checking existing layers...")
	local existing_layers = {}
	if gui_data.layers then
		for _, layer in ipairs(gui_data.layers) do
			if layer.name then
				existing_layers[layer.name] = true
				print("Found existing layer:", layer.name)
			end
		end
	end

	-- Convert set to array of used layers
	local layers = {}
	for layer_name in pairs(used_layers) do
		if not existing_layers[layer_name] then
			table.insert(layers, layer_name)
			print("Adding new layer:", layer_name)
		else
			print("Layer already exists:", layer_name)
		end
	end

	-- Sort new layers for consistent output
	table.sort(layers)

	print("Found", #layers, "new layers to add")

	-- Add new layers (preserving existing ones)
	print("Adding new layers...")
	gui_data.layers = gui_data.layers or {}
	for _, layer_name in ipairs(layers) do
		table.insert(gui_data.layers, {
			name = layer_name,
		})
	end
	if #gui_data.layers == 0 then
		gui_data.layers = nil
	end

	-- Create a lookup table for faster matching - include both existing and new layers
	local layer_lookup = {}
	for layer_name in pairs(existing_layers) do
		layer_lookup[layer_name] = true
	end
	for _, layer_name in ipairs(layers) do
		layer_lookup[layer_name] = true
	end

	-- Update nodes to use the correct layer
	print("Updating node layers...")
	if gui_data.nodes then
		for _, node in ipairs(gui_data.nodes) do
			if node.texture then
				local layer_name = node.texture:match("([^/]+)")
				if layer_name and layer_lookup[layer_name] then
					print("Assigning node", node.id, "to layer:", layer_name)
					node.layer = layer_name
				end
			elseif node.font then
				local layer_name = node.font
				if layer_lookup[layer_name] then
					print("Assigning node", node.id, "to layer:", layer_name)
					node.layer = layer_name
				end
			end
		end
	end

	-- Write the updated GUI file
	print("Writing updated GUI file...")
	local success = defold_parser.save_to_file(gui_absolute_path, gui_data)

	if not success then
		print("Error: Failed to save GUI file")
		print("Attempting to restore from backup...")
		local restored = restore_from_backup(backup_path, gui_absolute_path)
		if not restored then
			print("Critical: Failed to restore from backup. Manual intervention may be required.")
		end
		return {}
	end

	-- Everything worked, remove the backup
	remove_backup(backup_path)

	print("Successfully assigned layers for GUI:", gui_path)

	return {}
end

return M
