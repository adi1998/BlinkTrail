gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "HeraBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "FireBoon",
    },
    characterName = "Hera",
    addToExistingGod = true,
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Sworn Blink",
    description = "Creates a rift in the shape of your dash trail.",
    StatLines = {"HeraRiftDamageStatDisplay1"},
    boonIconPath = "GUI\\Screens\\BoonIcons\\Hera_28",
    reuseBaseIcons = true,
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBase",
            BaseType = "Projectile",
            BaseName = "BlinkTrailProjectileHeraOmega",
            BaseProperty = "Damage",
        },
    },
    RarityLevels =
    {
        Common =
        {
            Multiplier = 1.0,
        },
        Rare =
        {
            Multiplier = 1.25,
        },
        Epic =
        {
            Multiplier = 1.5,
        },
        Heroic =
        {
            Multiplier = 1.75,
        }
    },
    ExtraFields =
    {
        [_PLUGIN.guid .. "OnSprintAction"] = {
            FunctionName = _PLUGIN.guid .. "." .. "StartHeraBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailProjectileHeraOmega",
                DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 4, -- Needs additional precision due to the number being operated on
                    AbsoluteStackValues =
                    {
                        [1] = 0.25,
                        [2] = 0.125,
                        [3] = 10/120,
                    },
                },
                ReportValues =
                {
                    ReportedMultiplier = "DamageMultiplier"
                },
            }
        },
        GameStateRequirements =
        {
            {
                FunctionName = _PLUGIN.guid .. "." .. "CheckNoExistingBlinkBoons",
                FunctionArgs = {}
            },
        },
    }
})

local booname = gods.GetInternalBoonName("HeraBlinkTrailBoon")
game.LootData.HeraUpgrade.TraitIndex[booname]= true

function mod.StartHeraBlink( args )
    if not game.IsEmpty(game.MapState.BlinkDropTrail) then
        for id, ids in pairs(game.MapState.BlinkDropTrail) do    
            -- game.SetAnimation({ Name = "HeraBlinkRopeOut", DestinationId = id, CopyFromPrev = true })
            -- game.thread(DestroyOnDelay, { id }, 0.1 )
        end
        game.MapState.BlinkDropTrail = {}
    end
    local initialId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    local angle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
    local location = game.GetLocation({ Id = game.CurrentRun.Hero.ObjectId })
    local blinkIds = { initialId }
    local blinkAnimationIds = {}
    local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.2
    local startTime = game._worldTime
    local maxTrailLength = 99

    game.MapState.BlinkDropTrail = game.MapState.BlinkDropTrail or {}
    game.MapState.BlinkDropTrail[initialId] = blinkIds
    local skipped = true
    while game.MapState.BlinkDropTrail and game.MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod do
        game.wait (0.13, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        print("distance", distance)
        if distance > 0 then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            table.insert( blinkIds, targetId )
            print(targetId)
            local newangle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
            local newlocation = game.GetLocation({ Id = game.CurrentRun.Hero.ObjectId })
            angle = (angle + newangle)/2
            -- local loc_angle = LuaGetAngleBetween(location.X,location.Y,newlocation.X,newlocation.Y)
            local loc_angle = (game.LuaGetAngleBetween(newlocation.X,-newlocation.Y,location.X,-location.Y) + 180) % 360
            local animid = game.CreateAnimationsBetween({
                Animation = "HeraBlinkShort" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            local animid = game.CreateAnimationsBetween({
                Animation = "HeraBlinkShortDark" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            game.thread(mod.AnimationWithDelay, {
                Animation = "HeraBlinkDissShort" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false }, 0.5)
            print("animid",animid)
            print("angle", angle)
            print("loc angle", loc_angle)
            angle = game.GetAngleBetween({Id = blinkIds [#blinkIds], DestinationId = blinkIds [#blinkIds - 1]})
            if distance > 90 or (skipped and distance > 30) then
                game.CreateProjectileFromUnit({
                    Name = args.ProjectileName,
                    Id = game.CurrentRun.Hero.ObjectId,
                    Angle = angle,
                    FireFromId = animid,
                    DamageMultiplier = args.DamageMultiplier,
                    FizzleOldestProjectileCount = 4
                })
                skipped = false
            else
                skipped = true
            end
            angle = newangle
            location = newlocation
            if game.TableLength(blinkIds) > maxTrailLength then
                local lastItemId = table.remove( blinkIds, 1 )
                -- game.SetAnimation({ Name = "HeraBlinkRopeOut", DestinationId = lastItemId, CopyFromPrev = true })
                -- game.thread(DestroyOnDelay, { lastItemId }, 0.09 )
            end
        end
    end
    if game.MapState.BlinkDropTrail then
        game.MapState.BlinkDropTrail[ initialId ] = nil
    end
    print("blink id count", #blinkIds)
    local lastItemId = table.remove( blinkIds )
    -- Destroy({Id = lastItemId})
    local outDuration = 0.16 -- time to remove trail over
    local waitInterval = outDuration/#blinkIds
    local minWaitInterval = 0.06
    local skipInterval = 1
    local skipCounter = 0
    if waitInterval < minWaitInterval then
        local multiplier = math.ceil(minWaitInterval/waitInterval)
        waitInterval = waitInterval * multiplier
        skipInterval = multiplier
    end

    local finalAnchor = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    game.Attach({ Id = finalAnchor, DestinationId = game.CurrentRun.Hero.ObjectId })
    if game.GetDistance({ Id = finalAnchor, DestinationId = game.CurrentRun.Hero.ObjectId }) > 0 then
        game.CreateAnimationsBetween({ Animation = "HeraBlinkShort" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds - 1], Id = finalAnchor, Stretch = true, UseZLocation = false })
        game.CreateAnimationsBetween({
                Animation = "HeraBlinkShortDark" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds - 1], Id = finalAnchor,
                Stretch = true, UseZLocation = false})
        game.thread(mod.AnimationWithDelay, {
                Animation = "HeraBlinkDissShort" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds - 1], Id = finalAnchor,
                Stretch = true, UseZLocation = false }, 0.5)
    end
    while not game.IsEmpty( blinkIds ) do
        while skipCounter < skipInterval do
            local lastItemId = table.remove( blinkIds, 1 )
            -- game.SetAnimation({ Name = "HeraBlinkRopeOut", DestinationId = lastItemId, CopyFromPrev = true })
            -- game.thread(DestroyOnDelay, { lastItemId }, 0.1 )
            skipCounter = skipCounter + 1
        end
        skipCounter = 0
        game.wait( waitInterval, "BlinkTrailPresentation")
    end
    -- Destroy({ Id = finalAnchor })
end