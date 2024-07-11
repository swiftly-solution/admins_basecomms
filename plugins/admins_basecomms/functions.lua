function PerformCommBan(player_steamid, player_name, admin_steamid, admin_name, seconds, reason, btype)
    if not db:IsConnected() then return end
    player_steamid = tostring(player_steamid)

    db:Query(
        string.format(
            "insert into %s (player_name, player_steamid, type, expiretime, length, reason, admin_name, admin_steamid, serverid) values ('%s', '%s', %d, %d, %d, '%s', '%s', '%s', %d)",
            config:Fetch("admins.tablenames.comms"), db:EscapeString(player_name), db:EscapeString(player_steamid), btype, seconds == 0 and (0) or math.floor(GetTime() / 1000) + seconds, 
            seconds, reason, db:EscapeString(admin_name), admin_steamid, config:Fetch("admins.serverid")
        )
    )

    logger:Write(LogType_t.Common, string.format("'%s' (%s) %s '%s' (%s). Time: %s | Reason: %s", admin_name, tostring(admin_steamid), btype == CommsType.Gag and "gagged" or "muted", player_name, player_steamid, ComputePrettyTime(seconds), reason))

    local players = FindPlayersByTarget(player_steamid, false)
    if #players > 0 then
        local player = players[1]
        if btype == CommsType.Gag then
            player:SetVar("player_gagged", true)
            player:SetVar("player_gag_duration", math.floor(GetTime() / 1000) + seconds)
        elseif btype == CommsType.Mute then
            player:SetVar("player_muted", true)
            player:SetVar("player_mute_duration", math.floor(GetTime() / 1000) + seconds)
        end
    end
end

function PerformCommUnban(player_steamid, btype)
    if not db:IsConnected() then return end
    player_steamid = tostring(player_steamid)

    db:Query(
        string.format(
            "update %s set expiretime = UNIX_TIMESTAMP() where player_steamid = '%s' and serverid = %d and (expiretime = 0 OR expiretime - UNIX_TIMESTAMP() > 0) and type = '%d'",
            config:Fetch("admins.tablenames.comms"), db:EscapeString(player_steamid), config:Fetch("admins.serverid"), btype
        )
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
        end
    end
end

function PrintSanctionIfAvailable(playerid, btype)
    if btype == CommsType.Gag then
        if player:GetVar("player_gagged") then
            local seconds = (player:GetVar("player_gag_duration") - math.floor(GetTime() / 1000))
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), "...")
        end
    elseif btype == CommsType.Mute then
        if player:GetVar("player_muted") then
            local seconds = (player:GetVar("player_mute_duration") - math.floor(GetTime() / 1000))
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), "...")
        end
    end
end

function SendToAdmins(flags, text)
    for i=1,playermanager:GetPlayerCap() do
        if exports["admins"]:HasFlags(i-1, flags) then
            local pl = GetPlayer(i-1)
            if pl then
                pl:SendMsg(MessageType.Chat, text)
            end
        end
    end
end
