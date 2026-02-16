local SaveManager = {}
SaveManager.__index = SaveManager

function SaveManager:new(filename, defaultData)
	local self = setmetatable({}, SaveManager)
	self.filename = filename or "save.lua"
	self.defaultData = defaultData or {}
	self.data = {}

	if love.filesystem.getInfo(self.filename) then
		print(love.filesystem.getInfo(self.filename).modtime)
		self:load()
	else
		self.data = self.defaultData
		self:save()
	end

	return self
end

-- Sérialisation en string
local function serializeTable(tbl, indent)
	indent = indent or 0
	local str = "{\n"
	local padding = string.rep(" ", indent + 2)
	for k, v in pairs(tbl) do
		local key = type(k) == "string" and string.format("[%q]", k) or "[" .. k .. "]"
		if type(v) == "table" then
			str = str .. padding .. key .. " = " .. serializeTable(v, indent + 2) .. ",\n"
		elseif type(v) == "string" then
			str = str .. padding .. key .. " = " .. string.format("%q", v) .. ",\n"
		else
			str = str .. padding .. key .. " = " .. tostring(v) .. ",\n"
		end
	end
	return str .. string.rep(" ", indent) .. "}"
end

function SaveManager:save()
	local data = "return " .. serializeTable(self.data)
	love.filesystem.write(self.filename, data)
end

function SaveManager:load()
	if love.filesystem.getInfo(self.filename) then
		local chunk = love.filesystem.load(self.filename)
		if chunk then
			local ok, result = pcall(chunk)
			if ok and type(result) == "table" then
				self.data = result
			end
		end
	end
end

function SaveManager:reset()
	self.data = self.defaultData
	self:save()
end

function SaveManager:update(key, value, mode)
	mode = mode or "set"

	if mode == "set" then
		self.data[key] = value
	elseif mode == "add" then
		local current = tonumber(self.data[key]) or 0
		self.data[key] = current + value
	end

	self:save()
end

return SaveManager

