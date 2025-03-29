local file_path = "/tmp/keymap_conflicts.txt"
local file = io.open(file_path, "w")

if not file then
  print("Error: Could not open file at " .. file_path)
  return
end

local modes = { "n", "i", "v", "c", "x", "s", "o", "t", "l" }
local mappings = {}

for _, mode in ipairs(modes) do
  for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
    local lhs = map.lhs
    if not mappings[lhs] then
      mappings[lhs] = {}
    end
    table.insert(mappings[lhs], mode)
  end
end

for key, used_modes in pairs(mappings) do
  if #used_modes > 1 then
    file:write("Conflict: " .. key .. " mapped in modes: " .. table.concat(used_modes, ", ") .. "\n")
  end
end

file:close()
print("Conflicts saved to " .. file_path)
