
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
        game.Destroy({Id = dropLocation})
    end
end

function mod.StartHestiaBlink( args )
    -- game.LoadPackages({Name = "BiomeN"})
    if not game.IsEmpty(game.MapState.BlinkDropTrail) then
        for id, ids in pairs(game.MapState.BlinkDropTrail) do
            -- game.SetAnimation({ Name = "ProjectileLightningBallEnd", DestinationId = id , DataProperties = {Duration = 0.2}})
            game.SetAlpha({Id = id, Fraction = 0, Duration = 0.15})
            game.thread(game.DestroyOnDelay, { id }, 0.15 )
        end
        game.MapState.BlinkDropTrail = {}
    end
    local initialId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    game.thread(game.DestroyOnDelay, { initialId }, 2)
    local blinkIds = { initialId }
    local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.1
    local startTime = game._worldTime
    game.MapState.BlinkDropTrail = game.MapState.BlinkDropTrail or {}
    game.MapState.BlinkDropTrail[initialId] = blinkIds
    local fx_index = 5
    local skippedLast = false
    while game.MapState.BlinkDropTrail and game.MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod and fx_index >= 0 do
        game.wait(0.25, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        if distance > 0 then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            game.thread(game.DestroyOnDelay, { targetId }, 2)
            table.insert( blinkIds, targetId )
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_HestiaFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            if distance > 140 or distance > 40 and skippedLast then
                game.SetAnimation({ Name = "HestiaBlinkBallIn", DestinationId = blinkIds [#blinkIds - 1]})
                game.thread(mod.PoseidonProjectileWithDelay,
                    { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = math.random(360), DamageMultiplier = args.DamageMultiplier, FireFromId = blinkIds [#blinkIds - 1] }
                , 0.4)
                skippedLast = false
            else
                skippedLast = true
            end
        end
    end
    game.wait(0.25, "BlinkTrailPresentation")
    game.SetAnimation({ Name = "HestiaBlinkBallIn", DestinationId = blinkIds [#blinkIds]})
    game.thread(mod.PoseidonProjectileWithDelay,
        { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = math.random(360), DamageMultiplier = args.DamageMultiplier, FireFromId = blinkIds [#blinkIds] }
    , 0.4)
end