--
-- register nodes:
--

minetest.register_node("lantern:candle", {
	description = "Candle",
	drawtype = "plantlike",
	inventory_image = "candle_inv.png",
	tiles = {
			{name="candle.png", animation={type = "vertical_frames", aspect_w = 32, aspect_h = 32, length = 0.8}},
		},	
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	light_source = LIGHT_MAX - 1,
	groups = {dig_immediate = 3, attached_node = 1},
	sounds = default.node_sound_defaults(),
	selection_box = {
			type = "fixed",
			fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
		},
})