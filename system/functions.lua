--------------------Check your Games (ONLY PSP GAMES)-----------------------------------------------------------------------
list = {data = {}, len = 0, icons = {}, picons = {} }
filenames = { fn = {}, len = 0 }

function credits()
	local pos = 1
	local y = 85
	local reverse = false
	local ft = font.load("resources/fonts/Neuton-Bold.ttf")
	font.setdefault(ft)
	while true do
		draw.gradrect(1, 1, 959, 543, color.blue, color.green, __DIAGONAL)
		buttons.read()
		screen.print(472, 20, "Credits", 1, color.red)	
		screen.print(472, 35, "----------", 1, color.red)
		screen.print(460, y, "Acid_Snake", 1, color.black, color.orange)
		screen.print(460, y+20, "Yoti", 1, color.black, color.orange)
		screen.print(460, y+40, "Krazynez", 1, color.black, color.orange)
		screen.print(430, y+60, "#Blame Cypress", 1, color.black, color.orange)
		if buttons.released.r then
			font.setdefault()
			break
		end
		if y > 409 and reverse == true then
			y -= 1 
		elseif y > 409 and reverse == false then
			reverse = true
		elseif y < 86 and reverse == true then
			reverse = false
		elseif reverse == true and y > 85 then
			y -= 1
		elseif reverse == false then
			y += 1
		end
		screen.flip()
	end
end

function find_license()
	local pos = 1
	buttons.homepopup(1)
	buttons.interval(10,10)
	while true do
		buttons.read()
		if back then back:blit(0,0) end
		screen.print(40, 20, "Please choose a License:")

		local y = 85
		for i=pos, math.minmax(#files.listfiles(PATHTOLICENSE),1, #files.listfiles(PATHTOLICENSE)) do
			if i == pos and i < 10 then 
				screen.print(10,y," "..i.."  ->") 
			else if i == pos and i > 9 then
				screen.print(10,y,i.." ->") 
			end
			end
			screen.print(65,y,files.listfiles(PATHTOLICENSE)[i].name or "unk")
			y += 20
		end
		
		if buttons.up and pos > 1 then pos -= 1 end
		if buttons.down and pos < #files.listfiles(PATHTOLICENSE) then pos += 1 end

		if buttons.cross then
			return files.listfiles(PATHTOLICENSE)[pos]
		end
		if buttons.circle then
			return "cancelled"
		end
		if buttons.held.square then
			screen.print(600, 500, "Oh.... Hey you \nfound me good job ;-)")
		end
		screen.print(40, 500, "Press X to confirm")
		screen.print(400, 500, "Press O to Cancel")
		screen.flip()
	end
end

function copy_license(license)
	if license == nil then
		os.message("Could not find valid RIF, using fake license.\nYour bubble will only work with henkaku")
		return false
	end
	local test = files.copy(license.path, "ux0:/pspemu/bgdl/00000004/NPUG80318/sce_sys/package/")
	if test < 1 then
		os.message("Copying RIF\n"..license.name.."\nfailed!")
		buttons.homepopup(1)
		return false
	else
		if files.exists("ux0:/pspemu/bgdl/00000004/NPUG80318/sce_sys/package/work.bin") then
			local test2 = files.delete("ux0:/pspemu/bgdl/00000004/NPUG80318/sce_sys/package/work.bin")
		end
		local keep = files.cdir()
		files.cdir("ux0:/pspemu/bgdl/00000004/NPUG80318/sce_sys/package/")
		local test3 = files.rename(license.name, "work.bin")
		
		if test3 > 0 then
			os.message("Successfully copied RIF file.")
		else
			os.message("Moving RIF\n"..license.name.."\nfailed!")
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
