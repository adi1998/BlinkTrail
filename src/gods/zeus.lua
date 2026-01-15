gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "ZeusBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "AirBoon",
    },
    characterName = "Zeus",
    addToExistingGod = { boonPosition = 5 },
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Thunder Blink",
    description = "Creates chain lightning from your dash trail.",
    StatLines = {
        "LightningDamageStatDisplay1",
        "BlinkTrailReserveManaStatDisplay2",
    },
    boonIconPath = _PLUGIN.guid .. "\\Icons\\Zeus_Blink",
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBase",
            BaseType = "Projectile",
            BaseName = "BlinkTrailZeusSpark",
            BaseProperty = "Damage",
        },
        {
            External = true,
            BaseType = "ProjectileBase",
            BaseName = "BlinkTrailZeusSpark",
            BaseProperty = "NumJumps",
            Format = "TotalTargets",
            ExtractAs = "Bounces",
            SkipAutoExtract = true,
        },
        {
            Key = "ReportedManaReservationCost",
            ExtractAs = "TooltipManaReservation",
        }
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
        },
        Perfect =
        {
            Multiplier = 3.5,
        }
    },
    ExtraFields =
    {
        [_PLUGIN.guid .. "OnSprintAction"] = {
            FunctionName = _PLUGIN.guid .. "." .. "StartZeusBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailZeusSpark",
                DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 4, -- Needs additional precision due to the number being operated on
                    AbsoluteStackValues =
                    {
                        [1] = 0.5,
                        [2] = 0.3
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
        SetupFunction =
		{
			Name = "TraitReserveMana",
			Args =
			{
				Name = gods.GetInternalBoonName("AphroditeBlinkTrailBoon"),
				ManaReservationCost = 30,
				ReportValues =
				{
					ReportedManaReservationCost = "ManaReservationCost",
				}
			},
		},
        OnExpire =
		{
			FunctionName = "TraitUnreserveMana",
			FunctionArgs = { Name = gods.GetInternalBoonName("AphroditeBlinkTrailBoon") },
		},
    }
})