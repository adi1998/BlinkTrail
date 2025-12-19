gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "ZeusBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "AirBoon",
    },
    characterName = "Zeus",
    addToExistingGod = true,

    BlockStacking = false,
    displayName = "Thunder Blink",
    description = "Creates chain lightning from your dash trail",
    StatLines = {"LightningDamageStatDisplay1"},
    boonIconPath = "GUI\\Screens\\BoonIcons\\Zeus_28",
    reuseBaseIcons = true,
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBase",
            BaseType = "Projectile",
            BaseName = "BlinkTrailProjectileHeraOmega",
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
            FunctionName = _PLUGIN.guid .. "." .. "StartZeusBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailProjectileZeus",
                DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 4, -- Needs additional precision due to the number being operated on
                    AbsoluteStackValues =
                    {
                        [1] = 0.25,
                        [2] = 0.125,
                        [3] = 10/120,
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
                FunctionName = _PLUGIN.guid .. "." .. "CheckExistingBlinkBoons",
                FunctionArgs = {}
            },
        },
    }
})