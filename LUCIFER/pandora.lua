interface = getBots()
bot = getBot()

say = function(content)
    bot:say(tostring(content))
end

move = function(x, y)
    bot:moveTo(x, y)
end

findPath = function(x, y)
    return bot:findPath(x, y)
end

findItem = function(itemid)
    return bot:getInventory():getItemCount(itemid)
end

findClothes = function(itemid)
    item = bot:getInventory():getItem(itemid)
    if item == nil then
        return false
    end

    return item.isActive
end

getposx = function()
    player = bot:getWorld():getLocal()
    if player then
        return player.posx
    end

    return 0
end

getposy = function()
    player = bot:getWorld():getLocal()
    if player then
        return player.posy
    end

    return 0
end

getTilePosition = function(x_offset, y_offset)
    local_player = bot:getWorld():getLocal()
    if not local_player then
        return { x = 0, y = 0 }
    end

    return {
        x = math.floor(local_player.posx / 32) + x_offset,
        y = math.floor(local_player.posy / 32) + y_offset
    }
end

place = function(itemid, x, y)
    position = getTilePosition(x, y)
    bot:place(position.x, position.y, itemid)
end

punch = function(x, y)
    place(18, x, y)
end

wrench = function(x, y)
    place(32, x, y)
end

drop = function(itemid, count)  
    if not count then
        bot:drop(itemid, findItem(itemid))
    else
        bot:drop(itemid, count)
    end
end

trash = function(itemid, count)  
    if not count then
        bot:trash(itemid, findItem(itemid))
    else
        bot:trash(itemid, count)
    end
end

wear = function(itemid)
    if findClothes(itemid) then
        bot:unwear(itemid)
    else
        bot:wear(itemid)
    end
end

enter = function()
    bot:enter()
end

collect = function(range, itemid)
    if itemid == nil then
    else
    end
end

collectSet = function(active, range)
    bot.auto_collect = active
    if range then
        bot.collect_range = range
    end
end

sendPacket = function(type, packet)
    bot:sendPacket(type, packet)
end

sendPacketRaw = function(data)
    packet = GameUpdatePacket.new()

    if data.type then
        packet.type = data.type
    end
    if data.netid then
        packet.netid = data.netid
    end
    if data.flags then
        packet.flags = data.flags
    end
    if data.int_data then
        packet.int_data = data.int_data
    end
    if data.pos_x then
        packet.pos_x = data.pos_x
    end
    if data.pos_y then
        packet.pos_y = data.pos_y
    end
    if data.pos2_x then
        packet.pos2_x = data.pos2_x
    end
    if data.pos2_y then
        packet.pos2_y = data.pos2_y
    end
    if data.int_x then
        packet.int_x = data.int_x
    end
    if data.int_y then
        packet.int_y = data.int_y
    end

    bot:sendRaw(packet)
end

connect = function()
    return bot:connect()
end

disconnect = function()
    bot:disconnect()
end

startFishing = function(bait_id)
    bot.auto_fish.active = true
    if bot.auto_fish.bait then
        bot.auto_fish.bait = bait_id
    end
end

stopFishing = function()
    bot.auto_fish.active = false
end

getPing = function()
    return bot:getPing()
end

getSignal = function()
    signal = bot:getSignal()
    
    signals = {
        "null",
        "red",
        "yellow",
        "green",
        "rapid green",
        "prize"
    }

    return signals[signal.type +1]
end

request = function(type, url)
    client = HttpClient.new()
    client.url = url

    if type == "GET" then
        client:setMethod(Method.get)
    elseif type == "POST" then
        client:setMethod(Method.post)
    elseif type == "PATCH" then
        client:setMethod(Method.patch)
    end

    return client:request().body
end

setBool = function(name, active)
    if name == "Auto Access" then
        bot.auto_accept = activew
    elseif name == "Auto Reconnect" then
        bot.auto_reconnect = active
    elseif name == "Auto Leave" then
        bot.auto_leave = active
    elseif name == "Ignore Gems" then
        bot.ignore_gems = active
    end
end

function getStatus(instance)
    local statuslist = {
        [BotStatus.offline] = "offline",
        [BotStatus.online] = "online",
        [BotStatus.account_banned] = "banned",
        [BotStatus.location_banned] = "banned",
        [BotStatus.server_overload] = "login failed",
        [BotStatus.too_many_login] = "login failed",
        [BotStatus.maintenance] = "maintenance",
        [BotStatus.version_update] = "version update",
        [BotStatus.server_busy] = "login failed",
        [BotStatus.error_connecting] = "ercon",
        [BotStatus.logon_fail] = "login failed",
    }

    return statuslist[instance.status]
end

function getCaptcha(instance)
    local captchalist = {
        [CaptchaStatus.no_captcha] = "solved", 
        [CaptchaStatus.not_found] = "wrong", 
        [CaptchaStatus.solved] = "solved", 
        [CaptchaStatus.solving] = "solving",
        [CaptchaStatus.wrong] = "wrong", 
        [CaptchaStatus.failed] = "wrong" 
    }

    return captchalist[instance.capcha_status]
end

GetBot = function(name)
    instance = nil
    if name then
        instance = getBot(name)
    else
        instance = getBot()
    end

    if not instance then
        return nil
    end
 
    return {
        name = instance.name,
        world = instance:getWorld().name,
        status = getStatus(instance),
        captcha = getCaptcha(instance),
        x = getposx(),
        y = getposy(),
        gems = instance.gem_count,
        level = instance.level,
        slots = instance:getInventory().slotcount
    }
end

GetBots = function()
    bots = {}
    for i, instance in pairs(getBots()) do
        table.insert(bots, GetBot(instance.name))
    end

    return bots
end

AddBot = function(name, pass, proxy)
    if proxy then
        addProxy(proxy)
    end

    if not pass then
        addBot(name)
        return
    end
   
    addBot(name, pass)
end

getTile = function(x, y)
    tile = bot:getWorld():getTile(x, y)
    if not tile then
        return {
            fg = 0, bg = 0, data = 0, ready = false, flags = 0
        }
    end

    tile_extra = 0
    if tile:hasExtra() then
        tile_extra = tile:getExtra().id
    end

    return {
        fg = tile.fg,
        bg = tile.bg,
        x = x,
        y = y,
        extra = tile.flags,
        data = tile_extra,
        ready = tile:canHarvest(),
        flags = getInfo(tile.fg).collision_type
    }
end

getTiles = function()
    tiles = {}
    for _, tile in pairs(bot:getWorld():getTiles()) do
        table.insert(tiles, getTile(tile.x, tile.y))
    end
    return tiles
end

getInventory = function()
    return bot:getInventory():getItems()
end

getClothes = function()
    clothes = {}
    for _, item in pairs(getInventory()) do
        if item.isActive then
            table.insert(clothes, { name = getInfo(item.id).name, id = item.id })
        end
    end

    return clothes
end

webhook = function(wh)
    if not wh.url then
        return
    end

    instance = Webhook.new(wh.url)

    if wh.username then
        instance.username = wh.username
    end

    if wh.content then
        instance.content = wh.content
    end

    if wh.embed then
        instance.embed1.use = true
        instance.embed1.description = wh.embed
    end

    if wh.avatar then
        instance.avatar_url = wh.avatar_url
    end

    if wh.edit then
        message_id = wh.url:match("/([^/]+)$")
        if message_id then
            instance:edit(message_id)
        end
    else
        instance:send()
    end
end

addHook = function(name, detour)
    addEvent(Event.OnVariantList, detour)
end

removeHook = function(name) --_(o.o)_--
    removeEvents()
end

removeHooks = function()
    removeEvents()
end