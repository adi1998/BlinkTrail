function mod.CreateAphroditeProjectile( id, functionArgs, blinkId )
    game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] = game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] or 0
    local angle = math.rad( math.random(0,360) )
    local offset = game.CalcOffset( angle , functionArgs.SpawnDistance )
    local dropLocation = game.SpawnObstacle({ Name = "InvisibleTarget", DestinationId = id })
    local angle_reverse = math.deg(angle) + 180
    game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] = game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] + 1
    game.wait( functionArgs.Delay )
    if game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] <= 5 then
        game.CreateProjectileFromUnit({
            Name = functionArgs.ProjectileName,
            Id = game.CurrentRun.Hero.ObjectId,
            DestinationId = dropLocation,
            FireFromTarget = true,
            OffsetX = offset.X,
            OffsetY = offset.Y,
            Angle = angle_reverse,
            DamageMultiplier = functionArgs.DamageMultiplier,
        })
        game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] = game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] - 1
        if game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] < 0 then
            game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] = 0
        end
        -- print("shot aphro", game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"])
        local arrowSound = game.PlaySound({ Name = "/Leftovers/SFX/AuraPerfectThrow", Id = dropLocation, ManagerCap = 46 })
        game.SetVolume({Id = arrowSound, Value = 0.3, Duration = 0.0})
        game.wait( 0.35 )
        game.SetAnimation({ Name = "BlinkTrailAphroditeTargetFast", DestinationId = blinkId})
    else
        game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] = game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] - 1
        if game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] < 0 then
            game.MapState[_PLUGIN.guid .. "AphroBlinkActiveCount"] = 0
        end
        game.Destroy({ Ids = {blinkId} })
    end

    game.thread(game.DestroyOnDelay, {dropLocation, id}, 0.1)
end

function mod.StartAphroditeBlink( args )
    if not game.IsEmpty(game.MapState.BlinkDropTrail) then
        for id, ids in pairs(game.MapState.BlinkDropTrail) do
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
    game.MapState.BlinkDropTrail = game.MapState.BlinkDropTrail or {}
    game.MapState.BlinkDropTrail[initialId] = blinkIds
    local fx_index = 5
    while game.MapState.BlinkDropTrail and game.MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod and fx_index >= 0 do
        game.wait(0.22, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        -- print("distance", distance)
        if distance > 0 then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            local targetProjId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })

            table.insert( blinkIds, targetId )

            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_AphroditeFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_AphroditeFxC", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_AphroditeFxC_Back", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            if distance > 100 then
                game.SetAnimation({ Name = "BlinkTrailAphroditeTarget", DestinationId = blinkIds [#blinkIds - 1]})
                game.thread(game.DestroyOnDelay, { blinkIds [#blinkIds - 1] }, 1.35)
                game.thread(mod.CreateAphroditeProjectile, prevProj, args, blinkIds [#blinkIds - 1])
            end
            prevProj = targetProjId
        end
    end
    game.wait(0.22, "BlinkTrailPresentation")
    local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })

    if distance > 100 then
        game.SetAnimation({ Name = "BlinkTrailAphroditeTarget", DestinationId = blinkIds [#blinkIds]})
        game.thread(game.DestroyOnDelay, { blinkIds [#blinkIds] }, 1.35)
        game.thread(mod.CreateAphroditeProjectile, prevProj, args, blinkIds [#blinkIds])
    end
    if game.MapState.BlinkDropTrail then
        game.MapState.BlinkDropTrail[ initialId ] = nil
    end

    local lastItemId = table.remove( blinkIds )
    game.thread(game.DestroyOnDelay, { lastItemId }, 2 )
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
            -- game.SetAnimation({ Name = "ProjectileLightningBallEnd", DestinationId = lastItemId, DataProperties = {Duration = 0.2} })
            game.thread(game.DestroyOnDelay, { lastItemId }, 2 )
            skipCounter = skipCounter + 1
        end
        skipCounter = 0
        game.wait( waitInterval, "BlinkTrailPresentation")
    end
end