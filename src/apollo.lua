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

    BlockStacking = false,
    displayName = "Blinding Blink",
    description = "Completely blind enemies caught in your dash trail for {#BoldFormatGraft}{$TooltipData.ExtractData.Duration} Sec {#Prev}.",
    StatLines = {"ApolloBlinkCooldownStatDisplay"},
    boonIconPath = "GUI\\Screens\\BoonIcons\\Apollo_28",
    reuseBaseIcons = true,
    ExtractValues =
    {
        {
            Key = "ReportedCooldown",
            ExtractAs = "Cooldown",
            SkipAutoExtract = true,
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
            FunctionName = _PLUGIN.guid .. "." .. "StartHeraBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailProjectileHeraOmega",
                DamageMultiplier = 0.02,
            }
        },
        OnEnemyDamagedAction = 
        {
            ValidProjectiles = {"BlinkTrailProjectileApollo", "BlinkTrailProjectileHeraOmega"},
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
    
end

function mod.SuperBlind(enemy, functionArgs, triggerArgs)
    game.CurrentRun.CurrentRoom[_PLUGIN.guid .. "InvisTargetTable"] = game.CurrentRun.CurrentRoom[_PLUGIN.guid .. "InvisTargetTable"] or {}
    local invisTargetTable = game.CurrentRun.CurrentRoom[_PLUGIN.guid .. "InvisTargetTable"]
    invisTargetTable[enemy.ObjectId] = game.SpawnObstacle({ Name = "InvisibleTarget", Group = "Scripting", DestinationId = game.CurrentRun.Hero.ObjectId })
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
    if not game.CheckCooldown( "ApolloSuperBlind" .. tostring(enemy.ObjectId), functionArgs.Cooldown ) then
		return
	end
    game.thread(mod.SuperBlind, enemy, functionArgs, triggerArgs)
end