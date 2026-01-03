gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "HestiaBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "FireBoon",
    },
    characterName = "Hestia",
    addToExistingGod = true,
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Flame Blink",
    description = "Spawns lava pools from your dash trail.",
    StatLines = {"HestiaLavaPoolStatDisplay"},
    boonIconPath = _PLUGIN.guid .. "\\Icons\\Hestia_Blink",
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBase",
            BaseType = "Projectile",
            BaseName = "BlinkTrailProjectileFireHestia",
            BaseProperty = "DamagePerConsecutiveHit",
            DecimalPlaces = 1
        },
        {
            ExtractAs = "Fuse",
            SkipAutoExtract = true,
            External = true,
            BaseType = "ProjectileBase",
            BaseName = "BlinkTrailProjectileFireHestia",
            BaseProperty = "ConsecutiveHitWindow",
            DecimalPlaces = 2,
        }
    },
    RarityLevels =
    {
        Common =
        {
            Multiplier = 1,
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
            FunctionName = _PLUGIN.guid .. "." .. "StartHestiaBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailProjectileHestia",
                DamageMultiplier = 1,
            }
        },
        OnProjectileDeathFunction = {
            ValidProjectiles = { "BlinkTrailProjectileHestia" },
            Name = _PLUGIN.guid .. "." .. "CheckHestiaLavaPool",
            Args = {
                ValidProjectileName = "BlinkTrailProjectileHestia",
                ProjectileName = "BlinkTrailProjectileFireHestia",
                DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 2,
                    AbsoluteStackValues = {
                        [1] = 0.5,
                        [2] = 0.3,
                        [3] = 0.2
                    }
                },
                ReportValues = { ReportedMultiplier = "DamageMultiplier"},
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

function mod.CheckHestiaLavaPool(triggerArgs, functionArgs)
    -- print("triggerArgs.name", triggerArgs.name)
    -- print("functionArgs.ValidProjectileName", functionArgs.ValidProjectileName)
    -- print("functionArgs.ProjectileName", functionArgs.ProjectileName)
    -- print("triggerArgs.Armed", triggerArgs.Armed)
    -- print("triggerArgs.LocationX", triggerArgs.LocationX)
    -- print("triggerArgs.LocationY", triggerArgs.LocationY)
    -- print("triggerArgs.Detonated", triggerArgs.Detonated)
    -- print("functionArgs.DamageMultiplier", functionArgs.DamageMultiplier)
    if triggerArgs.name == functionArgs.ValidProjectileName and triggerArgs.LocationX and triggerArgs.LocationY and triggerArgs.Detonated then
        local dropLocation = game.SpawnObstacle({ Name = "InvisibleTarget", LocationX = triggerArgs.LocationX, LocationY = triggerArgs.LocationY  })
        local dataProperties = {
            DamagePerConsecutiveHit = functionArgs.DamageMultiplier
        }
        game.CreateProjectileFromUnit({
            Name = functionArgs.ProjectileName,
            Id = game.CurrentRun.Hero.ObjectId,
            DestinationId = dropLocation,
            DataProperties = dataProperties,
            FireFromTarget = true,
            FizzleOldestProjectileCount = 5,
        })
    end
end

function mod.StartHestiaBlink( args )
    if not game.IsEmpty(game.MapState.BlinkDropTrail) then
        for id, ids in pairs(game.MapState.BlinkDropTrail) do
            -- game.SetAnimation({ Name = "ProjectileLightningBallEnd", DestinationId = id , DataProperties = {Duration = 0.2}})
            game.thread(game.DestroyOnDelay, { id }, 0.1 )
        end
        game.MapState.BlinkDropTrail = {}
    end
    local initialId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    local angle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
    local prevProj = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    local blinkIds = { initialId }
    local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.1
    local startTime = game._worldTime
    local maxTrailLength = 99
    game.MapState.BlinkDropTrail = game.MapState.BlinkDropTrail or {}
    game.MapState.BlinkDropTrail[initialId] = blinkIds
    local fx_index = 5
    local delay_count = 0
    local anim_list = {}
    while game.MapState.BlinkDropTrail and game.MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod and fx_index >= 0 do
        game.wait(0.25, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        print("distance", distance)
        if distance > 0 then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            local targetProjId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            table.insert( blinkIds, targetId )
            game.SetAnimation({ Name = "HestiaBlinkBallIn", DestinationId = blinkIds [#blinkIds - 1]})
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_HestiaFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            game.thread(mod.PoseidonProjectileWithDelay,
                { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = math.random(360), DamageMultiplier = args.DamageMultiplier, FireFromId = prevProj }
            , 0.4)
            prevProj = targetProjId
            angle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
        end
    end
    game.wait(0.25, "BlinkTrailPresentation")
    game.SetAnimation({ Name = "HestiaBlinkBallIn", DestinationId = blinkIds [#blinkIds]})
    game.thread(mod.PoseidonProjectileWithDelay,
        { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = math.random(360), DamageMultiplier = args.DamageMultiplier, FireFromId = prevProj }
    , 0.4)
    if game.MapState.BlinkDropTrail then
        game.MapState.BlinkDropTrail[ initialId ] = nil
    end
    print("blink id count", #blinkIds)
    local lastItemId = table.remove( blinkIds )
    -- game.Destroy({Id = lastItemId})
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
        -- game.CreateAnimationsBetween({ Animation = "BlinkLightningBall", DestinationId = blinkIds [#blinkIds - 1], Id = finalAnchor, Stretch = false, UseZLocation = false})
    end
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