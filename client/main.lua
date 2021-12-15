BR = nil
local InBossMenu = false
local LastPosition = nil
local lastskin = {}

Citzen.CreateThread(function()
	while BR == nil do
		TriggerEvent('brt:getSharedObject', function(obj) BR = obj end)
		Citzen.Wait(0)
	end

	while BR.GetPlayerData().job == nil do
		Citzen.Wait(10)
	end

	BR.PlayerData = BR.GetPlayerData()
end)

RegisterNetEvent('brt:setJob')
AddEventHandler('brt:setJob', function(job)
	BR.PlayerData.job = job
end)

function OpenBossMenu(society, close, options)
	local isBoss = nil
	local options  = options or {}
	local elements = {}

	BR.TriggerServerCallback('brt_society:isBoss', function(result)
		isBoss = result
	end, society)

	while isBoss == nil do
		Citzen.Wait(100)
	end

	if not isBoss then
		return
	end

	local defaultOptions = {
		withdraw  = false,
		deposit   = true,
		dwithdraw = true,
		ddeposit  = true,
		wash      = false,
		employees = true,
		salary    = false,
		grade     = true,
		inventory = true,
		vehicle   = true,
		weapon    = true,
		cloth     = true
	}

	for k,v in pairs(defaultOptions) do
		if options[k] == nil then
			options[k] = v
		end
	end

	local wait = true
	BR.TriggerServerCallback('brt_society:getSocietyMoney', function(money, dirty_money)
		table.insert(elements ,{label = 'Bodje: <span style="color:green;">$'.. money .. '</span>', value = nil})
		table.insert(elements ,{label = 'PoolKasif: <span style="color:red;">$'.. dirty_money .. '</span>', value = nil})
		wait = false
	end, BR.PlayerData.job.name)

	while wait do
		Citzen.Wait(0)
	end

	if options.withdraw then
		table.insert(elements, {label = _U('withdraw_society_money'), value = 'withdraw_society_money'})
	end

	if options.deposit then
		table.insert(elements, {label = _U('deposit_society_money'), value = 'deposit_money'})
	end

	if options.dwithdraw then
		table.insert(elements, {label = _U('withdraw_society_dirty_money'), value = 'withdraw_society_dirty_money'})
	end

	if options.ddeposit then
		table.insert(elements, {label = _U('deposit_society_dirty_money'), value = 'deposit_dirty_money'})
	end

	if options.wash then
		table.insert(elements, {label = _U('wash_money'), value = 'wash_money'})
	end

	if options.employees then
		table.insert(elements, {label = _U('employee_management'), value = 'manage_employees'})
	end

	if options.salary then
		table.insert(elements, {label = _U('salary_management'), value = 'manage_grades'})
	end

	if options.grade then
		table.insert(elements, {label = _U('manage_grades_name'), value = 'manage_grades_name'})
	end

	if options.inventory then
		table.insert(elements, {label = _U('manage_inventory'), value = 'manage_inventory'})
	end

	if options.vehicle then
		table.insert(elements, {label = _U('manage_vehicles'), value = 'manage_vehicles'})
	end

	if options.weapon then
		table.insert(elements, {label = _U('manage_weapons'), value = 'manage_weapons'})
	end

	if options.cloth then
		table.insert(elements, {label = _U('manage_grades_outfit'), value = 'manage_grades_outfit'})
	end


	BR.UI.Menu.Open('default', GetCurrentResourceName(), 'boss_actions_' .. society, {
		title    = _U('boss_menu'),
		align    = 'top-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'withdraw_society_money' then
			BR.UI.Menu.Open('dialog', GetCurrentResourceName(), 'withdraw_society_money_amount_' .. society, {
				title = _U('withdraw_amount')
			}, function(data, menu)
				local amount = tonumber(data.value)
				if amount == nil then
					BR.ShowNotification(_U('invalid_amount'))
				else
					menu.close()
					TriggerServerEvent('brt_society:withdrawMoney', society, amount)
				end
			end, function(data, menu)
				menu.close()
			end)
		elseif data.current.value == 'deposit_money' then
			OpenDepositMoney(society, close, options)
		elseif data.current.value == 'withdraw_society_dirty_money' then
			BR.UI.Menu.Open('dialog', GetCurrentResourceName(), 'withdraw_society_dirty_money_amount_' .. society, {
				title = _U('withdraw_amount')
			}, function(data, menu)
				local amount = tonumber(data.value)
				if amount == nil then
					BR.ShowNotification("Meghdar Namotabar")
				else
					menu.close()
					TriggerServerEvent('brt_society:withdrawDirty_Money', society, amount)
				end
			end, function(data, menu)
				menu.close()
			end)
		elseif data.current.value == 'deposit_dirty_money' then
			OpenDepositDirty_Money(society, close, options)
		elseif data.current.value == 'wash_money' then
			BR.UI.Menu.Open('dialog', GetCurrentResourceName(), 'wash_money_amount_' .. society, {
				title = _U('wash_money_amount')
			}, function(data, menu)
				local amount = tonumber(data.value)
				if amount == nil then
					BR.ShowNotification(_U('invalid_amount'))
				else
					menu.close()
					TriggerServerEvent('brt_society:washMoney', society, amount)
				end
			end, function(data, menu)
				menu.close()
			end)
		elseif data.current.value == 'manage_employees' then
			OpenManageEmployeesMenu(society)
		elseif data.current.value == 'manage_grades' then
			OpenManageGradesMenu(society)
		elseif data.current.value == 'manage_grades_name' then
			OpenGradeNames(society)
		elseif data.current.value == 'manage_grades_outfit' then
			if society == 'police' or society == 'sheriff' or society == 'fbi' or society == 'artesh' or society == 'government' then
				OpenSetOutfitMenu(society)
			else
				OpenManageEmployeeClothes(society)
			end
		elseif data.current.value == 'manage_weapons' then
			if DoesHaveArmory(society) then
				OpenWeaponsManagment(society)
			else
				BR.ShowNotification("Shoghl Shoma In Ghabeliyat Tanzim In Mored Ra Nadarad :(")
			end
		elseif data.current.value == 'manage_vehicles' then
			if DoesHaveGarage(society) then
				OpenVehiclesManagment(society)
			else
				BR.ShowNotification("Shoghl Shoma In Ghabeliyat Tanzim In Mored Ra Nadarad :(")
			end
		elseif data.current.value == 'manage_inventory' then
			if DoesHaveInventory(society) then
				OpenInventoryManagment(society)
			else
				BR.ShowNotification("Shoghl Shoma In Ghabeliyat Tanzim In Mored Ra Nadarad :(")
			end
		end
	end, function(data, menu)
		if close then
			close(data, menu)
		end
	end)
end

function OpenInventoryManagment(society)
	BR.TriggerServerCallback('brt_society:getGrades', function(grades)
		local elements = {}
		for k,v in pairs(grades) do
			table.insert(elements, {label = v.label, grade = k})
		end
        BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades_' .. society .. '_new', {
            title = "Rank Ha",
            align = 'top-right',
            elements = elements
        }, function(data, menu)
            local gradeNumber = tonumber(data.current.grade)
			ChangeInventoryPerm(society, gradeNumber)
		end, function(data1, menu1)
			menu1.close()
		end)
	end, society)
end

function ChangeInventoryPerm(society, rank)
	BR.TriggerServerCallback('brt_society:getJobItems', function(authorizedItems)
		if authorizedItems then
			BR.TriggerServerCallback('brt_society:getItems', function(items)
				local rows = {}
				for k, society_items in ipairs(authorizedItems) do
					local found = false
					if items then
						for k2, item_state in ipairs(items) do
							if string.lower(society_items.name) == string.lower(item_state.name) then
								if item_state.status == true then
									table.insert(rows, { label = '(✔️) '..society_items.label, name = item_state.name, value = item_state.status })
								elseif item_state.status == false then
									table.insert(rows, { label = '(❌) '..society_items.label, name = item_state.name, value = item_state.status })
								end
								found = true
								break
							end
						end
					end
					if not found then
						table.insert(rows, { label = '(❌) '..society_items.label, name = society_items.name, value = false })
					end
				end
				BR.UI.Menu.CloseAll()
				BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades_Items_' .. society .. '', {
					title = "Modiriyat Inventory",
					align = 'top-right',
					elements = rows
				}, function(data, menu)
					local state = data.current.value
					local name = data.current.name
					if state then
						BR.TriggerServerCallback('brt_society:setSocietyItemPerm', function(result)
							ChangeInventoryPerm(society, rank)
						end, society, rank, rows, false, name)
					else
						BR.TriggerServerCallback('brt_society:setSocietyItemPerm', function(result)
							ChangeInventoryPerm(society, rank)
						end, society, rank, rows, true, name)
					end
				end, function(data, menu)
					menu.close()
				end)
			end, rank, society)
		else
			BR.ShowNotification("Hich Itemi Dakhel Inventory Nist")
		end
	end, society)
end

function OpenVehiclesManagment(society)
	BR.TriggerServerCallback('brt_society:getGrades', function(grades)
		local elements = {}
		for k,v in pairs(grades) do
			table.insert(elements, {label = v.label, grade = k})
		end
        BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades_' .. society .. '_new', {
            title = "Rank Ha",
            align = 'top-right',
            elements = elements
        }, function(data, menu)
            local gradeNumber = tonumber(data.current.grade)
			ChangeVehiclePerm(society, gradeNumber)
		end, function(data1, menu1)
			menu1.close()
		end)
	end, society)
end

function ChangeVehiclePerm(society, rank)
	local authorizedVehicles = Config.Garage[society]
	if authorizedVehicles then
		BR.TriggerServerCallback('brt_society:getVehicles', function(vehs)
			local rows = {}
			for k, society_vehicles in ipairs(authorizedVehicles) do
				local found = false
				if vehs then
					for k2, vehicle_state in ipairs(vehs) do
						if string.lower(society_vehicles.model) == string.lower(vehicle_state.model) then
							if vehicle_state.status == true then
								table.insert(rows, { label = '(✔️) '..vehicle_state.name, model = vehicle_state.model, name = vehicle_state.name, value = vehicle_state.status })
							elseif vehicle_state.status == false then
								table.insert(rows, { label = '(❌) '..vehicle_state.name, model = vehicle_state.model, name = vehicle_state.name, value = vehicle_state.status })
							end
							found = true
							break
						end
					end
				end
				if not found then
					table.insert(rows, { label = '(❌) '..society_vehicles.label, model = society_vehicles.model, name = society_vehicles.label, value = false })
				end
			end
			BR.UI.Menu.CloseAll()
			BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades_vehicles_' .. society .. '', {
				title = "Modiriyat Vasayele Naghlie",
				align = 'top-right',
				elements = rows
			}, function(data, menu)
				local state = data.current.value
				local model = data.current.model
				if state then
					BR.TriggerServerCallback('brt_society:setSocietyVehPerm', function(result)
						ChangeVehiclePerm(society, rank)
					end, society, rank, rows, false, model)
				else
					BR.TriggerServerCallback('brt_society:setSocietyVehPerm', function(result)
						ChangeVehiclePerm(society, rank)
					end, society, rank, rows, true, model)
				end
			end, function(data, menu)
				menu.close()
			end)
		end, rank, society)
	else
		BR.ShowNotification("Dar Load Kardan Vasayele Naghlie Moshkeli Pish Amade")
	end
end

function OpenWeaponsManagment(society)
	BR.TriggerServerCallback('brt_society:getGrades', function(grades)
		local elements = {}
		for k,v in pairs(grades) do
			table.insert(elements, {label = v.label, grade = k})
		end
        BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades_' .. society .. '_new', {
            title = "Rank Ha",
            align = 'top-right',
            elements = elements
        }, function(data, menu)
            local gradeNumber = tonumber(data.current.grade)
			ChangeWeaponPerm(society, gradeNumber)
		end, function(data1, menu1)
			menu1.close()
		end)
	end, society)
end

function ChangeWeaponPerm(society, rank)
	local authorizedWeapons = Config.Armory[society]
	if authorizedWeapons then
		BR.TriggerServerCallback('brt_society:getWeapons', function(weapons)
			local rows = {}
			for k, society_weapons in ipairs(authorizedWeapons) do
				local found = false
				if weapons then
					for k2, weapon_state in ipairs(weapons) do
						if string.lower(society_weapons) == string.lower(weapon_state.model) then
							if weapon_state.status == true then
								table.insert(rows, { label = '(✔️) '..GetModelLabel(weapon_state.model), model = weapon_state.model, value = weapon_state.status })
							elseif weapon_state.status == false then
								table.insert(rows, { label = '(❌) '..GetModelLabel(weapon_state.model), model = weapon_state.model, value = weapon_state.status })
							end
							found = true
							break
						end
					end
				end
				if not found then
					table.insert(rows, { label = '(❌) '..GetModelLabel(society_weapons), model = society_weapons, value = false })
				end
			end
			BR.UI.Menu.CloseAll()
			BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades_weapons_' .. society .. '', {
				title = "Modiriyat Aslahe Ha",
				align = 'top-right',
				elements = rows
			}, function(data, menu)
				local state = data.current.value
				local model = data.current.model
				if state then
					BR.TriggerServerCallback('brt_society:setSocietyWeapPerm', function(result)
						ChangeWeaponPerm(society, rank)
					end, society, rank, rows, false, model)
				else
					BR.TriggerServerCallback('brt_society:setSocietyWeapPerm', function(result)
						ChangeWeaponPerm(society,rank)
					end, society, rank, rows, true, model)
				end
			end, function(data, menu)
				menu.close()
			end)
		end, rank, society)
	else
		BR.ShowNotification("Dar Load Kardan Aslahe Ha Moshkeli Pish Amade")
	end
end

function OpenGradeNames(society)
	BR.TriggerServerCallback('brt_society:getGrades', function(grades)
		local elements = {}
		for k,v in pairs(grades) do
			table.insert(elements, {label = v.label, grade = k})
		end
		BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades_name', {
			title    = _U('manage_grades_name'),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			BR.UI.Menu.Open('dialog', GetCurrentResourceName(), 'rename_grade', {
                title    = "Esm Jadid Rank Ra Benevisid",
			}, function(data2, menu2)
				if not data2.value then
					BR.ShowNotification("Shoma Dar Ghesmat Esm Chizi Vared Nakardid")
					return
				end
				if data2.value:match("[^%w%s]") or data2.value:match("%d") then
					BR.ShowNotification("Shoma Mojaz Be Vared Kardan ~r~Character Haye Khas ~s~Va Ya ~r~Adad ~s~Nistid!")
					return
				end
				menu2.close()
				menu.close()
				TriggerServerEvent('brt_society:renameGrade', tonumber(data.current.grade), data2.value)
				OpenGradeNames(society)
            end, function (data2, menu2)
                menu2.close()
            end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenSetOutfitMenu(society)
	local elements = {
		{label = 'Lebas Asli', value = 'employee'},
		{label = 'Lebas Division', value = 'division'}
	}
	BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades_outfit' .. society, {
		title    = _U('manage_grades_outfit'),
		align    = 'top-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'employee' then
			OpenManageEmployeeClothes(society)
		end
		if data.current.value == 'division' then
			OpenManageDivisionClothes(society)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenManageEmployeeClothes(society)
	TriggerEvent('skinchanger:getSkin', function(skin)
		lastskin = skin
	end)
	BR.TriggerServerCallback('brt_society:getGrades', function(grades)
		local elements = {}
		for k,v in pairs(grades) do
		  	table.insert(elements, {label = '(' .. k .. ') | ' .. v.label, grade = k})
		end

		BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_clothe_' .. society, {
			title    = 'Modiriat Lebas',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			BR.TriggerServerCallback('brt_society:getJobSkinOnBoss', function(skin)
				skin_male = skin.skin_male
				skin_female = skin.skin_female
			end, society, tonumber(data.current.grade))
			BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_clothe2_' .. society, {
				title    = 'Modiriat Lebas',
				align    = 'top-right',
				elements = {
					{label = 'Poshidan Lebas In Rank', value = 'poshidan'},
					{label = 'Taghir Lebas In Rank', value = 'change'}
				}
			}, function(data2, menu2)
				if data2.current.value == "poshidan" then
					BR.TriggerServerCallback('brt_skin:getPlayerSkin', function(skin)
						if skin.sex == 0 then
							TriggerEvent('skinchanger:loadClothes', skin, skin_male)
						else
							TriggerEvent('skinchanger:loadClothes', skin, skin_female)
						end
					end)
				elseif data2.current.value == "change" then
					TriggerEvent('brt_skin:openRestrictedMenu', function(data2, menu2)
						menu2.close()
						TriggerEvent('skinchanger:getSkin', function(skin)
							TriggerServerEvent('brt_society:setUniform', society, tonumber(data.current.grade), skin)				
							TriggerEvent('skinchanger:loadSkin', lastskin)
							TriggerEvent("brt:restoreLoadout")
							BR.ShowNotification('Taghirat Baraye Rank ~g~' .. data.current.label .. ' ~s~Anjam Shod')
						end, function(data2, menu2)						
							menu2.close()						
						end)
					end, function(data2, menu2)
						menu2.close()
						TriggerEvent('skinchanger:loadSkin', lastskin)
						TriggerEvent("brt:restoreLoadout")	
					end, {
						'sex',
						'tshirt_1',
						'tshirt_2',
						'torso_1',
						'torso_2',
						'decals_1',
						'decals_2',
						'mask_1',
						'mask_2',
						'arms',
						'arms_2',
						'pants_1',
						'pants_2',
						'bproof_1',
						'bproof_2',
						'shoes_1',
						'shoes_2',
						'chain_1',
						'chain_2',
						'bags_1',
						'bags_2',
						'helmet_1',
						'helmet_2',
						'glasses_1',
						'glasses_2',
					})
				end
			end, function(data2, menu2)
				menu2.close()
				TriggerEvent('skinchanger:loadSkin', lastskin)
				TriggerEvent("brt:restoreLoadout")
			end)	
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenManageDivisionClothes(society)
	TriggerEvent('skinchanger:getSkin', function(skin)
		lastskin = skin
	end)
		local elements = {}
		if society == "police" then
			table.insert(elements, {label = "🥷 SWAT", value = "swat"})
			table.insert(elements, {label = "🚁 XRay", value = "xray"})
			table.insert(elements, {label = "🚘 Rahnamayii Ranandegi", value = "rahvar"})
			table.insert(elements, {label = "🐕‍🦺 K9", value = "k9"})
			table.insert(elements, {label = "🕵️‍♂️ Detective", value = "detective"})
			table.insert(elements, {label = "⛵ Niroye Daryayii", value = "daryayi"})
		elseif society == "sheriff" or society == "fbi" then
			table.insert(elements, {label = "🥷 SWAT", value = "swat"})
			table.insert(elements, {label = "🚁 XRay", value = "xray"})
			table.insert(elements, {label = "🐕‍🦺 K9", value = "k9"})
			table.insert(elements, {label = "🕵️‍♂️ Detective", value = "detective"})
			table.insert(elements, {label = "⛵ Niroye Daryayii", value = "daryayi"})
		elseif society == "artesh" then
			table.insert(elements, {label = "🥷 SWAT", value = "swat"})
			table.insert(elements, {label = "🚁 XRay", value = "xray"})
			table.insert(elements, {label = "🐕‍🦺 K9", value = "k9"})
			table.insert(elements, {label = "⛵ Niroye Daryayii", value = "daryayi"})
		elseif society == "government" then
			table.insert(elements, {label = "🚁 XRay", value = "xray"})
		end

		BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_clothe_' .. society, {
			title    = 'Modiriat Lebas Division',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			BR.TriggerServerCallback('brt_society:getDivisionSkinOnBoss', function(skin)
				skin_male = skin.skin_male
				skin_female = skin.skin_female
			end, society, data.current.value)
			BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_clothe2_' .. society, {
				title    = 'Modiriat Lebas Divison',
				align    = 'top-right',
				elements = {
					{label = 'Poshidan Lebas', value = 'poshidan'},
					{label = 'Taghir Lebas', value = 'change'}
				}
			}, function(data2, menu2)
				if data2.current.value == "poshidan" then
					BR.TriggerServerCallback('brt_skin:getPlayerSkin', function(skin)
						if skin.sex == 0 then
							TriggerEvent('skinchanger:loadClothes', skin, skin_male)
						else
							TriggerEvent('skinchanger:loadClothes', skin, skin_female)
						end
					end)
				elseif data2.current.value == "change" then
					TriggerEvent('brt_skin:openRestrictedMenu', function(data2, menu2)
						menu2.close()
						TriggerEvent('skinchanger:getSkin', function(skin)
							TriggerServerEvent('brt_society:setDivisionUniform', society, data.current.value, skin)				
							TriggerEvent('skinchanger:loadSkin', lastskin)
							TriggerEvent("brt:restoreLoadout")
							BR.ShowNotification('Taghirat Baraye Lebas ~g~' .. data.current.value .. ' ~s~Anjam Shod')
						end, function(data2, menu2)						
							menu2.close()						
						end)
					end, function(data2, menu2)
						menu2.close()
						TriggerEvent('skinchanger:loadSkin', lastskin)
						TriggerEvent("brt:restoreLoadout")	
					end, {
						'sex',
						'tshirt_1',
						'tshirt_2',
						'torso_1',
						'torso_2',
						'decals_1',
						'decals_2',
						'mask_1',
						'mask_2',
						'arms',
						'arms_2',
						'pants_1',
						'pants_2',
						'bproof_1',
						'bproof_2',
						'shoes_1',
						'shoes_2',
						'chain_1',
						'chain_2',
						'bags_1',
						'bags_2',
						'helmet_1',
						'helmet_2',
						'glasses_1',
						'glasses_2',
					})
				end
			end, function(data2, menu2)
				menu2.close()
				TriggerEvent('skinchanger:loadSkin', lastskin)
				TriggerEvent("brt:restoreLoadout")
			end)	
		end, function(data, menu)
			menu.close()
		end)
end

function OpenDepositMoney(society, close, options)
	BR.UI.Menu.Open('dialog', GetCurrentResourceName(), 'deposit_money_amount_' .. society, {
		title = _U('deposit_amount')
	}, function(data, menu)
		local amount = tonumber(data.value)
		if amount == nil then
			BR.ShowNotification(_U('invalid_amount'))
		else
			menu.close()
			TriggerServerEvent('brt_society:depositMoney', society, amount)
			OpenBossMenu(society, close, options)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenDepositDirty_Money(society, close, options)
	BR.UI.Menu.Open('dialog', GetCurrentResourceName(), 'deposit_dirty_money_amount_' .. society, {
		title = _U('deposit_amount')
	}, function(data, menu)
		local amount = tonumber(data.value)
		if amount == nil then
			BR.ShowNotification("Meghdar Namotabar")
		else
			menu.close()
			TriggerServerEvent('brt_society:depositDirty_Money', society, amount)
			OpenBossMenu(society, close, options)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenManageEmployeesMenu(society)
	BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_employees_' .. society, {
		title    = _U('employee_management'),
		align    = 'top-right',
		elements = {
			{label = 'List Karmandan OnDuty', value = 'employee_list'},
			{label = 'List Karmandan OffDuty', value = 'employee_listoff'},
			{label = 'Estekhdam', value = 'recruit'}
		}
	}, function(data, menu)
		if data.current.value == 'employee_list' then
			OpenEmployeeList(society)
		end
		if data.current.value == 'employee_listoff' then
			OpenEmployeeList('off'..society)
		end
		if data.current.value == 'recruit' then
			OpenRecruitMenu(society)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenEmployeeList(society)

	BR.TriggerServerCallback('brt_society:getEmployees', function(employees)

		local elements = {
			head = {_U('employee'), _U('grade'), _U('actions')},
			rows = {}
		}

		for i=1, #employees, 1 do
			local gradeLabel = (employees[i].job.grade_label == '' and employees[i].job.label or employees[i].job.grade_label)

			table.insert(elements.rows, {
				data = employees[i],
				cols = {
					employees[i].name,
					gradeLabel,
					'({{' .. _U('promote') .. '|promote}} {{' .. _U('fire') .. '|fire}}'
				}
			})
		end

		BR.UI.Menu.Open('list', GetCurrentResourceName(), 'employee_list_' .. society, elements, function(data, menu)
			local employee = data.data

			if data.value == 'promote' then
				menu.close()
				OpenPromoteMenu(society, employee)
			elseif data.value == 'fire' then
				BR.ShowNotification(_U('you_have_fired', employee.name))

				BR.TriggerServerCallback('brt_society:setJob', function()
					OpenEmployeeList(society)
				end, employee.identifier, 'nojob', 0, 'fire')
			end
		end, function(data, menu)
			menu.close()
			OpenManageEmployeesMenu(society)
		end)

	end, society)

end

function OpenRecruitMenu(society)

	BR.TriggerServerCallback('brt_society:getOnlinePlayers', function(players)

		local elements = {}

		for i=1, #players, 1 do
			if players[i].job.name ~= society then
				table.insert(elements, {
					label = players[i].name,
					value = players[i].source,
					name = players[i].name,
					identifier = players[i].identifier
				})
			end
		end

		BR.UI.Menu.Open('default', GetCurrentResourceName(), 'recruit_' .. society, {
			title    = _U('recruiting'),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)

			BR.UI.Menu.Open('default', GetCurrentResourceName(), 'recruit_confirm_' .. society, {
				title    = _U('do_you_want_to_recruit', data.current.name),
				align    = 'top-right',
				elements = {
					{label = _U('no'),  value = 'no'},
					{label = _U('yes'), value = 'yes'}
				}
			}, function(data2, menu2)
				menu2.close()

				if data2.current.value == 'yes' then
					BR.TriggerServerCallback('brt_society:setJob', function()
						OpenRecruitMenu(society)
					end, data.current.identifier, society, 1, 'hire')
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

RegisterNetEvent('brt_society:inv')
AddEventHandler('brt_society:inv', function(job)
	BR.UI.Menu.CloseAll()
	BR.UI.Menu.Open('question', GetCurrentResourceName(), 'Aks_For_Join', {
		title 	 = 'Invite Az Taraf Job',
		align    = 'center',
		question = 'Aya Shoma Mikhahid Vared Shoghl ('.. job ..') Beshid?',
		elements = {
			{label = 'Bale', value = 'yes'},
			{label = 'Kheir', value = 'no'},
		}
	}, function(data, menu)
		if data.current.value == 'yes' then
			TriggerServerEvent("brt_society:acceptinv")
			BR.UI.Menu.CloseAll()		
		elseif data.current.value == 'no' then
			menu.close()
            BR.UI.Menu.CloseAll()													
		end
	end)
end)

function OpenPromoteMenu(society, employee)

	BR.TriggerServerCallback('brt_society:getJob', function(job)

		local elements = {}

		for i=1, #job.grades, 1 do
			local gradeLabel = (job.grades[i].label == '' and job.label or job.grades[i].label)

			table.insert(elements, {
				label = gradeLabel,
				value = job.grades[i].grade,
				selected = (employee.job.grade == job.grades[i].grade)
			})
		end

		BR.UI.Menu.Open('default', GetCurrentResourceName(), 'promote_employee_' .. society, {
			title    = _U('promote_employee', employee.name),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			menu.close()
			BR.ShowNotification(_U('you_have_promoted', employee.name, data.current.label))

			BR.TriggerServerCallback('brt_society:setJob', function()
				OpenEmployeeList(society)
			end, employee.identifier, society, data.current.value, 'promote')
		end, function(data, menu)
			menu.close()
			OpenEmployeeList(society)
		end)

	end, society)

end

function OpenManageGradesMenu(society)

	BR.TriggerServerCallback('brt_society:getJob', function(job)

		local elements = {}

		for i=1, #job.grades, 1 do
			local gradeLabel = (job.grades[i].label == '' and job.label or job.grades[i].label)

			table.insert(elements, {
				label = ('%s - <span style="color:green;">%s</span>'):format(gradeLabel, _U('money_generic', BR.Math.GroupDigits(job.grades[i].salary))),
				value = job.grades[i].grade
			})
		end

		BR.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades_' .. society, {
			title    = _U('salary_management'),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)

			BR.UI.Menu.Open('dialog', GetCurrentResourceName(), 'manage_grades_amount_' .. society, {
				title = _U('salary_amount')
			}, function(data2, menu2)

				local amount = tonumber(data2.value)

				if amount == nil then
					BR.ShowNotification(_U('invalid_amount'))
				elseif amount > Config.MaxSalary then
					BR.ShowNotification(_U('invalid_amount_max'))
				else
					menu2.close()

					BR.TriggerServerCallback('brt_society:setJobSalary', function()
						OpenManageGradesMenu(society)
					end, society, data.current.value, amount)
				end

			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)

	end, society)

end

AddEventHandler('brt_society:openBossMenu', function(society, close, options)
	OpenBossMenu(society, close, options)
end)


function DoesHaveArmory(job)
    local access = false
	if Config.Armory[job] then
		access = true
	end
    return access
end

function DoesHaveGarage(job)
	local access = false
		if Config.Garage[job] then
			access = true
		end
    return access
end

function DoesHaveInventory(job)
	local access = false
	for i,v in ipairs(Config.Inventory) do
		if v == job then
			access = true
			break
		end
	end
	return access
end

function GetModelLabel(name)
	local label = string.upper(string.gsub(name, 'WEAPON_', ''))
	label = string.gsub(label, '_', ' ')
	return label
end