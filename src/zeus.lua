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
            Multiplier = 1.5,
        },
        Epic =
        {
            Multiplier = 2,
        },
        Heroic =
        {
            Multiplier = 2.5,
        }
    },
    ExtraFields =
    {
        [_PLUGIN.guid .. "OnSprintAction"] = {
            FunctionName = _PLUGIN.guid .. "." .. "StartZeusBlink",
            FunctionArgs =
            {
                ProjectileName = "ProjectileZeusSpark",
                DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 4, -- Needs additional precision due to the number being operated on
                    AbsoluteStackValues =
                    {
                        [1] = 0.5,
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

function mod.StartZeusBlink( args )

end