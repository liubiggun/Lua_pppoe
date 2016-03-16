#!/usr/bin/lua

socket = require "nixio".socket
bit = require "nixio".bit

local ip1, ip2, ip3, ip4 = arg[1], arg[2], arg[3], arg[4]
local mac = arg[5]
local isp = arg[6]

--local ip1, ip2, ip3, ip4 = 172, 19, 54, 123
--local mac = "B2:68:B6:FF:C8:AD"
--local isp = 3


--转换无符号32位整数为int32
function u2i (uint)
	local rs=uint
	local signed = bit.rshift(uint,31)
        --获取符号位
        if signed > 0 then  --负数
		rs = bit.band(bit.bnot(uint), 0x7fffffff) + 1
		rs = -1 * rs
	end	
	return rs	
end

--lua用double来保存数值，故进行数值运算时需要将checksum转化为int32
--不参与数值运算的数值不需要u2i，因为我们在bit运算时已经将其视为int32
function calchecksum(bytes)
	local checksum = 0x4e67c6a7
	
	for k, v in ipairs(bytes) do
		local rb = u2i(bit.band(bit.rshift(checksum, 2), 0xffffffff))
		local lb = u2i(bit.band(bit.lshift(checksum, 5), 0xffffffff))

		if u2i(checksum) < 0 then
			rb = u2i(bit.band(bit.bor(rb, 0xc0000000), 0xffffffff))
		end

		local temp = rb + lb + v
		--溢出，钟摆原理
		if temp < 0x80000000 then
			temp = temp + 0x100000000
		elseif temp > 0x7fffffff then
			temp = temp - 0x100000000
		end
		checksum = bit.band(bit.bxor(checksum, temp), 0xffffffff)
		--print(checksum)
	end	
	
	return bit.band(checksum, 0x7fffffff)
end

local data = string.char(0)
local bytes = {0}

--1至30字节为0x00
for i=2, 30 do
	data = data..string.char(0)
	bytes[i] = 0
end

--31至34字节为ip
data = data..string.char(ip1)..string.char(ip2)..string.char(ip3)..string.char(ip4)
bytes[31], bytes[32], bytes[33], bytes[34] = ip1, ip2, ip3, ip4

--35字节到51字节是mac地址
data = data..mac

for i=35, 51 do
	bytes[i] = string.byte(mac, i-34)
end

--52字节到54字节是0x00，55字节是isp，56字节是0x00
data = data..string.char(0)..string.char(0)..string.char(0)..string.char(isp)..string.char(0)
bytes[52], bytes[53], bytes[54], bytes[55],bytes[56] = 0, 0, 0, isp, 0

--57字节到60字节是校验和，小端方式pack
checksum = calchecksum(bytes)

data = data..string.char(bit.band(checksum, 0x000000ff))
data = data..string.char(bit.band(bit.rshift(checksum, 8),0x000000ff))
data = data..string.char(bit.band(bit.rshift(checksum, 16),0x000000ff))
data = data..string.char(bit.band(bit.rshift(checksum, 24),0x000000ff))

local server = "202.193.160.123"
local port = 20015

local sock = socket("inet","dgram")
sock:setopt("socket", "reuseaddr", 1)
sock:setopt("socket", "rcvtimeo", 3)

sock:sendto(data, server, port)

msg, _, _ = sock:recvfrom(5)

if msg then
	print("success")
else
	print("fail")
end

sock:close()


















