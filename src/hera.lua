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
                FunctionName = _PLUGIN.guid .. "." .. "CheckExistingBlinkBoons",
                FunctionArgs = {}
            },
        },
    }
})

function mod.StartHeraBlink( args )
    if not IsEmpty(MapState.BlinkDropTrail) then
        for id, ids in pairs(MapState.BlinkDropTrail) do    
            SetAnimation({ Name = "HeraBlinkRopeOut", DestinationId = id, CopyFromPrev = true })
            thread(DestroyOnDelay, { id }, 0.1 )
        end
        MapState.BlinkDropTrail = {}
    end
    local initialId = SpawnObstacle({ Name = "BlankObstacle", DestinationId = CurrentRun.Hero.ObjectId, Group = "Standing" })
    local angle = GetAngle({ Id = CurrentRun.Hero.ObjectId })
    local location = GetLocation({ Id = CurrentRun.Hero.ObjectId })
    local blinkIds = { initialId }
    local blinkAnimationIds = {}
    local nextClipRegenTime  = GetWeaponDataValue({ Id = CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
    local waitPeriod = nextClipRegenTime + (GetWeaponDataValue({ Id = CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.08
    local startTime = _worldTime
    local maxTrailLength = 99

    MapState.BlinkDropTrail = MapState.BlinkDropTrail or {}
    MapState.BlinkDropTrail[initialId] = blinkIds
    local skipped = true
    while MapState.BlinkDropTrail and MapState.BlinkDropTrail[initialId] and (_worldTime - startTime) < waitPeriod do
        wait (0.13, "BlinkTrailPresentation")
        local distance = GetDistance({ Id = blinkIds [#blinkIds], DestinationId = CurrentRun.Hero.ObjectId })
        print("distance", distance)
        if distance > 0 then
            local targetId = SpawnObstacle({ Name = "BlankObstacle", DestinationId = CurrentRun.Hero.ObjectId, Group = "Standing" })
            table.insert( blinkIds, targetId )
            print(targetId)
            local newangle = GetAngle({ Id = CurrentRun.Hero.ObjectId })
            local newlocation = GetLocation({ Id = CurrentRun.Hero.ObjectId })
            angle = (angle + newangle)/2
            -- local loc_angle = LuaGetAngleBetween(location.X,location.Y,newlocation.X,newlocation.Y)
            local loc_angle = (LuaGetAngleBetween(newlocation.X,-newlocation.Y,location.X,-location.Y) + 180) % 360
            local animid = CreateAnimationsBetween({
                    Animation = "HeraBlinkShort" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                    Stretch = true, UseZLocation = false})
            local animid = CreateAnimationsBetween({
                    Animation = "HeraBlinkShortDark" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                    Stretch = true, UseZLocation = false})
            print("animid",animid)
            print("angle", angle)
            print("loc angle", loc_angle)
            if distance > 90 or (skipped and distance > 30) then
                CreateProjectileFromUnit({
                    Name = args.ProjectileName,
                    Id = CurrentRun.Hero.ObjectId,
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
            if TableLength(blinkIds) > maxTrailLength then
                local lastItemId = table.remove( blinkIds, 1 )
                SetAnimation({ Name = "HeraBlinkRopeOut", DestinationId = lastItemId, CopyFromPrev = true })
                thread(DestroyOnDelay, { lastItemId }, 0.09 )
            end
        end
    end
    if MapState.BlinkDropTrail then
        MapState.BlinkDropTrail[ initialId ] = nil
    end
    print("blink id count", #blinkIds)
    local lastItemId = table.remove( blinkIds )
    Destroy({Id = lastItemId})
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

    local finalAnchor = SpawnObstacle({ Name = "BlankObstacle", DestinationId = CurrentRun.Hero.ObjectId, Group = "Standing" })
    Attach({ Id = finalAnchor, DestinationId = CurrentRun.Hero.ObjectId })
    if GetDistance({ Id = finalAnchor, DestinationId = CurrentRun.Hero.ObjectId }) > 0 then
        CreateAnimationsBetween({ Animation = "HeraBlinkShort" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds - 1], Id = finalAnchor, Stretch = true, UseZLocation = false })
    end
    while not IsEmpty( blinkIds ) do
        while skipCounter < skipInterval do
            local lastItemId = table.remove( blinkIds, 1 )
            SetAnimation({ Name = "HeraBlinkRopeOut", DestinationId = lastItemId, CopyFromPrev = true })
            thread(DestroyOnDelay, { lastItemId }, 0.1 )
            skipCounter = skipCounter + 1
        end
        skipCounter = 0
        wait( waitInterval, "BlinkTrailPresentation")
    end
    Destroy({ Id = finalAnchor })
end

game.OverwriteTableKeys( game.ProjectileData, {
    BlinkTrailProjectileHeraOmega =
    {
        InheritFrom = { "HeraColorProjectile" },
    },
})

game.ProcessDataStore(game.ProjectileData)