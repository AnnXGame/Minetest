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

mt_color_grey  = "#AAAAAA"
mt_color_blue  = "#0000DD"
mt_color_green = "#00DD00"
mt_color_dark_green = "#003300"

--for all other colors ask sfan5 to complete his work!

local menupath = minetest.get_mainmenu_path()
local basepath = minetest.get_builtin_path()
defaulttexturedir = minetest.get_texturepath_share() .. DIR_DELIM .. "base" ..
                    DIR_DELIM .. "pack" .. DIR_DELIM

dofile(basepath .. DIR_DELIM .. "common" .. DIR_DELIM .. "async_event.lua")
dofile(basepath .. DIR_DELIM .. "common" .. DIR_DELIM .. "filterlist.lua")
dofile(basepath .. DIR_DELIM .. "fstk" .. DIR_DELIM .. "buttonbar.lua")
dofile(basepath .. DIR_DELIM .. "fstk" .. DIR_DELIM .. "dialog.lua")
dofile(basepath .. DIR_DELIM .. "fstk" .. DIR_DELIM .. "tabview.lua")
dofile(basepath .. DIR_DELIM .. "fstk" .. DIR_DELIM .. "ui.lua")
dofile(menupath .. DIR_DELIM .. "common.lua")
dofile(menupath .. DIR_DELIM .. "gamemgr.lua")
dofile(menupath .. DIR_DELIM .. "modmgr.lua")
dofile(menupath .. DIR_DELIM .. "tab_server.lua")
dofile(menupath .. DIR_DELIM .. "tab_texturepacks.lua")
dofile(menupath .. DIR_DELIM .. "textures.lua")

--------------------------------------------------------------------------------
local function main_event_handler(tabview, event)
    if event == "MenuQuit" then
        minetest.close()
    end

    return true
end

--------------------------------------------------------------------------------
local function get_formspec(tabview, name, tabdata)
    local retval = ""
    retval = retval .. "bgcolor[#00000000;false]"
    retval = retval .. "button[2.5,4.3;7,1;event_restore;" .. fgettext("Restore") .. "]"
    retval = retval .. "button[2.5,2.9;3.25,1;event_removeads;"..  fgettext("Remove Ads") .. "]"
    retval = retval .. "button[6.25,2.9;3.25,1;event_vip;".. fgettext("VIP") .. "]"
    retval = retval .. "button[2.5,1.5;7,1;event_server;".. fgettext("Play") .. "]"

    if minetest.setting_get("apppromote") ~= "" then
        retval = retval .. "image_button[10.5,2.5;1.2,1.2;"..core.formspec_escape(mm_texture.basetexturedir) ..
        "logo.png;btn_promote;;true;true;"
        .. core.formspec_escape(mm_texture.basetexturedir).."logo.png]"
    end

    return retval
end

--------------------------------------------------------------------------------

local function main_button_handler(tabview, fields, name, tabdata)
    local index = ''
    if fields["event_server"] then  index = "server"       end
    if fields["event_local"]  then  index = "multiplayer"  end

    if fields["event_removeads"] ~= nil then
        core.removeads()
        return true
    end

    if fields["btn_promote"] ~= nil then
        print("btn_promote")
        core.promoteapp()
        return true
    end

    if fields["event_restore"] ~= nil then
        core.restoreiap()
        return true
    end

    if fields["event_vip"] ~= nil then
        core.vip()
        return true
    end

    if index == '' then return end
    for name,def in pairs(tabview.tablist) do
       if index == def.name then
        local get_fs = function()
           local retval = def.get_formspec(tabview, name, tabdata)
           retval = 'size[12,5.2]'..retval
           return retval
        end
        local dlg = dialog_create(def.name, get_fs, def.button_handler, def.on_change)
        dlg:set_parent(tabview)
        tabview:hide()
        dlg:show()
        return dlg
       end
    end
   return false
end

--------------------------------------------------------------------------------
local function on_activate(type,old_tab,new_tab)
    if type == "LEAVE" then
        return
    end
   -- if minetest.setting_getbool("public_serverlist") then
   --     asyncOnlineFavourites()
   -- else
   --     menudata.favorites = minetest.get_favorites("local")
   -- end
    menudata.favorites = {}
    mm_texture.clear("header")
    mm_texture.clear("footer")
    minetest.set_clouds(false)
    minetest.set_background("background",minetest.formspec_escape(mm_texture.basetexturedir)..'background.jpg')
    --minetest.set_background("header",minetest.formspec_escape(mm_texture.basetexturedir)..'menu_header.png')
end

--------------------------------------------------------------------------------
tab_main = {
    name = "main",
    caption = fgettext("Main"),
    cbf_formspec = get_formspec,
    cbf_button_handler = main_button_handler,
    on_change = on_activate
    }

--------------------------------------------------------------------------------
local function init_globals()
    -- Init gamedata
    gamedata.worldindex = 0

    menudata.worldlist = filterlist.create(
        minetest.get_worlds,
        compare_worlds,
        -- Unique id comparison function
        function(element, uid)
            return element.name == uid
        end,
        -- Filter function
        function(element, gameid)
            return element.gameid == gameid
        end
    )

    menudata.worldlist:add_sort_mechanism("alphabetic", sort_worlds_alphabetic)
    menudata.worldlist:set_sortmode("alphabetic")

    if not minetest.setting_get("menu_last_game") then
        local default_game = minetest.setting_get("default_game") or "magichet"
        minetest.setting_set("menu_last_game", default_game )
    end

    mm_texture.init()


    -- Create main tabview
    local tv_main = tabview_create("maintab",{x=12,y=5.2},{x=0,y=0})

    tv_main:set_autosave_tab(false)
    tv_main:add(tab_main)
   -- tv_main:add(tab_multiplayer)
    tv_main:add(tab_server)
    tv_main:set_global_event_handler(main_event_handler)
    tv_main:set_fixed_size(false)
    ui.set_default("main")
    tv_main:show()
    ui.update()
    minetest.sound_play("main_menu", true)

end

init_globals()
