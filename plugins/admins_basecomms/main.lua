AddEventHandler("OnPluginStart", function(event)
	db = Database(config:Fetch("admins.connection_name"))
	if not db:IsConnected() then return end

	db:Query("CREATE TABLE `" ..
		config:Fetch("admins.tablenames.comms") ..
		"` (`id` INT NOT NULL AUTO_INCREMENT , `player_name` TEXT NOT NULL , `player_steamid` TEXT NOT NULL , `type` INT NOT NULL , `expiretime` INT NOT NULL , `length` INT NOT NULL , `reason` TEXT NOT NULL , `admin_name` TEXT NOT NULL , `admin_steamid` TEXT NOT NULL , `date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP , `serverid` INT NOT NULL, PRIMARY KEY (`id`)) ENGINE = InnoDB;")

	GenerateMenu()
	return EventResult.Continue
end)

AddEventHandler("OnPlayerConnectFull", function(event)
	local playerid = event:GetInt("userid")
	local player = GetPlayer(playerid)
	if not player then return end
	if player:IsFakeClient() then return end

	db:Query(
		"select * from " ..
		config:Fetch("admins.tablenames.comms") ..
		" where (player_steamid = '" ..
		tostring(player:GetSteamID()) ..
		"') and serverid = " ..
		config:Fetch("admins.serverid") ..
		" and (expiretime = 0 OR expiretime - UNIX_TIMESTAMP() > 0) order by id limit 1",
		function(err, result)
			if #err > 0 then return print("ERROR: " .. err) end

			if #result > 0 then
				for i = 1, #result do
					local commsRow = result[i]
					if (commsRow.type == CommsType.Mute and commsRow.player_steamid == tostring(player:GetSteamID())) then
						player:SetVoiceFlags(VoiceFlagValue.Speak_Muted)
						player:SetVar("player_muted", true)
						player:SetVar("player_mute_duration", commsRow.expiretime)
					end
					if (commsRow.type == CommsType.Gag and commsRow.player_steamid == tostring(player:GetSteamID())) then
						player:SetVar("player_gagged", true)
						player:SetVar("player_gag_duration", commsRow.expiretime)
					end
				end
			end
		end)
end)

AddEventHandler("OnAllPluginsLoaded", function(event)
	if GetPluginState("admins") == PluginState_t.Started then
		exports["admins"]:RegisterMenuCategory("admins.adminmenu.comms.title", "admin_comms", "j")
	end

	return EventResult.Continue
end)

AddEventHandler("OnClientChat", function(event, playerid, text, teamonly)
	local player = GetPlayer(playerid)
	if not player then return end

	if teamonly and text:sub(1, 1) == "@" then
		local sendText = text:sub(2)
		if not exports["admins"]:HasFlags(playerid, "j") then
			player:SendMsg(MessageType.Chat,
				FetchTranslation("admins.chat.to_admins"):gsub("{NAME}", player:CBasePlayerController().PlayerName):gsub(
					"{TEXT}", sendText))
		end

		local tosendmsg = FetchTranslation("admins.chat.admin_chat"):gsub("{NAME}",
			player:CBasePlayerController().PlayerName):gsub("{TEXT}", sendText)
		SendToAdmins("j", tosendmsg)

		event:SetReturn(false)
		return EventResult.Continue
	end

	if player:GetVar("player_gagged") then
		local duration = player:GetVar("player_gag_duration") - math.floor(GetTime() / 1000)
		if duration > 0 then
			ReplyToCommand(playerid, config:Fetch("admins.prefix"),
				FetchTranslation("admins.gag.try"):gsub("{TIME}", ComputePrettyTime(duration)))
			event:SetReturn(false)
			return EventResult.Stop
		end
	end

	event:SetReturn(true)
	return EventResult.Continue
end)

SetTimer(10000, function()
	for i = 1, playermanager:GetPlayerCap() do
		local playerid = i - 1
		local player = GetPlayer(playerid)
		if player then
			if not player:IsFakeClient() then
				-- [[ Gag Check ]]
				if player:GetVar("player_gagged") then
					if player:GetVar("player_gag_duration") ~= 0 then
						local duration = player:GetVar("player_gag_duration") - math.floor(GetTime() / 1000)
						if duration <= 0 then
							PerformCommUnban(player:GetSteamID(), CommsType.Gag)
							ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.gag.expire"))
						end
					end
				end
				-- [[ Mute Check ]]
				if player:GetVar("player_muted") then
					if player:GetVar("player_mute_duration") ~= 0 then
						local duration = player:GetVar("player_mute_duration") - math.floor(GetTime() / 1000)
						if duration <= 0 then
							PerformCommUnban(player:GetSteamID(), CommsType.Mute)
							player:SetVoiceFlags(VoiceFlagValue.Speak_Normal)
							ReplyToCommand(playerid, config:Fetch("admins.prefix"),
								FetchTranslation("admins.mute.expire"))
						end
					end
				end
			end
		end
	end
end)
