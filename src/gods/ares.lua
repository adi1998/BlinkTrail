gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "AresBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "EarthBoon",
    },
    characterName = "Ares",
    addToExistingGod = true,
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Bloody Blink",
    description = "Create multiple {$Keywords.BladeRift} from your dash trail. Enemies damaged from {$Keywords.BladeRift} spill {!Icons.BloodDropIcon}",
    StatLines = {"BladeRiftDamageStatDisplay1"},
    boonIconPath = "GUI\\Screens\\BoonIcons\\Ares_28",
    reuseBaseIcons = true,
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBaseOverTime",
            BaseType = "Projectile",
            BaseName = "BlinkTrailProjectileAres",
            BaseProperty = "Damage",
            BaseFuseProperty = "Fuse",
        },
        {
            ExtractAs = "BladeRiftDuration",
            SkipAutoExtract = true,
            External = true,
            BaseType = "ProjectileBase",
            BaseName = "BlinkTrailProjectileAres",
            BaseProperty = "TotalFuse",
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
            Multiplier = 1.25,
        },
        Epic =
        {
            Multiplier = 1.5,
        },
        Heroic =
        {
            Multiplier = 1.75,
        }
    },
    ExtraFields =
    {
        [_PLUGIN.guid .. "OnSprintAction"] = {
            FunctionName = _PLUGIN.guid .. "." .. "StartAresBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailProjectileAres",
                DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 4, -- Needs additional precision due to the number being operated on
                    AbsoluteStackValues =
                    {
                        [1] = 0.25,
                        [2] = 0.125,
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
        AcquireFunctionName = "SetupBloodDropDisplay",
		OnExpire = { FunctionName = "CheckBloodDropDisplay", },
        OnEnemyDamagedAction =
        {
            ValidProjectiles = {"BlinkTrailProjectileAres", "AresProjectile"},
            FunctionName = _PLUGIN.guid .. "." .. "CheckAresRiftBloodDrop",
            Args =
            {
                Cooldown = 0.5,
                Name = "BloodDrop",
                Chance = 1
            }
        }
    }
})

function mod.CheckAresRiftBloodDrop(victim, functionArgs, triggerArgs)
    if game.MapState[_PLUGIN.guid .. "LastBloodDropTime"] == nil or game._worldTime >= game.MapState[_PLUGIN.guid .. "LastBloodDropTime"] + functionArgs.Cooldown  then
        game.thread( game.CreateBloodDrop, victim, functionArgs )
        game.MapState[_PLUGIN.guid .. "LastBloodDropTime"] = game._worldTime
    end
end

function mod.StartAresBlinkTrailPresentation()
	if not IsEmpty(MapState.BlinkDropTrail) then
		for id, ids in pairs(MapState.BlinkDropTrail) do	
			SetAnimation({ Name = "AresBlinkTrailFxOut", DestinationId = id, CopyFromPrev = true })
			thread(DestroyOnDelay, { id }, 0.1 )
		end
		
		MapState.BlinkDropTrail = {}
	end
	local initialId = SpawnObstacle({ Name = "BlankObstacle", DestinationId = CurrentRun.Hero.ObjectId, Group = "Standing" })
	local blinkIds = { initialId }
	local blinkAnimationIds = {}
	local nextClipRegenTime  = GetWeaponDataValue({ Id = CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
	local waitPeriod = nextClipRegenTime + (GetWeaponDataValue({ Id = CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.08
	local startTime = _worldTime
	local maxTrailLength = 99 

	MapState.BlinkDropTrail = MapState.BlinkDropTrail or {}
	MapState.BlinkDropTrail[initialId] = blinkIds
	while MapState.BlinkDropTrail and MapState.BlinkDropTrail[initialId] and (_worldTime - startTime) < waitPeriod do
		wait (0.0666, "BlinkTrailPresentation")
		local distance = GetDistance({ Id = blinkIds [#blinkIds], DestinationId = CurrentRun.Hero.ObjectId })
		if distance > 0 then
			local targetId = SpawnObstacle({ Name = "BlankObstacle", DestinationId = CurrentRun.Hero.ObjectId, Group = "Standing" })
			table.insert( blinkIds, targetId )
			CreateAnimationsBetween({ Animation = "AresBlinkTrailFxIn", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1], Stretch = true, UseZLocation = false, Group = "Standing", SetAnimation = true, MatchOwnerToAnimation = true})
			if TableLength(blinkIds) > maxTrailLength then
				local lastItemId = table.remove( blinkIds, 1 )
				SetAnimation({ Name = "AresBlinkTrailFxOut", DestinationId = lastItemId, CopyFromPrev = true })
				thread(DestroyOnDelay, { lastItemId }, 0.09 )
			end
		end
	end
	if MapState.BlinkDropTrail then
		MapState.BlinkDropTrail[ initialId ] = nil
	end
	local lastItemId = table.remove( blinkIds )
	Destroy({Id = lastItemId})
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

	local finalAnchor = SpawnObstacle({ Name = "BlankObstacle", DestinationId = CurrentRun.Hero.ObjectId, Group = "Standing" })
	Attach({ Id = finalAnchor, DestinationId = CurrentRun.Hero.ObjectId })
	if GetDistance({ Id = finalAnchor, DestinationId = CurrentRun.Hero.ObjectId }) > 0 then
		CreateAnimationsBetween({ Animation = "AresBlinkTrailFxIn", DestinationId = blinkIds [#blinkIds - 1], Id = finalAnchor, Stretch = true, UseZLocation = false, Group = "Standing", SetAnimation = true, MatchOwnerToAnimation = true})
	end
	while not IsEmpty( blinkIds ) do
		while skipCounter < skipInterval do
			local lastItemId = table.remove( blinkIds, 1 )
			SetAnimation({ Name = "AresBlinkTrailFxOut", DestinationId = lastItemId, CopyFromPrev = true })
			thread(DestroyOnDelay, { lastItemId }, 0.1 )
			skipCounter = skipCounter + 1
		end
		skipCounter = 0
		wait( waitInterval, "BlinkTrailPresentation")
	end
	Destroy({ Id = finalAnchor })
end

function mod.StartAresBlink( args )
    game.thread(mod.StartAresBlinkTrailPresentation)
    game.wait(0.05)
    local angle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
    local prevProj = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.1
    local startTime = game._worldTime
    while not game.IsEmpty(game.MapState.BlinkDropTrail) and (game._worldTime - startTime) < waitPeriod do
        game.wait(0.2, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = prevProj, DestinationId = game.CurrentRun.Hero.ObjectId })
        if distance > 0 then
            local targetProjId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            game.thread(mod.PoseidonProjectileWithDelay,
                { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = math.random(360), DamageMultiplier = args.DamageMultiplier, FireFromId = prevProj, FizzleOldestProjectileCount = 6 }
            , 0.08)
            prevProj = targetProjId
        end
    end
    game.wait(0.2, "BlinkTrailPresentation")
    game.thread(mod.PoseidonProjectileWithDelay,
        { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, Angle = math.random(360), DamageMultiplier = args.DamageMultiplier, FireFromId = prevProj, FizzleOldestProjectileCount = 6 }
    , 0.1)
end