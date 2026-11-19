local library = {}
local Compression = { Deflate = {}, Zlib = {}, Library = library }

local function Compress(p, p2)
	return library:CompressDeflate(p, p2)
end

Compression.Deflate.Compress = Compress

local function Decompress(p)
	return library:DecompressDeflate(p)
end

Compression.Deflate.Decompress = Decompress

local function Compress2(p, p2)
	return library:CompressZlib(p, p2)
end

Compression.Zlib.Compress = Compress2

local function Decompress2(p)
	return library:DecompressZlib(p)
end

Compression.Zlib.Decompress = Decompress2

library = {}

library._VERSION = "1.0.2-release"
library._MAJOR = "LibDeflate"
library._MINOR = 3
library._COPYRIGHT = "LibDeflate 1.0.2-release Copyright (C) 2018-2020 Haoqian He. Licensed under the zlib License"

local assert = assert
local error = error
local pairs = pairs
local byte = string.byte
local char = string.char
local find = string.find
local gsub = string.gsub
local sub = string.sub
local concat = table.concat
local sort = table.sort
local tostring = tostring
local type = type

local v = {}
local v2 = {}

local v3 = {}

local v4 = {}

local v5 = {}
local v6 = {}

local v7 = {}

local v8 = {}
local v9 = {}

local v10 = {
	16,
	17,
	18,
	0,
	8,
	7,
	9,
	6,
	10,
	5,
	11,
	4,
	12,
	3,
	13,
	2,
	14,
	1,
	15
}
local v11 = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	1,
	1,
	1,
	1,
	2,
	2,
	2,
	2,
	3,
	3,
	3,
	3,
	4,
	4,
	4,
	4,
	5,
	5,
	5,
	5,
	0
}
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = {
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	13,
	15,
	17,
	19,
	23,
	27,
	31,
	35,
	43,
	51,
	59,
	67,
	83,
	99,
	115,
	131,
	163,
	195,
	227,
	258
}

local v16 = {
	[0] = 1,
	2,
	3,
	4,
	5,
	7,
	9,
	13,
	17,
	25,
	33,
	49,
	65,
	97,
	129,
	193,
	257,
	385,
	513,
	769,
	1025,
	1537,
	2049,
	3073,
	4097,
	6145,
	8193,
	12289,
	16385,
	24577
}

local v17 = {
	[0] = 0,
	0,
	0,
	0,
	1,
	1,
	2,
	2,
	3,
	3,
	4,
	4,
	5,
	5,
	6,
	6,
	7,
	7,
	8,
	8,
	9,
	9,
	10,
	10,
	11,
	11,
	12,
	12,
	13,
	13
}
local v18 = nil
local v19 = nil
local v20 = nil
local v21 = nil

for i = 0, 255 do
	v[i] = char(i)
end

local v22 = 1

for i = 0, 32 do
	v2[i] = v22
	v22 *= 2
end

for i = 1, 9 do
	v3[i] = {}

	for j = 0, v2[i + 1] - 1 do
		local v23 = j
		local v24 = 0

		for _ = 1, i do
			local v25 = v24 - v24 % 2 + ((v24 % 2 == 1 or v23 % 2 == 1) and 1 or 0)
			v23 = (v23 - v23 % 2) / 2
			v24 = v25 * 2
		end

		v3[i][j] = (v24 - v24 % 2) / 2
	end
end

local total = 18
local v23 = 16
local total2 = 265
local v24 = 1

for i = 3, 258 do
	if i <= 10 then
		v4[i] = i + 254
		v5[i] = 0
	elseif i == 258 then
		v4[258] = 285
		v5[258] = 0
	else
		if total < i then
			total += v23
			v23 *= 2
			total2 += 4
			v24 += 1
		end

		local v25 = i - total - 1 + v23 / 2
		v4[i] = (v25 - v25 % (v23 / 8)) / (v23 / 8) + total2
		v5[i] = v24
		v6[i] = v25 % (v23 / 8)
	end
end

v7[1] = 0
v7[2] = 1
v8[1] = 0
v8[2] = 0
local v25 = 4
local v26 = 3
local total3 = 2
local count = 0

for i = 3, 256 do
	if v25 < i then
		v26 *= 2
		v25 *= 2
		total3 += 2
		count += 1
	end

	v7[i] = i <= v26 and total3 or total3 + 1
	v8[i] = count < 0 and 0 or count

	if v25 >= 8 then
		v9[i] = (i - v25 / 2 - 1) % (v25 / 4)
	end
end

function library:Adler32(value)
	if type(value) ~= "string" then
		error(("Usage: LibDeflate:Adler32(str): 'str' - string expected got '%s'."):format((type(value))), 2)
	end

	local count2 = #value
	local total4 = 1
	local v27 = 1
	local v28 = 0

	while total4 <= count2 - 15 do
		local v29, v30, v31, v32, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46 = byte(value, total4, total4 + 15)
		v28 = (v28 + v27 * 16 + v29 * 16 + 15 * v30 + 14 * v31 + 13 * v32 + 12 * v35 + 11 * v36 + 10 * v37 + 9 * v38 + 8 * v39 + 7 * v40 + 6 * v41 + 5 * v42 + 4 * v43 + 3 * v44 + 2 * v45 + v46) % 65521
		v27 = (v27 + v29 + v30 + v31 + v32 + v35 + v36 + v37 + v38 + v39 + v40 + v41 + v42 + v43 + v44 + v45 + v46) % 65521
		total4 += 16
	end

	while total4 <= count2 do
		v27 = (v27 + byte(value, total4, total4)) % 65521
		v28 = (v28 + v27) % 65521
		total4 += 1
	end

	return (v28 * 65536 + v27) % 4294967296
end

local function IsEqualAdler32(p, p2): boolean
	return p % 4294967296 == p2 % 4294967296
end

function library:CreateDictionary(value, strlen, adler)
	if type(value) ~= "string" then
		error(
			("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'str' - string expected got '%s'."):format((type(value))),
			2
		)
	end

	if type(strlen) ~= "number" then
		error(
			("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'strlen' - number expected got '%s'."):format((type(strlen))),
			2
		)
	end

	if type(adler) ~= "number" then
		error(
			("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'adler32' - number expected got '%s'."):format((type(adler))),
			2
		)
	end

	if strlen ~= #value then
		error(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'strlen' does not match the actual length of 'str'. 'strlen': %u, '#str': %u . Please check if 'str' is modified unintentionally."):format(
			strlen,
			#value
		))
	end

	if strlen == 0 then
		error("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'str' - Empty string is not allowed.", 2)
	end

	if strlen > 32768 then
		error(
			("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'str' - string longer than 32768 bytes is not allowed. Got %d bytes."):format(strlen),
			2
		)
	end

	local adler32 = self:Adler32(value)

	if adler % 4294967296 ~= adler32 % 4294967296 then
		error(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'adler32' does not match the actual adler32 of 'str'. 'adler32': %u, 'Adler32(str)': %u . Please check if 'str' is modified unintentionally."):format(
			adler,
			adler32
		))
	end

	local dictionary = { ["adler32"] = adler, hash_tables = {}, string_table = {}, strlen = strlen }

	local string_table = dictionary.string_table
	local hash_tables = dictionary.hash_tables
	string_table[1] = byte(value, 1, 1)
	string_table[2] = byte(value, 2, 2)

	if not (strlen >= 3) then
		return dictionary
	end

	local v27 = string_table[1] * 256 + string_table[2]
	local v28 = 1

	while v28 <= strlen - 2 - 3 do
		local v29, v30, v31, v32 = byte(value, v28 + 2, v28 + 5)
		string_table[v28 + 2] = v29
		string_table[v28 + 3] = v30
		string_table[v28 + 4] = v31
		string_table[v28 + 5] = v32
		local v36 = (v27 * 256 + v29) % 16777216
		local v37 = hash_tables[v36]

		if not v37 then
			v37 = {}
			hash_tables[v36] = v37
		end

		v37[#v37 + 1] = v28 - strlen
		local v38 = v28 + 1
		local v39 = (v36 * 256 + v30) % 16777216
		local v40 = hash_tables[v39]

		if not v40 then
			v40 = {}
			hash_tables[v39] = v40
		end

		v40[#v40 + 1] = v38 - strlen
		local v41 = v38 + 1
		local v42 = (v39 * 256 + v31) % 16777216
		local v43 = hash_tables[v42]

		if not v43 then
			v43 = {}
			hash_tables[v42] = v43
		end

		v43[#v43 + 1] = v41 - strlen
		local v44 = v41 + 1
		v27 = (v42 * 256 + v32) % 16777216
		local v45 = hash_tables[v27]

		if not v45 then
			v45 = {}
			hash_tables[v27] = v45
		end

		v45[#v45 + 1] = v44 - strlen
		v28 = v44 + 1
	end

	while v28 <= strlen - 2 do
		local v29 = byte(value, v28 + 2)
		string_table[v28 + 2] = v29
		v27 = (v27 * 256 + v29) % 16777216
		local v30 = hash_tables[v27]

		if not v30 then
			v30 = {}
			hash_tables[v27] = v30
		end

		v30[#v30 + 1] = v28 - strlen
		v28 += 1
	end

	return dictionary
end

local function IsValidDictionary(data)
	if type(data) ~= "table" then
		return false, ("'dictionary' - table expected got '%s'."):format((type(data)))
	end

	if
		type(data.adler32) == "number"
		and type(data.string_table) == "table"
		and type(data.strlen) == "number"
		and not (data.strlen <= 0)
		and not (data.strlen > 32768)
		and data.strlen == #data.string_table
		and type(data.hash_tables) == "table"
	then
		return true, ""
	end

	return false, ("'dictionary' - corrupted dictionary."):format((type(data)))
end

local v27 = {
	[0] = { false, nil, 0, 0, 0 },
	[1] = { false, nil, 4, 8, 4 },
	[2] = { false, nil, 5, 18, 8 },
	[3] = { false, nil, 6, 32, 32 },
	[4] = { true, 4, 4, 16, 16 },
	[5] = { true, 8, 16, 32, 32 },
	[6] = { true, 8, 16, 128, 128 },
	[7] = { true, 8, 32, 128, 256 },
	[8] = { true, 32, 128, 258, 1024 },
	[9] = { true, 32, 258, 258, 4096 }
}

local function IsValidArguments(p, p2, p3, p4, items)
	if type(p) ~= "string" then
		return false, ("'str' - string expected got '%s'."):format((type(p)))
	end

	if p2 then
		local v28, v29 = IsValidDictionary(p3)

		if not v28 then
			return false, v29
		end
	end

	if not p4 then
		return true, ""
	end

	local typeName = type(items)

	if typeName ~= "nil" and typeName ~= "table" then
		return false, ("'configs' - nil or table expected got '%s'."):format((type(items)))
	end

	if typeName ~= "table" then
		return true, ""
	end

	for k, item in pairs(items) do
		if k ~= "level" and k ~= "strategy" then
			return false, ("'configs' - unsupported table key in the configs: '%s'."):format(k)
		end

		if k == "level" and not v27[item] then
			return false, ("'configs' - unsupported 'level': %s."):format((tostring(item)))
		end

		if k == "strategy" and item ~= "fixed" and item ~= "huffman_only" and item ~= "dynamic" then
			return false, ("'configs' - unsupported 'strategy': '%s'."):format((tostring(item)))
		end
	end

	return true, ""
end

local function CreateWriter()
	local count2 = 0
	local v28 = 0
	local v29 = 0
	local total4 = 0
	local v30 = {}

	local joineds = {}

	local function WriteBits(p, p2)
		v28 += p * v2[v29]
		v29 += p2
		total4 += p2

		if v29 >= 32 then
			count2 += 1
			v30[count2] = v[v28 % 256] .. v[(v28 - v28 % 256) / 256 % 256] .. v[(v28 - v28 % 65536) / 65536 % 256] .. v[(v28 - v28 % 16777216) / 16777216 % 256]
			local v31 = v2[32 - v29 + p2]
			v28 = (p - p % v31) / v31
			v29 -= 32
		end
	end

	local function WriteString(list)
		for _ = 1, v29, 8 do
			count2 += 1
			v30[count2] = char(v28 % 256)
			v28 = (v28 - v28 % 256) / 256
		end

		v29 = 0
		count2 += 1
		v30[count2] = list
		total4 += #list * 8
	end

	local function FlushWriter(p)
		if p == 3 then
			return total4
		end

		if p == 1 or p == 2 then
			local v31 = (8 - v29 % 8) % 8

			if v29 > 0 then
				v28 = v28 - v2[v29] + v2[v29 + v31]

				for _ = 1, v29, 8 do
					count2 += 1
					v30[count2] = v[v28 % 256]
					v28 = (v28 - v28 % 256) / 256
				end

				v28 = 0
				v29 = 0
			end

			if p == 2 then
				total4 += v31
				return total4
			end
		end

		local joined = concat(v30)
		v30 = {}
		count2 = 0
		joineds[#joineds + 1] = joined

		if p == 0 then
			return total4
		end

		return total4, concat(joineds)
	end

	return WriteBits, WriteString, FlushWriter
end

local function MinHeapPush(p, list, p2)
	p2 += 1
	p[p2] = list
	local item = list[1]

	local v28 = (p2 - p2 % 2) / 2

	while v28 >= 1 and item < p[v28][1] do
		local v29 = p[v28]
		p[v28] = list
		p[p2] = v29
		p2 = v28
		v28 = (v28 - v28 % 2) / 2
	end
end

local function MinHeapPop(list, p)
	local item = list[1]
	local item2 = list[p]
	local v28 = item2[1]
	list[1] = item2
	list[p] = item
	local v29 = p - 1

	local v30 = 1
	local v31 = v30 * 2
	local v32 = v31 + 1

	while v31 <= v29 do
		local item3 = list[v31]
		local v34

		if v32 <= v29 and list[v32][1] < item3[1] then
			local item4 = list[v32]

			if not (item4[1] < v28) then
				break
			end

			list[v32] = item2
			list[v30] = item4

			v34 = v32 * 2
			v30 = v32
			v32 = v34 + 1
		else
			if not (item3[1] < v28) then
				break
			end

			list[v31] = item2
			list[v30] = item3

			v34 = v31 * 2
			v32 = v34 + 1
			v30 = v31
		end

		v31 = v34
	end

	return item
end

local function GetHuffmanCodeFromBitlen(p, list, p2, p3)
	local v28 = 0
	local v29 = {}
	local huffmanCode = {}

	for i = 1, p3 do
		v28 = (v28 + (p[i - 1] or 0)) * 2
		v29[i] = v28
	end

	for i = 0, p2 do
		local item = list[i]

		if not item then
			continue
		end

		local v30 = v29[item]
		v29[item] = v30 + 1

		if item <= 9 then
			huffmanCode[i] = v3[item][v30]
		else
			local v31 = 0

			for _ = 1, item do
				local v32 = v31 - v31 % 2 + ((v31 % 2 == 1 or v30 % 2 == 1) and 1 or 0)
				v30 = (v30 - v30 % 2) / 2
				v31 = v32 * 2
			end

			huffmanCode[i] = (v31 - v31 % 2) / 2
		end
	end

	return huffmanCode
end

local function SortByFirstThenSecond(list, list2): boolean
	if list[1] < list2[1] then
		return true
	elseif list[1] == list2[1] then
		return list[2] < list2[2]
	else
		return false
	end
end

local function GetHuffmanBitlenAndCode(items, p, p2)
	local v28 = 0
	local v29 = {}
	local v30 = {}
	local result = {}
	local v31 = -1
	local v32 = {}
	local v34 = {}

	for k, item in pairs(items) do
		v28 += 1
		v29[v28] = { item, k }
	end

	if v28 == 0 then
		return {}, {}, -1
	end

	if v28 == 1 then
		local v35 = v29[1][2]
		result[v35] = 1
		v34[v35] = 0
		return result, v34, v35
	else
		sort(v29, SortByFirstThenSecond)

		for i = 1, v28 do
			v30[i] = v29[i]
		end

		while v28 > 1 do
			local minHeapPop = MinHeapPop(v30, v28)
			v28 -= 1
			local minHeapPop2 = MinHeapPop(v30, v28)
			v28 -= 1

			MinHeapPush(v30, {
				minHeapPop[1] + minHeapPop2[1],
				-1,
				minHeapPop,
				minHeapPop2
			}, v28)
			v28 += 1
		end

		local v35 = { v30[1], 0, 0, 0 }

		v30[1][1] = 0
		local v36 = 1
		local v37 = 1
		local v38 = 0

		while v36 <= v37 do
			local v39 = v35[v36]
			local v40 = v39[1]
			local v41 = v39[2]
			local v42 = v39[3]
			local v43 = v39[4]

			if v42 then
				v37 += 1
				v35[v37] = v42
				v42[1] = v40 + 1
			end

			if v43 then
				v37 += 1
				v35[v37] = v43
				v43[1] = v40 + 1
			end

			v36 += 1

			if p < v40 then
				v38 += 1
				v40 = p
			end

			if not (v41 >= 0) then
				continue
			end

			result[v41] = v40

			v31 = v31 < v41 and v41 or v31

			v32[v40] = (v32[v40] or 0) + 1
		end

		if v38 > 0 then
			repeat
				local v39 = p - 1

				while (v32[v39] or 0) == 0 do
					v39 -= 1
				end

				v32[v39] -= 1

				v32[v39 + 1] = (v32[v39 + 1] or 0) + 2
				v32[p] -= 1
				v38 -= 2
			until v38 <= 0

			local v39 = 1

			for i = p, 1, -1 do
				local v40 = v32[i] or 0

				while v40 > 0 do
					result[v29[v39][2]] = i
					v40 -= 1
					v39 += 1
				end
			end
		end

		return result, GetHuffmanCodeFromBitlen(v32, result, p2, p), v31
	end
end

local function RunLengthEncodeHuffmanBitlen(list, p, p2, p3)
	local v28 = p + (p3 < 0 and 0 or p3) + 1
	local v29 = nil
	local v30 = 0
	local count2 = 0
	local result = {}
	local count3 = 0
	local result2 = {}
	local result3 = {}

	for i = 0, v28 + 1 do
		local v31

		if i <= p then
			v31 = list[i] or 0
		else
			v31 = i <= v28 and (p2[i - p - 1] or 0) or nil
		end

		if v31 == v29 then
			v30 += 1

			if v31 == 0 or v30 ~= 6 then
				if v31 == 0 and v30 == 138 then
					count2 += 1
					result[count2] = 18
					count3 += 1
					result2[count3] = 127
					result3[18] = (result3[18] or 0) + 1
					v30 = 0
				end
			else
				count2 += 1
				result[count2] = 16
				count3 += 1
				result2[count3] = 3
				result3[16] = (result3[16] or 0) + 1
				v30 = 0
			end
		else
			if v30 == 1 then
				count2 += 1
				result[count2] = v29
				result3[v29] = (result3[v29] or 0) + 1
			elseif v30 == 2 then
				count2 += 1
				result[count2] = v29
				count2 += 1
				result[count2] = v29
				result3[v29] = (result3[v29] or 0) + 2
			elseif v30 >= 3 then
				count2 += 1
				local v32 = v29 == 0 and (v30 <= 10 and 17 or 18) or 16
				result[count2] = v32
				result3[v32] = (result3[v32] or 0) + 1
				count3 += 1
				result2[count3] = v30 <= 10 and v30 - 3 or v30 - 11
			end

			if v31 and v31 ~= 0 then
				count2 += 1
				result[count2] = v31
				result3[v31] = (result3[v31] or 0) + 1
				v29 = v31
				v30 = 0
			else
				v29 = v31
				v30 = 1
			end
		end
	end

	return result, result2, result3
end

local function LoadStringToTable(value, p, p2, p3, p4)
	local v28 = p2 - p4

	while v28 <= p3 - 15 - p4 do
		local v29 = v28 + 1
		local v30 = v28 + 2
		local v31 = v28 + 3
		local v32 = v28 + 4
		local v34 = v28 + 5
		local v35 = v28 + 6
		local v36 = v28 + 7
		local v37 = v28 + 8
		local v38 = v28 + 9
		local v39 = v28 + 10
		local v40 = v28 + 11
		local v41 = v28 + 12
		local v42 = v28 + 13
		local v43 = v28 + 14
		local v44 = v28 + 15
		local v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60, v61, v62 = byte(value, v28 + p4, v28 + 15 + p4)
		p[v28] = v47
		p[v29] = v48
		p[v30] = v49
		p[v31] = v50
		p[v32] = v51
		p[v34] = v52
		p[v35] = v53
		p[v36] = v54
		p[v37] = v55
		p[v38] = v56
		p[v39] = v57
		p[v40] = v58
		p[v41] = v59
		p[v42] = v60
		p[v43] = v61
		p[v44] = v62

		v28 += 16
	end

	while v28 <= p3 - p4 do
		p[v28] = byte(value, v28 + p4, v28 + p4)
		v28 += 1
	end

	return p
end

local function GetBlockLZ77Result(p, list, p2, p3, p4, p5, data)
	local v28 = v27[p]

	local v29 = v28[1]
	local v30 = v28[2]
	local v31 = v28[3]
	local v32 = v28[4]
	local v34 = v28[5]
	local v35 = (v29 or not v31) and 2147483646 or v31
	local v36 = v34 - v34 % 4 / 4
	local hash_tables, string_table, v37

	if data then
		hash_tables = data.hash_tables
		string_table = data.string_table
		v37 = data.strlen
		assert(p3 == 1)

		if p3 <= p4 and v37 >= 2 then
			local v38 = string_table[v37 - 1] * 65536 + string_table[v37] * 256 + list[1]
			local v39 = p2[v38]

			if not v39 then
				v39 = {}
				p2[v38] = v39
			end

			v39[#v39 + 1] = -1
		end

		if p3 + 1 <= p4 and v37 >= 1 then
			local v38 = string_table[v37] * 65536 + list[1] * 256 + list[2]
			local v39 = p2[v38]

			if not v39 then
				v39 = {}
				p2[v38] = v39
			end

			v39[#v39 + 1] = 0
		end
	else
		v37 = 0
	end

	local v38 = v37 + 3

	local v39 = (list[p3 - p5] or 0) * 256 + (list[p3 + 1 - p5] or 0)

	local v40 = p4 + (v29 and 1 or 0)
	local v41 = 0
	local v42 = 0
	local v43 = false
	local count2 = 0
	local result = {}

	local result2 = {}
	local count3 = 0
	local result3 = {}

	local result4 = {}
	local count4 = 0
	local result5 = {}
	local count5 = 0
	local result6 = {}

	while p3 <= v40 do
		local v44 = p3 - p5
		local v45 = p5 - 3

		local v46 = 0

		v39 = (v39 * 256 + (list[v44 + 2] or 0)) % 16777216

		local v47 = nil
		local v48 = p2[v39]
		local v49, v50

		if v48 then
			v49 = #v48
			v47 = v48
			v50 = v49
		else
			v49 = 0
			v48 = {}
			p2[v39] = v48

			if hash_tables then
				v47 = hash_tables[v39]
				v50 = v47 and #v47 or 0
			else
				v50 = 0
			end
		end

		if p3 <= p4 then
			v48[v49 + 1] = p3
		end

		local v51, v52

		if v50 > 0 and p3 + 2 <= p4 and (not v29 or v41 < v31) then
			local v53 = if v29 and v30 <= v41 and v36 then v36 else v34

			local v54 = p4 - p3

			local v55 = (v54 >= 257 and 257 or v54) + v44
			local v56 = v44 + 3
			v51 = v42
			v52 = v41

			while true do
				if not (v50 >= 1 and v53 > 0) then
					v41 = v46
					break
				end

				local v57 = v47[v50]

				if p3 - v57 > 32768 then
					v41 = v46
					break
				end

				if v57 < p3 then
					local v58

					if v57 >= -257 then
						local v59 = v57 - v45
						v58 = v56

						while v58 <= v55 and list[v59] == list[v58] do
							v58 += 1
							v59 += 1
						end
					else
						local v59 = v38 + v57
						v58 = v56

						while v58 <= v55 and string_table[v59] == list[v58] do
							v58 += 1
							v59 += 1
						end
					end

					v41 = v58 - v44

					if v46 < v41 then
						v42 = p3 - v57
					else
						v41 = v46
					end

					if v32 <= v41 then
						break
					end
				else
					v41 = v46
				end

				v50 -= 1
				v53 -= 1

				if v50 == 0 and v57 > 0 and hash_tables then
					v47 = hash_tables[v39]
					v50 = v47 and #v47 or 0
				end

				v46 = v41
			end
		else
			v51 = v42
			v52 = v41
			v41 = v46
		end

		if not v29 then
			v51 = v42
			v52 = v41
		end

		if v29 and not v43 or not (v52 > 3) and (v52 ~= 3 or not (v51 < 4096)) or not (v41 <= v52) then
			if v29 and not v43 then
				p3 += 1
				v43 = true
			else
				v44 = v29 and v44 - 1 or v44
				local item = list[v44]
				count2 += 1
				result[count2] = item
				result2[item] = (result2[item] or 0) + 1
				p3 += 1
			end
		else
			local v53 = v4[v52]

			local v54 = v5[v52]
			local v55, v56, v57

			if v51 <= 256 then
				v55 = v7[v51]
				v56 = v9[v51]

				v57 = v8[v51]
			else
				local v58 = 384
				local v59 = 512
				v55 = 16
				v57 = 7

				while true do
					if v51 <= v58 then
						v56 = (v51 - v59 / 2 - 1) % (v59 / 4)
						break
					end

					if v51 <= v59 then
						v56 = (v51 - v59 / 2 - 1) % (v59 / 4)
						v55 += 1
						break
					end

					v55 += 2
					v57 += 1
					v58 *= 2
					v59 *= 2
				end
			end

			count2 += 1
			result[count2] = v53
			result2[v53] = (result2[v53] or 0) + 1

			count3 += 1
			result3[count3] = v55
			result4[v55] = (result4[v55] or 0) + 1

			if v54 > 0 then
				local v58 = v6[v52]
				count4 += 1
				result5[count4] = v58
			end

			if v57 > 0 then
				count5 += 1
				result6[count5] = v56
			end

			for i = p3 + 1, p3 + v52 - (v29 and 2 or 1) do
				v39 = (v39 * 256 + (list[i - p5 + 2] or 0)) % 16777216

				if not (v52 <= v35) then
					continue
				end

				local v58 = p2[v39]

				if not v58 then
					v58 = {}
					p2[v39] = v58
				end

				v58[#v58 + 1] = i
			end

			p3 = p3 + v52 - (v29 and 1 or 0)
			v43 = false
		end
	end

	result[count2 + 1] = 256
	result2[256] = (result2[256] or 0) + 1

	return result, result5, result2, result3, result6, result4
end

local function GetBlockDynamicHuffmanHeader(p, p2)
	local v28, v29, v30 = GetHuffmanBitlenAndCode(p, 15, 285)

	local v31, v32, v34 = GetHuffmanBitlenAndCode(p2, 15, 29)

	local v35, v36, v37 = RunLengthEncodeHuffmanBitlen(v28, v30, v31, v34)

	local v38, v39 = GetHuffmanBitlenAndCode(v37, 7, 18)
	local v40 = 0

	for i = 1, 19 do
		if (v38[v10[i]] or 0) ~= 0 then
			v40 = i
		end
	end

	local v41 = v40 - 4
	local v42 = v30 + 1 - 257
	local v43 = v34 + 1 - 1
	return v42, v43 < 0 and 0 or v43, v41, v38, v39, v35, v36, v28, v29, v31, v32
end

local function GetDynamicHuffmanBlockSize(list, p, p2, p3, list2, p4, p5)
	local dynamicHuffmanBlockSize = 17 + (p2 + 4) * 3

	for i = 1, #list2 do
		local item = list2[i]
		dynamicHuffmanBlockSize += p3[item]

		if item >= 16 then
			dynamicHuffmanBlockSize += item == 16 and 2 or item == 17 and 3 or 7
		end
	end

	local count2 = 0

	for i = 1, #list do
		local item = list[i]
		dynamicHuffmanBlockSize += p4[item]

		if not (item > 256) then
			continue
		end

		count2 += 1

		if item > 264 and item < 285 then
			dynamicHuffmanBlockSize += v11[item - 256]
		end

		local v28 = p[count2]
		dynamicHuffmanBlockSize += p5[v28]

		if v28 > 3 then
			dynamicHuffmanBlockSize += (v28 - v28 % 2) / 2 - 1
		end
	end

	return dynamicHuffmanBlockSize
end

local function CompressDynamicHuffmanBlock(callback, flag, list, p, p2, p3, p4, p5, p6, p7, p8, list2, p9, p10, p11, p12, p13)
	callback(flag and 1 or 0, 1)
	callback(2, 2)

	callback(p4, 5)
	callback(p5, 5)
	callback(p6, 4)

	for i = 1, p6 + 4 do
		callback(p7[v10[i]] or 0, 3)
	end

	local v28 = 1

	for i = 1, #list2 do
		local item = list2[i]
		callback(p8[item], p7[item])

		if not (item >= 16) then
			continue
		end

		callback(p9[v28], item == 16 and 2 or item == 17 and 3 or 7)
		v28 += 1
	end

	local count2 = 0
	local count3 = 0
	local count4 = 0

	for i = 1, #list do
		local item = list[i]
		callback(p11[item], p10[item])

		if not (item > 256) then
			continue
		end

		count2 += 1

		if item > 264 and item < 285 then
			count3 += 1
			callback(p[count3], v11[item - 256])
		end

		local v29 = p2[count2]
		callback(p13[v29], p12[v29])

		if not (v29 > 3) then
			continue
		end

		count4 += 1
		callback(p3[count4], (v29 - v29 % 2) / 2 - 1)
	end
end

local function GetFixedHuffmanBlockSize(list, p)
	local fixedHuffmanBlockSize = 3
	local count2 = 0

	for i = 1, #list do
		local item = list[i]
		fixedHuffmanBlockSize += v12[item]

		if not (item > 256) then
			continue
		end

		count2 += 1

		if item > 264 and item < 285 then
			fixedHuffmanBlockSize += v11[item - 256]
		end

		local v28 = p[count2]
		fixedHuffmanBlockSize += 5

		if v28 > 3 then
			fixedHuffmanBlockSize += (v28 - v28 % 2) / 2 - 1
		end
	end

	return fixedHuffmanBlockSize
end

local function CompressFixedHuffmanBlock(callback, flag, list, p, p2, p3)
	callback(flag and 1 or 0, 1)
	callback(1, 2)
	local count2 = 0
	local count3 = 0
	local count4 = 0

	for i = 1, #list do
		local item = list[i]
		callback(v13[item], v12[item])

		if not (item > 256) then
			continue
		end

		count2 += 1

		if item > 264 and item < 285 then
			count3 += 1
			callback(p[count3], v11[item - 256])
		end

		local v28 = p2[count2]
		callback(v14[v28], 5)

		if not (v28 > 3) then
			continue
		end

		count4 += 1
		callback(p3[count4], (v28 - v28 % 2) / 2 - 1)
	end
end

local function GetStoreBlockSize(p, p2, p3) -- 1 equivalent call inferred from this helper
	assert(p2 - p + 1 <= 65535)

	return 3 + (8 - (p3 + 3) % 8) % 8 + 32 + (p2 - p + 1) * 8
end

local function CompressStoreBlock(callback, callback2, flag, value, p, p2, p3)
	assert(p2 - p + 1 <= 65535)
	callback(flag and 1 or 0, 1)
	callback(0, 2)
	local v28 = (8 - (p3 + 3) % 8) % 8

	if v28 > 0 then
		callback(v2[v28] - 1, v28)
	end

	local v29 = p2 - p + 1
	callback(v29, 16)

	callback(255 - v29 % 256 + (255 - (v29 - v29 % 256) / 256) * 256, 16)

	callback2(value:sub(p, p2))
end

local function Deflate(p, p2, p3, callback, list, p4)
	local v28 = {}
	local v29 = {}
	local flag = nil
	local v30 = nil
	local v31 = nil

	local v32 = callback(3)
	local count2 = #list

	local v34 = nil
	local strategy = nil

	if p then
		if p.level then
			v34 = p.level
		end

		if p.strategy then
			strategy = p.strategy
		end
	end

	if not v34 then
		if count2 < 2048 then
			v34 = 7
		else
			v34 = if count2 > 65536 then 3 else 5
		end
	end

	while not flag do
		local v35

		if v30 then
			v30 = v31 + 1
			v31 += 32768
			v35 = v30 - 32768 - 1
		else
			v31 = 65535
			v30 = 1
			v35 = 0
		end

		if count2 <= v31 then
			v31 = count2
			flag = true
		else
			flag = false
		end

		local v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52

		if v34 ~= 0 then
			LoadStringToTable(list, v28, v30, v31 + 3, v35)

			if v30 == 1 and p4 then
				local string_table = p4.string_table
				local strlen = p4.strlen

				for i = 0, -strlen + 1 < -257 and -257 or -strlen + 1, -1 do
					v28[i] = string_table[strlen + i]
				end
			end

			local v53, v54

			if strategy == "huffman_only" then
				v38 = {}
				LoadStringToTable(list, v38, v30, v31, v30 - 1)

				v38[v31 - v30 + 2] = 256
				v53 = {}
				v39 = {}

				for i = 1, v31 - v30 + 2 do
					local v55 = v38[i]
					v53[v55] = (v53[v55] or 0) + 1
				end

				v54 = {}
				v40 = {}
				v41 = {}
			else
				v38, v39, v53, v40, v41, v54 = GetBlockLZ77Result(v34, v28, v29, v30, v31, v35, p4)
			end

			v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52 = GetBlockDynamicHuffmanHeader(v53, v54)
			v37 = GetDynamicHuffmanBlockSize(v38, v40, v44, v45, v47, v49, v51)

			v36 = GetFixedHuffmanBlockSize(v38, v40)
		end

		local storeBlockSize = GetStoreBlockSize(v30, v31, v32) -- inferred equivalent call
		local v54

		if v36 and v36 < storeBlockSize and v36 then
			v54 = v36
		else
			v54 = storeBlockSize
		end

		if v37 and v37 < v54 and v37 then
			v54 = v37
		end

		if v34 == 0 or strategy ~= "fixed" and strategy ~= "dynamic" and storeBlockSize == v54 then
			CompressStoreBlock(p2, p3, flag, list, v30, v31, v32)

			v32 += storeBlockSize
		elseif strategy == "dynamic" or strategy ~= "fixed" and v36 ~= v54 then
			if strategy == "dynamic" or v37 == v54 then
				CompressDynamicHuffmanBlock(
					p2,
					flag,
					v38,
					v39,
					v40,
					v41,
					v42,
					v43,
					v44,
					v45,
					v46,
					v47,
					v48,
					v49,
					v50,
					v51,
					v52
				)

				v32 += v37
			end
		else
			CompressFixedHuffmanBlock(p2, flag, v38, v39, v40, v41)

			v32 += v36
		end

		local v55

		if flag then
			v55 = callback(3)
		else
			v55 = callback(0)
		end

		assert(v55 == v32)

		if flag then
			continue
		end

		if p4 and v30 == 1 then
			local v57 = 0

			while v28[v57] do
				v28[v57] = nil
				v57 -= 1
			end
		end

		local v57 = 1
		p4 = nil

		for i = v31 - 32767, v31 do
			v28[v57] = v28[i - v35]
			v57 += 1
		end

		for k, v58 in pairs(v29) do
			local count3 = #v58

			if not (count3 > 0 and v31 + 1 - v58[1] > 32768) then
				continue
			end

			if count3 == 1 then
				v29[k] = nil
			else
				local count4 = 0
				local v59 = {}

				for i = 2, count3 do
					local v60 = v58[i]

					if not (v31 + 1 - v60 <= 32768) then
						continue
					end

					count4 += 1
					v59[count4] = v60
				end

				v29[k] = v59
			end
		end
	end
end

local function CompressDeflateInternal(p, p2, p3)
	local WriteBits, WriteString, FlushWriter = CreateWriter()
	Deflate(p3, WriteBits, WriteString, FlushWriter, p, p2)
	local v28, v29 = FlushWriter(1)
	return v29, (8 - v28 % 8) % 8
end

local function CompressZlibInternal(p, p2, p3)
	local WriteBits, WriteString, FlushWriter = CreateWriter()

	WriteBits(120, 8)
	local v28 = p2 and 1 or 0
	local v29 = 128 + v28 * 32
	WriteBits(v29 + (31 - (30720 + v29) % 31), 8)

	if v28 == 1 then
		local adler32 = p2.adler32
		local v30 = adler32 % 256
		local v31 = (adler32 - v30) / 256
		local v32 = v31 % 256
		local v37 = (v31 - v32) / 256
		local v38 = v37 % 256
		WriteBits((v37 - v38) / 256 % 256, 8)
		WriteBits(v38, 8)
		WriteBits(v32, 8)
		WriteBits(v30, 8)
	end

	Deflate(p3, WriteBits, WriteString, FlushWriter, p, p2)
	FlushWriter(2)

	local adler32 = library:Adler32(p)

	local v30 = adler32 % 256
	local v31 = (adler32 - v30) / 256
	local v32 = v31 % 256
	local v37 = (v31 - v32) / 256
	local v38 = v37 % 256
	WriteBits((v37 - v38) / 256 % 256, 8)
	WriteBits(v38, 8)
	WriteBits(v32, 8)
	WriteBits(v30, 8)
	local v39, v40 = FlushWriter(1)
	return v40, (8 - v39 % 8) % 8
end

function library:CompressDeflate(p, p2)
	local v28, v29 = IsValidArguments(p, false, nil, true, p2)

	if not v28 then
		error("Usage: LibDeflate:CompressDeflate(str, configs): " .. v29, 2)
	end

	return CompressDeflateInternal(p, nil, p2)
end

function library.CompressDeflateWithDict(_, p, p2, p3)
	local v28, v29 = IsValidArguments(p, true, p2, true, p3)

	if not v28 then
		error("Usage: LibDeflate:CompressDeflateWithDict" .. "(str, dictionary, configs): " .. v29, 2)
	end

	return CompressDeflateInternal(p, p2, p3)
end

function library:CompressZlib(p, p2)
	local v28, v29 = IsValidArguments(p, false, nil, true, p2)

	if not v28 then
		error("Usage: LibDeflate:CompressZlib(str, configs): " .. v29, 2)
	end

	return CompressZlibInternal(p, nil, p2)
end

function library.CompressZlibWithDict(_, p, p2, p3)
	local v28, v29 = IsValidArguments(p, true, p2, true, p3)

	if not v28 then
		error("Usage: LibDeflate:CompressZlibWithDict" .. "(str, dictionary, configs): " .. v29, 2)
	end

	return CompressZlibInternal(p, p2, p3)
end

local function CreateReader(value)
	local count2 = #value
	local total4 = 1
	local v28 = 0
	local v29 = 0

	local function ReadBits(p)
		local v30 = v2[p]

		if p <= v28 then
			local v31 = v29 % v30
			v29 = (v29 - v31) / v30
			v28 -= p
			return v31
		else
			local v31 = v2[v28]

			local v32 = total4
			local v35, v36, v37, v38 = byte(value, v32, total4 + 3)

			v29 += ((v35 or 0) + (v36 or 0) * 256 + (v37 or 0) * 65536 + (v38 or 0) * 16777216) * v31
			total4 += 4
			v28 = v28 + 32 - p
			local v39 = v29 % v30
			v29 = (v29 - v39) / v30

			return v39
		end
	end

	local function ReadBytes(p, p2, count3)
		assert(v28 % 8 == 0)
		local v30

		if v28 / 8 < p then
			v30 = v28 / 8 or p
		else
			v30 = p
		end

		for _ = 1, v30 do
			local v31 = v29 % 256
			count3 += 1
			p2[count3] = char(v31)
			v29 = (v29 - v31) / 256
		end

		v28 -= v30 * 8
		local v31 = p - v30

		if (count2 - total4 - v31 + 1) * 8 + v28 < 0 then
			return -1
		end

		for i = total4, total4 + v31 - 1 do
			count3 += 1
			p2[count3] = sub(value, i, i)
		end

		total4 += v31
		return count3
	end

	local function Decode(list, p, p2)
		local v30, v31, v32

		if p2 > 0 then
			if v28 < 15 and value then
				local v34 = v2[v28]

				local v35 = total4
				local v37, v38, v39, v40 = byte(value, v35, total4 + 3)

				v29 += ((v37 or 0) + (v38 or 0) * 256 + (v39 or 0) * 65536 + (v40 or 0) * 16777216) * v34
				total4 += 4
				v28 += 32
			end

			local v34 = v2[p2]
			v28 -= p2
			local v35 = v29 % v34
			v29 = (v29 - v35) / v34

			local v36 = v3[p2][v35]

			v30 = list[p2]

			if v36 < v30 then
				return p[v36]
			end

			v31 = v30 * 2
			v32 = v36 * 2
		else
			v32 = 0
			v31 = 0
			v30 = 0
		end

		for i = p2 + 1, 15 do
			local v34 = v29 % 2
			v29 = (v29 - v34) / 2
			v28 -= 1

			v32 = v34 == 1 and v32 + 1 - v32 % 2 or v32
			local v35 = list[i] or 0
			local v36 = v32 - v31

			if v36 < v35 then
				return p[v30 + v36]
			end

			v30 += v35
			v31 = (v31 + v35) * 2
			v32 *= 2
		end

		return -10
	end

	local function ReaderBitlenLeft()
		return (count2 - total4 + 1) * 8 + v28
	end

	local function SkipToByteBoundary()
		local v30 = v28 % 8
		local v31 = v2[v30]
		v28 -= v30
		v29 = (v29 - v29 % v31) / v31
	end

	return ReadBits, ReadBytes, Decode, ReaderBitlenLeft, SkipToByteBoundary
end

local function CreateDecompressState(p, dictionary)
	local readBits, readBytes, decode, readerBitlenLeft, skipToByteBoundary = CreateReader(p)

	return {
		ReadBits = readBits,
		ReadBytes = readBytes,
		Decode = decode,
		ReaderBitlenLeft = readerBitlenLeft,
		SkipToByteBoundary = skipToByteBoundary,
		buffer_size = 0,
		buffer = {},
		result_buffer = {},
		dictionary = dictionary
	}
end

local function GetHuffmanForDecode(list, p, p2)
	local v28 = p2
	local result = {}

	for i = 0, p do
		local v29 = list[i] or 0

		if v29 > 0 and v29 < v28 and v29 then
			v28 = v29
		end

		result[v29] = (result[v29] or 0) + 1
	end

	if result[0] == p + 1 then
		return 0, result, {}, 0
	end

	local v29 = 1

	for i = 1, p2 do
		v29 = v29 * 2 - (result[i] or 0)

		if v29 < 0 then
			return v29
		end
	end

	local v30 = { 0 }

	for i = 1, p2 - 1 do
		v30[i + 1] = v30[i] + (result[i] or 0)
	end

	local result2 = {}

	for i = 0, p do
		local v31 = list[i] or 0

		if v31 == 0 then
			continue
		end

		result2[v30[v31]] = i
		v30[v31] += 1
	end

	return v29, result, result2, v28
end

local function DecodeUntilEndOfBlock(state, p, p2, p3, p4, p5, p6)
	local buf = state.buffer
	local buffer_size = state.buffer_size
	local readBits = state.ReadBits
	local decode = state.Decode
	local readerBitlenLeft = state.ReaderBitlenLeft
	local result_buffer = state.result_buffer
	local dictionary = state.dictionary
	local string_table, strlen, v28

	if dictionary and not buf[0] then
		string_table = dictionary.string_table
		strlen = dictionary.strlen
		v28 = -strlen + 1

		for i = 0, -strlen + 1 < -257 and -257 or -strlen + 1, -1 do
			buf[i] = v[string_table[strlen + i]]
		end
	else
		v28 = 1
	end

	while true do
		local decoded = decode(p, p2, p3)

		if decoded < 0 or decoded > 285 then
			return -10
		end

		if decoded < 256 then
			buffer_size += 1
			buf[buffer_size] = v[decoded]
		elseif decoded > 256 then
			local v29 = decoded - 256
			local v30 = v15[v29]

			v30 = v29 >= 8 and v30 + readBits(v11[v29]) or v30

			decoded = decode(p4, p5, p6)

			if decoded < 0 or decoded > 29 then
				return -10
			end

			local v31 = v16[decoded]

			v31 = v31 > 4 and v31 + readBits(v17[decoded]) or v31

			local v32 = buffer_size - v31 + 1

			if v32 < v28 then
				return -11
			end

			if v32 >= -257 then
				for _ = 1, v30 do
					buffer_size += 1
					buf[buffer_size] = buf[v32]
					v32 += 1
				end
			else
				local v34 = strlen + v32

				for _ = 1, v30 do
					buffer_size += 1
					buf[buffer_size] = v[string_table[v34]]
					v34 += 1
				end
			end
		end

		if readerBitlenLeft() < 0 then
			return 2
		end

		if buffer_size >= 65536 then
			result_buffer[#result_buffer + 1] = concat(buf, "", 1, 32768)

			for i = 32769, buffer_size do
				buf[i - 32768] = buf[i]
			end

			buffer_size -= 32768
			buf[buffer_size + 1] = nil
		end

		if decoded == 256 then
			state.buffer_size = buffer_size

			return 0
		end
	end
end

local function DecompressStoreBlock(state): number
	local buf = state.buffer
	local buffer_size = state.buffer_size
	local readBits = state.ReadBits
	local readBytes = state.ReadBytes
	local readerBitlenLeft = state.ReaderBitlenLeft
	local skipToByteBoundary = state.SkipToByteBoundary
	local result_buffer = state.result_buffer

	skipToByteBoundary()
	local v28 = readBits(16)

	if readerBitlenLeft() < 0 then
		return 2
	end

	local v29 = readBits(16)

	if readerBitlenLeft() < 0 then
		return 2
	end

	if not (v28 % 256 + v29 % 256 == 255 and (v28 - v28 % 256) / 256 + (v29 - v29 % 256) / 256 == 255) then
		return -2
	end

	local buffer_size2 = readBytes(v28, buf, buffer_size)

	if buffer_size2 < 0 then
		return 2
	end

	if buffer_size2 >= 65536 then
		result_buffer[#result_buffer + 1] = concat(buf, "", 1, 32768)

		for i = 32769, buffer_size2 do
			buf[i - 32768] = buf[i]
		end

		buffer_size2 -= 32768
		buf[buffer_size2 + 1] = nil
	end

	state.buffer_size = buffer_size2
	return 0
end

local function DecompressFixBlock(data) -- 1 equivalent call inferred from this helper
	return DecodeUntilEndOfBlock(data, v18, v19, 7, v20, v21, 5)
end

local function DecompressDynamicBlock(data)
	local readBits = data.ReadBits
	local decode = data.Decode
	local v28 = readBits(5) + 257
	local v29 = readBits(5) + 1
	local v30 = readBits(4) + 4

	if v28 > 286 or v29 > 30 then
		return -3
	end

	local v31 = {}

	for i = 1, v30 do
		v31[v10[i]] = readBits(3)
	end

	local v32, v34, v35, v36 = GetHuffmanForDecode(v31, 18, 7)

	if v32 ~= 0 then
		return -4
	end

	local count2 = 0
	local v37 = {}
	local v38 = {}

	while count2 < v28 + v29 do
		local decoded = decode(v34, v35, v36)

		if decoded < 0 then
			return decoded
		end

		if decoded < 16 then
			if count2 < v28 then
				v37[count2] = decoded
			else
				v38[count2 - v28] = decoded
			end

			count2 += 1
		else
			local v39 = 0
			local v40

			if decoded == 16 then
				if count2 == 0 then
					return -5
				end

				if count2 - 1 < v28 then
					v39 = v37[count2 - 1]
				else
					v39 = v38[count2 - v28 - 1]
				end

				v40 = 3 + readBits(2)
			elseif decoded == 17 then
				v40 = 3 + readBits(3)
			else
				v40 = 11 + readBits(7)
			end

			local v41 = count2 + v40

			if v28 + v29 < v41 then
				return -6
			end

			while v40 > 0 do
				v40 -= 1

				if count2 < v28 then
					v37[count2] = v39
				else
					v38[count2 - v28] = v39
				end

				count2 += 1
			end
		end
	end

	if (v37[256] or 0) == 0 then
		return -9
	end

	local v39, v40, v41, v42 = GetHuffmanForDecode(v37, v28 - 1, 15)

	if v39 ~= 0 and (v39 < 0 or v28 ~= (v40[0] or 0) + (v40[1] or 0)) then
		return -7
	end

	local v43, v44, v45, v46 = GetHuffmanForDecode(v38, v29 - 1, 15)

	if v43 == 0 or not (v43 < 0) and v29 == (v44[0] or 0) + (v44[1] or 0) then
		return DecodeUntilEndOfBlock(data, v40, v41, v42, v44, v45, v46)
	end

	return -8
end

local function Inflate(data)
	local readBits = data.ReadBits
	local v28 = nil

	while not v28 do
		v28 = readBits(1) == 1
		local v29 = readBits(2)
		local v30

		if v29 == 0 then
			v30 = DecompressStoreBlock(data)
		elseif v29 == 1 then
			v30 = DecompressFixBlock(data) -- inferred equivalent call
		elseif v29 == 2 then
			v30 = DecompressDynamicBlock(data)
		else
			return nil, -1
		end

		if v30 ~= 0 then
			return nil, v30
		end
	end

	data.result_buffer[#data.result_buffer + 1] = concat(data.buffer, "", 1, data.buffer_size)
	return (concat(data.result_buffer))
end

local function DecompressDeflateInternal(p, dictionary)
	local decompressState = CreateDecompressState(p, dictionary)
	local v28, v29 = Inflate(decompressState)

	if not v28 then
		return nil, v29
	end

	local readerBitlenLeft = decompressState.ReaderBitlenLeft()
	return v28, (readerBitlenLeft - readerBitlenLeft % 8) / 8
end

local function DecompressZlibInternal(p, dictionary)
	local decompressState = CreateDecompressState(p, dictionary)
	local readBits = decompressState.ReadBits

	local v28 = readBits(8)

	if decompressState.ReaderBitlenLeft() < 0 then
		return nil, 2
	end

	local v29 = v28 % 16
	local v30 = (v28 - v29) / 16

	if v29 ~= 8 then
		return nil, -12
	end

	if v30 > 7 then
		return nil, -13
	end

	local v31 = readBits(8)

	if decompressState.ReaderBitlenLeft() < 0 then
		return nil, 2
	end

	if (v28 * 256 + v31) % 31 ~= 0 then
		return nil, -14
	end

	local v32 = (v31 - v31 % 32) / 32 % 2
	local _ = (v31 - v31 % 64) / 64 % 4

	if v32 == 1 then
		if not dictionary then
			return nil, -16
		end

		local v35 = readBits(8)
		local v36 = readBits(8)
		local v37 = readBits(8)
		local v38 = readBits(8)
		local v39 = v35 * 16777216 + v36 * 65536 + v37 * 256 + v38

		if decompressState.ReaderBitlenLeft() < 0 then
			return nil, 2
		end

		local adler32 = dictionary.adler32

		if v39 % 4294967296 ~= adler32 % 4294967296 then
			return nil, -17
		end
	end

	local v35, v36 = Inflate(decompressState)

	if not v35 then
		return nil, v36
	end

	decompressState.SkipToByteBoundary()

	local v37 = readBits(8)
	local v38 = readBits(8)
	local v39 = readBits(8)
	local v40 = readBits(8)

	if decompressState.ReaderBitlenLeft() < 0 then
		return nil, 2
	end

	local v41 = v37 * 16777216 + v38 * 65536 + v39 * 256 + v40
	local adler32 = library:Adler32(v35)

	if v41 % 4294967296 ~= adler32 % 4294967296 then
		return nil, -15
	end

	local readerBitlenLeft = decompressState.ReaderBitlenLeft()
	return v35, (readerBitlenLeft - readerBitlenLeft % 8) / 8
end

function library:DecompressDeflate(p)
	local v28, v29

	if type(p) == "string" then
		v28 = true
		v29 = ""
	else
		v29 = ("'str' - string expected got '%s'."):format((type(p)))
		v28 = false
	end

	if not v28 then
		error("Usage: LibDeflate:DecompressDeflate(str): " .. v29, 2)
	end

	return DecompressDeflateInternal(p)
end

function library.DecompressDeflateWithDict(_, p, dictionary)
	local v28, v29

	if type(p) == "string" then
		local v30
		v30, v28 = IsValidDictionary(dictionary)

		if v30 then
			v29 = true
			v28 = ""
		else
			v29 = false
		end
	else
		v28 = ("'str' - string expected got '%s'."):format((type(p)))
		v29 = false
	end

	if not v29 then
		error("Usage: LibDeflate:DecompressDeflateWithDict(str, dictionary): " .. v28, 2)
	end

	return DecompressDeflateInternal(p, dictionary)
end

function library:DecompressZlib(p)
	local v28, v29

	if type(p) == "string" then
		v28 = true
		v29 = ""
	else
		v29 = ("'str' - string expected got '%s'."):format((type(p)))
		v28 = false
	end

	if not v28 then
		error("Usage: LibDeflate:DecompressZlib(str): " .. v29, 2)
	end

	return DecompressZlibInternal(p)
end

function library.DecompressZlibWithDict(_, p, dictionary)
	local v28, v29

	if type(p) == "string" then
		local v30
		v30, v28 = IsValidDictionary(dictionary)

		if v30 then
			v29 = true
			v28 = ""
		else
			v29 = false
		end
	else
		v28 = ("'str' - string expected got '%s'."):format((type(p)))
		v29 = false
	end

	if not v29 then
		error("Usage: LibDeflate:DecompressZlibWithDict(str, dictionary): " .. v28, 2)
	end

	return DecompressZlibInternal(p, dictionary)
end

v12 = {}

for i = 0, 143 do
	v12[i] = 8
end

for i = 144, 255 do
	v12[i] = 9
end

v12[256] = 7
v12[257] = 7
v12[258] = 7
v12[259] = 7
v12[260] = 7
v12[261] = 7
v12[262] = 7
v12[263] = 7
v12[264] = 7
v12[265] = 7
v12[266] = 7
v12[267] = 7
v12[268] = 7
v12[269] = 7
v12[270] = 7
v12[271] = 7
v12[272] = 7
v12[273] = 7
v12[274] = 7
v12[275] = 7
v12[276] = 7
v12[277] = 7
v12[278] = 7
v12[279] = 7

v12[280] = 8
v12[281] = 8
v12[282] = 8
v12[283] = 8
v12[284] = 8
v12[285] = 8
v12[286] = 8
v12[287] = 8

local v28 = {}

for i = 0, 31 do
	v28[i] = 5
end

local v29, v30, v31 = GetHuffmanForDecode(v12, 287, 9)
v18 = v30
v19 = v31
assert(v29 == 0)

local v32, v34, v35 = GetHuffmanForDecode(v28, 31, 5)
v20 = v34
v21 = v35
assert(v32 == 0)

v13 = GetHuffmanCodeFromBitlen(v18, v12, 287, 9)

v14 = GetHuffmanCodeFromBitlen(v20, v28, 31, 5)

local v36 = {
	["\0"] = "%z",
	["("] = "%(",
	[")"] = "%)",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["["] = "%[",
	["]"] = "%]",
	["^"] = "%^",
	["$"] = "%$"
}

local function escape_for_gsub(value) -- 7 equivalent calls inferred from this helper
	return value:gsub("([%z%(%)%.%%%+%-%*%?%[%]%^%$])", v36)
end

function library.CreateCodec(_, value, value2, value3)
	if type(value) ~= "string" or type(value2) ~= "string" or type(value3) ~= "string" then
		error(
			"Usage: LibDeflate:CreateCodec(reserved_chars, escape_chars, map_chars): All arguments must be string.",
			2
		)
	end

	if value2 == "" then
		return nil, "No escape characters supplied."
	end

	if #value < #value3 then
		return nil, "The number of reserved characters must be at least as many as the number of mapped chars."
	end

	if value == "" then
		return nil, "No characters to encode."
	end

	local v37 = value .. value2 .. value3

	local set = {}

	for i = 1, #v37 do
		local v38 = byte(v37, i, i)

		if set[v38] then
			return
				nil,
				"There must be no duplicate characters in the concatenation of reserved_chars, escape_chars and map_chars."
		end

		set[v38] = true
	end

	local v38 = {}
	local v39 = {}

	local v40 = {}
	local v41 = {}

	if #value3 > 0 then
		local v42 = {}
		local v43 = {}

		for i = 1, #value3 do
			local v44 = sub(value, i, i)
			local v45 = sub(value3, i, i)
			v41[v44] = v45
			v40[#v40 + 1] = v44
			v42[v45] = v44
			v43[#v43 + 1] = v45
		end

		v38[#v38 + 1] = "([" .. escape_for_gsub(concat(v43)) .. "])" -- inferred equivalent call
		v39[#v39 + 1] = v42
	end

	local v42 = 1
	local v43 = sub(value2, v42, v42)
	local count2 = 0
	local v44 = {}
	local v45 = {}

	for i = 1, #v37 do
		local v46 = sub(v37, i, i)

		if not v41[v46] then
			while count2 >= 256 or set[count2] do
				count2 += 1

				if not (count2 > 255) then
					continue
				end

				v38[#v38 + 1] = escape_for_gsub(v43) .. "([" .. escape_for_gsub(concat(v44)) .. "])" -- inferred equivalent call
				v39[#v39 + 1] = v45

				v42 += 1
				v43 = sub(value2, v42, v42)

				if not v43 or v43 == "" then
					return nil, "Out of escape characters."
				end

				count2 = 0
				v44 = {}
				v45 = {}
			end

			local v47 = v[count2]
			v41[v46] = v43 .. v47
			v40[#v40 + 1] = v46
			v45[v47] = v46
			v44[#v44 + 1] = v47
			count2 += 1
		end

		if i ~= #v37 then
			continue
		end

		v38[#v38 + 1] = escape_for_gsub(v43) .. "([" .. escape_for_gsub(concat(v44)) .. "])" -- inferred equivalent call
		v39[#v39 + 1] = v45
	end

	local v47 = "([" .. escape_for_gsub(concat(v40)) .. "])" -- inferred equivalent call
	local v46 = {}

	function v46.Encode(_, value4)
		if type(value4) ~= "string" then
			error(("Usage: codec:Encode(str): 'str' - string expected got '%s'."):format((type(value4))), 2)
		end

		return gsub(value4, v47, v41)
	end

	local count3 = #v38

	local v48 = "([" .. escape_for_gsub(value) .. "])" -- inferred equivalent call

	function v46.Decode(_, value4)
		if type(value4) ~= "string" then
			error(("Usage: codec:Decode(str): 'str' - string expected got '%s'."):format((type(value4))), 2)
		end

		if find(value4, v48) then
			return nil
		end

		for i = 1, count3 do
			value4 = gsub(value4, v38[i], v39[i])
		end

		return value4
	end

	return v46
end

local v37 = nil

local byte_to_6bit_char = {
	[0] = "a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"(",
	")"
}

local _6bit_to_byte = {
	[97] = 0,
	[98] = 1,
	[99] = 2,
	[100] = 3,
	[101] = 4,
	[102] = 5,
	[103] = 6,
	[104] = 7,
	[105] = 8,
	[106] = 9,
	[107] = 10,
	[108] = 11,
	[109] = 12,
	[110] = 13,
	[111] = 14,
	[112] = 15,
	[113] = 16,
	[114] = 17,
	[115] = 18,
	[116] = 19,
	[117] = 20,
	[118] = 21,
	[119] = 22,
	[120] = 23,
	[121] = 24,
	[122] = 25,
	[65] = 26,
	[66] = 27,
	[67] = 28,
	[68] = 29,
	[69] = 30,
	[70] = 31,
	[71] = 32,
	[72] = 33,
	[73] = 34,
	[74] = 35,
	[75] = 36,
	[76] = 37,
	[77] = 38,
	[78] = 39,
	[79] = 40,
	[80] = 41,
	[81] = 42,
	[82] = 43,
	[83] = 44,
	[84] = 45,
	[85] = 46,
	[86] = 47,
	[87] = 48,
	[88] = 49,
	[89] = 50,
	[90] = 51,
	[48] = 52,
	[49] = 53,
	[50] = 54,
	[51] = 55,
	[52] = 56,
	[53] = 57,
	[54] = 58,
	[55] = 59,
	[56] = 60,
	[57] = 61,
	[40] = 62,
	[41] = 63
}

function library.EncodeForPrint(_, value)
	if type(value) ~= "string" then
		error(("Usage: LibDeflate:EncodeForPrint(str): 'str' - string expected got '%s'."):format((type(value))), 2)
	end

	local count2 = #value
	local v40 = count2 - 2
	local total4 = 1
	local count3 = 0
	local v41 = {}

	while total4 <= v40 do
		local v43, v44, v45 = byte(value, total4, total4 + 2)
		total4 += 3
		local v46 = v43 + v44 * 256 + v45 * 65536
		local v47 = v46 % 64
		local v48 = (v46 - v47) / 64
		local v49 = v48 % 64
		local v50 = (v48 - v49) / 64
		local v51 = v50 % 64
		local v52 = (v50 - v51) / 64
		count3 += 1
		v41[count3] = byte_to_6bit_char[v47] .. byte_to_6bit_char[v49] .. byte_to_6bit_char[v51] .. byte_to_6bit_char[v52]
	end

	local v42 = 0
	local v43 = 0

	while total4 <= count2 do
		v43 += byte(value, total4, total4) * v2[v42]
		v42 += 8
		total4 += 1
	end

	while v42 > 0 do
		local v44 = v43 % 64
		count3 += 1
		v41[count3] = byte_to_6bit_char[v44]
		v43 = (v43 - v44) / 64
		v42 -= 6
	end

	return concat(v41)
end

function library.DecodeForPrint(_, value)
	if type(value) ~= "string" then
		error(("Usage: LibDeflate:DecodeForPrint(str): 'str' - string expected got '%s'."):format((type(value))), 2)
	end

	local v40 = value:gsub("^[%c ]+", ""):gsub("[%c ]+$", "")

	local count2 = #v40

	if count2 == 1 then
		return nil
	end

	local v41 = count2 - 3
	local total4 = 1
	local count3 = 0
	local v42 = {}

	while total4 <= v41 do
		local v44, v45, v46, v47 = byte(v40, total4, total4 + 3)
		local v48 = _6bit_to_byte[v44]
		local v49 = _6bit_to_byte[v45]
		local v50 = _6bit_to_byte[v46]
		local v51 = _6bit_to_byte[v47]

		if not (v48 and v49 and v50 and v51) then
			return nil
		end

		total4 += 4
		local v52 = v48 + v49 * 64 + v50 * 4096 + v51 * 262144
		local v53 = v52 % 256
		local v54 = (v52 - v53) / 256
		local v55 = v54 % 256
		local v56 = (v54 - v55) / 256
		count3 += 1
		v42[count3] = v[v53] .. v[v55] .. v[v56]
	end

	local v43 = 0
	local v44 = 0

	while total4 <= count2 do
		local v46 = _6bit_to_byte[byte(v40, total4, total4)]

		if not v46 then
			return nil
		end

		v44 += v46 * v2[v43]
		v43 += 6
		total4 += 1
	end

	while v43 >= 8 do
		local v45 = v44 % 256
		count3 += 1
		v42[count3] = v[v45]
		v44 = (v44 - v45) / 256
		v43 -= 8
	end

	return concat(v42)
end

local function InternalClearCache()
	v37 = nil
end

library.internals = {
	LoadStringToTable = LoadStringToTable,
	IsValidDictionary = IsValidDictionary,
	IsEqualAdler32 = IsEqualAdler32,
	_byte_to_6bit_char = byte_to_6bit_char,
	_6bit_to_byte = _6bit_to_byte,
	InternalClearCache = InternalClearCache
}

return Compression