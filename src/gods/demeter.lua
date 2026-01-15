gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "DemeterBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "EarthBoon",
    },
    characterName = "Demeter",
    addToExistingGod = { boonPosition = 5 },
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Crystal Blink",
    description = "Create crystal beams along your dash trail.",
    StatLines = {
        "DemeterCrystalBeamStatDisplay",
        "BlinkTrailReserveManaStatDisplay2",
    },
    boonIconPath = _PLUGIN.guid .. "\\Icons\\Demeter_Blink",
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBase",
            BaseType = "Projectile",
            BaseName = "BlinkTrailDemeterProjectileTracking",
            BaseProperty = "Damage",
        },
        {
            ExtractAs = "Fuse",
            SkipAutoExtract = true,
            External = true,
            BaseType = "ProjectileBase",
            BaseName = "BlinkTrailDemeterProjectileTracking",
            BaseProperty = "Fuse",
            DecimalPlaces = 2,
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
            Multiplier = 2.0,
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
            FunctionName = _PLUGIN.guid .. "." .. "StartDemeterBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailDemeterProjectileTracking",
                DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 4, -- Needs additional precision due to the number being operated on
                    AbsoluteStackValues =
                    {
                        [1] = 0.5,
                        [2] = 0.3,
                        [3] = 0.2,
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
				Name = gods.GetInternalBoonName("DemeterBlinkTrailBoon"),
				ManaReservationCost = 15,
				ReportValues =
				{
					ReportedManaReservationCost = "ManaReservationCost",
				}
			},
		},
        OnExpire =
		{
			FunctionName = "TraitUnreserveMana",
			FunctionArgs = { Name = gods.GetInternalBoonName("DemeterBlinkTrailBoon") },
		},
    }
})
