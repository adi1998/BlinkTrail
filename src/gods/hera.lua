gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "HeraBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "FireBoon",
    },
    characterName = "Hera",
    addToExistingGod = { boonPosition = 5 },
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Sworn Blink",
    description = "Creates a rift in the shape of your dash trail.",
    StatLines = {"HeraRiftDamageStatDisplay1"},
    boonIconPath = _PLUGIN.guid .. "\\Icons\\Hera_Blink",
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
        },
        Perfect =
        {
            Multiplier = 2.25,
        }
    },
    ExtraFields =
    {
        [_PLUGIN.guid .. "OnSprintAction"] = {
            FunctionName = _PLUGIN.guid .. "." .. "StartHeraBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailProjectileHeraOmega",
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
                FunctionName = _PLUGIN.guid .. "." .. "CheckNoExistingBlinkBoons",
                FunctionArgs = {}
            },
        },
    }
})
