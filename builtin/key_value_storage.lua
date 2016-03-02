--
-- Key-value storage stuff
--

function minetest.kv_put(key, data)
    local json = minetest.write_json(data)
    if not json then
        minetest.log("error", "kv_put: Error in json serialize key=".. key .. " luaized_data=" .. minetest.serialize(data))
        return
    end
    return minetest.kv_put_string(key, json)
end

function minetest.kv_get(key)
    local data = minetest.kv_get_string(key)
    if data ~= nil then
        data = minetest.parse_json(data)
    end
    return data
end

function minetest.kv_rename(key1, key2)
    local data = minetest.kv_get_string(key1)
    minetest.kv_delete(key1)
    minetest.kv_put_string(key2, data)
end
