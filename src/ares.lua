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