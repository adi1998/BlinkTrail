
function mod.StartApolloBlink( args )
    local initialId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    local blinkIds = { initialId }
    local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0)
    local startTime = game._worldTime

    game.MapState.BlinkDropTrail = game.MapState.BlinkDropTrail or {}
    game.MapState.BlinkDropTrail[initialId] = blinkIds
    local count = 0
    while game.MapState.BlinkDropTrail and game.MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod do
        if count > 2 then
            game.wait (0.13, "BlinkTrailPresentation")
        else
            game.wait (0.066, "BlinkTrailPresentation")
        end
        count = count + 1
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })

        if distance > 0 then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            table.insert( blinkIds, targetId )
            local random_anim = math.random(4)
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_ApolloFx"..random_anim, DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            game.thread(mod.AnimationWithDelay, {
            Animation = "BlinkGhostTrail_ApolloFx"..random_anim, DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
            Stretch = true, UseZLocation = false }, 0.5)

            game.thread(mod.PoseidonProjectileWithDelay,
                { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, DamageMultiplier = args.DamageMultiplier, FireFromId = blinkIds [#blinkIds - 1], FizzleOldestProjectileCount = 4 }
            , 0.5)
        end
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
            game.thread(game.DestroyOnDelay, { lastItemId }, 2 )
            skipCounter = skipCounter + 1
        end
        skipCounter = 0
        game.wait( waitInterval, "BlinkTrailPresentation")
    end
end

function mod.SuperBlind(enemy, functionArgs, triggerArgs)
    game.CurrentRun.CurrentRoom[_PLUGIN.guid .. "InvisTargetTable"] = game.CurrentRun.CurrentRoom[_PLUGIN.guid .. "InvisTargetTable"] or {}
    local invisTargetTable = game.CurrentRun.CurrentRoom[_PLUGIN.guid .. "InvisTargetTable"]
    invisTargetTable[enemy.ObjectId] = game.SpawnObstacle({ Name = "InvisibleTarget", Group = "Scripting", DestinationId = game.CurrentRun.Hero.ObjectId })
    local anim_obstacle = game.SpawnObstacle({ Name = "BlankObstacle", Group = "Standing", DestinationId = enemy.ObjectId })
    game.SetAnimation({Name = "ApolloAoEStrikeBlink", DestinationId = anim_obstacle})
    game.FinishTargetMarker( enemy )
    game.thread( game.OnInvisStartPresentation, enemy )
    game.wait(functionArgs.Duration)
    game.thread( game.InCombatText, enemy.ObjectId, "Alerted", 0.45, { OffsetY = enemy.HealthBarOffsetY, SkipFlash = true, PreDelay = game.RandomFloat(0.1, 0.15), SkipShadow = true } )
    if invisTargetTable[enemy.ObjectId] then
        game.Destroy({ Id = invisTargetTable[enemy.ObjectId] })
        invisTargetTable[enemy.ObjectId] = nil
    end
    game.Destroy({ Id = anim_obstacle })
end

function mod.CheckSuperBlindApply(enemy, functionArgs, triggerArgs)
    if not game.CheckCooldown( "ApolloSuperBlind" .. tostring(enemy.ObjectId), functionArgs.Cooldown * game.GetTotalHeroTraitValue("OlympianRechargeMultiplier", { IsMultiplier = true }) ) then
		return
	end
    game.thread(mod.SuperBlind, enemy, functionArgs, triggerArgs)
end