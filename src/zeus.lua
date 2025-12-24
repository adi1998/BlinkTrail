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
        {
            External = true,
            BaseType = "ProjectileBase",
            BaseName = "BlinkTrailZeusSpark",
            BaseProperty = "NumJumps",
            Format = "TotalTargets",
            ExtractAs = "Bounces",
            SkipAutoExtract = true,
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
                        [2] = 0.3
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

local boonname = gods.GetInternalBoonName("ZeusBlinkTrailBoon")
game.LootData.ZeusUpgrade.TraitIndex[boonname]= true

function mod.ProjectileWithDelay(args, delay)
    game.wait(delay)
    local enemyId = game.GetClosest({Id = args.FireFromId, DestinationName = "EnemyTeam", Distance = 730})
    local angle = game.GetAngleBetween({ Id = args.FireFromId, DestinationId = enemyId })
    if enemyId == 0 then
        angle = math.random(1,360)
    end
    args.Angle = angle
    local addlProperties = {}
    addlProperties.NumJumps = game.GetBaseDataValue({ Type = "Projectile", Name = args.Name, Property = "NumJumps"}) + game.GetTotalHeroTraitValue("ZeusSparkBonusBounces")
    args.DataProperties = addlProperties
    game.CreateProjectileFromUnit(args)
end

function mod.StartZeusBlink( args )
    if not game.IsEmpty(game.MapState.BlinkDropTrail) then
        for id, ids in pairs(game.MapState.BlinkDropTrail) do
            game.SetAnimation({ Name = "ProjectileLightningBallEnd", DestinationId = id , DataProperties = {Duration = 0.2}})
            game.thread(game.DestroyOnDelay, { id }, 0.1 )
        end
        game.MapState.BlinkDropTrail = {}
    end
    local initialId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    local prevProj = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    local blinkIds = { initialId }
    local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.04
    local startTime = game._worldTime
    local maxTrailLength = 99
    game.MapState.BlinkDropTrail = game.MapState.BlinkDropTrail or {}
    game.MapState.BlinkDropTrail[initialId] = blinkIds

    while game.MapState.BlinkDropTrail and game.MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod do
        game.wait(0.13, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        print("distance", distance)
        if distance > 0 then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            local targetProjId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            table.insert( blinkIds, targetId )
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_ZeusFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            game.SetAnimation({ Name = "BlinkLightningBall", DestinationId = blinkIds [#blinkIds - 1]})
            game.thread(mod.ProjectileWithDelay,{
                Name = args.ProjectileName,
                Id = game.CurrentRun.Hero.ObjectId,
                FireFromId = prevProj,
                DamageMultiplier = args.DamageMultiplier,
                ProjectileCap = 8
            }, 1)
            prevProj = targetProjId
            game.thread(game.DestroyOnDelay, { blinkIds [#blinkIds - 1] }, 1.1 )
        end
    end

    game.wait(0.13, "BlinkTrailPresentation")
    game.SetAnimation({ Name = "BlinkLightningBall", DestinationId = prevProj})
    game.thread(mod.ProjectileWithDelay,{
        Name = "BlinkTrailZeusSpark",
        Id = game.CurrentRun.Hero.ObjectId,
        FireFromId = prevProj,
        DamageMultiplier = args.DamageMultiplier,
        ProjectileCap = 8
    }, 1)

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
    while not game.IsEmpty( blinkIds ) do
        while skipCounter < skipInterval do
            local lastItemId = table.remove( blinkIds, 1 )
            -- game.SetAnimation({ Name = "ProjectileLightningBallEnd", DestinationId = lastItemId, DataProperties = {Duration = 0.2} })
            -- game.thread(DestroyOnDelay, { lastItemId }, 0.1 )
            skipCounter = skipCounter + 1
        end
        skipCounter = 0
        game.wait( waitInterval, "BlinkTrailPresentation")
    end
    -- Destroy({ Id = finalAnchor })
end