gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "ApolloBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "AirBoon",
    },
    characterName = "Apollo",
    addToExistingGod = true,
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Blinding Blink",
    description = "Completely blind enemies caught in your dash trail for {#BoldFormatGraft}{$TooltipData.ExtractData.Duration} Sec {#Prev}.",
    StatLines = {"ApolloBlinkCooldownStatDisplay"},
    boonIconPath = _PLUGIN.guid .. "\\Icons\\Apollo_Blink",
    ExtractValues =
    {
        {
            Key = "ReportedCooldown",
            ExtractAs = "Cooldown",
            Format = "SpeedModifiedDuration",
            DecimalPlaces = 1,
        },
        {
            Key = "ReportedDuration",
            ExtractAs = "Duration",
            SkipAutoExtract = true,
        },
    },
    RarityLevels =
    {
        Common =
        {
            Multiplier = 1,
        },
        Rare =
        {
            Multiplier = 27/30,
        },
        Epic =
        {
            Multiplier = 24/30,
        },
        Heroic =
        {
            Multiplier = 21/30,
        }
    },
    ExtraFields =
    {
        [_PLUGIN.guid .. "OnSprintAction"] = {
            FunctionName = _PLUGIN.guid .. "." .. "StartApolloBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailProjectileApollo",
                DamageMultiplier = 1,
            }
        },
        OnEnemyDamagedAction = 
        {
            ValidProjectiles = {"BlinkTrailProjectileApollo", "ApolloCast"},
            FunctionName = _PLUGIN.guid .. "." .. "CheckSuperBlindApply",
            Args =
            {
                Duration = 3,
                Cooldown = {
                    BaseValue = 30,
                    MinimumSourceValue = 10,
                    AbsoluteStackValues =
                    {
                        [1] = -3,
                        [2] = -1,
                    },
                },
                ReportValues =
                {
                    ReportedCooldown = "Cooldown",
                    ReportedDuration = "Duration"
                },
            },
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

function mod.StartApolloBlink( args )
    if not game.IsEmpty(game.MapState.BlinkDropTrail) then
        for id, ids in pairs(game.MapState.BlinkDropTrail) do    
            -- game.SetAnimation({ Name = "HeraBlinkRopeOut", DestinationId = id, CopyFromPrev = true })
            -- game.thread(DestroyOnDelay, { id }, 0.1 )
        end
        game.MapState.BlinkDropTrail = {}
    end
    local initialId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    local angle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
    local location = game.GetLocation({ Id = game.CurrentRun.Hero.ObjectId })
    local blinkIds = { initialId }
    local blinkAnimationIds = {}
    local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
    local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0)
    local startTime = game._worldTime
    local maxTrailLength = 99

    game.MapState.BlinkDropTrail = game.MapState.BlinkDropTrail or {}
    game.MapState.BlinkDropTrail[initialId] = blinkIds
    local skipped = true
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
            print(targetId)
            local newangle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
            local newlocation = game.GetLocation({ Id = game.CurrentRun.Hero.ObjectId })
            angle = (angle + newangle)/2
            -- local loc_angle = LuaGetAngleBetween(location.X,location.Y,newlocation.X,newlocation.Y)
            local loc_angle = (game.LuaGetAngleBetween(newlocation.X,-newlocation.Y,location.X,-location.Y) + 180) % 360
            local random_anim = math.random(4)
            local animid = game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_ApolloFx"..random_anim, DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            -- game.thread(mod.AnimationWithDelay, {
            -- Animation = "BlinkGhostTrail_ApolloFx_Dark"..random_anim, DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
            -- Stretch = true, UseZLocation = false }, 0.1)
            -- local animid = game.CreateAnimationsBetween({
            --     Animation = "HeraBlinkShortDark" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
            --     Stretch = true, UseZLocation = false})
            game.thread(mod.AnimationWithDelay, {
            Animation = "BlinkGhostTrail_ApolloFx"..random_anim, DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
            Stretch = true, UseZLocation = false }, 0.5)

            print("animid",animid)
            print("angle", angle)
            print("loc angle", loc_angle)
            angle = game.GetAngleBetween({Id = blinkIds [#blinkIds], DestinationId = blinkIds [#blinkIds - 1]})
            
            game.thread(mod.PoseidonProjectileWithDelay,
                { Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, DamageMultiplier = args.DamageMultiplier, FireFromId = blinkIds [#blinkIds - 1], FizzleOldestProjectileCount = 4 }
            , 0.5)
            
            angle = newangle
            location = newlocation
            if game.TableLength(blinkIds) > maxTrailLength then
                local lastItemId = table.remove( blinkIds, 1 )
                -- game.SetAnimation({ Name = "HeraBlinkRopeOut", DestinationId = lastItemId, CopyFromPrev = true })
                -- game.thread(DestroyOnDelay, { lastItemId }, 0.09 )
            end
        end
    end
    if game.MapState.BlinkDropTrail then
        game.MapState.BlinkDropTrail[ initialId ] = nil
    end
    print("blink id count", #blinkIds)
    local lastItemId = table.remove( blinkIds )
    -- Destroy({Id = lastItemId})
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
        -- game.CreateAnimationsBetween({ Animation = "HeraBlinkShort" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds - 1], Id = finalAnchor, Stretch = true, UseZLocation = false })
        -- game.CreateAnimationsBetween({
        --         Animation = "HeraBlinkShortDark" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds - 1], Id = finalAnchor,
        --         Stretch = true, UseZLocation = false})
        -- game.thread(mod.AnimationWithDelay, {
        --         Animation = "HeraBlinkDissShort" .. tostring(math.random(3)), DestinationId = blinkIds [#blinkIds - 1], Id = finalAnchor,
        --         Stretch = true, UseZLocation = false }, 0.5)
    end
    while not game.IsEmpty( blinkIds ) do
        while skipCounter < skipInterval do
            local lastItemId = table.remove( blinkIds, 1 )
            -- game.SetAnimation({ Name = "HeraBlinkRopeOut", DestinationId = lastItemId, CopyFromPrev = true })
            -- game.thread(DestroyOnDelay, { lastItemId }, 0.1 )
            skipCounter = skipCounter + 1
        end
        skipCounter = 0
        game.wait( waitInterval, "BlinkTrailPresentation")
    end
    -- Destroy({ Id = finalAnchor })
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
end

function mod.CheckSuperBlindApply(enemy, functionArgs, triggerArgs)
    if not game.CheckCooldown( "ApolloSuperBlind" .. tostring(enemy.ObjectId), functionArgs.Cooldown * game.GetTotalHeroTraitValue("OlympianRechargeMultiplier", { IsMultiplier = true }) ) then
		return
	end
    game.thread(mod.SuperBlind, enemy, functionArgs, triggerArgs)
end