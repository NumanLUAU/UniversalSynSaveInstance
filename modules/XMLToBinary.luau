--[[
	written by: @NumanLUAU on github
	discord: @corescripts
]]

--!strict

-- >> constants
local MAGIC = "<roblox!\x89\xff\r\n\x1a\n"
local VERSION = 0
local END_SIGNATURE = "END\0"
local END_PAYLOAD = "</roblox>"

local T_STRING = 0x01
local T_BOOL = 0x02
local T_INT = 0x03
local T_FLOAT = 0x04
local T_DOUBLE = 0x05
local T_UDIM = 0x06
local T_UDIM2 = 0x07
local T_RAY = 0x08
local T_FACES = 0x09
local T_AXES = 0x0A
local T_BRICKCOLOR = 0x0B
local T_COLOR3 = 0x0C
local T_VECTOR2 = 0x0D
local T_VECTOR3 = 0x0E
local T_VECTOR2INT16 = 0x0F
local T_CFRAME = 0x10
local T_TOKEN = 0x12
local T_REFERENCE = 0x13
local T_VECTOR3INT16 = 0x14
local T_NUMBERSEQUENCE = 0x15
local T_COLORSEQUENCE = 0x16
local T_NUMBERRANGE = 0x17
local T_RECT = 0x18
local T_PHYSICALPROPERTIES = 0x19
local T_COLOR3UINT8 = 0x1A
local T_INT64 = 0x1B
local T_SHAREDSTRING = 0x1C
local T_UNIQUEID = 0x1F
local T_FONT = 0x20
local T_SECURITY_CAPABILITIES = 0x21
local T_CONTENT = 0x22

local U32 = 4294967296
local U32_HALF = 2147483648

local ROBLOX_SERVICE_CLASSES = {
	Workspace = true,
	Players = true,
	Lighting = true,
	ReplicatedFirst = true,
	ReplicatedStorage = true,
	ServerScriptService = true,
	ServerStorage = true,
	StarterGui = true,
	StarterPack = true,
	StarterPlayer = true,
	Teams = true,
	SoundService = true,
	Chat = true,
	LocalizationService = true,
	TestService = true,
	VoiceChatService = true,
	MaterialService = true,
	PhysicsService = true,
	TextChatService = true,
	ProximityPromptService = true,
	Debris = true,
	JointsService = true,
	RunService = true,
	InsertService = true,
	KeyframeSequenceProvider = true,
	ContentProvider = true,
	ContextActionService = true,
	TweenService = true,
	PathfindingService = true,
	MarketplaceService = true,
	BadgeService = true,
	GamePassService = true,
	SocialService = true,
	FriendService = true,
	AssetService = true,
	CollectionService = true,
	HttpService = true,
	DataStoreService = true,
	MessagingService = true,
	PolicyService = true,
	TeleportService = true,
	GuiService = true,
	StarterGear = true,
	SharedTableRegistry = true,
	ScriptContext = true,
	LogService = true,
	AnalyticsService = true,
	AvatarEditorService = true,
	VRService = true,
	UserInputService = true,
	HapticService = true,
	GamepadService = true,
	OpenCloudService = true,
	MemoryStoreService = true,
	NetworkClient = true,
	NetworkServer = true,
	CookiesService = true,
	SolidModelDataService = true,
	NotificationService = true,
	AdService = true,
}

local ROTATIONS = {
	[0x02] = {1,0,0, 0,1,0, 0,0,1},
	[0x03] = {1,0,0, 0,0,-1, 0,1,0},
	[0x05] = {1,0,0, 0,-1,0, 0,0,-1},
	[0x06] = {1,0,0, 0,0,1, 0,-1,0},
	[0x07] = {0,1,0, 1,0,0, 0,0,-1},
	[0x09] = {0,0,1, 1,0,0, 0,1,0},
	[0x0A] = {0,-1,0, 1,0,0, 0,0,1},
	[0x0C] = {0,0,-1, 1,0,0, 0,-1,0},
	[0x0D] = {0,1,0, 0,0,1, 1,0,0},
	[0x0E] = {0,0,-1, 0,1,0, 1,0,0},
	[0x10] = {0,-1,0, 0,0,-1, 1,0,0},
	[0x11] = {0,0,1, 0,-1,0, 1,0,0},
	[0x14] = {-1,0,0, 0,1,0, 0,0,-1},
	[0x15] = {-1,0,0, 0,0,1, 0,1,0},
	[0x17] = {-1,0,0, 0,-1,0, 0,0,1},
	[0x18] = {-1,0,0, 0,0,-1, 0,-1,0},
	[0x19] = {0,1,0, -1,0,0, 0,0,1},
	[0x1B] = {0,0,-1, -1,0,0, 0,1,0},
	[0x1C] = {0,-1,0, -1,0,0, 0,0,-1},
	[0x1E] = {0,0,1, -1,0,0, 0,-1,0},
	[0x1F] = {0,1,0, 0,0,-1, -1,0,0},
	[0x20] = {0,0,1, 0,1,0, -1,0,0},
	[0x22] = {0,-1,0, 0,0,1, -1,0,0},
	[0x23] = {0,0,-1, 0,-1,0, -1,0,0},
}

local ROTATION_TO_ID = {}

for id, matrix in pairs(ROTATIONS) do
	local key = ""

	for i = 1, 9 do
		key ..= string.format("%.6f,", matrix[i])
	end

	ROTATION_TO_ID[key] = id
end

local PROPERTY_TYPE_OVERRIDES = {
	TeamColor = "BrickColor",
	BrickColor = "BrickColor",
}

local FORCE_CONTENT_ID_STRING = {
	["Animation.AnimationId"] = true,
	["Sound.SoundId"] = true,
	["Decal.Texture"] = true,
	["Decal.ColorMap"] = true,
	["Decal.MetalnessMap"] = true,
	["Decal.NormalMap"] = true,
	["Decal.RoughnessMap"] = true,
	["Texture.Texture"] = true,
	["MeshPart.MeshId"] = true,
	["SpecialMesh.MeshId"] = true,
	["SpecialMesh.TextureId"] = true,
	["FileMesh.MeshId"] = true,
	["FileMesh.TextureId"] = true,
	["Shirt.ShirtTemplate"] = true,
	["Pants.PantsTemplate"] = true,
	["ShirtGraphic.Graphic"] = true,
	["ClothingAssetBase.ClothingAssetId"] = true,
}

local CONTENT_STRUCT_PROPERTY_NAMES = {
	ColorMapContent = true,
	NormalMapContent = true,
	RoughnessMapContent = true,
	MetalnessMapContent = true,
	EmissiveMaskContent = true,
	TextureContent = true,
}

-- >> types
type U64 = {
	high: number,
	low: number,
}

type XmlElement = {
	tag: string,
	attributes: {[string]: string},
	children: {XmlElement},
	text: string,
}

type Property = {
	name: string,
	tag: string,
	element: XmlElement,
}

type Instance = {
	className: string,
	referent: string,
	name: string,
	parent: Instance?,
	children: {Instance},
	properties: {[string]: Property},
	propertyOrder: {string},
	order: number,
}

type Writer = {
	buffer: buffer,
	size: number,
	position: number,
}

-- >> functions
--// creates a growable binary writer backed by Roblox buffer.
local function createWriter(size: number?): Writer
	local capacity = math.max(size or 256, 1)

	return {
		buffer = buffer.create(capacity),
		size = capacity,
		position = 0,
	}
end

--// grows the backing buffer when the requested write no longer fits.
local function ensure(writer: Writer, amount: number)
	local required = writer.position + amount

	if required <= writer.size then
		return
	end

	local size = writer.size

	while size < required do
		size *= 2
	end

	local nextBuffer = buffer.create(size)

	if writer.position > 0 then
		buffer.copy(nextBuffer, 0, writer.buffer, 0, writer.position)
	end

	writer.buffer = nextBuffer
	writer.size = size
end

--// writes raw bytes into the writer.
local function writeBytes(writer: Writer, value: string)
	local length = #value

	if length == 0 then
		return
	end

	ensure(writer, length)
	buffer.writestring(writer.buffer, writer.position, value, length)
	writer.position += length
end

--// writes one unsigned byte.
local function writeU8(writer: Writer, value: number)
	ensure(writer, 1)
	buffer.writeu8(writer.buffer, writer.position, bit32.band(value, 0xff))
	writer.position += 1
end

--// writes a little-endian unsigned 16-bit integer.
local function writeU16(writer: Writer, value: number)
	ensure(writer, 2)
	buffer.writeu16(writer.buffer, writer.position, bit32.band(value, 0xffff))
	writer.position += 2
end

--// writes a little-endian signed 16-bit integer.
local function writeI16(writer: Writer, value: number)
	ensure(writer, 2)
	buffer.writei16(
		writer.buffer,
		writer.position,
		math.clamp(math.floor(value), -32768, 32767)
	)
	writer.position += 2
end

--// writes a little-endian unsigned 32-bit integer.
local function writeU32(writer: Writer, value: number)
	ensure(writer, 4)
	buffer.writeu32(
		writer.buffer,
		writer.position,
		bit32.band(value, 0xffffffff)
	)
	writer.position += 4
end

--// writes a little-endian signed 32-bit integer.
local function writeI32(writer: Writer, value: number)
	ensure(writer, 4)
	buffer.writei32(
		writer.buffer,
		writer.position,
		value
	)
	writer.position += 4
end

--// writes a little-endian float.
local function writeF32(writer: Writer, value: number)
	ensure(writer, 4)
	buffer.writef32(writer.buffer, writer.position, value)
	writer.position += 4
end

--// writes a little-endian double.
local function writeF64(writer: Writer, value: number)
	ensure(writer, 8)
	buffer.writef64(writer.buffer, writer.position, value)
	writer.position += 8
end

--// writes a big-endian u32.
local function writeBEU32(writer: Writer, value: number)
	value = bit32.band(value, 0xffffffff)

	writeU8(writer, bit32.band(bit32.rshift(value, 24), 0xff))
	writeU8(writer, bit32.band(bit32.rshift(value, 16), 0xff))
	writeU8(writer, bit32.band(bit32.rshift(value, 8), 0xff))
	writeU8(writer, bit32.band(value, 0xff))
end

--// converts the used portion of a writer into a binary string.
local function writerString(writer: Writer): string
	return buffer.readstring(writer.buffer, 0, writer.position)
end

--// writes a Roblox length-prefixed string.
local function writeString(writer: Writer, value: string)
	writeU32(writer, #value)
	writeBytes(writer, value)
end

--// writes a Roblox length-prefixed binary string.
local function writeBString(writer: Writer, value: string)
	writeU32(writer, #value)
	writeBytes(writer, value)
end

--// creates an unsigned 64-bit zero value.
local function u64Zero(): U64
	return {
		high = 0,
		low = 0,
	}
end

--// returns a 64-bit value with both halves masked to unsigned 32-bit ranges.
local function normalizeU64(value: U64): U64
	return {
		high = bit32.band(value.high, 0xffffffff),
		low = bit32.band(value.low, 0xffffffff),
	}
end

--// tests the sign bit of a 64-bit two's complement value.
local function u64Negative(value: U64): boolean
	return value.high >= U32_HALF
end

--// bitwise-nots a 64-bit value.
local function u64Not(value: U64): U64
	return {
		high = bit32.bxor(value.high, 0xffffffff),
		low = bit32.bxor(value.low, 0xffffffff),
	}
end

--// adds one to a 64-bit value.
local function u64AddOne(value: U64): U64
	local low = value.low + 1

	if low >= U32 then
		return {
			high = bit32.band(value.high + 1, 0xffffffff),
			low = low - U32,
		}
	end

	return {
		high = value.high,
		low = low,
	}
end

--// shifts an unsigned 64-bit value left by one.
local function u64ShiftLeft1(value: U64): U64
	return {
		high = bit32.band(
			bit32.lshift(value.high, 1) + bit32.rshift(value.low, 31),
			0xffffffff
		),
		low = bit32.lshift(value.low, 1),
	}
end

--// performs the Python transform_i64 operation without converting through double precision.
local function transformI64(value: U64): U64
	local shifted = u64ShiftLeft1(value)

	if u64Negative(value) then
		return u64Not(shifted)
	end

	return normalizeU64(shifted)
end

--// parses an unsigned decimal string into an exact 64-bit pair.
local function parseUnsignedDecimal(value: string): U64
	value = string.gsub(value, "^%s+", "")
	value = string.gsub(value, "%s+$", "")

	local result = u64Zero()

	if value == "" then
		return result
	end

	for i = 1, #value do
		local digit = string.byte(value, i) - 48

		if digit < 0 or digit > 9 then
			break
		end

		local low = result.low * 10 + digit
		local carry = math.floor(low / U32)

		result.low = low - carry * U32
		result.high = (result.high * 10 + carry) % U32
	end

	return result
end

--// parses a signed decimal integer into an exact two's complement 64-bit pair.
local function parseInt64(value: string): U64
	value = string.gsub(value, "^%s+", "")
	value = string.gsub(value, "%s+$", "")

	if value == "" then
		return u64Zero()
	end

	local negative = string.sub(value, 1, 1) == "-"

	if negative then
		value = string.sub(value, 2)
	elseif string.sub(value, 1, 1) == "+" then
		value = string.sub(value, 2)
	end

	local result = parseUnsignedDecimal(value)

	if negative then
		result = u64Not(result)
		result = u64AddOne(result)
	end

	return result
end

--// parses a hexadecimal string into an exact 64-bit pair.
local function parseHex64(value: string): U64
	value = string.lower(string.gsub(value, "^%s+", ""))
	value = string.gsub(value, "%s+$", "")
	value = string.gsub(value, "^0x", "")

	value = string.rep("0", math.max(0, 16 - #value)) .. value

	local highText = string.sub(value, math.max(1, #value - 15), math.max(8, #value - 8))
	local lowText = string.sub(value, math.max(9, #value - 7))

	local high = tonumber(highText, 16) or 0
	local low = tonumber(lowText, 16) or 0

	return {
		high = high,
		low = low,
	}
end

--// writes a raw big-endian 64-bit value.
local function writeBEU64(writer: Writer, value: U64)
	writeBEU32(writer, value.high)
	writeBEU32(writer, value.low)
end

--// returns the IEEE-754 single precision bit representation of a number.
local FLOAT_SCRATCH = buffer.create(4)

local function floatBits(value: number): number
	buffer.writef32(FLOAT_SCRATCH, 0, value)
	return buffer.readu32(FLOAT_SCRATCH, 0)
end

--// performs the float bit rotation used by Roblox interleaving.
local function rotatedF32Bits(value: number): number
	local bits = floatBits(value)

	return bit32.bor(
		bit32.lshift(bits, 1),
		bit32.rshift(bits, 31)
	)
end

--// transforms a signed 32-bit integer exactly like Python's transform_i32.
local function transformI32(value: number): number
	local unsigned = bit32.band(value, 0xffffffff)

	if unsigned >= U32_HALF then
		unsigned -= U32
	end

	return bit32.band(
		bit32.bxor(
			bit32.lshift(unsigned, 1),
			bit32.arshift(unsigned, 31)
		),
		0xffffffff
	)
end

--// writes a column-interleaved 32-bit integer sequence.
local function writeInterleavedI32(
	writer: Writer,
	values: {number},
	transformed: boolean?
)
	local count = #values

	if count == 0 then
		return
	end

	local columns = {
		{},
		{},
		{},
		{},
	}

	for i = 1, count do
		local value

		if transformed == false then
			value = bit32.band(values[i], 0xffffffff)
		else
			value = transformI32(values[i])
		end

		columns[1][i] = bit32.band(bit32.rshift(value, 24), 0xff)
		columns[2][i] = bit32.band(bit32.rshift(value, 16), 0xff)
		columns[3][i] = bit32.band(bit32.rshift(value, 8), 0xff)
		columns[4][i] = bit32.band(value, 0xff)
	end

	for column = 1, 4 do
		for i = 1, count do
			writeU8(writer, columns[column][i])
		end
	end
end

--// writes a column-interleaved unsigned 32-bit sequence.
local function writeInterleavedU32(writer: Writer, values: {number})
	writeInterleavedI32(writer, values, false)
end

--// writes a column-interleaved float sequence.
local function writeInterleavedF32(writer: Writer, values: {number})
	local count = #values

	if count == 0 then
		return
	end

	local columns = {
		{},
		{},
		{},
		{},
	}

	for i, value in ipairs(values) do
		local bits = rotatedF32Bits(value)

		columns[1][i] = bit32.band(bit32.rshift(bits, 24), 0xff)
		columns[2][i] = bit32.band(bit32.rshift(bits, 16), 0xff)
		columns[3][i] = bit32.band(bit32.rshift(bits, 8), 0xff)
		columns[4][i] = bit32.band(bits, 0xff)
	end

	for column = 1, 4 do
		for i = 1, count do
			writeU8(writer, columns[column][i])
		end
	end
end

--// writes a column-interleaved exact 64-bit sequence.
local function writeInterleavedI64(writer: Writer, values: {U64})
	local count = #values

	if count == 0 then
		return
	end

	local columns = {
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
	}

	for i, original in ipairs(values) do
		local value = transformI64(original)

		columns[1][i] = bit32.band(bit32.rshift(value.high, 24), 0xff)
		columns[2][i] = bit32.band(bit32.rshift(value.high, 16), 0xff)
		columns[3][i] = bit32.band(bit32.rshift(value.high, 8), 0xff)
		columns[4][i] = bit32.band(value.high, 0xff)
		columns[5][i] = bit32.band(bit32.rshift(value.low, 24), 0xff)
		columns[6][i] = bit32.band(bit32.rshift(value.low, 16), 0xff)
		columns[7][i] = bit32.band(bit32.rshift(value.low, 8), 0xff)
		columns[8][i] = bit32.band(value.low, 0xff)
	end

	for column = 1, 8 do
		for i = 1, count do
			writeU8(writer, columns[column][i])
		end
	end
end

--// writes delta-transformed referents.
local function writeReferents(writer: Writer, values: {number})
	local deltas = table.create(#values)
	local last = 0

	for i, value in ipairs(values) do
		deltas[i] = value - last
		last = value
	end

	writeInterleavedI32(writer, deltas)
end

--// strips an XML namespace from a tag name.
local function localName(tag: string): string
	local namespace = string.find(tag, "}", 1, true)

	if namespace then
		return string.sub(tag, namespace + 1)
	end

	local colon = string.find(tag, ":", 1, true)

	if colon then
		return string.sub(tag, colon + 1)
	end

	return tag
end

--// decodes XML character entities.
local function decodeEntities(value: string): string
	value = string.gsub(value, "&lt;", "<")
	value = string.gsub(value, "&gt;", ">")
	value = string.gsub(value, "&quot;", "\"")
	value = string.gsub(value, "&apos;", "'")
	value = string.gsub(value, "&#x([%da-fA-F]+);", function(hex)
		local codepoint = tonumber(hex, 16)

		if not codepoint then
			return ""
		end

		return utf8.char(codepoint)
	end)
	value = string.gsub(value, "&#(%d+);", function(decimal)
		local codepoint = tonumber(decimal)

		if not codepoint then
			return ""
		end

		return utf8.char(codepoint)
	end)
	value = string.gsub(value, "&amp;", "&")

	return value
end

--// skips XML whitespace.
local function skipWhitespace(data: string, position: number): number
	while position <= #data do
		local byte = string.byte(data, position)

		if byte ~= 32 and byte ~= 9 and byte ~= 10 and byte ~= 13 then
			break
		end

		position += 1
	end

	return position
end

--// reads an XML name.
local function readName(data: string, position: number): (string, number)
	local start = position

	while position <= #data do
		local value = string.sub(data, position, position)

		if not value:match("[%w_:%.%-]") then
			break
		end

		position += 1
	end

	return string.sub(data, start, position - 1), position
end

--// reads an XML quoted attribute value.
local function readAttributeValue(data: string, position: number): (string, number)
	position = skipWhitespace(data, position)

	local quote = string.sub(data, position, position)

	if quote ~= "\"" and quote ~= "'" then
		error("invalid XML attribute")
	end

	position += 1

	local finish = string.find(data, quote, position, true)

	if not finish then
		error("unterminated XML attribute")
	end

	return decodeEntities(string.sub(data, position, finish - 1)), finish + 1
end

--// parses an XML document into a small ElementTree-style structure.
local function parseXml(data: string): XmlElement
	local position = 1
	local root: XmlElement? = nil
	local stack: {XmlElement} = {}

	while position <= #data do
		local open = string.find(data, "<", position, true)

		if not open then
			if #stack > 0 then
				stack[#stack].text ..= decodeEntities(string.sub(data, position))
			end

			break
		end

		if open > position and #stack > 0 then
			stack[#stack].text ..= decodeEntities(
				string.sub(data, position, open - 1)
			)
		end

		if string.sub(data, open, open + 3) == "<!--" then
			local finish = string.find(data, "-->", open + 4, true)

			if not finish then
				error("unterminated XML comment")
			end

			position = finish + 3
			continue
		end

		if string.sub(data, open, open + 8) == "<![CDATA[" then
			local finish = string.find(data, "]]>", open + 9, true)

			if not finish then
				error("unterminated CDATA")
			end

			if #stack > 0 then
				stack[#stack].text ..= string.sub(
					data,
					open + 9,
					finish - 1
				)
			end

			position = finish + 3
			continue
		end

		if string.sub(data, open, open + 1) == "<?" then
			local finish = string.find(data, "?>", open + 2, true)

			if not finish then
				error("unterminated XML declaration")
			end

			position = finish + 2
			continue
		end

		if string.sub(data, open, open + 8) == "<!DOCTYPE" then
			local finish = string.find(data, ">", open + 9, true)

			if not finish then
				error("unterminated DOCTYPE")
			end

			position = finish + 1
			continue
		end

		local closing = string.sub(data, open + 1, open + 1) == "/"

		if closing then
			local name, afterName = readName(data, open + 2)
			local finish = string.find(data, ">", afterName, true)

			if not finish then
				error("unterminated XML closing tag")
			end

			local current = stack[#stack]

			if not current or localName(current.tag) ~= localName(name) then
				error("mismatched XML closing tag: " .. name)
			end

			table.remove(stack)
			position = finish + 1
			continue
		end

		local name, cursor = readName(data, open + 1)

		if name == "" then
			error("invalid XML tag")
		end

		local attributes = {}
		local selfClosing = false

		while cursor <= #data do
			cursor = skipWhitespace(data, cursor)

			if string.sub(data, cursor, cursor) == "/" then
				cursor += 1
				cursor = skipWhitespace(data, cursor)

				if string.sub(data, cursor, cursor) ~= ">" then
					error("invalid XML self-closing tag")
				end

				selfClosing = true
				cursor += 1
				break
			end

			if string.sub(data, cursor, cursor) == ">" then
				cursor += 1
				break
			end

			local attributeName
			attributeName, cursor = readName(data, cursor)

			if attributeName == "" then
				error("invalid XML attribute")
			end

			cursor = skipWhitespace(data, cursor)

			if string.sub(data, cursor, cursor) ~= "=" then
				error("XML attribute missing '='")
			end

			cursor += 1

			local attributeValue
			attributeValue, cursor = readAttributeValue(data, cursor)

			attributes[attributeName] = attributeValue
		end

		local element: XmlElement = {
			tag = name,
			attributes = attributes,
			children = {},
			text = "",
		}

		if #stack == 0 then
			if root then
				error("multiple XML roots")
			end

			root = element
		else
			table.insert(stack[#stack].children, element)
		end

		if not selfClosing then
			table.insert(stack, element)
		end

		position = cursor
	end

	if #stack ~= 0 then
		error("unclosed XML tag")
	end

	if not root then
		error("XML contains no root element")
	end

	return root
end

--// returns trimmed direct text from an XML element.
local function text(element: XmlElement?, default: string?): string
	if not element then
		return default or ""
	end

	if element.text == "" then
		return default or ""
	end

	return string.gsub(element.text, "^%s*(.-)%s*$", "%1")
end

--// finds a direct child element by name.
local function child(element: XmlElement?, name: string): XmlElement?
	if not element then
		return nil
	end

	for _, candidate in ipairs(element.children) do
		if localName(candidate.tag) == name then
			return candidate
		end
	end

	return nil
end

--// reads trimmed text from a named direct child.
local function childText(
	element: XmlElement?,
	name: string,
	default: string?
): string
	return text(child(element, name), default)
end

--// parses a floating-point XML number.
local function numberValue(value: string?, default: number?): number
	local fallback = default or 0
	local cleaned = string.lower(
		string.gsub(value or "", "^%s*(.-)%s*$", "%1")
	)

	if cleaned == "" then
		return fallback
	end

	if cleaned == "nan" then
		return 0 / 0
	end

	if cleaned == "inf" or cleaned == "+inf"
		or cleaned == "infinity" or cleaned == "+infinity" then
		return math.huge
	end

	if cleaned == "-inf" or cleaned == "-infinity" then
		return -math.huge
	end

	return tonumber(cleaned) or fallback
end

--// parses a normal integer XML value.
local function integerValue(value: string?, default: number?): number
	local fallback = default or 0
	local cleaned = string.gsub(value or "", "^%s*(.-)%s*$", "%1")

	if cleaned == "" then
		return fallback
	end

	local result = tonumber(cleaned)

	if result then
		return math.floor(result)
	end

	return fallback
end

--// parses an XML boolean.
local function booleanValue(value: string?): boolean
	local cleaned = string.lower(
		string.gsub(value or "", "^%s*(.-)%s*$", "%1")
	)

	return cleaned == "1"
		or cleaned == "true"
		or cleaned == "yes"
end

--// reads ContentId and Content XML forms.
local function contentText(element: XmlElement?): string
	if not element then
		return ""
	end

	local direct = text(element)

	if direct ~= "" then
		return direct
	end

	return text(child(element, "url"))
end

--// decodes base64 into a byte string.
local function base64Decode(value: string): string
	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local reverse = {}

	for i = 1, #alphabet do
		reverse[string.sub(alphabet, i, i)] = i - 1
	end

	local cleaned = string.gsub(value, "%s+", "")
	local output = {}
	local accumulator = 0
	local bitCount = 0

	for i = 1, #cleaned do
		local character = string.sub(cleaned, i, i)

		if character ~= "=" then
			local number = reverse[character]

			if number ~= nil then
				accumulator = accumulator * 64 + number
				bitCount += 6

				if bitCount >= 8 then
					bitCount -= 8

					table.insert(
						output,
						string.char(
							math.floor(accumulator / 2 ^ bitCount) % 256
						)
					)
				end
			end
		end
	end

	return table.concat(output)
end

--// returns the MD5 digest used by the SSTR chunk.
local function md5(value: string): string
	local bytes = {string.byte(value, 1, #value)}
	local originalLength = #bytes

	local bitLengthLow = (originalLength * 8) % U32
	local bitLengthHigh = math.floor(originalLength / 536870912)

	table.insert(bytes, 0x80)

	while #bytes % 64 ~= 56 do
		table.insert(bytes, 0)
	end

	for shift = 0, 24, 8 do
		table.insert(
			bytes,
			math.floor(bitLengthLow / 2 ^ shift) % 256
		)
	end

	for shift = 0, 24, 8 do
		table.insert(
			bytes,
			math.floor(bitLengthHigh / 2 ^ shift) % 256
		)
	end

	local a0 = 0x67452301
	local b0 = 0xefcdab89
	local c0 = 0x98badcfe
	local d0 = 0x10325476

	local shifts = {
		7,12,17,22,
		7,12,17,22,
		7,12,17,22,
		7,12,17,22,

		5,9,14,20,
		5,9,14,20,
		5,9,14,20,
		5,9,14,20,

		4,11,16,23,
		4,11,16,23,
		4,11,16,23,
		4,11,16,23,

		6,10,15,21,
		6,10,15,21,
		6,10,15,21,
		6,10,15,21,
	}

	local k = {
		0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
		0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
		0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
		0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
		0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
		0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
		0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
		0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
		0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
		0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
		0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
		0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
		0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
		0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
		0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
		0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
	}

	--// rotates a 32-bit value left.
	local function leftRotate(value: number, amount: number): number
		return bit32.bor(
			bit32.lshift(value, amount),
			bit32.rshift(value, 32 - amount)
		)
	end

	for chunkStart = 1, #bytes, 64 do
		local words = table.create(16)

		for word = 0, 15 do
			local offset = chunkStart + word * 4

			words[word + 1] =
				bytes[offset]
				+ bytes[offset + 1] * 256
				+ bytes[offset + 2] * 65536
				+ bytes[offset + 3] * 16777216
		end

		local a = a0
		local b = b0
		local c = c0
		local d = d0

		for i = 0, 63 do
			local f
			local g

			if i < 16 then
				f = bit32.bor(
					bit32.band(b, c),
					bit32.band(bit32.bnot(b), d)
				)

				g = i
			elseif i < 32 then
				f = bit32.bor(
					bit32.band(d, b),
					bit32.band(bit32.bnot(d), c)
				)

				g = (5 * i + 1) % 16
			elseif i < 48 then
				f = bit32.bxor(b, c, d)
				g = (3 * i + 5) % 16
			else
				f = bit32.bxor(
					c,
					bit32.bor(b, bit32.bnot(d))
				)

				g = (7 * i) % 16
			end

			local temp = d
			local sum = (a + f + k[i + 1] + words[g + 1]) % U32

			d = c
			c = b
			b = (b + leftRotate(sum, shifts[i + 1])) % U32
			a = temp
		end

		a0 = (a0 + a) % U32
		b0 = (b0 + b) % U32
		c0 = (c0 + c) % U32
		d0 = (d0 + d) % U32
	end

	local result = {}

	for _, value in ipairs({a0, b0, c0, d0}) do
		for shift = 0, 24, 8 do
			table.insert(
				result,
				string.char(math.floor(value / 2 ^ shift) % 256)
			)
		end
	end

	return table.concat(result)
end

--// creates the literal-only LZ4 block used by the Python converter.
local function lz4LiteralBlock(data: string): string
	local length = #data
	local output = createWriter(length + 16)

	writeU8(output, math.min(length, 15) * 16)

	if length >= 15 then
		local remaining = length - 15

		while remaining >= 255 do
			writeU8(output, 255)
			remaining -= 255
		end

		writeU8(output, remaining)
	end

	writeBytes(output, data)

	return writerString(output)
end

--// creates one RBXL binary chunk.
local function makeChunk(
	signature: string,
	payload: string,
	compression: string
): string
	local output = createWriter(#payload + 32)

	writeBytes(output, signature)

	if compression == "none" then
		writeU32(output, 0)
		writeU32(output, #payload)
		writeU32(output, 0)
		writeBytes(output, payload)

		return writerString(output)
	end

	if compression == "lz4" then
		local compressed = lz4LiteralBlock(payload)

		writeU32(output, #compressed)
		writeU32(output, #payload)
		writeU32(output, 0)
		writeBytes(output, compressed)

		return writerString(output)
	end

	error("zstd compression is unavailable in this Luau implementation")
end

--// parses the root SharedStrings table.
local function parseSharedStrings(root: XmlElement): {[string]: string}
	local table = {}

	for _, element in ipairs(root.children) do
		if localName(element.tag) == "SharedStrings" then
			for _, entry in ipairs(element.children) do
				if localName(entry.tag) == "SharedString" then
					local key = entry.attributes.md5 or ""

					if key ~= "" then
						table[key] = base64Decode(text(entry))
					end
				end
			end
		end
	end

	return table
end

--// parses all Roblox Item elements into instances.
local function parseInstances(
	root: XmlElement
): ({Instance}, {[string]: Instance})
	local roots = {}
	local byReferent = {}
	local order = 0

	local function visit(item: XmlElement, parent: Instance?)
		local className = item.attributes.class
		local referent = item.attributes.referent

		if not className or not referent then
			error("Item missing class/referent")
		end

		if byReferent[referent] then
			error("duplicate referent: " .. referent)
		end

		local instance: Instance = {
			className = className,
			referent = referent,
			name = className,
			parent = parent,
			children = {},
			properties = {},
			propertyOrder = {},
			order = order,
		}

		order += 1
		byReferent[referent] = instance

		if parent then
			table.insert(parent.children, instance)
		else
			table.insert(roots, instance)
		end

		for _, element in ipairs(item.children) do
			local tag = localName(element.tag)

			if tag == "Properties" then
				for _, property in ipairs(element.children) do
					local name = property.attributes.name

					if name then
						instance.properties[name] = {
							name = name,
							tag = localName(property.tag),
							element = property,
						}

						table.insert(instance.propertyOrder, name)

						if name == "Name" then
							instance.name = text(property, className)
						end
					end
				end
			elseif tag == "Item" then
				visit(element, instance)
			end
		end
	end

	for _, element in ipairs(root.children) do
		if localName(element.tag) == "Item" then
			visit(element, nil)
		end
	end

	return roots, byReferent
end

--// produces the same iterative depth-first postorder as Python.
local function postorder(roots: {Instance}): {Instance}
	local output = {}
	local stack = {}

	for i = #roots, 1, -1 do
		table.insert(stack, {
			instance = roots[i],
			expanded = false,
		})
	end

	while #stack > 0 do
		local entry = table.remove(stack)
		local instance = entry.instance

		if entry.expanded then
			table.insert(output, instance)
		else
			table.insert(stack, {
				instance = instance,
				expanded = true,
			})

			for i = #instance.children, 1, -1 do
				table.insert(stack, {
					instance = instance.children[i],
					expanded = false,
				})
			end
		end
	end

	return output
end

--// parses an XML vector.
local function vector(
	element: XmlElement?,
	names: {string}
): {number}
	local values = table.create(#names)

	for i, name in ipairs(names) do
		values[i] = numberValue(childText(element, name, "0"))
	end

	return values
end

--// parses a UDim value.
local function parseUdim(element: XmlElement): (number, number)
	return
		numberValue(childText(element, "Scale", "0")),
		integerValue(childText(element, "Offset", "0"))
end

--// parses a UDim2 value.
local function parseUdim2(
	element: XmlElement
): (number, number, number, number)
	return
		numberValue(
			childText(element, "XS", childText(element, "XScale", "0"))
		),
		numberValue(
			childText(element, "YS", childText(element, "YScale", "0"))
		),
		integerValue(
			childText(element, "XO", childText(element, "XOffset", "0"))
		),
		integerValue(
			childText(element, "YO", childText(element, "YOffset", "0"))
		)
end

--// parses a CFrame position and rotation matrix.
local function parseCFrame(
	element: XmlElement
): ({number}, {number})
	return
		vector(element, {"X", "Y", "Z"}),
		vector(element, {
			"R00","R01","R02",
			"R10","R11","R12",
			"R20","R21","R22",
		})
end

--// resolves a CFrame rotation matrix to its canonical rotation id.
local function parseMatrixId(
	matrix: {number}
): (number, {number})
	local rounded = table.create(9)
	local key = ""

	for i, value in ipairs(matrix) do
		rounded[i] = math.floor(value * 1000000 + 0.5) / 1000000
		key ..= string.format("%.6f,", rounded[i])
	end

	local id = ROTATION_TO_ID[key]

	if id then
		return id, {}
	end

	for candidateId, candidate in pairs(ROTATIONS) do
		local valid = true

		for i = 1, 9 do
			if math.abs(rounded[i] - candidate[i]) >= 1e-5 then
				valid = false
				break
			end
		end

		if valid then
			return candidateId, {}
		end
	end

	return 0, matrix
end

--// returns the property element for one instance.
local function getElement(
	instance: Instance,
	propertyName: string
): XmlElement?
	local property = instance.properties[propertyName]

	return property and property.element or nil
end

--// writes NumberSequence keypoints exactly in the same little-endian layout.
local function encodeNumberSequence(
	elements: {XmlElement?}
): string
	local output = createWriter()

	for _, element in ipairs(elements) do
		local keypoints = {}

		if element then
			for _, keypoint in ipairs(element.children) do
				local tag = string.lower(localName(keypoint.tag))

				if tag == "keypoint"
					or tag == "numbersequencekeypoint" then
					table.insert(keypoints, {
						numberValue(childText(keypoint, "Time", "0")),
						numberValue(childText(keypoint, "Value", "0")),
						numberValue(childText(keypoint, "Envelope", "0")),
					})
				end
			end
		end

		writeU32(output, #keypoints)

		for _, values in ipairs(keypoints) do
			writeF32(output, values[1])
			writeF32(output, values[2])
			writeF32(output, values[3])
		end
	end

	return writerString(output)
end

--// writes ColorSequence keypoints exactly in the same little-endian layout.
local function encodeColorSequence(
	elements: {XmlElement?}
): string
	local output = createWriter()

	for _, element in ipairs(elements) do
		local keypoints = {}

		if element then
			for _, keypoint in ipairs(element.children) do
				local tag = string.lower(localName(keypoint.tag))

				if tag == "keypoint"
					or tag == "colorsequencekeypoint" then

					local color =
						child(keypoint, "Color3")
						or child(keypoint, "Color")
						or keypoint

					table.insert(keypoints, {
						numberValue(childText(keypoint, "Time", "0")),
						numberValue(childText(color, "R", "0")),
						numberValue(childText(color, "G", "0")),
						numberValue(childText(color, "B", "0")),
					})
				end
			end
		end

		writeU32(output, #keypoints)

		for _, values in ipairs(keypoints) do
			writeF32(output, values[1])
			writeF32(output, values[2])
			writeF32(output, values[3])
			writeF32(output, values[4])
			writeF32(output, 0)
		end
	end

	return writerString(output)
end

--// encodes one grouped Roblox property.
local function encodeValues(
	tag: string,
	propertyName: string,
	group: {Instance},
	idMap: {[string]: number},
	sharedMap: {[string]: number},
	className: string,
	sharedStringTable: {[string]: string}
): (number?, string?)

	tag = PROPERTY_TYPE_OVERRIDES[propertyName] or tag

	if FORCE_CONTENT_ID_STRING[className .. "." .. propertyName] then
		tag = "ContentId"
	elseif CONTENT_STRUCT_PROPERTY_NAMES[propertyName] then
		tag = "Content"
	elseif tag == "Content" then
		tag = "ContentId"
	end

	local elements = table.create(#group)

	for _, instance in ipairs(group) do
		table.insert(
			elements,
			getElement(instance, propertyName)
		)
	end

	if tag == "string" or tag == "ProtectedString" then
		local output = createWriter()

		for _, element in ipairs(elements) do
			writeString(output, text(element))
		end

		return T_STRING, writerString(output)
	end

	if tag == "ContentId" then
		local output = createWriter()

		for _, element in ipairs(elements) do
			writeString(output, contentText(element))
		end

		return T_STRING, writerString(output)
	end

	if tag == "SecurityCapabilities" then
		local values = table.create(#elements)

		for i, element in ipairs(elements) do
			values[i] = parseInt64(text(element))
		end

		local output = createWriter(#elements * 8)

		writeInterleavedI64(output, values)

		return T_SECURITY_CAPABILITIES, writerString(output)
	end

	if tag == "NumberSequence" then
		return T_NUMBERSEQUENCE, encodeNumberSequence(elements)
	end

	if tag == "ColorSequence" then
		return T_COLORSEQUENCE, encodeColorSequence(elements)
	end

	if tag == "Content" then
		local sourceTypes = {}
		local uris = {}

		for _, element in ipairs(elements) do
			local value = contentText(element)

			if value == "" then
				table.insert(sourceTypes, 0)
			else
				table.insert(sourceTypes, 1)
				table.insert(uris, value)
			end
		end

		local output = createWriter()

		writeInterleavedI32(output, sourceTypes)
		writeU32(output, #uris)

		for _, uri in ipairs(uris) do
			writeString(output, uri)
		end

		writeU32(output, 0)
		writeU32(output, 0)

		return T_CONTENT, writerString(output)
	end

	if tag == "BinaryString" then
		local output = createWriter()

		for _, element in ipairs(elements) do
			writeBString(output, base64Decode(text(element)))
		end

		return T_STRING, writerString(output)
	end

	if tag == "bool" then
		local output = createWriter(#elements)

		for _, element in ipairs(elements) do
			writeU8(output, booleanValue(text(element)) and 1 or 0)
		end

		return T_BOOL, writerString(output)
	end

	if tag == "int" then
		local values = table.create(#elements)

		for i, element in ipairs(elements) do
			values[i] = integerValue(text(element))
		end

		local output = createWriter(#elements * 4)
		writeInterleavedI32(output, values)

		return T_INT, writerString(output)
	end

	if tag == "int64" then
		local values = table.create(#elements)

		for i, element in ipairs(elements) do
			values[i] = parseInt64(text(element))
		end

		local output = createWriter(#elements * 8)
		writeInterleavedI64(output, values)

		return T_INT64, writerString(output)
	end

	if tag == "float" then
		local values = table.create(#elements)

		for i, element in ipairs(elements) do
			values[i] = numberValue(text(element))
		end

		local output = createWriter(#elements * 4)
		writeInterleavedF32(output, values)

		return T_FLOAT, writerString(output)
	end

	if tag == "double" then
		local output = createWriter(#elements * 8)

		for _, element in ipairs(elements) do
			writeF64(output, numberValue(text(element)))
		end

		return T_DOUBLE, writerString(output)
	end

	if tag == "token" then
		local values = table.create(#elements)

		for i, element in ipairs(elements) do
			values[i] = integerValue(text(element))
		end

		local output = createWriter(#elements * 4)
		writeInterleavedU32(output, values)

		return T_TOKEN, writerString(output)
	end

	if tag == "BrickColor" then
		local values = table.create(#elements)

		for i, element in ipairs(elements) do
			values[i] = integerValue(text(element))
		end

		local output = createWriter(#elements * 4)
		writeInterleavedU32(output, values)

		return T_BRICKCOLOR, writerString(output)
	end

	if tag == "Color3uint8" then
		local r = {}
		local g = {}
		local b = {}

		for _, element in ipairs(elements) do
			local packed = integerValue(text(element), 0)

			table.insert(
				r,
				bit32.band(bit32.rshift(packed, 16), 0xff)
			)

			table.insert(
				g,
				bit32.band(bit32.rshift(packed, 8), 0xff)
			)

			table.insert(
				b,
				bit32.band(packed, 0xff)
			)
		end

		local output = createWriter(#elements * 3)

		for _, value in ipairs(r) do
			writeU8(output, value)
		end

		for _, value in ipairs(g) do
			writeU8(output, value)
		end

		for _, value in ipairs(b) do
			writeU8(output, value)
		end

		return T_COLOR3UINT8, writerString(output)
	end

	if tag == "Color3" then
		local r, g, b = {}, {}, {}

		for _, element in ipairs(elements) do
			local values = vector(element, {"R", "G", "B"})

			table.insert(r, values[1])
			table.insert(g, values[2])
			table.insert(b, values[3])
		end

		local output = createWriter(#elements * 12)

		writeInterleavedF32(output, r)
		writeInterleavedF32(output, g)
		writeInterleavedF32(output, b)

		return T_COLOR3, writerString(output)
	end

	if tag == "Vector2" then
		local x, y = {}, {}

		for _, element in ipairs(elements) do
			local values = vector(element, {"X", "Y"})

			table.insert(x, values[1])
			table.insert(y, values[2])
		end

		local output = createWriter(#elements * 8)

		writeInterleavedF32(output, x)
		writeInterleavedF32(output, y)

		return T_VECTOR2, writerString(output)
	end

	if tag == "Vector3" then
		local x, y, z = {}, {}, {}

		for _, element in ipairs(elements) do
			local values = vector(element, {"X", "Y", "Z"})

			table.insert(x, values[1])
			table.insert(y, values[2])
			table.insert(z, values[3])
		end

		local output = createWriter(#elements * 12)

		writeInterleavedF32(output, x)
		writeInterleavedF32(output, y)
		writeInterleavedF32(output, z)

		return T_VECTOR3, writerString(output)
	end

	if tag == "Vector2int16" then
		local output = createWriter(#elements * 4)

		for _, element in ipairs(elements) do
			writeI16(
				output,
				integerValue(childText(element, "X", "0"))
			)

			writeI16(
				output,
				integerValue(childText(element, "Y", "0"))
			)
		end

		return T_VECTOR2INT16, writerString(output)
	end

	if tag == "Vector3int16" then
		local output = createWriter(#elements * 6)

		for _, element in ipairs(elements) do
			writeI16(
				output,
				integerValue(childText(element, "X", "0"))
			)

			writeI16(
				output,
				integerValue(childText(element, "Y", "0"))
			)

			writeI16(
				output,
				integerValue(childText(element, "Z", "0"))
			)
		end

		return T_VECTOR3INT16, writerString(output)
	end

	if tag == "UDim" then
		local scales, offsets = {}, {}

		for _, element in ipairs(elements) do
			local scale, offset = parseUdim(element)

			table.insert(scales, scale)
			table.insert(offsets, offset)
		end

		local output = createWriter(#elements * 8)

		writeInterleavedF32(output, scales)
		writeInterleavedI32(output, offsets)

		return T_UDIM, writerString(output)
	end

	if tag == "UDim2" then
		local xs, ys, xo, yo = {}, {}, {}, {}

		for _, element in ipairs(elements) do
			local xScale, yScale, xOffset, yOffset =
				parseUdim2(element)

			table.insert(xs, xScale)
			table.insert(ys, yScale)
			table.insert(xo, xOffset)
			table.insert(yo, yOffset)
		end

		local output = createWriter(#elements * 16)

		writeInterleavedF32(output, xs)
		writeInterleavedF32(output, ys)
		writeInterleavedI32(output, xo)
		writeInterleavedI32(output, yo)

		return T_UDIM2, writerString(output)
	end

	if tag == "Ref" or tag == "Object" then
		local ids = {}

		for _, element in ipairs(elements) do
			local reference = text(element)

			if reference == "" then
				table.insert(ids, -1)
			else
				table.insert(ids, idMap[reference] or -1)
			end
		end

		local output = createWriter(#elements * 4)

		writeReferents(output, ids)

		return T_REFERENCE, writerString(output)
	end

	if tag == "Faces" then
		local bits = {
			Right = 0,
			Top = 1,
			Back = 2,
			Left = 3,
			Bottom = 4,
			Front = 5,
		}

		local output = createWriter(#elements)

		for _, element in ipairs(elements) do
			local mask = 0

			if element then
				for _, face in ipairs(element.children) do
					local bit = bits[localName(face.tag)]

					if bit and booleanValue(text(face)) then
						mask = bit32.bor(
							mask,
							bit32.lshift(1, bit)
						)
					end
				end
			end

			writeU8(output, mask)
		end

		return T_FACES, writerString(output)
	end

	if tag == "Axes" then
		local bits = {
			X = 0,
			Y = 1,
			Z = 2,
		}

		local output = createWriter(#elements)

		for _, element in ipairs(elements) do
			local mask = 0

			if element then
				for _, axis in ipairs(element.children) do
					local bit = bits[localName(axis.tag)]

					if bit and booleanValue(text(axis)) then
						mask = bit32.bor(
							mask,
							bit32.lshift(1, bit)
						)
					end
				end
			end

			writeU8(output, mask)
		end

		return T_AXES, writerString(output)
	end

	if tag == "Ray" then
		local output = createWriter(#elements * 24)

		for _, element in ipairs(elements) do
			writeF32(
				output,
				numberValue(
					childText(
						element,
						"originX",
						childText(element, "OriginX", "0")
					)
				)
			)

			writeF32(
				output,
				numberValue(
					childText(
						element,
						"originY",
						childText(element, "OriginY", "0")
					)
				)
			)

			writeF32(
				output,
				numberValue(
					childText(
						element,
						"originZ",
						childText(element, "OriginZ", "0")
					)
				)
			)

			writeF32(
				output,
				numberValue(
					childText(
						element,
						"directionX",
						childText(element, "DirectionX", "0")
					)
				)
			)

			writeF32(
				output,
				numberValue(
					childText(
						element,
						"directionY",
						childText(element, "DirectionY", "0")
					)
				)
			)

			writeF32(
				output,
				numberValue(
					childText(
						element,
						"directionZ",
						childText(element, "DirectionZ", "0")
					)
				)
			)
		end

		return T_RAY, writerString(output)
	end

	if tag == "CFrame" or tag == "CoordinateFrame" then
		local rotations = createWriter()
		local x, y, z = {}, {}, {}

		for _, element in ipairs(elements) do
			local position
			local matrix

			if element then
				position, matrix = parseCFrame(element)
			else
				position = {0, 0, 0}
				matrix = ROTATIONS[0x02]
			end

			local rotationId, custom = parseMatrixId(matrix)

			writeU8(rotations, rotationId)

			if rotationId == 0 then
				for _, value in ipairs(custom) do
					writeF32(rotations, value)
				end
			end

			table.insert(x, position[1])
			table.insert(y, position[2])
			table.insert(z, position[3])
		end

		local output = createWriter(
			rotations.position + #elements * 12
		)

		writeBytes(output, writerString(rotations))
		writeInterleavedF32(output, x)
		writeInterleavedF32(output, y)
		writeInterleavedF32(output, z)

		return T_CFRAME, writerString(output)
	end

	if tag == "NumberRange" then
		local output = createWriter(#elements * 8)

		for _, element in ipairs(elements) do
			writeF32(
				output,
				numberValue(childText(element, "min", "0"))
			)

			writeF32(
				output,
				numberValue(childText(element, "max", "0"))
			)
		end

		return T_NUMBERRANGE, writerString(output)
	end

	if tag == "Rect2D" or tag == "Rect" then
		local minX, minY, maxX, maxY = {}, {}, {}, {}

		for _, element in ipairs(elements) do
			local minElement = child(element, "Min")
			local maxElement = child(element, "Max")

			local values

			if minElement and maxElement then
				values = {
					numberValue(childText(minElement, "X", "0")),
					numberValue(childText(minElement, "Y", "0")),
					numberValue(childText(maxElement, "X", "0")),
					numberValue(childText(maxElement, "Y", "0")),
				}
			else
				values = {
					numberValue(childText(element, "MinX", "0")),
					numberValue(childText(element, "MinY", "0")),
					numberValue(childText(element, "MaxX", "0")),
					numberValue(childText(element, "MaxY", "0")),
				}
			end

			table.insert(minX, values[1])
			table.insert(minY, values[2])
			table.insert(maxX, values[3])
			table.insert(maxY, values[4])
		end

		local output = createWriter(#elements * 16)

		writeInterleavedF32(output, minX)
		writeInterleavedF32(output, minY)
		writeInterleavedF32(output, maxX)
		writeInterleavedF32(output, maxY)

		return T_RECT, writerString(output)
	end

	if tag == "SharedString" then
		local ids = {}

		for _, element in ipairs(elements) do
			local key = text(element)
			local raw = sharedStringTable[key] or ""

			if sharedMap[raw] == nil then
				local nextId = 0

				for _ in pairs(sharedMap) do
					nextId += 1
				end

				sharedMap[raw] = nextId
			end

			table.insert(ids, sharedMap[raw])
		end

		local output = createWriter(#elements * 4)

		writeInterleavedU32(output, ids)

		return T_SHAREDSTRING, writerString(output)
	end

	if tag == "UniqueId" then
		local output = createWriter(#elements * 16)

		for _, element in ipairs(elements) do
			local index = integerValue(
				childText(element, "Index", "0")
			)

			local timeValue = integerValue(
				childText(element, "Time", "0")
			)

			local randomValue = childText(
				element,
				"Random",
				"0"
			)

			writeBEU32(output, index)
			writeBEU32(output, timeValue)
			writeBEU64(output, parseHex64(randomValue))
		end

		return T_UNIQUEID, writerString(output)
	end

	if tag == "Font" then
		local output = createWriter()

		for _, element in ipairs(elements) do
			writeString(
				output,
				childText(element, "Family", "")
			)

			writeU16(
				output,
				integerValue(
					childText(element, "Weight", "400")
				)
			)

			writeU8(
				output,
				integerValue(
					childText(element, "Style", "0")
				)
			)

			writeString(
				output,
				childText(element, "CachedFaceId", "")
			)
		end

		return T_FONT, writerString(output)
	end

	if tag == "PhysicalProperties" then
		local output = createWriter()

		for _, element in ipairs(elements) do
			local custom = false

			if element then
				custom =
					booleanValue(
						childText(element, "CustomPhysics", "")
					)
					or booleanValue(
						element.attributes.CustomPhysics
					)
			end

			if not custom then
				writeU8(output, 0)
			else
				writeU8(output, 1)

				writeF32(
					output,
					numberValue(
						childText(element, "Density", "0.7")
					)
				)

				writeF32(
					output,
					numberValue(
						childText(element, "Friction", "0.3")
					)
				)

				writeF32(
					output,
					numberValue(
						childText(element, "Elasticity", "0.5")
					)
				)

				writeF32(
					output,
					numberValue(
						childText(element, "FrictionWeight", "1")
					)
				)

				writeF32(
					output,
					numberValue(
						childText(element, "ElasticityWeight", "1")
					)
				)
			end
		end

		return T_PHYSICALPROPERTIES, writerString(output)
	end

	return nil
end

--// converts the parsed instance tree into RBXL/RBXM binary.
local function convert(
	roots: {Instance},
	compression: string,
	sharedStringTable: {[string]: string}
): string
	local ordered = postorder(roots)
	local idMap = {}

	for i, instance in ipairs(ordered) do
		idMap[instance.referent] = i - 1
	end

	local grouped = {}

	for _, instance in ipairs(ordered) do
		grouped[instance.className] =
			grouped[instance.className] or {}

		table.insert(
			grouped[instance.className],
			instance
		)
	end

	local classNames = {}

	for className in pairs(grouped) do
		table.insert(classNames, className)
	end

	table.sort(classNames)

	local typeIds = {}

	for i, className in ipairs(classNames) do
		typeIds[className] = i - 1
	end

	local sharedMap = {}
	local sharedValues = {}

	for _, instance in ipairs(ordered) do
		for _, property in pairs(instance.properties) do
			if property.tag == "SharedString" then
				local raw =
					sharedStringTable[text(property.element)] or ""

				if sharedMap[raw] == nil then
					sharedMap[raw] = #sharedValues
					table.insert(sharedValues, raw)
				end
			end
		end
	end

	local output = createWriter(
		math.max(1024, #ordered * 64)
	)

	writeBytes(output, MAGIC)
	writeU16(output, VERSION)
	writeU32(output, #typeIds)
	writeU32(output, #ordered)
	writeU32(output, 0)
	writeU32(output, 0)

	if #sharedValues > 0 then
		local payload = createWriter()

		writeU32(payload, 0)
		writeU32(payload, #sharedValues)

		for _, raw in ipairs(sharedValues) do
			writeBytes(payload, md5(raw))
			writeBString(payload, raw)
		end

		writeBytes(
			output,
			makeChunk(
				"SSTR",
				writerString(payload),
				compression
			)
		)
	end

	--// INST chunks.
	for _, className in ipairs(classNames) do
		local group = grouped[className]
		local isService =
			ROBLOX_SERVICE_CLASSES[className] == true

		local payload = createWriter()

		writeU32(payload, typeIds[className])
		writeString(payload, className)
		writeU8(payload, isService and 1 or 0)
		writeU32(payload, #group)

		local referents = {}

		for _, instance in ipairs(group) do
			table.insert(
				referents,
				idMap[instance.referent]
			)
		end

		writeReferents(payload, referents)

		if isService then
			for _, instance in ipairs(group) do
				writeU8(
					payload,
					instance.parent == nil and 1 or 0
				)
			end
		end

		writeBytes(
			output,
			makeChunk(
				"INST",
				writerString(payload),
				compression
			)
		)
	end

	--// PROP chunks.
	for _, className in ipairs(classNames) do
		local group = grouped[className]
		local names = {}

		for _, instance in ipairs(group) do
			for propertyName in pairs(instance.properties) do
				if propertyName ~= "Name" then
					names[propertyName] = true
				end
			end
		end

		local propertyNames = {}

		for propertyName in pairs(names) do
			table.insert(propertyNames, propertyName)
		end

		table.sort(propertyNames)

		for _, propertyName in ipairs(propertyNames) do
			local sample: Property? = nil

			for _, instance in ipairs(group) do
				local property = instance.properties[propertyName]

				if property then
					sample = property
					break
				end
			end

			if sample then
				local typeId, values = encodeValues(
					sample.tag,
					propertyName,
					group,
					idMap,
					sharedMap,
					className,
					sharedStringTable
				)

				if typeId and values then
					local payload = createWriter(
						#values + 64
					)

					writeU32(
						payload,
						typeIds[className]
					)

					writeString(
						payload,
						propertyName
					)

					writeU8(payload, typeId)
					writeBytes(payload, values)

					writeBytes(
						output,
						makeChunk(
							"PROP",
							writerString(payload),
							compression
						)
					)
				else
					warn(
						string.format(
							"unsupported property %s.%s (<%s>); skipped",
							className,
							propertyName,
							sample.tag
						)
					)
				end
			end
		end

		local payload = createWriter(
			#group * 16 + 32
		)

		writeU32(
			payload,
			typeIds[className]
		)

		writeString(payload, "Name")
		writeU8(payload, T_STRING)

		for _, instance in ipairs(group) do
			writeString(payload, instance.name)
		end

		writeBytes(
			output,
			makeChunk(
				"PROP",
				writerString(payload),
				compression
			)
		)
	end

	--// PRNT.
	local children = {}
	local parents = {}

	for _, instance in ipairs(ordered) do
		table.insert(
			children,
			idMap[instance.referent]
		)

		if instance.parent then
			table.insert(
				parents,
				idMap[instance.parent.referent]
			)
		else
			table.insert(parents, -1)
		end
	end

	local prnt = createWriter(
		#ordered * 8 + 5
	)

	writeU8(prnt, 0)
	writeU32(prnt, #ordered)
	writeReferents(prnt, children)
	writeReferents(prnt, parents)

	writeBytes(
		output,
		makeChunk(
			"PRNT",
			writerString(prnt),
			compression
		)
	)

	writeBytes(
		output,
		makeChunk(
			END_SIGNATURE,
			END_PAYLOAD,
			"none"
		)
	)

	return writerString(output)
end

-- >> main
--// converts Roblox RBXLX/RBMX XML text into RBXL/RBXM binary text.
--// @params: xmlData string -- complete Roblox XML document.
--// @params: compression string? -- lz4 or none. defaults to lz4.
--// @returns: string -- binary Roblox file data.
local function Convert(
	xmlData: string,
	compression: string?
): string
	assert(
		type(xmlData) == "string",
		"xmlData must be a string"
	)

	compression = compression or "lz4"

	assert(
		compression == "lz4" or compression == "none",
		"compression must be 'lz4' or 'none'"
	)

	local root = parseXml(xmlData)

	if localName(root.tag) ~= "roblox" then
		error("root element must be <roblox>")
	end

	local sharedStringTable = parseSharedStrings(root)
	local roots = parseInstances(root)

	if #roots == 0 then
		error("XML contains no <Item> instances")
	end

	return convert(
		roots,
		compression,
		sharedStringTable
	)
end

return Convert
-- >> end << --
