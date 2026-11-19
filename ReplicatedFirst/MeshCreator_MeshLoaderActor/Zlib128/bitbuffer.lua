local v = table.create(256)

for i = 0, 255 do
	v[i + 1] = string.char(i)
end

local to2 = table.create(64)
local from2 = {}
local v2 = { To = nil, From = nil }

for i = 1, 64 do
	local v3 = string.sub("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", i, i)
	to2[i] = v3
	from2[string.byte(v3) + 1] = i - 1
end

v2.To = to2
v2.From = from2

local to3 = table.create(91)
local from3 = {}
local v3 = { To = nil, From = nil }

for i = 1, 91 do
	local v4 = string.sub(
		"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,./:;<=>?@[]^_`{|}~'",
		i,
		i
	)
	to3[i] = v4
	from3[string.byte(v4) + 1] = i - 1
end

v3.To = to3
v3.From = from3

local function Error(formatString: string, ...)
	error("[BitBuffer] " .. string.format(formatString, ...), 2)
end

local function WriteToBuffer(state, p: number, p2: number)
	local buf = state._buffer
	local index = state._index

	local v4 = index % 32
	local v5 = bit32.rshift(index, 5) + 1

	if v4 + p <= 32 then
		buf[v5] = bit32.replace(buf[v5] or 0, p2, v4, p)
	else
		local v6 = 32 - v4
		buf[v5] = bit32.replace(buf[v5] or 0, p2, v4, v6)
		buf[v5 + 1] = bit32.replace(buf[v5 + 1] or 0, bit32.extract(p2, v6, p - v6), 0, p - v6)
	end

	index += p
	state._size = math.max(state._size, index)
	state._index = index
end

local function ReadFromBuffer(state, p: number)
	local buf = state._buffer
	local index = state._index
	state._index += p

	local v4 = index % 32
	local v5 = bit32.rshift(index, 5) + 1

	local v6 = buf[v5] or 0

	if v4 == 0 then
		return (bit32.extract(v6, 0, p))
	end

	if v4 + p <= 32 then
		return (bit32.extract(v6, v4, p))
	end

	local v7 = 32 - v4
	local v8 = buf[v5 + 1] or 0
	return (bit32.replace(bit32.extract(v6, v4, v7), v8, v7, p - v7))
end

local function WriteBytesAligned(state, value: string)
	local count = #value

	if count < 4 then
		WriteToBuffer(state, count * 8, string.unpack("<I" .. count, value))
	elseif count == 4 then
		local v4, v5, v6, v7 = string.byte(value, 1, 4)
		WriteToBuffer(state, 32, v4 + v5 * 256 + v6 * 65536 + v7 * 16777216)
	elseif count < 8 then
		local v4, v5, v6, v7 = string.byte(value, 1, 4)
		WriteToBuffer(state, 32, v4 + v5 * 256 + v6 * 65536 + v7 * 16777216)
		WriteToBuffer(state, count * 8 - 32, string.unpack("<I" .. count - 4, value, 5))
	else
		local buf = state._buffer
		local index = state._index
		local v4 = index % 32
		local v5 = bit32.rshift(index, 5) + 1
		local v6

		if v4 == 0 then
			v6 = 0
		else
			v6 = 4 - v4 / 8
			WriteToBuffer(state, 32 - v4, string.unpack("<I" .. v6, value))
			v5 += 1
		end

		for i = v6 + 4, count, 4 do
			local v7, v8, v9, v10 = string.byte(value, i - 3, i)
			buf[v5] = v7 + v8 * 256 + v9 * 65536 + v10 * 16777216
			v5 += 1
		end

		local v7 = (count - v6 - 4) % 4

		if v7 > 0 then
			local v8 = string.unpack("<I" .. v7, value, count - v7 + 1)
			buf[v5] = bit32.replace(buf[v5] or 0, v8, 0, v7 * 8)
		end

		local v8 = (v5 - 1) * 32 + v7 * 8
		state._size = math.max(state._size, v8)
		state._index = v8
	end
end

local function ReadBytesAligned(state, p: number)
	if p < 4 then
		return string.pack("<I" .. p, ReadFromBuffer(state, p * 8))
	end

	if p == 4 then
		local readFromBuffer = ReadFromBuffer(state, 32)
		return (string.char(
			bit32.extract(readFromBuffer, 0, 8),
			bit32.extract(readFromBuffer, 8, 8),
			bit32.extract(readFromBuffer, 16, 8),
			(bit32.extract(readFromBuffer, 24, 8))
		))
	end

	local v4 = 3 - (state._index / 8 - 1) % 4
	local v5 = (p - v4) % 4
	local v6 = (p - v4 - v5) / 4

	local v7 = table.create(v6 + 2)
	local v8

	if v4 > 0 then
		v7[1] = string.pack("<I" .. v4, ReadFromBuffer(state, v4 * 8))
		v8 = 1
	else
		v8 = 0
	end

	local buf = state._buffer
	local v9 = bit32.rshift(state._index, 5) + 1

	for i = 1, v6 do
		local v10 = buf[v9 + i - 1] or 0
		v7[v8 + i] = string.char(
			bit32.extract(v10, 0, 8),
			bit32.extract(v10, 8, 8),
			bit32.extract(v10, 16, 8),
			(bit32.extract(v10, 24, 8))
		)
	end

	if v5 > 0 then
		v7[v8 + v6 + 1] = string.pack("<I" .. v5, (bit32.extract(buf[v9 + v6] or 0, 0, v5 * 8)))
	end

	state._index += v6 * 32 + v5 * 8
	return table.concat(v7)
end

local Bitbuffer = { ClassName = "BitBuffer" }
Bitbuffer.__index = Bitbuffer

function Bitbuffer.__tostring(_): string
	return "BitBuffer"
end

function Bitbuffer.is(p): boolean
	return getmetatable(p) == Bitbuffer
end

function Bitbuffer.new(size: number?)
	size = size or 0

	return (setmetatable({
		_buffer = table.create((math.ceil(size / 32))),
		_index = 0,
		_size = size
	}, Bitbuffer))
end

function Bitbuffer.FromString(value: string)
	if type(value) ~= "string" then
		Error("invalid argument #1 to 'FromString' (string expected, got %s)", (typeof(value)))
	end

	local count = #value
	local buf = table.create((math.ceil(count / 4)))

	for i = 1, count / 4 do
		local v4, v5, v6, v7 = string.byte(value, i * 4 - 3, i * 4)
		buf[i] = v4 + v5 * 256 + v6 * 65536 + v7 * 16777216
	end

	local v4 = count % 4

	if v4 ~= 0 then
		buf[math.ceil(count / 4)] = string.unpack("<I" .. v4, value, count - v4)
	end

	return (setmetatable({
		_buffer = buf,
		_index = 0,
		_size = #value * 8
	}, Bitbuffer))
end

function Bitbuffer.FromBase64(value: string)
	if type(value) ~= "string" then
		Error("invalid argument #1 to 'FromBase64' (string expected, got %s)", (typeof(value)))
	end

	local count = #value
	local from = v2.From

	local v4 = math.floor(count / 4)
	local buf = table.create((math.ceil((v4 * 24 + count % 4 * 6) / 32)))
	local v5 = 0
	local v6 = 0
	local v7 = 1

	for i = 1, v4 do
		local v8, v9, v10, v11 = string.byte(value, i * 4 - 3, i * 4)
		local v12 = from[v8 + 1]
		local v13 = from[v9 + 1]
		local v14 = from[v10 + 1]
		local v15 = from[v11 + 1]

		if v12 == nil then
			Error("invalid argument #1 to 'FromBase64' (invalid Base64 character at position %d)", i)
		elseif v13 == nil then
			Error("invalid argument #1 to 'FromBase64' (invalid Base64 character at position %d)", i + 1)
		elseif v14 == nil then
			Error("invalid argument #1 to 'FromBase64' (invalid Base64 character at position %d)", i + 2)
		elseif v15 == nil then
			Error("invalid argument #1 to 'FromBase64' (invalid Base64 character at position %d)", i + 3)
		end

		local v16 = v12 + v13 * 64 + v14 * 4096 + v15 * 262144

		if v5 + 24 <= 32 then
			v6 = bit32.replace(v6, v16, v5, 24)
			v5 += 24
		else
			if v5 < 32 then
				v6 = bit32.replace(v6, v16, v5, 32 - v5)
			end

			buf[v7] = v6
			v6 = bit32.rshift(v16, 32 - v5)
			v5 -= 8
			v7 += 1
		end
	end

	for i = v4 * 4 + 1, count do
		local v8 = from[string.byte(value, i, i) + 1]

		if v5 + 6 <= 32 then
			v6 = bit32.replace(v6, v8, v5, 6)
			v5 += 6
		else
			buf[v7] = bit32.replace(v6, v8, v5, 32 - v5)
			v6 = bit32.rshift(v8, 32 - v5)
			v5 -= 26
			v7 += 1
		end
	end

	if v5 ~= 0 then
		buf[v7] = v6
	end

	return (setmetatable({
		_buffer = buf,
		_index = 0,
		_size = #value * 6
	}, Bitbuffer))
end

function Bitbuffer.FromBase91(value: string)
	if type(value) == "string" then
		if #value % 2 ~= 0 then
			Error("invalid argument #1 to 'FromBase91' (invalid Base91 string: string length must be an even number)")
		end
	else
		Error("invalid argument #1 to 'FromBase91' (string expected, got %s)", (typeof(value)))
	end

	local buf = table.create(#value / 2 * 13 / 32 + 1)

	local from = v3.From
	local total = 0
	local v4 = 0
	local v5 = 0
	local v6 = 1

	for i = 1, #value, 2 do
		local v7, v8 = string.byte(value, i, i + 1)
		local v9 = from[v7 + 1]
		local v10 = from[v8 + 1]

		if v9 == nil then
			Error("invalid argument #1 to 'FromBase91' (invalid Base91 character at position %d)", i)
		elseif v10 == nil then
			Error("invalid argument #1 to 'FromBase91' (invalid Base91 character at position %d)", i + 1)
		end

		local v11 = v10 * 91 + v9
		local v12 = v11 % 8192 > 88 and 13 or 14
		total += v12

		if v4 + v12 <= 32 then
			v5 = bit32.replace(v5, v11, v4, v12)
			v4 += v12
		else
			local v13 = 32 - v4

			if v13 > 0 then
				v5 = bit32.replace(v5, v11, v4, v13)
			end

			buf[v6] = v5
			v6 += 1
			v5 = bit32.extract(v11, v13, v12 - v13)
			v4 = (v4 + v12) % 32
		end
	end

	if v4 ~= 0 then
		buf[v6] = v5
	end

	return (setmetatable({ _buffer = buf, _index = 0, _size = total }, Bitbuffer))
end

function Bitbuffer.FromBase128(value: string)
	if type(value) ~= "string" then
		Error("invalid argument #1 to 'FromBase128' (string expected, got %s)", (typeof(value)))
	end

	local count = #value
	local buf = table.create(math.ceil(count / 7) * 7)
	local v4 = 0
	local v5 = 0
	local v6 = 1

	for i = 1, count do
		local v7 = string.byte(value, i)

		if v7 > 127 then
			Error(
				"invalid argument #1 to 'FromBase128' (invalid Base128 character at position %d: got %d, expected lower than 128)",
				i,
				v7
			)
		end

		if v4 + 7 <= 32 then
			v5 += bit32.lshift(v7, v4)
			v4 += 7
		else
			local v8 = 32 - v4

			if v8 > 0 then
				buf[v6] = (v5 + bit32.lshift(v7, v4)) % 4294967296
				v5 = bit32.extract(v7, v8, 7 - v8)
				v4 -= 25
			else
				buf[v6] = v5
				v5 = v7
				v4 = 7
			end

			v6 += 1
		end
	end

	if v4 ~= 0 then
		buf[v6] = v5
	end

	return (setmetatable({
		_buffer = buf,
		_index = 0,
		_size = #value * 7
	}, Bitbuffer))
end

function Bitbuffer:ResetCursor()
	self._index = 0
end

function Bitbuffer:SetCursor(value: number)
	if type(value) ~= "number" then
		Error("invalid argument #1 to 'SetCursor' (number expected, got %s)", (typeof(value)))
	end

	self._index = math.max(math.floor(value), 0)
end

function Bitbuffer:GetCursor()
	return self._index
end

function Bitbuffer:ResetBuffer()
	table.clear(self._buffer)
	self._size = 0
	self._index = 0
end

function Bitbuffer:GetSize()
	return self._size
end

function Bitbuffer:ToString()
	local count = #self._buffer

	if count == 0 then
		return ""
	end

	local index = self._index
	self._index = 0
	local readBytesAligned = ReadBytesAligned(self, count * 4)
	self._index = index
	return readBytesAligned
end

function Bitbuffer:ToBase64()
	local buf = self._buffer

	local v4 = buf[1]

	local v5 = math.ceil(#buf * 32 / 24)
	local v6 = table.create(v5)

	local to = v2.To
	local v7 = 0
	local v8 = 2

	for i = 1, v5 do
		local v9

		if v7 + 24 <= 32 then
			v9 = bit32.extract(v4, v7, 24)
			v7 += 24
		else
			local v10 = 32 - v7
			local v11 = not (v10 > 0) and 0 or bit32.extract(v4, v7, v10)
			v4 = buf[v8] or 0
			v8 += 1
			v7 = 24 - v10
			v9 = bit32.replace(v11, v4, v10, v7)
		end

		v6[i] = to[bit32.extract(v9, 0, 6) + 1] .. to[bit32.extract(v9, 6, 6) + 1] .. to[bit32.extract(v9, 12, 6) + 1] .. to[bit32.extract(v9, 18, 6) + 1]
	end

	return table.concat(v6)
end

function Bitbuffer:ToBase91()
	local buf = self._buffer

	local v4 = buf[1]

	local v5 = table.create(#buf * 32 / 13 + 1)

	local to = v3.To
	local v6 = 2
	local v7 = 0
	local v8 = 1

	while v6 <= #buf + 1 do
		local v9

		if v7 + 13 <= 32 then
			v9 = bit32.extract(v4, v7, 13)
			v7 += 13
		else
			local v10 = 32 - v7
			local v11 = v7 - 19
			local v12 = not (v10 > 0) and 0 or bit32.extract(v4, v7, v10)
			v4 = buf[v6] or 0
			v6 += 1
			v9 = bit32.replace(v12, v4, v10, v11)
			v7 = v11
		end

		if v9 <= 88 then
			if v7 == 32 then
				v4 = buf[v6] or 0
				v6 += 1
				v9 += v4 % 2 * 8192
				v7 = 1
			else
				v9 += bit32.extract(v4, v7, 1) * 8192
				v7 += 1
			end
		end

		local v10 = v9 % 91
		local v11 = (v9 - v10) / 91

		v5[v8] = to[v10 + 1] .. to[v11 + 1]
		v8 += 1
	end

	return table.concat(v5)
end

function Bitbuffer:ToBase128()
	local buf = self._buffer
	local v4 = table.create(#buf)
	local v5 = 0

	for i, v6 in ipairs(buf) do
		local v7 = ""

		while v5 + 7 <= 32 do
			v7 ..= v[bit32.extract(v6, v5, 7) + 1]
			v5 += 7
		end

		if v5 < 32 then
			local v8 = 32 - v5
			v7 ..= v[bit32.replace(bit32.extract(v6, v5, v8), buf[i + 1] or 0, v8, 7 - v8) + 1]
			v5 -= 25
		else
			v5 = 0
		end

		v4[i] = v7
	end

	return table.concat(v4)
end

function Bitbuffer.WriteUInt(p, value: number, value2: number)
	if type(value) == "number" then
		if value < 1 or value > 32 then
			Error("invalid argument #1 to 'WriteUInt' (number must be in range [1,32])")
		elseif type(value2) ~= "number" then
			Error("invalid argument #2 to 'WriteUInt' (number expected, got %s)", (typeof(value2)))
		end
	else
		Error("invalid argument #1 to 'WriteUInt' (number expected, got %s)", (typeof(value)))
	end

	WriteToBuffer(p, value, value2)
end

function Bitbuffer.ReadUInt(p, value: number)
	if type(value) == "number" then
		if value < 1 or value > 32 then
			Error("invalid argument #1 to 'ReadUInt' (number must be in range [1,32])")
		end
	else
		Error("invalid argument #1 to 'ReadUInt' (number expected, got %s)", (typeof(value)))
	end

	return ReadFromBuffer(p, value)
end

function Bitbuffer.WriteInt(p, value: number, value2: number)
	if type(value) == "number" then
		if value < 1 or value > 32 then
			Error("invalid argument #1 to 'WriteInt' (number must be in range [1,32])")
		elseif type(value2) ~= "number" then
			Error("invalid argument #2 to 'WriteInt' (number expected, got %s)", (typeof(value2)))
		end
	else
		Error("invalid argument #1 to 'WriteInt' (number expected, got %s)", (typeof(value)))
	end

	WriteToBuffer(p, value, value2 % (bit32.lshift(1, value - 1) * 2))
end

function Bitbuffer.ReadInt(p, value: number)
	if type(value) == "number" then
		if value < 1 or value > 32 then
			Error("invalid argument #1 to 'ReadInt' (number must be in range [1,32])")
		end
	else
		Error("invalid argument #1 to 'ReadInt' (number expected, got %s)", (typeof(value)))
	end

	local readFromBuffer = ReadFromBuffer(p, value)
	local v4 = value == 32 and 4294967296 or bit32.lshift(1, value)

	if v4 / 2 <= readFromBuffer then
		return readFromBuffer - v4
	end

	return readFromBuffer
end

function Bitbuffer.WriteBool(p, p2)
	if p2 then
		WriteToBuffer(p, 1, 1)
	else
		WriteToBuffer(p, 1, 0)
	end
end

function Bitbuffer.ReadBool(p): boolean
	return ReadFromBuffer(p, 1) == 1
end

function Bitbuffer.WriteChar(p, value: string)
	if type(value) == "string" then
		if value == "" then
			Error("invalid argument #1 to 'WriteChar' (string cannot be empty)")
		end
	else
		Error("invalid argument #1 to 'WriteChar' (string expected, got %s)", (typeof(value)))
	end

	WriteToBuffer(p, 8, string.byte(value, 1, 1))
end

function Bitbuffer.ReadChar(p)
	return v[ReadFromBuffer(p, 8) + 1]
end

function Bitbuffer:WriteBytes(value: string)
	if type(value) ~= "string" then
		Error("invalid argument #1 to 'WriteBytes' (string expected, got %s)", (typeof(value)))
	end

	if value == "" then
		return
	end

	if self._index % 8 == 0 then
		WriteBytesAligned(self, value)
		return
	end

	local count = #value

	for i = 1, count / 4 do
		local v4 = i * 4
		local v5, v6, v7, v8 = string.byte(value, v4 - 3, v4)
		WriteToBuffer(self, 32, v5 + v6 * 256 + v7 * 65536 + v8 * 16777216)
	end

	local v4 = count % 4

	if v4 ~= 0 then
		WriteToBuffer(self, v4 * 8, string.unpack("<I" .. v4, value, count - v4 + 1))
	end
end

function Bitbuffer:ReadBytes(value: number)
	if type(value) ~= "number" then
		Error("invalid argument #1 to 'ReadBytes' (number expected, got %s)", (typeof(value)))
	end

	if value <= 0 then
		return ""
	end

	if self._index % 8 == 0 then
		return ReadBytesAligned(self, value)
	end

	local v4 = math.floor(value / 4)
	local v5 = table.create(v4 + value % 4)

	for i = 1, v4 do
		local readFromBuffer = ReadFromBuffer(self, 32)
		v5[i] = string.char(
			bit32.extract(readFromBuffer, 0, 8),
			bit32.extract(readFromBuffer, 8, 8),
			bit32.extract(readFromBuffer, 16, 8),
			(bit32.extract(readFromBuffer, 24, 8))
		)
	end

	for i = 1, value % 4 do
		v5[v4 + i] = v[ReadFromBuffer(self, 8) + 1]
	end

	return table.concat(v5)
end

function Bitbuffer:WriteString(value: string)
	if type(value) ~= "string" then
		Error("invalid argument #1 to 'WriteString' (string expected, got %s)", (typeof(value)))
	end

	local count = #value

	if count > 16777215 then
		Error("invalid argument #1 to 'WriteString' (string length must be lower than 2^24 - 1)")
	end

	WriteToBuffer(self, 24, count)
	self:WriteBytes(value)
end

function Bitbuffer:ReadString()
	return self:ReadBytes(ReadFromBuffer(self, 24))
end

function Bitbuffer.WriteFloat32(p, value: number)
	if type(value) ~= "number" then
		Error("invalid argument #1 to 'WriteFloat32' (number expected, got %s)", (typeof(value)))
	end

	if value == 0 then
		WriteToBuffer(p, 32, 0)
		return
	elseif value == 1e999 then
		WriteToBuffer(p, 32, 2139095040)
		return
	elseif value == -1e999 then
		WriteToBuffer(p, 32, 4286578688)
		return
	end

	if value ~= value then
		WriteToBuffer(p, 32, 2147483647)
		return
	end

	local v4, v5 = math.frexp((math.abs(value)))
	local v6 = math.round((v4 - 0.5) * 16777216)
	local v7 = math.clamp(v5, -127, 128) + 127

	WriteToBuffer(p, 32, (value >= 0 and 0 or 2147483648) + v7 * 8388608 + v6)
end

function Bitbuffer.ReadFloat32(p)
	local readFromBuffer = ReadFromBuffer(p, 32)

	if readFromBuffer == 0 then
		return 0
	elseif readFromBuffer == 2139095040 then
		return 1e999
	elseif readFromBuffer == 4286578688 then
		return -1e999
	elseif readFromBuffer == 2147483647 then
		return (0 / 0)
	end

	local v4 = bit32.band(readFromBuffer, 2147483648) == 0 and 1 or -1
	local v5 = bit32.extract(readFromBuffer, 23, 8) - 127
	return v4 * (readFromBuffer % 8388608 / 8388608 * 0.5 + 0.5) * math.pow(2, v5)
end

function Bitbuffer.WriteFloat64(p, value: number)
	if type(value) ~= "number" then
		Error("invalid argument #1 to 'WriteFloat64' (number expected, got %s)", (typeof(value)))
	end

	local v4, v5, v6, v7, v8, v9, v10, v11 = string.byte(string.pack("<d", value), 1, 8)
	WriteToBuffer(p, 32, v4 + v5 * 256 + v6 * 65536 + v7 * 16777216)
	WriteToBuffer(p, 32, v8 + v9 * 256 + v10 * 65536 + v11 * 16777216)
end

function Bitbuffer.ReadFloat64(p)
	local readFromBuffer = ReadFromBuffer(p, 32)
	local readFromBuffer2 = ReadFromBuffer(p, 32)

	return (string.unpack(
		"<d",
		(string.char(
			bit32.band(readFromBuffer, 255),
			bit32.extract(readFromBuffer, 8, 8),
			bit32.extract(readFromBuffer, 16, 8),
			bit32.extract(readFromBuffer, 24, 8),
			bit32.band(readFromBuffer2, 255),
			bit32.extract(readFromBuffer2, 8, 8),
			bit32.extract(readFromBuffer2, 16, 8),
			(bit32.extract(readFromBuffer2, 24, 8))
		))
	))
end

return Bitbuffer