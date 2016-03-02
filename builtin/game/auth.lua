-- Minetest: builtin/auth.lua

--
-- Authentication handler
--

function minetest.string_to_privs(str, delim)
	if type(str) ~= "string" then return end
	delim = delim or ','
	local privs = {}
	for _, priv in pairs(string.split(str, delim)) do
		privs[priv:trim()] = true
	end
	return privs
end

function minetest.privs_to_string(privs, delim)
	assert(type(privs) == "table")
	delim = delim or ','
	local list = {}
	for priv, bool in pairs(privs) do
		if bool then
			table.insert(list, priv)
		end
	end
	return table.concat(list, delim)
end

assert(minetest.string_to_privs("a,b").b == true)
assert(minetest.privs_to_string({a=true,b=true}) == "a,b")

minetest.auth_file_path = minetest.get_worldpath().."/auth.txt"
minetest.auth_table = {}

local hex={}
for i=0,255 do
    hex[string.format("%0x",i)]=string.char(i)
    hex[string.format("%0X",i)]=string.char(i)
end

local function uri_decode(str)
	str = string.gsub (str, "+", " ")
	return (str:gsub('%%(%x%x)',hex))
end

function uri_encode (str)
	str = string.gsub (str, "([^0-9a-zA-Z_ -])", function (c) return string.format ("%%%02X", string.byte(c)) end)
	str = string.gsub (str, " ", "+")
	return str
end

local function read_auth_file()
	local newtable = {}
	local file, errmsg = io.open(minetest.auth_file_path, 'rb')
	if not file then
		minetest.log("info", minetest.auth_file_path.." could not be opened for reading ("..errmsg.."); assuming new world")
		return
	end
	for line in file:lines() do
		if line ~= "" then
			local fields = line:split(":", true)
			local name, password, privilege_string, last_login = unpack(fields)
			last_login = tonumber(last_login)
			if not (name and password and privilege_string) then
				error("Invalid line in auth.txt: "..dump(line))
			end
			local privileges = minetest.string_to_privs(privilege_string)
			newtable[uri_decode(name)] = {password=password, privileges=privileges, last_login=last_login}
		end
	end
	io.close(file)
	minetest.auth_table = newtable
	minetest.notify_authentication_modified()
end

local function save_auth_file()
	local newtable = {}
	-- Check table for validness before attempting to save
	for name, stuff in pairs(minetest.auth_table) do
		assert(type(name) == "string")
		assert(name ~= "")
		assert(type(stuff) == "table")
		assert(type(stuff.password) == "string")
		assert(type(stuff.privileges) == "table")
		assert(stuff.last_login == nil or type(stuff.last_login) == "number")
	end
	local file, errmsg = io.open(minetest.auth_file_path, 'w+b')
	if not file then
		error(minetest.auth_file_path.." could not be opened for writing: "..errmsg)
	end
	for name, stuff in pairs(minetest.auth_table) do
		local priv_string = minetest.privs_to_string(stuff.privileges)
		local parts = {uri_encode(name), stuff.password, priv_string, stuff.last_login or ""}
		file:write(table.concat(parts, ":").."\n")
	end
	io.close(file)
end

read_auth_file()

minetest.builtin_auth_handler = {
	get_auth = function(name)
		assert(type(name) == "string")
		-- Figure out what password to use for a new player (singleplayer
		-- always has an empty password, otherwise use default, which is
		-- usually empty too)
		local new_password_hash = ""
		-- If not in authentication table, return nil
		if not minetest.auth_table[name] then
			return nil
		end
		-- Figure out what privileges the player should have.
		-- Take a copy of the privilege table
		local privileges = {}
		for priv, _ in pairs(minetest.auth_table[name].privileges) do
			privileges[priv] = true
		end
		-- If singleplayer, give all privileges except those marked as give_to_singleplayer = false
		if minetest.is_singleplayer() then
			for priv, def in pairs(minetest.registered_privileges) do
				if def.give_to_singleplayer then
					privileges[priv] = true
				end
			end
		-- For the admin, give everything
		elseif name == minetest.setting_get("name") then
			for priv, def in pairs(minetest.registered_privileges) do
				privileges[priv] = true
			end
		end
		-- All done
		return {
			password = minetest.auth_table[name].password,
			privileges = privileges,
			-- Is set to nil if unknown
			last_login = minetest.auth_table[name].last_login,
		}
	end,
	create_auth = function(name, password)
		assert(type(name) == "string")
		assert(type(password) == "string")
		minetest.log('info', "Built-in authentication handler adding player '"..name.."'")
		local privs = minetest.setting_get("default_privs")
		if minetest.setting_getbool("creative_mode") and minetest.setting_get("default_privs_creative") then
			privs = minetest.setting_get("default_privs_creative")
		end
		minetest.auth_table[name] = {
			password = password,
			privileges = minetest.string_to_privs(privs),
			last_login = os.time(),
		}
		save_auth_file()
	end,
	set_password = function(name, password)
		assert(type(name) == "string")
		assert(type(password) == "string")
		if not minetest.auth_table[name] then
			minetest.builtin_auth_handler.create_auth(name, password)
		else
			minetest.log('info', "Built-in authentication handler setting password of player '"..name.."'")
			minetest.auth_table[name].password = password
			save_auth_file()
		end
		return true
	end,
	set_privileges = function(name, privileges)
		assert(type(name) == "string")
		assert(type(privileges) == "table")
		if not minetest.auth_table[name] then
			minetest.builtin_auth_handler.create_auth(name,
				minetest.get_password_hash(name,
					minetest.setting_get("default_password")))
		end
		minetest.auth_table[name].privileges = privileges
		minetest.notify_authentication_modified(name)
		save_auth_file()
	end,
	reload = function()
		read_auth_file()
		return true
	end,
	record_login = function(name)
		assert(type(name) == "string")
		assert(minetest.auth_table[name]).last_login = os.time()
		save_auth_file()
	end,
}

function minetest.register_authentication_handler(handler)
	if minetest.registered_auth_handler then
		error("Add-on authentication handler already registered by "..minetest.registered_auth_handler_modname)
	end
	minetest.registered_auth_handler = handler
	minetest.registered_auth_handler_modname = minetest.get_current_modname()
end

function minetest.get_auth_handler()
	return minetest.registered_auth_handler or minetest.builtin_auth_handler
end

local function auth_pass(name)
	return function(...)
		local auth_handler = minetest.get_auth_handler()
		if auth_handler[name] then
			return auth_handler[name](...)
		end
		return false
	end
end

minetest.set_player_password = auth_pass("set_password")
minetest.set_player_privs    = auth_pass("set_privileges")
minetest.auth_reload         = auth_pass("reload")


local record_login = auth_pass("record_login")

minetest.register_on_joinplayer(function(player)
	record_login(player:get_player_name())
end)

