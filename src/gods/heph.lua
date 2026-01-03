gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "HephaestusBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "FireBoon",
    },
    characterName = "Hephaestus",
    addToExistingGod = true,
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Volcanic Blink",
    description = "Drops mines behind your dash trail.",
    StatLines = {"HephMineBlastBoonStatDisplay"},
    boonIconPath = _PLUGIN.guid .. "\\Icons\\Hephaestus_Blink",
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBase",
            BaseType = "Projectile",
            BaseName = "HephMineBlast",
            BaseProperty = "Damage",
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
            FunctionName = _PLUGIN.guid .. "." .. "StartHephBlink",
            FunctionArgs =
            {
                ProjectileName = "HephMineBlast",
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
    }
})

function mod.CreateMine(delay, id, args)
    game.MapState[_PLUGIN.guid .. "HephMineTable"] = game.MapState[_PLUGIN.guid .. "HephMineTable"] or {}
    game.MapState[_PLUGIN.guid .. "HephMineMap"] = game.MapState[_PLUGIN.guid .. "HephMineMap"] or {}
    table.insert(game.MapState[_PLUGIN.guid .. "HephMineTable"], id)
    game.MapState[_PLUGIN.guid .. "HephMineMap"][id] = true
    game.SetAnimation({Name = "HephMineAoe", DestinationId = id})
    while game.MapState[_PLUGIN.guid .. "HephMineMap"][id] do
        game.wait(delay)
        local enemyId = game.GetClosest({Id = id, DestinationName = "EnemyTeam"})
        if enemyId ~= 0 then
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
            print("mine range", distance)
            local enemy_distance = game.GetDistance({Id = enemyId, DestinationId = id})
            print("enemy distance", enemy_distance)
            if enemy_distance <= distance + 20 then
                -- detonate mine
                game.CreateProjectileFromUnit({ Name = args.ProjectileName, Id = game.CurrentRun.Hero.ObjectId, DamageMultiplier = args.DamageMultiplier, FireFromId = id })
                game.RemoveValueAndCollapse(game.MapState[_PLUGIN.guid .. "HephMineTable"], id)
                game.MapState[_PLUGIN.guid .. "HephMineMap"][id] = nil
                break
            end
        end
        if #game.MapState[_PLUGIN.guid .. "HephMineTable"] >= 5 then
            local oldestId = table.remove(game.MapState[_PLUGIN.guid .. "HephMineTable"], 1)
            game.MapState[_PLUGIN.guid .. "HephMineMap"][oldestId] = nil
        end
    end
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
    local fx_index = 5
    local delay_count = 0
    local anim_list = {}
    while game.MapState.BlinkDropTrail and game.MapState.BlinkDropTrail[initialId] and (game._worldTime - startTime) < waitPeriod and fx_index >= 0 do
        game.wait(0.3, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        
        if distance > 0 then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            local targetProjId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            table.insert( blinkIds, targetId )
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrail_HephFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            game.CreateAnimationsBetween({
                Animation = "BlinkGhostTrailSpark_HephFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
                Stretch = true, UseZLocation = false})
            game.thread(mod.CreateMine, 0.2, prevProj, args)
            prevProj = targetProjId
        end
    end
    game.wait(0.3, "BlinkTrailPresentation")
    game.thread(mod.CreateMine, 0.2, prevProj, args)

    if game.MapState.BlinkDropTrail then
        game.MapState.BlinkDropTrail[ initialId ] = nil
    end
    print("blink id count", #blinkIds)
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