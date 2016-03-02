print("[Chains] v1.2")

-- wrought iron items

minetest.register_node("chains:chain", {
	description = "Hanging chain (wrought iron)",
	walkable = false,
	climbable = true,
	sunlight_propagates = true,
	paramtype = "light",
	drops = "",
	tiles = { "chains_chain.png" },
	inventory_image = "chains_chain.png",
	drawtype = "plantlike",
	groups = {cracky=3},
	sounds =  default.node_sound_stone_defaults(),
})

minetest.register_node("chains:chain_top", {
	description = "Hanging chain (ceiling mount, wrought iron)",
	walkable = false,
	climbable = true,
	sunlight_propagates = true,
	paramtype = "light",
	drops = "",
	tiles = { "chains_chain_top.png" },
	inventory_image = "chains_chain_top_inv.png",
	drawtype = "plantlike",
	groups = {cracky=3},
	sounds =  default.node_sound_stone_defaults(),
})

minetest.register_node("chains:chandelier", {
	description = "Chandelier (wrought iron)",
	paramtype = "light",
	walkable = false,
	light_source = LIGHT_MAX-2,
	climbable = true,
	sunlight_propagates = true,
	paramtype = "light",
	drops = "",
	tiles = { {name="chains_chandelier.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}}},
	inventory_image = "chains_chandelier_inv.png",
	drawtype = "plantlike",
	groups = {cracky=3},
	sounds =  default.node_sound_stone_defaults(),
})


-- crafts

minetest.register_craft({
	output = 'chains:chain 2',
	recipe = {
		{'default:steel_ingot'},
		{'default:steel_ingot'},
		{'default:steel_ingot'},
	}
})

minetest.register_craft({
	output = 'chains:chain_top',
	recipe = {
		{'default:steel_ingot'},
		{'default:steel_ingot'},	
	},
})

minetest.register_craft({
	output = 'chains:chandelier',
	recipe = {
		{'', 'default:steel_ingot', ''},
		{'default:torch', 'default:steel_ingot', 'default:torch'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
	}
})