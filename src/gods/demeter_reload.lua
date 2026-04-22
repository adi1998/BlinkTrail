
function mod.CrystalBeamCleanup( projectileData, triggerArgs )
    game.MapState[_PLUGIN.guid .. "DemeterTurretMap"] = game.MapState[_PLUGIN.guid .. "DemeterTurretMap"] or {}
    local id = triggerArgs.ProjectileId
    game.Destroy({ Id = game.MapState[_PLUGIN.guid .. "DemeterTurretMap"][id] })
end

function mod.DemeterProjectileWithDelay(args, delay, turretId)
    game.wait(delay)
    game.MapState[_PLUGIN.guid .. "DemeterTurretMap"] = game.MapState[_PLUGIN.guid .. "DemeterTurretMap"] or {}
    local projId = game.CreateProjectileFromUnit(args)
    game.MapState[_PLUGIN.guid .. "DemeterTurretMap"][projId] = turretId
end

function mod.StartDemeterBlink( args )
    game.MapState[_PLUGIN.guid .. "DemeterTurretMap"] = game.MapState[_PLUGIN.guid .. "DemeterTurretMap"] or {}
    local initialId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    -- local angle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
    local blinkIds = { initialId }
    local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.1
    local startTime = game._worldTime
    game.MapState.BlinkDropTrail = game.MapState.BlinkDropTrail or {}
    game.MapState.BlinkDropTrail[initialId] = blinkIds
    local fx_index = 5
    local skippedLast = false
    while game.MapState.BlinkDropTrail and game.MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod and fx_index >= 0 do
        game.wait(0.2, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        if distance > 140 or distance > 40 and skippedLast then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            local angle = game.GetAngleBetween({ DestinationId = targetId, Id = blinkIds [#blinkIds] })
            table.insert( blinkIds, targetId )
            game.SetAnimation({ Name = "BlinkTrailDemeterTurret", DestinationId = blinkIds [#blinkIds - 1]})
            game.thread(game.DestroyOnDelay, { blinkIds [#blinkIds - 1] }, 3.4 )
            game.thread(mod.DemeterProjectileWithDelay,
                { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = (180 + angle) % 360, DamageMultiplier = args.DamageMultiplier, FireFromId = targetId, DataProperties = {Range = distance, MaxAdjustRate = 0, AttachToOwner = false}, FizzleOldestProjectileCount = 6 }
            , 0.4, blinkIds[#blinkIds - 1] )
            skippedLast = false
        else
            skippedLast = true
        end
    end
    game.wait(0.25, "BlinkTrailPresentation")
    game.SetAnimation({ Name = "BlinkTrailDemeterTurret", DestinationId = blinkIds [#blinkIds]})
    game.thread(game.DestroyOnDelay, { blinkIds [#blinkIds] }, 3.4 )

    local unitId = game.SpawnUnit({ Name = "DummyOlympusTarget", Group = "Standing", DestinationId = blinkIds[#blinkIds], DataProperties = {CollideWithUnits = false} })
    game.thread(game.DestroyOnDelay, { unitId }, 3.4 )
    game.SetUnitProperty({ DestinationId = unitId, Property = "CollideWithUnits", Value = false })
    game.thread(mod.DemeterProjectileWithDelay,
        { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, DestinationId = unitId, DamageMultiplier = args.DamageMultiplier, FizzleOldestProjectileCount = 6 }
    , 0.4, blinkIds[#blinkIds])

    if game.MapState.BlinkDropTrail then
        game.MapState.BlinkDropTrail[ initialId ] = nil
    end
end