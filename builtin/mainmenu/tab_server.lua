--Minetest
--Copyright (C) 2014 sapier
--
--This program is free software; you can redistribute it and/or modify
--it under the terms of the GNU Lesser General Public License as published by
--the Free Software Foundation; either version 3.0 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Lesser General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public License along
--with this program; if not, write to the Free Software Foundation, Inc.,
--51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

--------------------------------------------------------------------------------

local function get_formspec(tabview, name, tabdata)
         
        menudata.worldlist:refresh()
        local index = menudata.worldlist:get_current_index(
                                tonumber(minetest.setting_get("mainmenu_last_selected_world"))
                                )
        local world = menudata.worldlist:get_raw_element(index or 1)

        local pngpath = ''
        if world then
            pngpath = world.name .. '.png'
        end
        local retval =
            "size[16,11]"..
            "box[0,7.5;16,10;#999999]" ..
            "box[0,0;16,2;#999999]" ..
            "bgcolor[#00000070;true]"..
            "button[8.1,7.5;3.95,0.8;start_server;".. fgettext("Play") .. "]"..
            --"button[4.2,7.7;3.95,0.8;world_create;".. fgettext("New") .. "]"..

           -- "button[4.2,8.55;3.95,0.8;world_delete;".. fgettext("Delete") .. "]"..
            "button[4.2,7.5;3.95,0.8;cancel;".. fgettext("Back") .. "]"..
            "label[1.5,1.5;" .. fgettext("Select World:") .. "]" ..
            "checkbox[1.5,7.39;cb_creative_mode;" .. fgettext("Creative Mode") .. ";" .. dump(minetest.setting_getbool("creative_mode")) .. "]"
            .. "image[8.8,2;6.35,6.35;"..pngpath.."]"

        retval = retval ..
                "textlist[1.5,2.2;6.3,5;srv_worlds;" ..
                menu_render_worldlist() ..
                ";" .. (index or 1) .. ";true]"

        return retval
end

--------------------------------------------------------------------------------
local function main_button_handler(this, fields, name, tabdata)
    minetest.set_clouds(false)

        local world_doubleclick = false

        if fields["btn_single"]~=nil then
           local single = create_tab_single(true)
           single:set_parent(this.parent)
           single:show()
           this:hide()
           return true
        end

        if fields["srv_worlds"] ~= nil then
                local event = minetest.explode_textlist_event(fields["srv_worlds"])
                if event.type == "DCL" then
                        world_doubleclick = true
                end
                if event.type == "CHG" then
                        minetest.setting_set("mainmenu_last_selected_world",
                                menudata.worldlist:get_raw_index(minetest.get_textlist_index("srv_worlds")))
                        return true
                end
        end

        if menu_handle_key_up_down(fields,"srv_worlds","mainmenu_last_selected_world") then
                return true
        end

        if fields["cb_creative_mode"] then
                minetest.setting_set("creative_mode", fields["cb_creative_mode"])
                local bool = fields["cb_creative_mode"]
                if bool == 'true' then
                   bool = 'false'
                else
                   bool = 'true'
                end
                minetest.setting_set("enable_damage", bool)
                minetest.setting_save()
                return true
        end

        if fields["cb_enable_damage"] then
                minetest.setting_set("enable_damage", fields["cb_enable_damage"])
                return true
        end

        if fields["cb_server_announce"] then
                minetest.setting_set("server_announce", fields["cb_server_announce"])
                return true
        end
        if fields["freegold"] ~= nil then
            core.freegold()
            return true
        end
        if fields["gotoshop"] ~= nil then
            ui.gotoshop()
            return true
        end
        if fields["start_server"] ~= nil or
                world_doubleclick or
                fields["key_enter"] then
                local selected = minetest.get_textlist_index("srv_worlds")
                if selected ~= nil then
                        gamedata.playername     = "singleplayer"
                        gamedata.password       = ""
                        gamedata.port           = 35544
                        gamedata.address        = ""
                        gamedata.selected_world = menudata.worldlist:get_raw_index(selected)

                        minetest.setting_set("port",gamedata.port)
                        if fields["te_serveraddr"] ~= nil then
                                minetest.setting_set("bind_address",fields["te_serveraddr"])
                        end

                        --update last game
                        local world = menudata.worldlist:get_raw_element(gamedata.selected_world)

                        local game,index = gamemgr.find_by_gameid(world.gameid)
                        minetest.setting_set("menu_last_game",game.id)
                        minetest.start()
                        return true
                end
        end

        if fields["world_create"] ~= nil then
                local create_world_dlg = create_create_world_dlg(true)
                create_world_dlg:set_parent(this)
                create_world_dlg:show()
                this:hide()
                return true
        end

        if fields["world_delete"] ~= nil then
                local selected = minetest.get_textlist_index("srv_worlds")
                if selected ~= nil and
                        selected <= menudata.worldlist:size() then
                        local world = menudata.worldlist:get_list()[selected]
                        if world ~= nil and
                                world.name ~= nil and
                                world.name ~= "" then

                                if world.gold ~= -1 then
                                    gamedata.errormessage = fgettext("Can't delete this map(system map)")
                                    return true
                                end

                                local index = menudata.worldlist:get_raw_index(selected)
                                local delete_world_dlg = create_delete_world_dlg(world.name,index)
                                delete_world_dlg:set_parent(this)
                                delete_world_dlg:show()
                                this:hide()
                        end
                end

                return true
        end

        if fields["world_configure"] ~= nil then
                local selected = minetest.get_textlist_index("srv_worlds")
                if selected ~= nil then
                        local configdialog =
                                create_configure_world_dlg(
                                                menudata.worldlist:get_raw_index(selected))

                        if (configdialog ~= nil) then
                                configdialog:set_parent(this)
                                configdialog:show()
                                this:hide()
                        end
                end
                return true
        end

    if fields["cancel"] ~= nil then
       this:hide()
       this.parent:show()
       return true
    end

        return false
end

--------------------------------------------------------------------------------
tab_server = {
        name = "server",
        caption = fgettext("Server"),
        cbf_formspec = get_formspec,
        cbf_button_handler = main_button_handler,
        on_change = nil
}