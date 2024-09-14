function PerformCommBan(player_steamid, player_name, admin_steamid, admin_name, seconds, reason, btype)
    if not db:IsConnected() then return end
    player_steamid = tostring(player_steamid)

    db:QueryParams(
        "insert into @tablename (player_name, player_steamid, type, expiretime, length, reason, admin_name, admin_steamid) values ('@player_name', '@player_steamid', @sanctype, @expiretime, @length, '@reason', '@admin_name', '@admin_steamid')",
        { tablename = config:Fetch("admins.tablenames.comms"), player_name = player_name, player_steamid = player_steamid, sanctype = btype, expiretime = (seconds == 0 and (0) or (os.time() + seconds)), length = seconds, reason = reason, admin_name = admin_name, admin_steamid = admin_steamid }
    )

    logger:Write(LogType_t.Common,
        string.format("'%s' (%s) %s '%s' (%s). Time: %s | Reason: %s", admin_name, tostring(admin_steamid),
            btype == CommsType.Gag and "gagged" or "muted", player_name, player_steamid, ComputePrettyTime(seconds),
            reason))

    local players = FindPlayersByTarget(player_steamid, false)
    if #players > 0 then
        local player = players[1]
        if btype == CommsType.Gag then
            player:SetVar("player_gagged", true)
            player:SetVar("player_gag_duration", seconds == 0 and (0) or (os.time() + seconds))
        elseif btype == CommsType.Mute then
            player:SetVar("player_muted", true)
            player:SetVar("player_mute_duration", seconds == 0 and (0) or (os.time() + seconds))
            player:SetVoiceFlags(VoiceFlagValue.Speak_Muted)
        end
    end
end

function PerformCommUnban(player_steamid, btype)
    if not db:IsConnected() then return end
    player_steamid = tostring(player_steamid)

    db:QueryParams(
        "update @tablename set expiretime = UNIX_TIMESTAMP() where player_steamid = '@steamid' and (expiretime = 0 OR expiretime - UNIX_TIMESTAMP() > 0) and type = '@sanctype'",
        { tablename = config:Fetch("admins.tablenames.comms"), steamid = player_steamid, sanctype = btype }
    )

    local players = FindPlayersByTarget(player_steamid, false)
    if #players > 0 then
        local player = players[1]
        if btype == CommsType.Gag then
            player:SetVar("player_gagged", false)
            player:SetVar("player_gag_duration", 0)
        elseif btype == CommsType.Mute then
            player:SetVar("player_muted", false)
            player:SetVar("player_mute_duration", 0)
            player:SetVoiceFlags(VoiceFlagValue.Speak_Normal)
        end
    end
end

function SendToAdmins(flags, text)
    for i = 1, playermanager:GetPlayerCap() do
        if exports["admins"]:HasFlags(i - 1, flags) then
            local pl = GetPlayer(i - 1)
            if pl then
                pl:SendMsg(MessageType.Chat, text)
            end
        end
    end
end
