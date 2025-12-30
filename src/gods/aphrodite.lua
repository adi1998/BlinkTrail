gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "AphroditeBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "WaterBoon",
    },
    characterName = "Aphrodite",
    addToExistingGod = true,
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Flutter Blink",
    description = "Fires large arrows along targets mades by your dash trail.",
    StatLines = {"SupportFireDamageDisplay2"},
    boonIconPath = "GUI\\Screens\\BoonIcons\\Aphrodite_28",
    reuseBaseIcons = true,
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBase",
            BaseType = "Projectile",
            BaseName = "BlinkTrailProjectileAphrodite",
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
            Multiplier = 6/5,
        },
        Epic =
        {
            Multiplier = 7/5,
        },
        Heroic =
        {
            Multiplier = 8/5,
        }
    },
    ExtraFields =
    {
        [_PLUGIN.guid .. "OnSprintAction"] = {
            FunctionName = _PLUGIN.guid .. "." .. "StartAphroditeBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailProjectileAphrodite",
                SpawnDistance = 2600,
                Delay = 0.7,
                DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 4, -- Needs additional precision due to the number being operated on
                    AbsoluteStackValues =
                    {
                        [1] = 1/5,
                        [2] = 1/10
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

function mod.AphroditeProjectileWithDelay(args, delay, turretId)
    game.wait(delay)
    game.MapState[_PLUGIN.guid .. "AphroditeTurretMap"] = game.MapState[_PLUGIN.guid .. "AphroditeTurretMap"] or {}
    local projId = game.CreateProjectileFromUnit(args)
    game.MapState[_PLUGIN.guid .. "AphroditeTurretMap"][projId] = turretId
end

function mod.CreateAphroditeProjectile( id, functionArgs, blinkId )
    local angle = math.rad( math.random(0,360) )
    local offset = game.CalcOffset( angle , functionArgs.SpawnDistance )
    local dropLocation = game.SpawnObstacle({ Name = "InvisibleTarget", DestinationId = id })
    local angle_reverse = math.deg(angle) + 180
    game.wait( functionArgs.Delay )
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
    game.PlaySound({ Name = "/Leftovers/SFX/AuraPerfectThrow", Id = dropLocation, ManagerCap = 46 })
    game.wait( 0.4 )
    game.SetAnimation({ Name = "BlinkTrailAphroditeTargetFast", DestinationId = blinkId})
    --IncrementTableValue( SessionState, "ArtemisCastProjectiles" )
    game.thread(game.DestroyOnDelay, {dropLocation}, 0.1)
end

function mod.StartAphroditeBlink( args )
    game.MapState[_PLUGIN.guid .. "AphroditeTurretMap"] = game.MapState[_PLUGIN.guid .. "AphroditeTurretMap"] or {}
    if not game.IsEmpty(game.MapState.BlinkDropTrail) then
        for id, ids in pairs(game.MapState.BlinkDropTrail) do
            -- game.SetAnimation({ Name = "ProjectileLightningBallEnd", DestinationId = id , DataProperties = {Duration = 0.2}})
            game.thread(game.DestroyOnDelay, { id }, 0.1 )
        end
        game.MapState.BlinkDropTrail = {}
    end
    local initialId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
    -- local angle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
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
        game.wait(0.25, "BlinkTrailPresentation")
        local distance = game.GetDistance({ Id = blinkIds [#blinkIds], DestinationId = game.CurrentRun.Hero.ObjectId })
        
        if distance > 0 then
            local targetId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            local targetProjId = game.SpawnObstacle({ Name = "BlankObstacle", DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
            local angle = game.GetAngleBetween({ DestinationId = targetId, Id = blinkIds [#blinkIds] })
            table.insert( blinkIds, targetId )
            game.SetAnimation({ Name = "BlinkTrailAphroditeTarget", DestinationId = blinkIds [#blinkIds - 1]})
            game.thread(game.DestroyOnDelay, { blinkIds [#blinkIds - 1] }, 1.2)
            -- game.CreateAnimationsBetween({
            --     Animation = "BlinkGhostTrail_AphroditeFx", DestinationId = blinkIds [#blinkIds], Id = blinkIds [#blinkIds - 1],
            --     Stretch = true, UseZLocation = false})
            game.thread(mod.CreateAphroditeProjectile, prevProj, args, blinkIds [#blinkIds - 1])
            prevProj = targetProjId
            -- angle = game.GetAngle({ Id = game.CurrentRun.Hero.ObjectId })
        end
    end
    game.wait(0.25, "BlinkTrailPresentation")
    game.SetAnimation({ Name = "BlinkTrailAphroditeTarget", DestinationId = blinkIds [#blinkIds]})
    game.thread(game.DestroyOnDelay, { blinkIds [#blinkIds] }, 1.1)
    game.thread(mod.CreateAphroditeProjectile, prevProj, args, blinkIds [#blinkIds])
    -- game.thread(mod.AphroditeProjectileWithDelay,
    --     { Name = "FamiliarLinkLaser", Id = game.CurrentRun.Hero.ObjectId, DestinationId = unitId, DamageMultiplier = args.DamageMultiplier,  }
    -- , 0.4)
    if game.MapState.BlinkDropTrail then
        game.MapState.BlinkDropTrail[ initialId ] = nil
    end
    print("blink id count", #blinkIds)
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
    -- Destroy({ Id = finalAnchor })
end