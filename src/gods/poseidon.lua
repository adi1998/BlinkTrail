gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "PoseidonBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "WaterBoon",
    },
    characterName = "Poseidon",
    addToExistingGod = { boonPosition = 5 },
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Wave Blink",
    description = "Creates outward waves from your dash trail.",
    StatLines = {
        "PoseidonOmegaProjectileDamageStatDisplay1",
        "BlinkTrailReserveManaStatDisplay2",
    },
    boonIconPath = _PLUGIN.guid .. "\\Icons\\Poseidon_Blink",
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBase",
            BaseType = "Projectile",
            BaseName = "PoseidonBlinkWave",
            BaseProperty = "Damage",
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
            Multiplier = 40/30,
        },
        Epic =
        {
            Multiplier = 50/30,
        },
        Heroic =
        {
            Multiplier = 60/30,
        },
        Perfect =
        {
            Multiplier = 80/30,
        }
    },
    ExtraFields =
    {
        [_PLUGIN.guid .. "OnSprintAction"] = {
            FunctionName = _PLUGIN.guid .. "." .. "StartPoseidonBlink",
            FunctionArgs =
            {
                ProjectileName = "PoseidonBlinkWave",
                DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 4, -- Needs additional precision due to the number being operated on
                    AbsoluteStackValues =
                    {
                        [1] = 5/30,
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
                FunctionArgs = {
                    Except = "PoseidonBlinkTrailBoon"
                }
            },
        },
        SetupFunction =
		{
			Name = "TraitReserveMana",
			Args =
			{
				Name = gods.GetInternalBoonName("AphroditeBlinkTrailBoon"),
				ManaReservationCost = 20,
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