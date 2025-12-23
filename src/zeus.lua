gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "ZeusBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "AirBoon",
    },
    characterName = "Zeus",
    addToExistingGod = true,

    BlockStacking = false,
    displayName = "Thunder Blink",
    description = "Creates chain lightning from your dash trail",
    StatLines = {"LightningDamageStatDisplay1"},
    boonIconPath = "GUI\\Screens\\BoonIcons\\Zeus_28",
    reuseBaseIcons = true,
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBase",
            BaseType = "Projectile",
            BaseName = "BlinkTrailZeusSpark",
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
            Multiplier = 1.5,
        },
        Epic =
        {
            Multiplier = 2,
        },
        Heroic =
        {
            Multiplier = 2.5,
        }
    },
    ExtraFields =
    {
        [_PLUGIN.guid .. "OnSprintAction"] = {
            FunctionName = _PLUGIN.guid .. "." .. "StartZeusBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailZeusSpark",
                DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 4, -- Needs additional precision due to the number being operated on
                    AbsoluteStackValues =
                    {
                        [1] = 0.5,
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

local boonanme = gods.GetInternalBoonName("ZeusBlinkTrailBoon")
game.LootData.ZeusUpgrade.TraitIndex[boonanme]= true

function mod.ProjectileWithDelay(args, delay)
    game.wait(delay)
    local enemyId = GetClosest({Id = args.FireFromId, DestinationName = "EnemyTeam", Distance = 1100})
    local angle = GetAngleBetween({ Id = args.FireFromId, DestinationId = enemyId })
    if enemyId == 0 then
        angle = math.random(1,360)
    end
    args.Angle = angle

    game.CreateProjectileFromUnit(args)
end

function mod.StartZeusBlink( args )
    if not game.IsEmpty(game.MapState.BlinkDropTrail) then
        for id, ids in pairs(game.MapState.BlinkDropTrail) do
            SetAnimation({ Name = "ProjectileLightningBallEnd", DestinationId = id , DataProperties = {Duration = 0.2}})
            game.thread(game.DestroyOnDelay, { id }, 0.1 )
        end
        game.MapState.BlinkDropTrail = {}
    end
    local initialId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    local prevProj = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    local blinkIds = { initialId }
    local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0)
    local startTime = game._worldTime
    local maxTrailLength = 99
    game.MapState.BlinkDropTrail = MapState.BlinkDropTrail or {}
    game.MapState.BlinkDropTrail[initialId] = blinkIds

    while game.MapState.BlinkDropTrail and MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod do
        game.wait(0.13, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        print("distance", distance)
        if distance > 0 then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            local targetProjId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            table.insert( blinkIds, targetId )
            -- local animid = CreateAnimationsBetween({
            --     Animation = "BlinkLightningBall", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
            --     Stretch = false, UseZLocation = false})
            SetAnimation({ Name = "BlinkLightningBall", DestinationId = blinkIds [#blinkIds - 1]})
            local angle = math.random(1,360)
            -- CreateProjectileFromUnit({
            --         Name = "BlinkTrailZeusSpark",
            --         Id = CurrentRun.Hero.ObjectId,
            --         Angle = angle,
            --         FireFromId = prevProj,
            --         DamageMultiplier = args.DamageMultiplier,
            --         FizzleOldestProjectileCount = 10
            --     })
            game.thread(mod.ProjectileWithDelay,{
                Name = "BlinkTrailZeusSpark",
                Id = CurrentRun.Hero.ObjectId,
                -- Angle = angle,
                FireFromId = prevProj,
                DamageMultiplier = args.DamageMultiplier,
                ProjectileCap = 8
            }, 1)
            prevProj = targetProjId
            thread(DestroyOnDelay, { blinkIds [#blinkIds - 1] }, 1 )
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
        -- CreateAnimationsBetween({ Animation = "BlinkLightningBall", DestinationId = blinkIds [#blinkIds - 1], Id = finalAnchor, Stretch = false, UseZLocation = false})
    end
    while not IsEmpty( blinkIds ) do
        while skipCounter < skipInterval do
            local lastItemId = table.remove( blinkIds, 1 )
            -- SetAnimation({ Name = "ProjectileLightningBallEnd", DestinationId = lastItemId, DataProperties = {Duration = 0.2} })
            -- thread(DestroyOnDelay, { lastItemId }, 0.1 )
            skipCounter = skipCounter + 1
        end
        skipCounter = 0
        wait( waitInterval, "BlinkTrailPresentation")
    end
    -- Destroy({ Id = finalAnchor })
end