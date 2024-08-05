commands:Register("mute", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.no_permission"))
        end
    end

    if argc < 3 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            string.format(FetchTranslation("admins.mute.syntax"), prefix))
    end

    local target = args[1]
    local time = args[2]
    table.remove(args, 1)
    table.remove(args, 1)
    local reason = table.concat(args, " ")

    local players = FindPlayersByTarget(target, false)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    time = tonumber(time)
    if time < 0 or time > 525600 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.invalid_time"):gsub("{MIN}", 1):gsub("{MAX}", 525600))
    end

    local admin = nil
    if playerid ~= -1 then
        admin = GetPlayer(playerid)
    end

    for i = 1, #players do
        local targetPlayer = players[i]
        if admin then
            if exports["admins"]:GetImmunity(targetPlayer:GetSlot()) > exports["admins"]:GetImmunity(playerid) then
                ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.higher.immunity"))
                goto skipnextchecks
            end
        end

        local alreadymuted = targetPlayer:GetVar("player_muted")
        if alreadymuted then
            ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.mute.already"):gsub("{PLAYER_NAME}",
                    targetPlayer:CBasePlayerController().PlayerName))
            goto skipnextchecks
        end

        PerformCommBan(tostring(targetPlayer:GetSteamID()), targetPlayer:CBasePlayerController().PlayerName,
            admin and tostring(admin:GetSteamID()) or "0",
            admin and admin:CBasePlayerController().PlayerName or "CONSOLE", time * 60, reason, CommsType.Mute)
        targetPlayer:SetVoiceFlags(VoiceFlagValue.Speak_Muted)
        local muteMessage = FetchTranslation("admins.mute.message"):gsub("{ADMIN_NAME}",
            admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}",
            targetPlayer:CBasePlayerController().PlayerName):gsub("{TIME}", ComputePrettyTime(time)):gsub("{REASON}",
            reason)
        for j = 1, playermanager:GetPlayerCap() do
            ReplyToCommand(j - 1, config:Fetch("admins.prefix"), muteMessage)
        end
        ::skipnextchecks::
    end
end)

commands:Register("unmute", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.no_permission"))
        end
    end

    if argc < 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            string.format(FetchTranslation("admins.unmute.syntax"), prefix))
    end

    local target = args[1]

    local players = FindPlayersByTarget(target, false)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local admin = nil
    if playerid ~= -1 then
        admin = GetPlayer(playerid)
    end

    for i = 1, #players do
        local targetPlayer = players[i]

        local muted = targetPlayer:GetVar("player_muted")
        if not muted then
            ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.mute.inexistent"):gsub("{PLAYER_NAME}",
                    targetPlayer:CBasePlayerController().PlayerName))
            goto skipnextchecksun
        end

        PerformCommUnban(targetPlayer:GetSteamID(), CommsType.Mute)
        targetPlayer:SetVoiceFlags(VoiceFlagValue.Speak_Normal)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.unmute.message"):gsub("{ADMIN_NAME}",
                admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}",
                targetPlayer:CBasePlayerController().PlayerName))
        ::skipnextchecksun::
    end
end)

commands:Register("gag", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.no_permission"))
        end
    end

    if argc < 3 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            string.format(FetchTranslation("admins.gag.syntax"), prefix))
    end

    local target = args[1]
    local time = args[2]
    table.remove(args, 1)
    table.remove(args, 1)
    local reason = table.concat(args, " ")

    local players = FindPlayersByTarget(target, false)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    time = tonumber(time)
    if time < 0 or time > 525600 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.invalid_time"):gsub("{MIN}", 1):gsub("{MAX}", 525600))
    end

    local admin = nil
    if playerid ~= -1 then
        admin = GetPlayer(playerid)
    end

    for i = 1, #players do
        local targetPlayer = players[i]
        if admin then
            if exports["admins"]:GetImmunity(targetPlayer:GetSlot()) > exports["admins"]:GetImmunity(playerid) then
                ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.higher.immunity"))
                goto skipnextchecks1
            end
        end
        local alreadygagged = targetPlayer:GetVar("player_gagged")
        if alreadygagged then
            ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.gag.already"):gsub("{PLAYER_NAME}",
                    targetPlayer:CBasePlayerController().PlayerName))
            goto skipnextchecks1
        end

        PerformCommBan(tostring(targetPlayer:GetSteamID()), targetPlayer:CBasePlayerController().PlayerName,
            admin and tostring(admin:GetSteamID()) or "0",
            admin and admin:CBasePlayerController().PlayerName or "CONSOLE", time * 60, reason, CommsType.Gag)
        local gagMessage = FetchTranslation("admins.gag.message"):gsub("{ADMIN_NAME}",
            admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}",
            targetPlayer:CBasePlayerController().PlayerName):gsub("{TIME}", ComputePrettyTime(time)):gsub("{REASON}",
            reason)
        for j = 1, playermanager:GetPlayerCap() do
            ReplyToCommand(j - 1, config:Fetch("admins.prefix"), gagMessage)
        end
        ::skipnextchecks1::
    end
end)

commands:Register("ungag", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.no_permission"))
        end
    end

    if argc < 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            string.format(FetchTranslation("admins.ungag.syntax"), prefix))
    end

    local target = args[1]

    local players = FindPlayersByTarget(target, false)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local admin = nil
    if playerid ~= -1 then
        admin = GetPlayer(playerid)
    end

    for i = 1, #players do
        local targetPlayer = players[i]

        local gagged = targetPlayer:GetVar("player_gagged")
        if not gagged then
            ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.gag.inexistent"):gsub("{PLAYER_NAME}",
                    targetPlayer:CBasePlayerController().PlayerName))
            goto skipnextchecksun2
        end

        PerformCommUnban(targetPlayer:GetSteamID(), CommsType.Gag)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.ungag.message"):gsub("{ADMIN_NAME}",
                admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}",
                targetPlayer:CBasePlayerController().PlayerName))
        ::skipnextchecksun2::
    end
end)

commands:Register("silence", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.no_permission"))
        end
    end

    if argc < 3 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            string.format(FetchTranslation("admins.silence.syntax"), prefix))
    end

    local target = args[1]
    local time = args[2]
    table.remove(args, 1)
    table.remove(args, 1)
    local reason = table.concat(args, " ")

    local players = FindPlayersByTarget(target, false)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    time = tonumber(time)
    if time < 0 or time > 525600 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.invalid_time"):gsub("{MIN}", 1):gsub("{MAX}", 525600))
    end

    local admin = nil
    if playerid ~= -1 then
        admin = GetPlayer(playerid)
    end

    for i = 1, #players do
        local targetPlayer = players[i]
        if admin then
            if exports["admins"]:GetImmunity(targetPlayer:GetSlot()) > exports["admins"]:GetImmunity(playerid) then
                ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.higher.immunity"))
                goto skipnextchecks2
            end
        end

        if targetPlayer:GetVar("player_gagged") or targetPlayer:GetVar("player_muted") then
            ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.silence.already"):gsub("{PLAYER_NAME}",
                    targetPlayer:CBasePlayerController().PlayerName))
            goto skipnextchecks2
        end

        PerformCommBan(tostring(targetPlayer:GetSteamID()), targetPlayer:CBasePlayerController().PlayerName,
            admin and tostring(admin:GetSteamID()) or "0",
            admin and admin:CBasePlayerController().PlayerName or "CONSOLE", time * 60, reason, CommsType.Gag)
        PerformCommBan(tostring(targetPlayer:GetSteamID()), targetPlayer:CBasePlayerController().PlayerName,
            admin and tostring(admin:GetSteamID()) or "0",
            admin and admin:CBasePlayerController().PlayerName or "CONSOLE", time * 60, reason, CommsType.Mute)
        local silenceMessage = FetchTranslation("admins.silence.message"):gsub("{ADMIN_NAME}",
            admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}",
            targetPlayer:CBasePlayerController().PlayerName):gsub("{TIME}", ComputePrettyTime(time)):gsub("{REASON}",
            reason)
        for j = 1, playermanager:GetPlayerCap() do
            ReplyToCommand(j - 1, config:Fetch("admins.prefix"), silenceMessage)
        end
        ::skipnextchecks2::
    end
end)

commands:Register("unsilence", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.no_permission"))
        end
    end

    if argc < 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            string.format(FetchTranslation("admins.unsilence.syntax"), prefix))
    end

    local target = args[1]

    local players = FindPlayersByTarget(target, false)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local admin = nil
    if playerid ~= -1 then
        admin = GetPlayer(playerid)
    end

    for i = 1, #players do
        local targetPlayer = players[i]
        if not targetPlayer:GetVar("player_gagged") or not targetPlayer:GetVar("player_muted") then
            ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.silence.inexistent"):gsub("{PLAYER_NAME}",
                    targetPlayer:CBasePlayerController().PlayerName))
            goto skipnextchecks2un
        end

        PerformCommUnban(targetPlayer:GetSteamID(), CommsType.Gag)
        PerformCommUnban(targetPlayer:GetSteamID(), CommsType.Mute)
        targetPlayer:SetVoiceFlags(VoiceFlagValue.Speak_Normal)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.unsilence.message"):gsub("{ADMIN_NAME}",
                admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}",
                targetPlayer:CBasePlayerController().PlayerName))
        ::skipnextchecks2un::
    end
end)

local AddMuteMenuSelectedPlayer = {}
local AddMuteMenuSelectedReason = {}
local AddMuteMenuSelectedTime = {}

commands:Register("addmutemenu", function(playerid, args, argc, silent, prefix)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    AddMuteMenuSelectedPlayer[playerid] = nil
    AddMuteMenuSelectedReason[playerid] = nil
    AddMuteMenuSelectedTime[playerid] = nil

    local players = {}

    for i = 0, playermanager:GetPlayerCap() - 1, 1 do
        local pl = GetPlayer(i)
        if pl then
            if not pl:IsFakeClient() then
                table.insert(players, { pl:CBasePlayerController().PlayerName, "sw_addmutemenu_selectplayer " .. i })
            end
        end
    end

    if #players == 0 then
        table.insert(players, { FetchTranslation("admins.no_players"), "" })
    end

    menus:RegisterTemporary("addmutemenuadmintempplayer_" .. playerid, FetchTranslation("admins.adminmenu.addmute"),
        config:Fetch("admins.amenucolor"), players)

    player:HideMenu()
    player:ShowMenu("addmutemenuadmintempplayer_" .. playerid)
end)

commands:Register("addmutemenu_selectplayer", function(playerid, args, argc, silent)
    if playerid == -1 then return end

    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end

    local pid = tonumber(args[1])
    if pid == nil then return end
    local pl = GetPlayer(pid)
    if not pl then return end

    AddMuteMenuSelectedPlayer[playerid] = pid

    local options = {}

    for i = 0, config:FetchArraySize("admin_comms.reasons") - 1, 1 do
        table.insert(options,
            { config:Fetch("admin_comms.reasons[" .. i .. "]"), "sw_addgagmenu_selectreason \"" ..
            config:Fetch("admin_comms.reasons[" .. i .. "]") .. "\"" })
    end

    menus:RegisterTemporary("addmutemenuadmintempplayerreason_" .. playerid,
        FetchTranslation("admins.bans.select_reason"), config:Fetch("admins.amenucolor"), options)
    player:HideMenu()
    player:ShowMenu("addmutemenuadmintempplayerreason_" .. playerid)
end)


commands:Register("addmutemenu_selectreason", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "d") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end
    if not AddMuteMenuSelectedPlayer[playerid] then return player:HideMenu() end

    local reason = args[1]
    AddMuteMenuSelectedReason[playerid] = reason

    local options = {}

    for i = 0, config:FetchArraySize("admin_comms.times") - 1, 1 do
        table.insert(options,
            { math.floor(tonumber(config:Fetch("admin_comms.times[" .. i .. "]"))) == 0 and "Forever" or
            ComputePrettyTime(tonumber(config:Fetch("admin_comms.times[" .. i .. "]"))), "sw_addmutemenu_selecttime " ..
            i })
    end

    menus:RegisterTemporary("addmutemenuadmintempplayertime_" .. playerid,
        string.format("%s - %s", FetchTranslation("admins.adminmenu.addmute"), FetchTranslation("admins.time")),
        config:Fetch("admins.amenucolor"), options)

    player:HideMenu()
    player:ShowMenu("addmutemenuadmintempplayertime_" .. playerid)
end)

commands:Register("addmutemenu_selecttime", function(playerid, args, argc, silent, prefix)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end
    if not AddMuteMenuSelectedPlayer[playerid] then return player:HideMenu() end
    if not AddMuteMenuSelectedReason[playerid] then return player:HideMenu() end

    local timeidx = tonumber(args[1])
    if not config:Exists("admin_comms.times[" .. timeidx .. "]") then return end
    AddMuteMenuSelectedTime[playerid] = timeidx

    local pid = AddMuteMenuSelectedPlayer[playerid]
    local pl = GetPlayer(pid)
    if not pl then
        player:HideMenu()
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.not_connected"))
        return
    end

    local options = {
        { FetchTranslation("admins.addmute_confirm"):gsub("{COLOR}", config:Fetch("admins.amenucolor")):gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName):gsub("{TIME}", ComputePrettyTime(tonumber(config:Fetch("admin_comms.times[" .. timeidx .. "]")))), "" },
        { FetchTranslation("admins.yes"),                                                                                                                                                                                                                               "sw_addmutemenu_confirmbox yes" },
        { FetchTranslation("admins.no"),                                                                                                                                                                                                                                "sw_addmutemenu_confirmbox no" }
    }


    menus:RegisterTemporary("addmutemenuadmintempplayerconfirm_" .. playerid,
        string.format("%s - %s", FetchTranslation("admins.adminmenu.addmute"), FetchTranslation("admins.confirm")),
        config:Fetch("admins.amenucolor"), options)

    player:HideMenu()
    player:ShowMenu("addmutemenuadmintempplayerconfirm_" .. playerid)
end)

commands:Register("addmutemenu_confirmbox", function(playerid, args, argc, silent, prefix)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end
    if not AddMuteMenuSelectedPlayer[playerid] then return player:HideMenu() end
    if not AddMuteMenuSelectedTime[playerid] then return player:HideMenu() end
    if not AddMuteMenuSelectedReason[playerid] then return player:HideMenu() end

    local response = args[1]

    if response == "yes" then
        local pid = AddMuteMenuSelectedPlayer[playerid]
        local pl = GetPlayer(pid)
        if not pl then
            AddMuteMenuSelectedPlayer[playerid] = nil
            AddMuteMenuSelectedTime[playerid] = nil
            AddMuteMenuSelectedReason[playerid] = nil
            player:HideMenu()
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.not_connected"))
            return
        end

        local alreadymuted = pl:GetVar("player_muted")
        if alreadymuted then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.mute.already"):gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName))
        end

        local muteMessage = FetchTranslation("admins.mute.message"):gsub("{ADMIN_NAME}",
            player and player:CBasePlayerController().PlayerName):gsub("{PLAYER_NAME}",
            pl:CBasePlayerController().PlayerName):gsub("{TIME}",
            ComputePrettyTime(config:Fetch("admin_comms.times[" .. AddMuteMenuSelectedTime[playerid] .. "]"))):gsub(
            "{REASON}",
            AddMuteMenuSelectedReason[playerid])

        PerformCommBan(tostring(pl:GetSteamID()), pl:CBasePlayerController().PlayerName,
            player and tostring(player:GetSteamID()) or "0",
            player and player:CBasePlayerController().PlayerName or "CONSOLE",
            config:Fetch("admin_comms.times[" .. AddMuteMenuSelectedTime[playerid] .. "]"),
            AddMuteMenuSelectedReason[playerid], CommsType.Mute)
        pl:SetVoiceFlags(VoiceFlagValue.Speak_Muted)

        for i = 1, playermanager:GetPlayerCap() do
            ReplyToCommand(i - 1, config:Fetch("admins.prefix"), muteMessage)
        end
    end
end)

local AddGagMenuSelectedPlayer = {}
local AddGagMenuSelectedReason = {}
local AddGagMenuSelectedTime = {}

commands:Register("addgagmenu", function(playerid, args, argc, silent, prefix)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    AddGagMenuSelectedPlayer[playerid] = nil
    AddGagMenuSelectedReason[playerid] = nil
    AddGagMenuSelectedTime[playerid] = nil

    local players = {}

    for i = 0, playermanager:GetPlayerCap() - 1, 1 do
        local pl = GetPlayer(i)
        if pl then
            if not pl:IsFakeClient() then
                table.insert(players, { pl:CBasePlayerController().PlayerName, "sw_addgagmenu_selectplayer " .. i })
            end
        end
    end

    if #players == 0 then
        table.insert(players, { FetchTranslation("admins.no_players"), "" })
    end

    menus:RegisterTemporary("addgagmenuadmintempplayer_" .. playerid, FetchTranslation("admins.adminmenu.addgag"),
        config:Fetch("admins.amenucolor"), players)

    player:HideMenu()
    player:ShowMenu("addgagmenuadmintempplayer_" .. playerid)
end)

commands:Register("addgagmenu_selectplayer", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end

    local pid = tonumber(args[1])
    if pid == nil then return end
    local pl = GetPlayer(pid)
    if not pl then return end

    AddGagMenuSelectedPlayer[playerid] = pid

    local options = {}

    for i = 0, config:FetchArraySize("admin_comms.reasons") - 1, 1 do
        table.insert(options,
            { config:Fetch("admin_comms.reasons[" .. i .. "]"), "sw_addgagmenu_selectreason \"" ..
            config:Fetch("admin_comms.reasons[" .. i .. "]") .. "\"" })
    end

    menus:RegisterTemporary("addgagmenuadmintempplayerreason_" .. playerid, FetchTranslation("admins.bans.select_reason"),
        config:Fetch("admins.amenucolor"), options)
    player:HideMenu()
    player:ShowMenu("addgagmenuadmintempplayerreason_" .. playerid)
end)

commands:Register("addgagmenu_selectreason", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "d") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end
    if not AddGagMenuSelectedPlayer[playerid] then return player:HideMenu() end

    local reason = args[1]
    AddGagMenuSelectedReason[playerid] = reason

    local options = {}

    for i = 0, config:FetchArraySize("admin_comms.times") - 1, 1 do
        table.insert(options,
            { math.floor(tonumber(config:Fetch("admin_comms.times[" .. i .. "]"))) == 0 and "Forever" or
            ComputePrettyTime(tonumber(config:Fetch("admin_comms.times[" .. i .. "]"))), "sw_addgagmenu_selecttime " .. i })
    end

    menus:RegisterTemporary("addgagmenuadmintempplayertime_" .. playerid,
        string.format("%s - %s", FetchTranslation("admins.adminmenu.addgag"), FetchTranslation("admins.time")),
        config:Fetch("admins.amenucolor"), options)

    player:HideMenu()
    player:ShowMenu("addgagmenuadmintempplayertime_" .. playerid)
end)

commands:Register("addgagmenu_selecttime", function(playerid, args, argc, silent, prefix)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end
    if not AddGagMenuSelectedPlayer[playerid] then return player:HideMenu() end
    if not AddGagMenuSelectedReason[playerid] then return player:HideMenu() end

    local timeidx = tonumber(args[1])
    if not config:Exists("admin_comms.times[" .. timeidx .. "]") then return end
    AddGagMenuSelectedTime[playerid] = timeidx

    local pid = AddGagMenuSelectedPlayer[playerid]
    local pl = GetPlayer(pid)
    if not pl then
        player:HideMenu()
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.not_connected"))
        return
    end

    local options = {
        { FetchTranslation("admins.addgag_confirm"):gsub("{COLOR}", config:Fetch("admins.amenucolor")):gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName):gsub("{TIME}", ComputePrettyTime(tonumber(config:Fetch("admin_comms.times[" .. timeidx .. "]")))), "" },
        { FetchTranslation("admins.yes"),                                                                                                                                                                                                                              "sw_addgagmenu_confirmbox yes" },
        { FetchTranslation("admins.no"),                                                                                                                                                                                                                               "sw_addgagmenu_confirmbox no" }
    }


    menus:RegisterTemporary("addgagmenuadmintempplayerconfirm_" .. playerid,
        string.format("%s - %s", FetchTranslation("admin.adminmenu.addgag"), FetchTranslation("admins.confirm")),
        config:Fetch("admins.amenucolor"), options)

    player:HideMenu()
    player:ShowMenu("addgagmenuadmintempplayerconfirm_" .. playerid)
end)

commands:Register("addgagmenu_confirmbox", function(playerid, args, argc, silent, prefix)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end
    if not AddGagMenuSelectedPlayer[playerid] then return player:HideMenu() end
    if not AddGagMenuSelectedTime[playerid] then return player:HideMenu() end
    if not AddGagMenuSelectedReason[playerid] then return player:HideMenu() end

    local response = args[1]

    if response == "yes" then
        local pid = AddGagMenuSelectedPlayer[playerid]
        local pl = GetPlayer(pid)
        if not pl then
            AddGagMenuSelectedPlayer[playerid] = nil
            AddGagMenuSelectedTime[playerid] = nil
            AddGagMenuSelectedReason[playerid] = nil
            player:HideMenu()
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.not_connected"))
            return
        end

        local alreadygagged = pl:GetVar("player_gagged")
        if alreadygagged then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
                FetchTranslation("admins.gag.already"):gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName))
        end

        local gagMessage = FetchTranslation("admins.gag.message"):gsub("{ADMIN_NAME}",
            player and player:CBasePlayerController().PlayerName):gsub("{PLAYER_NAME}",
            pl:CBasePlayerController().PlayerName):gsub("{TIME}",
            ComputePrettyTime(config:Fetch("admin_comms.times[" .. AddGagMenuSelectedTime[playerid] .. "]"))):gsub(
            "{REASON}",
            AddGagMenuSelectedReason[playerid])

        PerformCommBan(tostring(pl:GetSteamID()), pl:CBasePlayerController().PlayerName,
            player and tostring(player:GetSteamID()) or "0",
            player and player:CBasePlayerController().PlayerName or "CONSOLE",
            config:Fetch("admin_comms.times[" .. AddGagMenuSelectedTime[playerid] .. "]"),
            AddMuteMenuSelectedReason[playerid], CommsType.Gag)

        for i = 1, playermanager:GetPlayerCap() do
            ReplyToCommand(i - 1, config:Fetch("admins.prefix"), gagMessage)
        end
    end
end)

local AddSilenceMenuSelectedPlayer = {}
local AddSilenceMenuSelectedReason = {}
local AddSilenceMenuSelectedTime = {}

commands:Register("addsilencemenu", function(playerid, args, argc, silent, prefix)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    AddSilenceMenuSelectedPlayer[playerid] = nil
    AddSilenceMenuSelectedReason[playerid] = nil
    AddSilenceMenuSelectedTime[playerid] = nil

    local players = {}

    for i = 0, playermanager:GetPlayerCap() - 1, 1 do
        local pl = GetPlayer(i)
        if pl then
            if not pl:IsFakeClient() then
                table.insert(players, { pl:CBasePlayerController().PlayerName, "sw_addsilencemenu_selectplayer " .. i })
            end
        end
    end

    if #players == 0 then
        table.insert(players, { FetchTranslation("admins.no_players"), "" })
    end

    menus:RegisterTemporary("addsilencemenuadmintempplayer_" .. playerid, FetchTranslation("admins.adminmenu.addsilence"),
        config:Fetch("admins.amenucolor"), players)

    player:HideMenu()
    player:ShowMenu("addsilencemenuadmintempplayer_" .. playerid)
end)

commands:Register("addsilencemenu_selectplayer", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end

    local pid = tonumber(args[1])
    if pid == nil then return end
    local pl = GetPlayer(pid)
    if not pl then return end

    AddSilenceMenuSelectedPlayer[playerid] = pid

    local options = {}

    for i = 0, config:FetchArraySize("admin_comms.reasons") - 1, 1 do
        table.insert(options,
            { config:Fetch("admin_comms.reasons[" .. i .. "]"), "sw_addsilencemenu_selectreason \"" ..
            config:Fetch("admin_comms.reasons[" .. i .. "]") .. "\"" })
    end

    menus:RegisterTemporary("addsilencemenuadmintempplayerreason_" .. playerid,
        FetchTranslation("admins.bans.select_reason"), config:Fetch("admins.amenucolor"), options)
    player:HideMenu()
    player:ShowMenu("addsilencemenuadmintempplayerreason_" .. playerid)
end)

commands:Register("addsilencemenu_selectreason", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "d") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end
    if not AddSilenceMenuSelectedPlayer[playerid] then return player:HideMenu() end

    local reason = args[1]
    AddSilenceMenuSelectedReason[playerid] = reason

    local options = {}

    for i = 0, config:FetchArraySize("admin_comms.times") - 1, 1 do
        table.insert(options,
            { math.floor(tonumber(config:Fetch("admin_comms.times[" .. i .. "]"))) == 0 and "Forever" or
            ComputePrettyTime(tonumber(config:Fetch("admin_comms.times[" .. i .. "]"))), "sw_addsilencemenu_selecttime " ..
            i })
    end

    menus:RegisterTemporary("addsilencemenuadmintempplayertime_" .. playerid,
        string.format("%s - %s", FetchTranslation("admins.adminmenu.addsilence"), FetchTranslation("admins.time")),
        config:Fetch("admins.amenucolor"), options)

    player:HideMenu()
    player:ShowMenu("addsilencemenuadmintempplayertime_" .. playerid)
end)

commands:Register("addsilencemenu_selecttime", function(playerid, args, argc, silent, prefix)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end
    if not AddSilenceMenuSelectedPlayer[playerid] then return player:HideMenu() end
    if not AddSilenceMenuSelectedReason[playerid] then return player:HideMenu() end

    local timeidx = tonumber(args[1])
    if not config:Exists("admin_comms.times[" .. timeidx .. "]") then return end
    AddSilenceMenuSelectedTime[playerid] = timeidx

    local pid = AddSilenceMenuSelectedPlayer[playerid]
    local pl = GetPlayer(pid)
    if not pl then
        player:HideMenu()
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.not_connected"))
        return
    end

    local options = {
        { FetchTranslation("admins.addsilence_confirm"):gsub("{COLOR}", config:Fetch("admins.amenucolor")):gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName):gsub("{TIME}", ComputePrettyTime(tonumber(config:Fetch("admin_comms.times[" .. timeidx .. "]")))), "" },
        { FetchTranslation("admins.yes"),                                                                                                                                                                                                                                  "sw_addsilencemenu_confirmbox yes" },
        { FetchTranslation("admins.no"),                                                                                                                                                                                                                                   "sw_addsilencemenu_confirmbox no" }
    }


    menus:RegisterTemporary("addsilencemenuadmintempplayerconfirm_" .. playerid,
        string.format("%s - %s", FetchTranslation("admin.adminmenu.addsilence"), FetchTranslation("admins.confirm")),
        config:Fetch("admins.amenucolor"), options)

    player:HideMenu()
    player:ShowMenu("addsilencemenuadmintempplayerconfirm_" .. playerid)
end)

commands:Register("addsilencemenu_confirmbox", function(playerid, args, argc, silent, prefix)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not exports["admins"]:HasFlags(playerid, "j") then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"),
            FetchTranslation("admins.no_permission"))
    end

    if argc == 0 then return end
    if not AddSilenceMenuSelectedPlayer[playerid] then return player:HideMenu() end
    if not AddSilenceMenuSelectedTime[playerid] then return player:HideMenu() end
    if not AddSilenceMenuSelectedReason[playerid] then return player:HideMenu() end

    local response = args[1]

    if response == "yes" then
        local pid = AddSilenceMenuSelectedPlayer[playerid]
        local pl = GetPlayer(pid)
        if not pl then
            AddSilenceMenuSelectedPlayer[playerid] = nil
            AddSilenceMenuSelectedTime[playerid] = nil
            AddSilenceMenuSelectedReason[playerid] = nil
            player:HideMenu()
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.not_connected"))
            return
        end

        if pl:GetVar("player_gagged") or pl:GetVar("player_muted") then
            return ReplyToCommand(playerid,
                config:Fetch("admins.prefix"),
                FetchTranslation("admins.silence.already"):gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName))
        end

        local silenceMessage = FetchTranslation("admins.silence.message"):gsub("{ADMIN_NAME}",
            player and player:CBasePlayerController().PlayerName):gsub("{PLAYER_NAME}",
            pl:CBasePlayerController().PlayerName):gsub("{TIME}",
            ComputePrettyTime(config:Fetch("admin_comms.times[" .. AddSilenceMenuSelectedTime[playerid] .. "]"))):gsub(
            "{REASON}",
            AddSilenceMenuSelectedReason[playerid])

        PerformCommBan(tostring(pl:GetSteamID()), pl:CBasePlayerController().PlayerName,
            player and tostring(player:GetSteamID()) or "0",
            player and player:CBasePlayerController().PlayerName or "CONSOLE",
            config:Fetch("admin_comms.times[" .. AddSilenceMenuSelectedTime[playerid] .. "]"),
            AddSilenceMenuSelectedReason[playerid], CommsType.Gag)

        PerformCommBan(tostring(pl:GetSteamID()), pl:CBasePlayerController().PlayerName,
            player and tostring(player:GetSteamID()) or "0",
            player and player:CBasePlayerController().PlayerName or "CONSOLE",
            config:Fetch("admin_comms.times[" .. AddSilenceMenuSelectedTime[playerid] .. "]"),
            AddSilenceMenuSelectedReason[playerid], CommsType.Mute)

        for i = 1, playermanager:GetPlayerCap() do
            ReplyToCommand(i - 1, config:Fetch("admins.prefix"), silenceMessage)
        end
    end
end)
