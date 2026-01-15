gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "ApolloBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "AirBoon",
    },
    characterName = "Apollo",
    addToExistingGod = { boonPosition = 5 },
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Blinding Blink",
    description = "Completely blind enemies caught in your dash trail for {#BoldFormatGraft}{$TooltipData.ExtractData.Duration} Sec{#Prev}.",
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
        },
        Perfect =
        {
            Multiplier = 15/30,
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
