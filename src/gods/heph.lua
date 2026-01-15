gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "HephaestusBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "FireBoon",
    },
    characterName = "Hephaestus",
    addToExistingGod = { boonPosition = 5 },
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Volcanic Blink",
    description = "Drops mines behind your dash trail.",
    StatLines = {
        "HephMineBlastBoonStatDisplay",
        "BlinkTrailReserveManaStatDisplay2",
    },
    boonIconPath = _PLUGIN.guid .. "\\Icons\\Hephaestus_Blink",
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBase",
            BaseType = "Projectile",
            BaseName = "HephMineBlast",
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
            FunctionName = _PLUGIN.guid .. "." .. "StartHephBlink",
            FunctionArgs =
            {
                ProjectileName = "HephMineBlast",
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
        SetupFunction =
		{
			Name = "TraitReserveMana",
			Args =
			{
				Name = gods.GetInternalBoonName("HephaestusBlinkTrailBoon"),
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
			FunctionArgs = { Name = gods.GetInternalBoonName("HephaestusBlinkTrailBoon") },
		},
    }
})