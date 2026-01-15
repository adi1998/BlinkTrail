gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "HestiaBlinkTrailBoon",
    isLegendary = false,
    InheritFrom =
    {
        "FireBoon",
    },
    characterName = "Hestia",
    addToExistingGod = { boonPosition = 5 },
    requirements = { OneOf = mod.SprintBoons },
    BlockStacking = false,
    displayName = "Flame Blink",
    description = "Spawns lava pools from your dash trail.",
    StatLines = {
        "HestiaLavaPoolStatDisplay",
        "BlinkTrailReserveManaStatDisplay2",
    },
    boonIconPath = _PLUGIN.guid .. "\\Icons\\Hestia_Blink",
    ExtractValues =
    {
        {
            Key = "ReportedMultiplier",
            ExtractAs = "Damage",
            Format = "MultiplyByBase",
            BaseType = "Projectile",
            BaseName = "BlinkTrailProjectileFireHestia",
            BaseProperty = "DamagePerConsecutiveHit",
            DecimalPlaces = 1
        },
        {
            ExtractAs = "Fuse",
            SkipAutoExtract = true,
            External = true,
            BaseType = "ProjectileBase",
            BaseName = "BlinkTrailProjectileFireHestia",
            BaseProperty = "ConsecutiveHitWindow",
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
            Multiplier = 7.5,
        },
        Rare =
        {
            Multiplier = 10,
        },
        Epic =
        {
            Multiplier = 12.5,
        },
        Heroic =
        {
            Multiplier = 15,
        },
        Perfect =
        {
            Multiplier = 20,
        }
    },
    ExtraFields =
    {
        [_PLUGIN.guid .. "OnSprintAction"] = {
            FunctionName = _PLUGIN.guid .. "." .. "StartHestiaBlink",
            FunctionArgs =
            {
                ProjectileName = "BlinkTrailProjectileHestia",
                DamageMultiplier = 1,
            }
        },
        OnProjectileDeathFunction = {
            ValidProjectiles = { "BlinkTrailProjectileHestia" },
            Name = _PLUGIN.guid .. "." .. "CheckHestiaLavaPool",
            Args = {
                ValidProjectileName = "BlinkTrailProjectileHestia",
                ProjectileName = "BlinkTrailProjectileFireHestia",
                DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 2,
                    AbsoluteStackValues = {
                        [1] = 2.5,
                        [2] = 1,
                    }
                },
                ReportValues = { ReportedMultiplier = "DamageMultiplier"},
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
