--------------------Check your Games (ONLY PSP GAMES)-----------------------------------------------------------------------
list = {data = {}, len = 0, icons = {}, picons = {} }
filenames = { fn = {}, len = 0 }


function get_filenames()
	if files.listfiles(PATHTOLICENSE) == nil then 
		os.message("Could not find valid RIF, using fake license.\nYour bubble will only work with henkaku")
	end
	return files.listfiles(PATHTOLICENSE)[1].path
end


function copy_license()
	local test = files.copy(get_filenames(), "ux0:/pspemu/bgdl/00000004/NPUG80318/sce_sys/package/")
	if test < 1 then
		os.message("Copying RIF\n"..files.listfiles(PATHTOLICENSE)[1].name.."\nfailed!")
		buttons.homepopup(1)
		return false
	else
		if files.exists("ux0:/pspemu/bgdl/00000004/NPUG80318/sce_sys/package/work.bin") then
			local test2 = files.delete("ux0:/pspemu/bgdl/00000004/NPUG80318/sce_sys/package/work.bin")
		end
		local test3 = 0
		local keep = files.cdir()
		files.cdir("ux0:/pspemu/bgdl/00000004/NPUG80318/sce_sys/package/")
		test3 = files.rename(files.listfiles(PATHTOLICENSE)[1].name, "work.bin")
		if test3 > 0 then
			os.message("Successfully copied RIF file.")
		else
			os.message("Moving RIF\n"..files.listfiles(PATHTOLICENSE)[1].name.."\nfailed!")
			buttons.homepopup(1)
			return false
		end

		files.cdir(keep)
		
		return true
		
	end
end

function reload_list()
	list.data = game.list(__GAME_LIST_PSPEMU)
	table.sort(list.data ,function (a,b) return string.lower(a.id)<string.lower(b.id); end)

	list.len = #list.data
	--Reversiva
	for i=list.len,1,-1 do
		local info = nil
		info = game.info(string.format("%s/eboot.pbp",list.data[i].path))
		
		if info then
			if info.CATEGORY and info.CATEGORY == "EG" then
				local img = nil
				local pimg = nil

				--Inicializar campos
				list.data[i].comp = "No"
				list.data[i].flag, list.data[i].del = 0, false
				list.data[i].clon = ""
				list.data[i].sceid, list.data[i].title = "Unk","Unk"

				if info.TITLE then list.data[i].title = info.TITLE end

				pimg = game.geticon0(string.format("%s/pboot.pbp",list.data[i].path))
				list.picons[i] = pimg

				img = game.geticon0(string.format("%s/eboot.pbp",list.data[i].path))
				if img then
					list.data[i].comp = "Yes"
					list.data[i].flag = 1
				end
				list.icons[i] = img

				sceid = game.sceid(string.format("%s/__sce_ebootpbp",list.data[i].path))
				if sceid and sceid != "---" then
					list.data[i].sceid = sceid
					if list.data[i].sceid != list.data[i].id then
						list.data[i].clon = "©"
						clon+=1
					end
				end

			else
				table.remove(list.data,i)
			end
		else
			table.remove(list.data,i)
		end
	end

	--Update
	list.len = #list.data
end

----------------------------Update DataBase---------------------------------------------------------------------------------
function update_db(flag)
	os.delay(1000)
	os.updatedb()
	if flag then
		os.message("Your PSVita will restart...\nRemember to activate Henkaku Again",0)
	else
		os.message("Your PSVita will restart...\nand your database will be rebuilt",0)
	end
	buttons.homepopup(1)
	os.delay(2500)
	power.restart()
end

------------------------Check your Free Space-------------------------------------------------------------------------------
function check_freespace()
	local info = os.devinfo("ux0:")
	if info then
		sizeUxo = info.free
		
		if (info.free > 40 * 1024* 1024) then return true
		else return false end
	end
end

function delete_bubble(_gameid)
	files.delete(PATHTOCLON.._gameid)
	files.delete(PATHTOGAME.._gameid)
end
