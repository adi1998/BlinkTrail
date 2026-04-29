function mod.ProjectileWithDelay(args, delay)
    game.wait(delay)
    -- local enemyId = game.GetClosest({Id = args.FireFromId, DestinationName = "EnemyTeam", Distance = 730})
    local angle = math.random(1,360)
    args.Angle = angle
    local addlProperties = {}
    if game.HeroHasTrait("ReboundingSparkBoon") then
        addlProperties.AllowRepeatedOwnerJumpHit = true
        addlProperties.AffectsSelf = true
        --addlProperties.MultipleUnitCollisions = true
    end
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
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.1
    local startTime = game._worldTime
    local maxTrailLength = 99
    game.MapState.BlinkDropTrail = game.MapState.BlinkDropTrail or {}
    game.MapState.BlinkDropTrail[initialId] = blinkIds
    local skippedLast = false
    while game.MapState.BlinkDropTrail and game.MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod do
        game.wait(0.16, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        -- print("distance", distance)
        if distance > 0 then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            local targetProjId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            table.insert( blinkIds, targetId )
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_ZeusFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            game.thread(mod.AnimationWithDelay, {
                Animation = "BlinkGhostTrail_ZeusFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false}, 0.7)
            if distance > 100 or skippedLast then
                game.SetAnimation({ Name = "BlinkLightningBall", DestinationId = prevProj})
                game.thread(mod.ProjectileWithDelay,{
                    Name = args.ProjectileName,
                    Id = game.CurrentRun.Hero.ObjectId,
                    FireFromId = prevProj,
                    DamageMultiplier = args.DamageMultiplier,
                    FizzleOldestProjectileCount = 7
                }, 1)
                skippedLast = false
            else
                skippedLast = true
            end
            game.thread(game.DestroyOnDelay, { prevProj }, 1.1 )
            prevProj = targetProjId
        end
    end

    game.wait(0.13, "BlinkTrailPresentation")
    game.SetAnimation({ Name = "BlinkLightningBall", DestinationId = prevProj})
    game.thread(mod.ProjectileWithDelay,{
        Name = "BlinkTrailZeusSpark",
        Id = game.CurrentRun.Hero.ObjectId,
        FireFromId = prevProj,
        DamageMultiplier = args.DamageMultiplier,
        FizzleOldestProjectileCount = 7
    }, 1)
    game.thread(game.DestroyOnDelay, { prevProj }, 1.1 )
    if game.MapState.BlinkDropTrail then
        game.MapState.BlinkDropTrail[ initialId ] = nil
    end

    local lastItemId = table.remove( blinkIds )
    game.thread(game.DestroyOnDelay, { lastItemId }, 1 )
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

    while not game.IsEmpty( blinkIds ) do
        while skipCounter < skipInterval do
            lastItemId = table.remove( blinkIds, 1 )
            game.thread(game.DestroyOnDelay, { lastItemId }, 1 )
            skipCounter = skipCounter + 1
        end
        skipCounter = 0
        game.wait( waitInterval, "BlinkTrailPresentation")
    end
end