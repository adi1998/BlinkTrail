function mod.ExplodeMineOnHit(victim, _, onHitArgs, triggerArgs)
    -- print("mine hit", victim.ObjectId, game.MapState[_PLUGIN.guid .. "HephMineUnitMap"][victim.ObjectId] )

    if onHitArgs and game.Contains(onHitArgs.InvalidProjectiles, triggerArgs.SourceProjectile) then
        return
    end

    if  game.MapState[_PLUGIN.guid .. "HephMineUnitMap"][victim.ObjectId] == 1 then
        -- print("update mine to 2")
        game.MapState[_PLUGIN.guid .. "HephMineUnitMap"][victim.ObjectId] = 2
    end
end

function mod.CreateMine(delay, id, args)
    game.MapState[_PLUGIN.guid .. "HephMineTable"] = game.MapState[_PLUGIN.guid .. "HephMineTable"] or {}
    game.MapState[_PLUGIN.guid .. "HephMineUnitMap"] = game.MapState[_PLUGIN.guid .. "HephMineUnitMap"] or {}
    game.MapState[_PLUGIN.guid .. "HephMineUnitList"] = game.MapState[_PLUGIN.guid .. "HephMineUnitList"] or {}
    game.MapState[_PLUGIN.guid .. "HephMineMap"] = game.MapState[_PLUGIN.guid .. "HephMineMap"] or {}
    table.insert(game.MapState[_PLUGIN.guid .. "HephMineTable"], id)
    game.MapState[_PLUGIN.guid .. "HephMineMap"][id] = true
    game.SetAnimation({Name = "HephMineAoe", DestinationId = id})
    local mine = game.DeepCopyTable(game.ObstacleData.DummyHephMineObs)
    mine.ObjectId = game.SpawnObstacle({ Name = "DummyHephMineObs", Group = "Standing", DestinationId = id })
    game.SetupObstacle(mine)
    local unitId = mine.ObjectId
    table.insert(game.MapState[_PLUGIN.guid .. "HephMineUnitList"], unitId)
    -- print("heph unit", unitId)
    game.MapState[_PLUGIN.guid .. "HephMineUnitMap"][unitId] = 1
    local detonate = false
    -- id = unitId
    while game.MapState[_PLUGIN.guid .. "HephMineMap"][id] do
        game.wait(delay)
        local enemyId = game.GetClosest({ Id = id, DestinationName = "EnemyTeam", IgnoreInvulnerable = true, IgnoreHomingIneligible = true })
        local typhonId = game.GetIdsByType({ Name = "TyphonHead" })[1]
        if enemyId ~= 0 and enemyId ~= typhonId then
            local angle = math.rad(game.GetAngleBetween({Id = enemyId, DestinationId = id}))
            local a = 200
            local b = a/2
            local cos_angle = math.cos(angle)
            local sin_angle = math.sin(angle)
            local term_x = cos_angle/a
            local term_y = sin_angle/b
            local sqr_term_x = term_x^2
            local sqr_term_y = term_y^2
            local sqrt_term = math.sqrt(sqr_term_x + sqr_term_y)
            local r = 1/sqrt_term
            local distance = math.sqrt((r*cos_angle)^2 + (r*sin_angle)^2)
            -- print("mine range", distance)
            local enemy_distance = game.GetDistance({Id = enemyId, DestinationId = id})
            -- print("enemy distance", enemy_distance)
            -- print("angle", game.GetAngleBetween({Id = id, DestinationId = enemyId}))
            -- print("mine location", mineLocation.X, mineLocation.Y)
            -- print("typhonLocation", typhonLocation.X, typhonLocation.Y)
            -- print("offset", mineLocation.X-typhonLocation.X, mineLocation.Y-typhonLocation.Y)
            -- print("---")
            if enemy_distance <= distance + 20 then
                -- detonate mine
                detonate = true
            end
        end
        if typhonId ~= nil and game.ActiveEnemies[typhonId] then
            local mineLocation = game.GetLocation({ Id = id })
            local typhonLocation = game.GetLocation({ Id = typhonId })
            local offsetX = mineLocation.X-typhonLocation.X
            local offsetY = mineLocation.Y-typhonLocation.Y
            if offsetY <= 450 and offsetX >= -530 and offsetX <= 530 then
                detonate = true
            end
        end
        if game.MapState[_PLUGIN.guid .. "HephMineUnitMap"][unitId] == 2 then
            -- print("detonating on hit", unitId)
            detonate = true
        end
        if detonate == true then
            game.CreateProjectileFromUnit({ Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, DamageMultiplier = args.DamageMultiplier, FireFromId = id })
            game.RemoveValueAndCollapse(game.MapState[_PLUGIN.guid .. "HephMineTable"], id)
            game.RemoveValueAndCollapse(game.MapState[_PLUGIN.guid .. "HephMineUnitList"], unitId)
            game.MapState[_PLUGIN.guid .. "HephMineMap"][id] = nil
            game.MapState[_PLUGIN.guid .. "HephMineUnitMap"][unitId] = nil
            break
        end
        if #game.MapState[_PLUGIN.guid .. "HephMineTable"] >= 5 then
            local oldestId = table.remove(game.MapState[_PLUGIN.guid .. "HephMineTable"], 1)
            local oldestUnitId = table.remove(game.MapState[_PLUGIN.guid .. "HephMineUnitList"], 1)
            game.MapState[_PLUGIN.guid .. "HephMineMap"][oldestId] = nil
            game.MapState[_PLUGIN.guid .. "HephMineUnitMap"][oldestUnitId] = nil
        end
    end
    game.Destroy({Id = unitId})
    game.Destroy({Id = id})
end

function mod.StartHephBlink( args )
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
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0)
    local startTime = game._worldTime
    local maxTrailLength = 99
    game.MapState.BlinkDropTrail = game.MapState.BlinkDropTrail or {}
    game.MapState.BlinkDropTrail[initialId] = blinkIds
    game.MapState[_PLUGIN.guid .. "HephMineUnitList"] = game.MapState[_PLUGIN.guid .. "HephMineUnitList"] or {}
    local fx_index = 5
    local delay_count = 0
    local anim_list = {}
    while game.MapState.BlinkDropTrail and game.MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod and fx_index >= 0 do
        game.wait(0.3, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        -- print("distance",distance)
        if distance > 0  then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            local targetProjId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })

            table.insert( blinkIds, targetId )
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_HephFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrailSpark_HephFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            if game.GetClosest({ Id = prevProj, DestinationIds = game.MapState[_PLUGIN.guid .. "HephMineUnitList"], Distance = 160, ScaleY = 0.5 }) == 0 then
                game.thread(mod.CreateMine, 0.2, prevProj, args)
            end
            prevProj = targetProjId
        end
    end
    game.wait(0.3, "BlinkTrailPresentation")
    if game.GetClosest({ Id = prevProj, DestinationIds = game.MapState[_PLUGIN.guid .. "HephMineUnitList"], Distance = 160, ScaleY = 0.5 }) == 0 then
        game.thread(mod.CreateMine, 0.2, prevProj, args)
    end

    if game.MapState.BlinkDropTrail then
        game.MapState.BlinkDropTrail[ initialId ] = nil
    end
    local lastItemId = table.remove( blinkIds )
    game.Destroy({Id = lastItemId})
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