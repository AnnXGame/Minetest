minetest.register_node("glowstone:block", {
	description = "Glowstone",
	tiles = {"glowstone_block.png"},
	is_ground_content = true,
	groups = {cracky=3,oddly_breakable_by_hand=2},
	drop = 'glowstone:block',
	sounds = default.node_sound_glass_defaults(),
	light_source = 14,
})

minetest.register_craft({
	output = 'glowstone:block 4',
	recipe = {
		{'group:stone', 'group:stone', 'group:stone'},
		{'group:stone', 'default:mese_crystal', 'group:stone'},
		{'group:stone', 'group:stone', 'group:stone'},
	}
})


local function overwrite(name, light)
	local table = minetest.registered_nodes[name]
	local table2 = {}
	for i,v in pairs(table) do
		table2[i] = v
	end
	table2.light_source = light
	minetest.register_node(":"..name, table2)
end

--stairs n slabs
if minetest.get_modpath("stairs") ~= nil then
	stairs.register_stair_and_slab("glowstone", "glowstone:block",
		{cracky=3,oddly_breakable_by_hand=2},
		{"glowstone_block.png"},
		"Glowstone Stair",
		"Glowstone Slab",
		default.node_sound_glass_defaults())

	minetest.after(0,overwrite,"stairs:slab_glowstone",14)
	minetest.after(0,overwrite,"stairs:stair_glowstone",14)
	minetest.after(0,overwrite,"stairs:slab_glowstoneupside_down",14)
	minetest.after(0,overwrite,"stairs:stair_glowstoneupside_down",14)
end
