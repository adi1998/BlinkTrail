function mod.PoseidonProjectileWithDelay(args, delay)
    game.wait(delay)
    game.CreateProjectileFromUnit(args)
end

function mod.PoseidonProjectileWithDelay2(args, delay, sound)
    game.wait(delay)
    game.CreateProjectileFromUnit(args)
    if sound then game.PlaySound({Name = sound, Id = args.FireFromId, ManagerCap = 64 }) end
    local doubleChance = game.GetTotalHeroTraitValue("DoubleOlympianProjectileChance") * game.GetTotalHeroTraitValue( "LuckMultiplier", { IsMultiplier = true })
    if game.RandomChance(doubleChance) then
        game.wait( game.GetTotalHeroTraitValue("DoubleOlympianProjectileInterval" )*(2/3) )
        -- local angle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
        game.CreateProjectileFromUnit(args)
    end
end

function mod.AnimationWithDelay(args,delay)
    game.wait(delay)
    if game.IsAlive({ Id = args.Id}) and game.IsAlive({ Id = args.DestinationId}) then
        game.CreateAnimationsBetween(args)
    end
end

function mod.StartPoseidonBlink( args )
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
        game.wait(0.17, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        
        if distance > 0 then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            local targetProjId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            table.insert( blinkIds, targetId )
            game.SetAnimation({ Name = "PoseidonBlinkBallIn", DestinationId = blinkIds [#blinkIds - 1]})
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_PoseidonFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            game.thread(mod.PoseidonProjectileWithDelay2,
                { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = angle+90, DamageMultiplier = args.DamageMultiplier, FireFromId = prevProj, ProjectileCap = 8 }
            , 1.2, "/SFX/Player Sounds/PoseidonOceanSwellSFX")
            game.thread(mod.PoseidonProjectileWithDelay2,
                { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = angle-90, DamageMultiplier = args.DamageMultiplier, FireFromId = prevProj, ProjectileCap = 8 }
            , 1.2)
            prevProj = targetProjId
            angle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
        end
    end
    game.wait(0.17, "BlinkTrailPresentation")
    game.SetAnimation({ Name = "PoseidonBlinkBallIn", DestinationId = blinkIds [#blinkIds]})
    game.thread(mod.PoseidonProjectileWithDelay2,
        { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = angle+90, DamageMultiplier = args.DamageMultiplier, FireFromId = prevProj, ProjectileCap = 8, DataProperties = {DetonateSound = "null"} }
    , 1.2, "/SFX/Player Sounds/PoseidonOceanSwellSFX")
    game.thread(mod.PoseidonProjectileWithDelay2,
        { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = angle-90, DamageMultiplier = args.DamageMultiplier, FireFromId = prevProj, ProjectileCap = 8 }
    , 1.2)
    if game.MapState.BlinkDropTrail then
        game.MapState.BlinkDropTrail[ initialId ] = nil
    end

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
    -- game.Destroy({ Id = finalAnchor })
end