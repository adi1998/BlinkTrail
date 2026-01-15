gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "AphroditeBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "WaterBoon",
    },
    characterName = "Aphrodite",
    addToExistingGod = { boonPosition = 5 },
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Flutter Blink",
    description = "Fires large arrows along targets mades by your dash trail.",
    StatLines = {"SupportFireDamageDisplay2"},
    boonIconPath = _PLUGIN.guid .. "\\Icons\\Aphrodite_Blink",
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
        },
        Perfect =
        {
            Multiplier = 10/5,
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
                Delay = 0.6,
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
