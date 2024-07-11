commands:Register("mute", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.no_permission")) end
    end

    if argc < 3 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.mute.syntax"), prefix))
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
    if time < 0 or time > 525600 then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_time"):gsub("{MIN}", 1):gsub("{MAX}", 525600)) end

    local admin = nil
    if playerid ~= -1 then
        admin = GetPlayer(playerid)
    end


    for i=1,#players do
        local targetPlayer = players[i]
        if admin then
            if exports["admins"]:GetImmunity(targetPlayer:GetSlot()) > exports["admins"]:GetImmunity(playerid) then 
                ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.higher.immunity")) 
                goto skipnextchecks
            end
        end
        
        local alreadymuted = targetPlayer:GetVar("player_muted")
        if alreadymuted then
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation(string.format("admins.mute.already"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName)))
            goto skipnextchecks
        end
        
        PerformCommBan(tostring(targetPlayer:GetSteamID()), targetPlayer:CBasePlayerController().PlayerName, admin and tostring(admin:GetSteamID()) or "0", admin and admin:CBasePlayerController().PlayerName or "CONSOLE", time * 60, reason, CommsType.Mute)
        targetPlayer:SetVoiceFlags(VoiceFlagValue.Speak_Muted)
        local muteMessage = FetchTranslation("admins.mute.message"):gsub("{ADMIN_NAME}", admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName):gsub("{TIME}", time):gsub("{REASON}", reason)
        for j=1,playermanager:GetPlayerCap() do
            ReplyToCommand(j-1, config:Fetch("admins.prefix"), muteMessage)
        end
        ::skipnextchecks::
    end
end)

commands:Register("unmute", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.no_permission")) end
    end

    if argc < 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.unmute.syntax"), prefix))
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

    for i=1,#players do
        local targetPlayer = players[i]

        local muted = targetPlayer:GetVar("player_muted")
        if not muted then
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation(string.format("admins.mute.inexistent"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName)))
            goto skipnextchecksun
        end

        PerformCommUnban(targetPlayer:GetSteamID(), CommsType.Mute)
        targetPlayer:SetVoiceFlags(VoiceFlagValue.Speak_Normal)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.unmute.message"):gsub("{ADMIN_NAME}", admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName))
        ::skipnextchecksun::
    end
end)

commands:Register("gag", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.no_permission")) end
    end

    if argc < 3 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.gag.syntax"), prefix))
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
    if time < 0 or time > 525600 then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_time"):gsub("{MIN}", 1):gsub("{MAX}", 525600)) end

    local admin = nil
    if playerid ~= -1 then
        admin = GetPlayer(playerid)
    end

    for i=1,#players do
        local targetPlayer = players[i]
        if admin then
            if exports["admins"]:GetImmunity(targetPlayer:GetSlot()) > exports["admins"]:GetImmunity(playerid) then 
                ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.higher.immunity")) 
                goto skipnextchecks1
            end
        end
        local alreadygagged = targetPlayer:GetVar("player_gagged")
        if alreadygagged then 
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation(string.format("admins.gag.already"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName))) 
            goto skipnextchecks1
        end
        
        PerformCommBan(tostring(targetPlayer:GetSteamID()), targetPlayer:CBasePlayerController().PlayerName, admin and tostring(admin:GetSteamID()) or "0", admin and admin:CBasePlayerController().PlayerName or "CONSOLE", time * 60, reason, CommsType.Gag)
        local gagMessage = FetchTranslation("admins.gag.message"):gsub("{ADMIN_NAME}", admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName):gsub("{TIME}", time):gsub("{REASON}", reason)
        for j=1,playermanager:GetPlayerCap() do
            ReplyToCommand(j-1, config:Fetch("admins.prefix"), gagMessage)
        end
        ::skipnextchecks1::
    end
end)

commands:Register("ungag", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.no_permission")) end
    end

    if argc < 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.ungag.syntax"), prefix))
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

    for i=1,#players do
        local targetPlayer = players[i]

        local gagged = targetPlayer:GetVar("player_gagged")
        if not gagged then
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation(string.format("admins.gag.inexistent"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName)))
            goto skipnextchecksun2
        end

        PerformCommUnban(targetPlayer:GetSteamID(), CommsType.Gag)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.ungag.message"):gsub("{ADMIN_NAME}", admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName))
        ::skipnextchecksun2::
    end 
end)

commands:Register("silence", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.no_permission")) end
    end

    if argc < 3 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.silence.syntax"), prefix))
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
    if time < 0 or time > 525600 then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_time"):gsub("{MIN}", 1):gsub("{MAX}", 525600)) end

    local admin = nil
    if playerid ~= -1 then
        admin = GetPlayer(playerid)
    end

    for i=1,#players do
        local targetPlayer = players[i]
        if admin then
            if exports["admins"]:GetImmunity(targetPlayer:GetSlot()) > exports["admins"]:GetImmunity(playerid) then 
                ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.higher.immunity")) 
                goto skipnextchecks2
            end
        end

        if targetPlayer:GetVar("player_gagged") or targetPlayer:GetVar("player_muted") then
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.silence.already"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName)) 
            goto skipnextchecks2
        end

        PerformCommBan(tostring(targetPlayer:GetSteamID()), targetPlayer:CBasePlayerController().PlayerName, admin and tostring(admin:GetSteamID()) or "0", admin and admin:CBasePlayerController().PlayerName or "CONSOLE", time * 60, reason, CommsType.Gag)
        PerformCommBan(tostring(targetPlayer:GetSteamID()), targetPlayer:CBasePlayerController().PlayerName, admin and tostring(admin:GetSteamID()) or "0", admin and admin:CBasePlayerController().PlayerName or "CONSOLE", time * 60, reason, CommsType.Mute)
        local silenceMessage = FetchTranslation("admins.silence.message"):gsub("{ADMIN_NAME}", admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName):gsub("{TIME}", time):gsub("{REASON}", reason)
        for j=1,playermanager:GetPlayerCap() do
            ReplyToCommand(j-1, config:Fetch("admins.prefix"), silenceMessage)
        end
        ::skipnextchecks2::
    end
end)

commands:Register("unsilence", function(playerid, args, argc, silent, prefix)
    if playerid ~= -1 then
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        if not hasAccess then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.no_permission")) end
    end

    if argc < 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.unsilence.syntax"), prefix))
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

    for i=1,#players do
        local targetPlayer = players[i]
        if not targetPlayer:GetVar("player_gagged") or not targetPlayer:GetVar("player_muted") then
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.silence.inexistent"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName)) 
            goto skipnextchecks2un
        end

        PerformCommUnban(targetPlayer:GetSteamID(), CommsType.Gag)
        PerformCommUnban(targetPlayer:GetSteamID(), CommsType.Mute)
        targetPlayer:SetVoiceFlags(VoiceFlagValue.Speak_Normal)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.unsilence.message"):gsub("{ADMIN_NAME}", admin and admin:CBasePlayerController().PlayerName or "CONSOLE"):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName))
        ::skipnextchecks2un::
    end
end)