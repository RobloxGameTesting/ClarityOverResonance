local compression = require(script.compression)
local bitbuffer = require(script.bitbuffer)

local compress = compression.Zlib.Compress
local decompress = compression.Zlib.Decompress

local v = bitbuffer.new()
local v2 = true

local function encodeBase128(p: string)
	if not v2 then
		v:ResetBuffer()
	end

	v2 = false
	v:WriteString(p)
	return v:ToBase128()
end

local function decodeBase128(p: string) -- 1 equivalent call inferred from this helper
	return bitbuffer.FromBase128(p):ReadString()
end

local Zlib128 = {}

function Zlib128.compress(p: string, value: number, value2: string)
	return encodeBase128(compress(p, {
		level = value or 6,
		strategy = value2 or "dynamic"
	}))
end

function Zlib128.decompress(p: string)
	local v3 = decodeBase128(p) -- inferred equivalent call
	return (decompress(v3))
end

return Zlib128