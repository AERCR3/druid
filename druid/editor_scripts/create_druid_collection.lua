--- 创建Druid集合资源的模块
--- 此模块用于从GUI文件自动生成对应的Collection文件
local M = {}

--- 创建Druid集合
--- 此函数根据GUI文件创建对应的Collection文件，便于在场景中使用
---@param selection table - 选择的资源
function M.create_druid_collection(selection)
	local gui_filepath = editor.get(selection, "path")
	print("Create Druid Collection for", gui_filepath)

	local absolute_project_path = editor.external_file_attributes(".").path
	local collection_resource_path = gui_filepath:gsub("%.gui$", ".collection")
	local new_collection_absolute_path = absolute_project_path .. collection_resource_path

	local filename = gui_filepath:match("([^/]+)%.gui$")

	-- Check if file already exists
	local f = io.open(new_collection_absolute_path, "r")
	if f then
		f:close()
		print("Collection file already exists at " .. new_collection_absolute_path)
		return
	end

	-- Template content
	local template = [[name: "%s"
scale_along_z: 0
embedded_instances {
  id: "go"
  data: "components {\n"
  "  id: \"%s\"\n"
  "  component: \"%s\"\n"
  "}\n"
  ""
  position {
    x: 0.0
    y: 0.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
]]
	local content = string.format(template, filename, filename, gui_filepath)

	-- Write file
	local file, err = io.open(new_collection_absolute_path, "w")
	if not file then
		print("Error creating collection file:", err)
		return
	end
	file:write(content)
	file:close()

	print("Collection created: " .. collection_resource_path)
end

return M
