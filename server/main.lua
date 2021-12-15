BR = nil
local Jobs = {}
local RegisteredSocieties = {}

TriggerEvent('brt:getSharedObject', function(obj) BR = obj end)

function GetSociety(name)
	for i=1, #RegisteredSocieties, 1 do
		if RegisteredSocieties[i].name == name then
			return RegisteredSocieties[i]
		end
	end
end

MySQL.ready(function()
	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result, 1 do
		Jobs[result[i].name]        = result[i]
		Jobs[result[i].name].grades = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM job_grades', {})

	for i=1, #result2, 1 do
		Jobs[result2[i].job_name].grades[tostring(result2[i].grade)] = result2[i]
	end	
end)
 
AddEventHandler('brt_society:registerSociety', function(name, label, account, datastore, inventory, data)
	local found = false

	local society = {
		name      = name,
		label     = label,
		account   = account,
		datastore = datastore,
		inventory = inventory,
		data      = data,
	}

	for i=1, #RegisteredSocieties, 1 do
		if RegisteredSocieties[i].name == name then
			found = true
			RegisteredSocieties[i] = society
			break
		end
	end

	if not found then
		table.insert(RegisteredSocieties, society)
	end
end)

AddEventHandler('brt_society:getSocieties', function(cb)
	cb(RegisteredSocieties)
end)

AddEventHandler('brt_society:getSociety', function(name, cb)
	cb(GetSociety(name))
end)

RegisterServerEvent('brt_society:withdrawMoney')
AddEventHandler('brt_society:withdrawMoney', function(society, amount)
	local xPlayer = BR.GetPlayerFromId(source)
	local society = GetSociety(society)
	amount = BR.Math.Round(tonumber(amount))

	if xPlayer.job.name ~= society.name then
		return
	end

	TriggerEvent('brt_addonaccount:getSharedAccount', society.account, function(account)
		if amount > 0 and account.money >= amount then
			account.removeMoney(amount)
			xPlayer.addMoney(amount)

			local bardashtanArray = {
				{
					["color"] = "5020550",
					["title"] = "> Bardasht Bodje",
					["description"] = "Esm Player: **"..xPlayer.name.."**",
					["fields"] = {
						{
							["name"] = "Meghdar: ",
							["value"] = amount.."$"
						}
					},
					["footer"] = {
					["text"] = "BR Log System",
					["icon_url"] = "https://cdn.discordapp.com/attachments/801538325600403466/802826232797331456/discordicon.png",
					}
				}
			}
			TriggerEvent('brt_bot:SendLog', society.name, SystemName, bardashtanArray,'system', source, false, false)

			TriggerClientEvent('brt:showNotification', xPlayer.source, _U('have_withdrawn', BR.Math.GroupDigits(amount)))
		else
			TriggerClientEvent('brt:showNotification', xPlayer.source, _U('invalid_amount'))
		end
	end)
end)

RegisterServerEvent('brt_society:withdrawDirty_Money')
AddEventHandler('brt_society:withdrawDirty_Money', function(society, amount)
	local xPlayer = BR.GetPlayerFromId(source)
	local society = GetSociety(society)
	amount = BR.Math.Round(tonumber(amount))

	if xPlayer.job.name ~= society.name then
		print(('brt_society: %s attempted to call withdrawMoney!'):format(xPlayer.identifier))
		return
	end

	TriggerEvent('brt_addonaccount:getSharedAccount', society.account, function(account)
		if amount > 0 and account.dirty_money >= amount then
			account.removeDirty_Money(amount)
			xPlayer.addDirty_Money(amount)

			local bardashtanArray = {
				{
					["color"] = "5020550",
					["title"] = "> Bardasht Pool Kasif",
					["description"] = "Esm Player: **"..xPlayer.name.."**",
					["fields"] = {
						{
							["name"] = "Meghdar: ",
							["value"] = amount.."$"
						}
					},
					["footer"] = {
					["text"] = "BR Log System",
					["icon_url"] = "https://cdn.discordapp.com/attachments/801538325600403466/802826232797331456/discordicon.png",
					}
				}
			}
			TriggerEvent('brt_bot:SendLog', society.name, SystemName, bardashtanArray,'system', source, false, false)

			TriggerClientEvent('brt:showNotification', xPlayer.source, "Shoma "..BR.Math.GroupDigits(amount).." Pool Kasif Bardashtid")
		else
			TriggerClientEvent('brt:showNotification', xPlayer.source, _U('invalid_amount'))
		end
	end)
end)

RegisterServerEvent('brt_society:depositMoney')
AddEventHandler('brt_society:depositMoney', function(society, amount)
	local xPlayer = BR.GetPlayerFromId(source)
	local society = GetSociety(society)
	amount = BR.Math.Round(tonumber(amount))

	if xPlayer.job.name ~= society.name then
		print(('brt_society: %s attempted to call depositMoney!'):format(xPlayer.identifier))
		return
	end

	if amount > 0 and xPlayer.money >= amount then
		TriggerEvent('brt_addonaccount:getSharedAccount', society.account, function(account)
			xPlayer.removeMoney(amount)
			account.addMoney(amount)
		end)

		local gozashtanArray = {
			{
				["color"] = "5020550",
				["title"] = "> Gozashtan Bodje",
				["description"] = "Esm Player: **"..xPlayer.name.."**",
				["fields"] = {
					{
						["name"] = "Meghdar: ",
						["value"] = amount.."$"
					}
				},
				["footer"] = {
				["text"] = "BR Log System",
				["icon_url"] = "https://cdn.discordapp.com/attachments/801538325600403466/802826232797331456/discordicon.png",
				}
			}
		}
		TriggerEvent('brt_bot:SendLog', society.name, SystemName, gozashtanArray,'system', source, false, false)

		TriggerClientEvent('brt:showNotification', xPlayer.source, _U('have_deposited', BR.Math.GroupDigits(amount)))
	else
		TriggerClientEvent('brt:showNotification', xPlayer.source, _U('invalid_amount'))
	end
end)

RegisterServerEvent('brt_society:depositDirty_Money')
AddEventHandler('brt_society:depositDirty_Money', function(society, amount)
	local xPlayer = BR.GetPlayerFromId(source)
	local society = GetSociety(society)
	amount = BR.Math.Round(tonumber(amount))

	if xPlayer.job.name ~= society.name then
		print(('brt_society: %s attempted to call depositMoney!'):format(xPlayer.identifier))
		return
	end

	if amount > 0 and xPlayer.dirty_money >= amount then
		TriggerEvent('brt_addonaccount:getSharedAccount', society.account, function(account)
			xPlayer.removeDirty_Money(amount)
			account.addDirty_Money(amount)
		end)

		local gozashtanArray = {
			{
				["color"] = "5020550",
				["title"] = "> Gozashtan Pool Kasif",
				["description"] = "Esm Player: **"..xPlayer.name.."**",
				["fields"] = {
					{
						["name"] = "Meghdar: ",
						["value"] = amount.."$"
					}
				},
				["footer"] = {
				["text"] = "BR Log System",
				["icon_url"] = "https://cdn.discordapp.com/attachments/801538325600403466/802826232797331456/discordicon.png",
				}
			}
		}
		TriggerEvent('brt_bot:SendLog', society.name, SystemName, gozashtanArray,'system', source, false, false)

		TriggerClientEvent('brt:showNotification', xPlayer.source, "Shoma "..BR.Math.GroupDigits(amount).." Pool Kasif Gozashtid")
	else
		TriggerClientEvent('brt:showNotification', xPlayer.source, _U('invalid_amount'))
	end
end)

BR.RegisterServerCallback('brt_society:getSocietyMoney', function(source, cb, societyName)
	local society = GetSociety(societyName)

	if society then
		TriggerEvent('brt_addonaccount:getSharedAccount', society.account, function(account)
			cb(account.money, account.dirty_money)
		end)
	else
		cb(0, 0)
	end
end)


BR.RegisterServerCallback('brt_society:getEmployees', function(source, cb, society)
	MySQL.Async.fetchAll('SELECT playerName, identifier, job, job_grade FROM users WHERE job = @job ORDER BY job_grade DESC', {
		['@job'] = society
	}, function (results)
		local employees = {}
		for i=1, #results, 1 do
			if results[i].job_grade < 0 then
				results[i].job_grade = results[i].job_grade * -1
			end
			table.insert(employees, {
				name       = string.gsub(results[i].playerName, "_", " " ),
				identifier = results[i].identifier,
				job = {
					name        = results[i].job,
					label       = Jobs[results[i].job].label,
					grade       = results[i].job_grade,
					grade_name  = Jobs[results[i].job].grades[tostring(results[i].job_grade)].name,
					grade_label = Jobs[results[i].job].grades[tostring(results[i].job_grade)].label
				}
			})
		end
		cb(employees)
	end)
end)


BR.RegisterServerCallback('brt_society:getJob', function(source, cb, society)
	local job    = json.decode(json.encode(Jobs[society]))
	local grades = {}

	for k,v in pairs(job.grades) do
		table.insert(grades, v)
	end

	table.sort(grades, function(a, b)
		return a.grade < b.grade
	end)

	job.grades = grades

	cb(job)
end)


BR.RegisterServerCallback('brt_society:setJob', function(source, cb, identifier, job, grade, type)
	local xPlayer = BR.GetPlayerFromId(source)
	local isBoss = xPlayer.job.grade_name == 'boss'

	if isBoss then
		local xTarget = BR.GetPlayerFromIdentifier(identifier)

		if xTarget then
			if type == 'hire' then
				xTarget.set('jobinv', job)
				TriggerClientEvent('brt_society:inv', xTarget.source, job)
			elseif type == 'promote' then
				xTarget.setJob(job, grade)
				TriggerClientEvent('brt:ShowNotification', xTarget.source, _U('you_have_been_promoted'))
				local Array = {
					{
						["color"] = "5020550",
						["title"] = "> Rank Up/Down",
						["description"] = "Player Source: **"..xPlayer.name.."**",
						["fields"] = {
							{
								["name"] = "Be Rank:",
								["value"] = grade
							},
							{
								["name"] = "Player Target: ",
								["value"] = xTarget.name
							}
						},
						["footer"] = {
						["text"] = "BR Log System",
						["icon_url"] = "https://cdn.discordapp.com/attachments/801538325600403466/802826232797331456/discordicon.png",
						}
					}
				}
				TriggerEvent('brt_bot:SendLog', job, SystemName, Array,'system', source, false, false)
			elseif type == 'fire' then
				xTarget.setJob(job, grade)
				TriggerClientEvent('brt:ShowNotification', xTarget.source, _U('you_have_been_fired', xTarget.job.label))
				local Array = {
					{
						["color"] = "5020550",
						["title"] = "> Ekhraj Jadid",
						["description"] = "Player Source: **"..xPlayer.name.."**",
						["fields"] = {
							{
								["name"] = "Player Target: ",
								["value"] = xTarget.name
							}
						},
						["footer"] = {
						["text"] = "BR Log System",
						["icon_url"] = "https://cdn.discordapp.com/attachments/801538325600403466/802826232797331456/discordicon.png",
						}
					}
				}
				TriggerEvent('brt_bot:SendLog', job, SystemName, Array,'system', source, false, false)
			end

			cb()
		else
			MySQL.Async.execute('UPDATE users SET job = @job, job_grade = @job_grade WHERE identifier = @identifier', {
				['@job']        = job,
				['@job_grade']  = grade,
				['@identifier'] = identifier
			}, function(rowsChanged)
				cb()
			end)
		end
	else
		cb()
	end
end)

RegisterServerEvent('brt_society:acceptinv')
AddEventHandler('brt_society:acceptinv', function()
	local _source = source
	local xPlayer = BR.GetPlayerFromId(_source)
	xPlayer.setJob(xPlayer.get('jobinv'), 1)

	local Array = {
		{
			["color"] = "5020550",
			["title"] = "> Estekhdam Jadid",
			["description"] = "Player: **"..xPlayer.name.."**",
			["footer"] = {
			["text"] = "BR Log System",
			["icon_url"] = "https://cdn.discordapp.com/attachments/801538325600403466/802826232797331456/discordicon.png",
			}
		}
	}
	TriggerEvent('brt_bot:SendLog', xPlayer.get('jobinv'), SystemName, Array,'system', source, false, false)
end)

BR.RegisterServerCallback('brt_society:setJobSalary', function(source, cb, job, grade, salary)
	local isBoss = isPlayerBoss(source, job)
	local identifier = GetPlayerIdentifier(source, 0)

	if isBoss then
		if salary <= Config.MaxSalary then
			MySQL.Async.execute('UPDATE job_grades SET salary = @salary WHERE job_name = @job_name AND grade = @grade', {
				['@salary']   = salary,
				['@job_name'] = job,
				['@grade']    = grade
			}, function(rowsChanged)
				Jobs[job].grades[tostring(grade)].salary = salary
				local xPlayers = BR.GetPlayers()

				for i=1, #xPlayers, 1 do
					local xPlayer = BR.GetPlayerFromId(xPlayers[i])

					if xPlayer.job.name == job and xPlayer.job.grade == grade then
						xPlayer.setJob(job, grade)
					end
				end

				local Array = {
					{
						["color"] = "5020550",
						["title"] = "> Taghir Salary",
						["description"] = "Player: **"..xPlayer.name.."**",
						["fields"] = {
							{
								["name"] = "Rank:",
								["value"] = grade
							},
							{
								["name"] = "Salary Jadid: ",
								["value"] = salary.."$"
							}
						},
						["footer"] = {
						["text"] = "BR Log System",
						["icon_url"] = "https://cdn.discordapp.com/attachments/801538325600403466/802826232797331456/discordicon.png",
						}
					}
				}
				TriggerEvent('brt_bot:SendLog', job, SystemName, Array,'system', source, false, false)

				cb()
			end)
		else
			print(('brt_society: %s attempted to setJobSalary over config limit!'):format(identifier))
			cb()
		end
	else
		print(('brt_society: %s attempted to setJobSalary'):format(identifier))
		cb()
	end
end)

BR.RegisterServerCallback('brt_society:getOnlinePlayers', function(source, cb)
	local xPlayers = BR.GetPlayers()
	local players  = {}

	for i=1, #xPlayers, 1 do
		local xPlayer = BR.GetPlayerFromId(xPlayers[i])
		table.insert(players, {
			source     = xPlayer.source,
			identifier = xPlayer.identifier,
			name       = xPlayer.name,
			job        = xPlayer.job
		})
	end

	cb(players)
end)

BR.RegisterServerCallback('brt_society:isBoss', function(source, cb, job)
	cb(isPlayerBoss(source, job))
end)


function isPlayerBoss(playerId, job)
	local xPlayer = BR.GetPlayerFromId(playerId)

	if xPlayer.job.name == job and xPlayer.job.grade_name == 'boss' then
		return true
	else
		return false
	end
end

BR.RegisterServerCallback('brt_society:getGrades', function(source, cb, plate)
	local xPlayer = BR.GetPlayerFromId(source)
	cb(BR.GetJob(xPlayer.job.name).grades)
end)

RegisterServerEvent('brt_society:renameGrade')
AddEventHandler('brt_society:renameGrade', function(grade, name)
	local _source = source
	local xPlayer = BR.GetPlayerFromId(_source)
	if xPlayer.job.name == "nojob" then
		return
	end
	if xPlayer.job.grade_name == 'boss' then
		if BR.SetJobGrade(xPlayer.job.name, grade, name) then
			TriggerClientEvent('brt:showNotification', _source, 'Esm Rank Be '..name..' Ba ~g~Movafaghiyat ~s~Taghir Kard')
			local xPlayers = BR.GetPlayers()
			for i=1, #xPlayers, 1 do
				local Member = BR.GetPlayerFromId(xPlayers[i])
				if Member.job.name == xPlayer.job.name and Member.job.grade == grade then
					Member.setJob(xPlayer.job.name, grade)
				end
			end

			local Array = {
				{
					["color"] = "5020550",
					["title"] = "> Taghir Esm Rank",
					["description"] = "Player: **"..xPlayer.name.."**",
					["fields"] = {
						{
							["name"] = "Rank:",
							["value"] = grade
						},
						{
							["name"] = "Esm Jadid: ",
							["value"] = name
						}
					},
					["footer"] = {
					["text"] = "BR Log System",
					["icon_url"] = "https://cdn.discordapp.com/attachments/801538325600403466/802826232797331456/discordicon.png",
					}
				}
			}
			TriggerEvent('brt_bot:SendLog', xPlayer.job.name, SystemName, Array,'system', source, false, false)
		else
			TriggerClientEvent('chatMessage', _source, "[SYSTEM]", {255, 0, 0}, " ^0Khatayi Dar Avaz Kardan Esm Job Grade Shoma Pish Amade")
		end
	end
end)

BR.RegisterServerCallback('brt_society:getUniforms', function(source, cb, rank, job)
	local xPlayer = BR.GetPlayerFromId(source)
	exports.ghmattimysql:scalar('SELECT skin FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(skin)
		local jobSkin = {
			skin_male   = json.decode(Jobs[job].grades[tostring(rank)].skin_male),
			skin_female = json.decode(Jobs[job].grades[tostring(rank)].skin_female)
		}

		if skin ~= nil then
			skin = json.decode(skin)
		end

		if jobSkin.skin_male == nil or jobSkin.skin_male == '' or jobSkin.skin_female == nil or jobSkin.skin_female == '' then
			TriggerClientEvent('brt:ShowNotification', source, 'Lotfan Dar Boss Action Lebas Haye Job Ro Set Konid')
		end

		cb(skin, jobSkin)
	end)
end)

BR.RegisterServerCallback('brt_society:getDivisionUniforms', function(source, cb, division, job)
	local xPlayer = BR.GetPlayerFromId(source)
	exports.ghmattimysql:scalar('SELECT skin FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(skin)
		if division == 'swat' then
			local DSkin = {
				skin_male   = json.decode(Jobs[job].swat_male),
				skin_female = json.decode(Jobs[job].swat_female)
			}
			if skin ~= nil then
				skin = json.decode(skin)
			end
			cb(skin, DSkin)
		elseif division == 'xray' then
			local DSkin = {
				skin_male   = json.decode(Jobs[job].xray_male),
				skin_female = json.decode(Jobs[job].xray_female)
			}
			if skin ~= nil then
				skin = json.decode(skin)
			end
			cb(skin, DSkin)
		elseif division == 'rahvar' then
			local DSkin = {
				skin_male   = json.decode(Jobs[job].rahvar_male),
				skin_female = json.decode(Jobs[job].rahvar_female)
			}
			if skin ~= nil then
				skin = json.decode(skin)
			end
			cb(skin, DSkin)
		elseif division == 'k9' then
			local DSkin = {
				skin_male   = json.decode(Jobs[job].k9_male),
				skin_female = json.decode(Jobs[job].k9_female)
			}
			if skin ~= nil then
				skin = json.decode(skin)
			end
			cb(skin, DSkin)
		elseif division == 'detective' then
			local DSkin = {
				skin_male   = json.decode(Jobs[job].detective_male),
				skin_female = json.decode(Jobs[job].detective_female)
			}
			if skin ~= nil then
				skin = json.decode(skin)
			end
			cb(skin, DSkin)
		elseif division == 'daryayi' then
			local DSkin = {
				skin_male   = json.decode(Jobs[job].daryayi_male),
				skin_female = json.decode(Jobs[job].daryayi_female)
			}
			if skin ~= nil then
				skin = json.decode(skin)
			end
			cb(skin, DSkin)
		end
	end)
end)


BR.RegisterServerCallback('brt_society:getWeapons', function(source, cb, rank, job)
	local weapon = Jobs[job].grades[tostring(rank)].weapons
	if weapon == nil or weapon == '' then
		cb(nil)
	else
		cb(json.decode(weapon))
	end
end)

BR.RegisterServerCallback('brt_society:getVehicles', function(source, cb, rank, job)
	local xPlayer = BR.GetPlayerFromId(source)
	local veh = Jobs[job].grades[tostring(rank)].vehicles
	if veh == nil or veh == '' then
		cb(nil)
	else
		cb(json.decode(veh))
	end
end)

BR.RegisterServerCallback('brt_society:getItems', function(source, cb, rank, job)
	local xPlayer = BR.GetPlayerFromId(source)
	local item = Jobs[job].grades[tostring(rank)].items
	if item == nil or item == '' then
		cb(nil)
	else
		cb(json.decode(item))
	end
end)

BR.RegisterServerCallback('brt_society:getJobItems', function(source, cb, job)
	TriggerEvent('brt_addoninventory:getSharedInventory', 'society_'..job, function(inventory)
		cb(inventory.items)
	end)
end)

BR.RegisterServerCallback('brt_society:getJobSkinOnBoss', function(source, cb, job, rank)
	local jobSkin = {
		skin_male   = json.decode(Jobs[job].grades[tostring(rank)].skin_male),
		skin_female = json.decode(Jobs[job].grades[tostring(rank)].skin_female)
	}
	cb(jobSkin)
end)

BR.RegisterServerCallback('brt_society:getDivisionSkinOnBoss', function(source, cb, job, division)
	if division == 'swat' then
		local Skin = {
			skin_male   = json.decode(Jobs[job].swat_male),
			skin_female = json.decode(Jobs[job].swat_female)
		}
		cb(Skin)
	elseif division == 'xray' then
		local Skin = {
			skin_male   = json.decode(Jobs[job].xray_male),
			skin_female = json.decode(Jobs[job].xray_female)
		}
		cb(Skin)
	elseif division == 'rahvar' then
		local Skin = {
			skin_male   = json.decode(Jobs[job].rahvar_male),
			skin_female = json.decode(Jobs[job].rahvar_female)
		}
		cb(Skin)
	elseif division == 'k9' then
		local Skin = {
			skin_male   = json.decode(Jobs[job].k9_male),
			skin_female = json.decode(Jobs[job].k9_female)
		}
		cb(Skin)
	elseif division == 'detective' then
		local Skin = {
			skin_male   = json.decode(Jobs[job].detective_male),
			skin_female = json.decode(Jobs[job].detective_female)
		}
		cb(Skin)
	elseif division == 'daryayi' then
		local Skin = {
			skin_male   = json.decode(Jobs[job].daryayi_male),
			skin_female = json.decode(Jobs[job].daryayi_female)
		}
		cb(Skin)
	end
end)

BR.RegisterServerCallback('brt_society:setSocietyItemPerm', function(source, cb, job, rank, items, status, choice)
	local isBoss = isPlayerBoss(source, job)
	local itemtable = {}
	if isBoss then
		for _, item in ipairs(items) do
			if item.name ~= choice then
				table.insert(itemtable, {
					name = item.name,
					status = item.value
				})
			else
				table.insert(itemtable, {
					name = item.name,
					status = status
				})
			end
		end
		Jobs[job].grades[tostring(rank)].items = json.encode(itemtable)
		MySQL.Async.execute('UPDATE job_grades SET items = @items WHERE job_name = @job_name AND grade = @grade', {
			['@items']   = json.encode(itemtable),
			['@job_name'] = job,
			['@grade']    = rank
		}, function(rowsChanged)
			cb(true)
		end)
	else
		cb()
	end
end)

BR.RegisterServerCallback('brt_society:setSocietyWeapPerm', function(source, cb, job, rank, weapons, status, choice)
	local isBoss = isPlayerBoss(source, job)
	local weapontable = {}
	if isBoss then
		for _, weapon in ipairs(weapons) do
			if weapon.model ~= choice then
				table.insert(weapontable, {
					model = weapon.model,
					status = weapon.value
				})
			else
				if status then
					table.insert(weapontable, {
						model = weapon.model,
						status = true
					})
				else
					table.insert(weapontable, {
						model = weapon.model,
						status = false
					})
				end
			end
		end
		Jobs[job].grades[tostring(rank)].weapons = json.encode(weapontable)
		MySQL.Async.execute('UPDATE job_grades SET weapons = @weapons WHERE job_name = @job_name AND grade = @grade', {
			['@weapons']   = json.encode(weapontable),
			['@job_name'] = job,
			['@grade']    = rank
		}, function(rowsChanged)
			cb(true)
		end)
	else
		cb()
	end
end)

BR.RegisterServerCallback('brt_society:setSocietyVehPerm', function(source, cb, job, rank, vehs, status, choice)
	local isBoss = isPlayerBoss(source, job)
	local vehtable = {}
	if isBoss then
		for _, veh in ipairs(vehs) do
			if veh.model ~= choice then
				table.insert(vehtable, {
					name = veh.name,
					model = veh.model,
					status = veh.value
				})
			else
				if status then
					table.insert(vehtable, {
						name = veh.name,
						model = veh.model,
						status = true
					})
				else
					table.insert(vehtable, {
						name = veh.name,
						model = veh.model,
						status = false
					})
				end
			end
		end
		Jobs[job].grades[tostring(rank)].vehicles = json.encode(vehtable)
		MySQL.Async.execute('UPDATE job_grades SET vehicles = @vehicles WHERE job_name = @job_name AND grade = @grade', {
			['@vehicles']   = json.encode(vehtable),
			['@job_name'] = job,
			['@grade']    = rank
		}, function(rowsChanged)
			cb(true)
		end)
	else
		cb()
	end
end)

RegisterServerEvent('brt_society:setUniform')
AddEventHandler('brt_society:setUniform', function(job, rank, model)
	local _source = source
	local isBoss = isPlayerBoss(_source, job)
	if isBoss then
		if model.sex == 0 then
			MySQL.Async.execute('UPDATE job_grades SET skin_male = @skin_male WHERE job_name = @job_name AND grade = @grade', {
				['@skin_male']   = json.encode(model),
				['@job_name'] = job,
				['@grade']    = rank
			}, function(rowsChanged)
				Jobs[job].grades[tostring(rank)].skin_male = json.encode(model)
			end)
		else
			MySQL.Async.execute('UPDATE job_grades SET skin_female = @skin_female WHERE job_name = @job_name AND grade = @grade', {
				['@skin_female']   = json.encode(model),
				['@job_name'] = job,
				['@grade']    = rank
			}, function(rowsChanged)
				Jobs[job].grades[tostring(rank)].skin_female = json.encode(model)
			end)
		end
	end
end)

RegisterServerEvent('brt_society:setDivisionUniform')
AddEventHandler('brt_society:setDivisionUniform', function(job, division, model)
	local _source = source
	local isBoss = isPlayerBoss(_source, job)
	if isBoss then
		if division == 'swat' then
			if model.sex == 0 then
				MySQL.Async.execute('UPDATE jobs SET swat_male = @skin_male WHERE name = @job_name', {
					['@skin_male']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].swat_male = json.encode(model)
				end)
			else
				MySQL.Async.execute('UPDATE jobs SET swat_female = @skin_female WHERE name = @job_name', {
					['@skin_female']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].swat_female = json.encode(model)
				end)
			end
		elseif division == 'xray' then
			if model.sex == 0 then
				MySQL.Async.execute('UPDATE jobs SET xray_male = @skin_male WHERE name = @job_name', {
					['@skin_male']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].xray_male = json.encode(model)
				end)
			else
				MySQL.Async.execute('UPDATE jobs SET xray_female = @skin_female WHERE name = @job_name', {
					['@skin_female']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].xray_female = json.encode(model)
				end)
			end
		elseif division == 'rahvar' then
			if model.sex == 0 then
				MySQL.Async.execute('UPDATE jobs SET rahvar_male = @skin_male WHERE name = @job_name', {
					['@skin_male']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].rahvar_male = json.encode(model)
				end)
			else
				MySQL.Async.execute('UPDATE jobs SET rahvar_female = @skin_female WHERE name = @job_name', {
					['@skin_female']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].rahvar_female = json.encode(model)
				end)
			end
		elseif division == 'k9' then
			if model.sex == 0 then
				MySQL.Async.execute('UPDATE jobs SET k9_male = @skin_male WHERE name = @job_name', {
					['@skin_male']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].k9_male = json.encode(model)
				end)
			else
				MySQL.Async.execute('UPDATE jobs SET k9_female = @skin_female WHERE name = @job_name', {
					['@skin_female']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].k9_female = json.encode(model)
				end)
			end
		elseif division == 'detective' then
			if model.sex == 0 then
				MySQL.Async.execute('UPDATE jobs SET detective_male = @skin_male WHERE name = @job_name', {
					['@skin_male']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].detective_male = json.encode(model)
				end)
			else
				MySQL.Async.execute('UPDATE jobs SET detective_female = @skin_female WHERE name = @job_name', {
					['@skin_female']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].detective_female = json.encode(model)
				end)
			end
		elseif division == 'daryayi' then
			if model.sex == 0 then
				MySQL.Async.execute('UPDATE jobs SET daryayi_male = @skin_male WHERE name = @job_name', {
					['@skin_male']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].daryayi_male = json.encode(model)
				end)
			else
				MySQL.Async.execute('UPDATE jobs SET daryayi_female = @skin_female WHERE name = @job_name', {
					['@skin_female']   = json.encode(model),
					['@job_name'] = job
				}, function(rowsChanged)
					Jobs[job].daryayi_female = json.encode(model)
				end)
			end
		end
	end
end)

RegisterCommand("jinvite", function(source, args)
	local xPlayer = BR.GetPlayerFromId(source)
	local isBoss = xPlayer.job.grade_name == 'boss'

	if isBoss then
		if not args[1] then
            TriggerClientEvent('chatMessage', source, "[SYSTEM]", {255, 0, 0}, " ^0Shoma dar ghesmat ID chizi vared nakardid!")
            return
        end
		if not tonumber(args[1]) then
			TriggerClientEvent('chatMessage', source, "[SYSTEM]", {255, 0, 0}, " ^0Shoma dar ghesmat ID faghat mitavanid adad vared konid")
			return
		end
		local xTarget = BR.GetPlayerFromId(tonumber(args[1]))

		if xTarget then
			xTarget.set('jobinv', xPlayer.job.name)
			TriggerClientEvent('brt_society:inv', xTarget.source, xPlayer.job.label)
        else
            TriggerClientEvent('chatMessage', source, "[SYSTEM]", {255, 0, 0}, " ^0ID vared shode eshtebah ast")
        end
    else
        TriggerClientEvent('chatMessage', source, "[SYSTEM]", {255, 0, 0}, " ^0Shoma Boss Nistid")
    end
end, false)