function mod.CheckAresRiftBloodDrop(victim, functionArgs, triggerArgs)
    if game.MapState[_PLUGIN.guid .. "LastBloodDropTime"] == nil or game._worldTime >= game.MapState[_PLUGIN.guid .. "LastBloodDropTime"] + functionArgs.Cooldown  then
        game.thread( game.CreateBloodDrop, victim, functionArgs )
        game.MapState[_PLUGIN.guid .. "LastBloodDropTime"] = game._worldTime
    end
end

function mod.StartAresBlinkTrailPresentation()
	if not game.IsEmpty(game.MapState.BlinkDropTrail) then
		for id, ids in pairs(game.MapState.BlinkDropTrail) do	
			game.SetAnimation({ Name = "AresBlinkTrailFxOut", DestinationId = id, CopyFromPrev = true })
			game.thread(game.DestroyOnDelay, { id }, 0.1 )
		end
		
		game.MapState.BlinkDropTrail = {}
	end
	local initialId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
	local blinkIds = { initialId }
	local blinkAnimationIds = {}
	local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
	local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.08
	local startTime = game._worldTime
	local maxTrailLength = 99 

	game.MapState.BlinkDropTrail = game.MapState.BlinkDropTrail or {}
	game.MapState.BlinkDropTrail[initialId] = blinkIds
	while game.MapState.BlinkDropTrail and game.MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod do
		game.wait (0.0666, "BlinkTrailPresentation")
		local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
		if distance > 0 then
			local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
			table.insert( blinkIds, targetId )
			game.CreateAnimationsBetween({ Animation = "AresBlinkTrailFxIn", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1], Stretch = true, UseZLocation = false, Group = "Standing", SetAnimation = true, MatchOwnerToAnimation = true})
			if game.TableLength(blinkIds) > maxTrailLength then
				local lastItemId = table.remove( blinkIds, 1 )
				game.SetAnimation({ Name = "AresBlinkTrailFxOut", DestinationId = lastItemId, CopyFromPrev = true })
				game.thread(game.DestroyOnDelay, { lastItemId }, 0.09 )
			end
		end
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
		game.CreateAnimationsBetween({ Animation = "AresBlinkTrailFxIn", DestinationId = blinkIds [#blinkIds - 1], Id = finalAnchor, Stretch = true, UseZLocation = false, Group = "Standing", SetAnimation = true, MatchOwnerToAnimation = true})
	end
	while not game.IsEmpty( blinkIds ) do
		while skipCounter < skipInterval do
			local lastItemId = table.remove( blinkIds, 1 )
			game.SetAnimation({ Name = "AresBlinkTrailFxOut", DestinationId = lastItemId, CopyFromPrev = true })
			game.thread(game.DestroyOnDelay, { lastItemId }, 0.1 )
			skipCounter = skipCounter + 1
		end
		skipCounter = 0
		game.wait( waitInterval, "BlinkTrailPresentation")
	end
	game.Destroy({ Id = finalAnchor })
end

function mod.StartAresBlink( args )
    game.thread(mod.StartAresBlinkTrailPresentation)
    game.wait(0.05)
    local angle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
    local prevProj = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.2
    local startTime = game._worldTime
    local skippedLast = false
    while not game.IsEmpty(game.MapState.BlinkDropTrail) and (game._worldTime - startTime) < waitPeriod do
        game.wait(0.2, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = prevProj, DestinationId = game.CurrentRun.Hero.ObjectId })
        if distance > 120 or distance > 40 and skippedLast == true then
            local targetProjId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            game.thread(mod.PoseidonProjectileWithDelay,
                { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = math.random(360), DamageMultiplier = args.DamageMultiplier, FireFromId = prevProj, FizzleOldestProjectileCount = 6 }
            , 0.08)
            prevProj = targetProjId
            skippedLast = false
        else
            skippedLast = true
        end
    end
    game.wait(0.2, "BlinkTrailPresentation")
    game.thread(mod.PoseidonProjectileWithDelay,
        { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = math.random(360), DamageMultiplier = args.DamageMultiplier, FireFromId = prevProj, FizzleOldestProjectileCount = 6 }
    , 0.1)
end