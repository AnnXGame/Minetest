--
-- register crafting recipes:
--
minetest.register_craft({
	output = 'lantern:candle 12',
	recipe = {
		{'default:coal_lump','default:coal_lump'},
		{'group:stick','group:stick'},
		}
})