local traitRequirements = {
    RandomStatusBoon = {
        OneFromEachSet =
		{
			[3] = {  "WeakPotencyBoon", "WeakVulnerabilityBoon", "HighHealthOffenseBoon", "FocusRawDamageBoon", gods.GetInternalBoonName("AphroditeBlinkTrailBoon") },
		},
    },

    DoubleExManaBoon = {
        OneFromEachSet = {
            [3] = { "DoubleStrikeChanceBoon", "ApolloCastAreaBoon", "ApolloBlindBoon", "ApolloExCastBoon", gods.GetInternalBoonName("ApolloBlinkTrailBoon") },
        }
    },

    InstantRootKill = {
        OneFromEachSet = {
            [3] = { "SlowExAttackBoon", "RootDurationBoon", "CastAttachBoon", gods.GetInternalBoonName("DemeterBlinkTrailBoon") },
        }
    },

    WeaponUpgradeBoon = {
        OneFromEachSet = {
            [3] = { "MassiveDamageBoon", "AntiArmorBoon", "MassiveKnockupBoon", gods.GetInternalBoonName("HephaestusBlinkTrailBoon") },
        }
    },

    AllElementalBoon = {
        OneFromEachSet = {
            [3] = { "DamageSharePotencyBoon", "SpawnCastDamageBoon", gods.GetInternalBoonName("HeraBlinkTrailBoon")},
        }
    },

    BurnSprintBoon = {
        OneFromEachSet = {
            [3] = { "CastProjectileBoon", "FireballManaSpecialBoon", gods.GetInternalBoonName("HestiaBlinkTrailBoon") },
        }
    },

    AmplifyConeBoon = {
        OneFromEachSet = {
            [2] = { "PoseidonSprintBoon", "PoseidonManaBoon", "PoseidonExCastBoon", gods.GetInternalBoonName("PoseidonBlinkTrailBoon") },
        }
    },

    LightningDebuffGeneratorBoon = {
        OneOf = { "FocusLightningBoon", gods.GetInternalBoonName("ZeusBlinkTrailBoon") }
    },

    SpawnKillBoon = {
        OneFromEachSet = {
            [2] = { "FocusLightningBoon",  "ZeusManaBoltBoon", "CastAnywhereBoon", "BoltRetaliateBoon", gods.GetInternalBoonName("ZeusBlinkTrailBoon") },
        }
    },

    DoubleBloodDropBoon = {
        OneFromEachSet = {
            [2] = { "AresManaBoon", "BloodDropRevengeBoon", "RendBloodDropBoon", gods.GetInternalBoonName("AresBlinkTrailBoon") },
        }
    },

    ManaShieldBoon = {
        OneFromEachSet = {
            { "DamageShareRetaliateBoon", "LinkedDeathDamageBoon", "DamageSharePotencyBoon", "SpawnCastDamageBoon", "OmegaHeraProjectileBoon", gods.GetInternalBoonName("HeraBlinkTrailBoon") },
            { "MassiveDamageBoon", "AntiArmorBoon", "HeavyArmorBoon", "ArmorBoon", "EncounterStartDefenseBuffBoon", "ManaToHealthBoon", "MassiveKnockupBoon", gods.GetInternalBoonName("HephaestusBlinkTrailBoon") },
        }
    },

    MoneyDamageBoon = {
		OneFromEachSet = {
			{ "HeraWeaponBoon", "HeraSpecialBoon", "HeraCastBoon", "OmegaHeraProjectileBoon", gods.GetInternalBoonName("HeraBlinkTrailBoon") },
			{ "PoseidonWeaponBoon", "PoseidonSpecialBoon", "PoseidonCastBoon", "OmegaPoseidonProjectileBoon", gods.GetInternalBoonName("PoseidonBlinkTrailBoon")  },
			{ "OmegaHeraProjectileBoon", "OmegaPoseidonProjectileBoon", gods.GetInternalBoonName("HeraBlinkTrailBoon"), gods.GetInternalBoonName("PoseidonBlinkTrailBoon") },
		},
	},

    GoodStuffBoon = {
        OneFromEachSet = {
            [3] = { "RoomRewardBonusBoon", "DoubleRewardBoon", "BoonGrowthBoon", "PlantHealthBoon", gods.GetInternalBoonName("DemeterBlinkTrailBoon") },
        }
    },

    PoseidonSplashSprintBoon = {
        OneFromEachSet = {
            [3] = { "ApolloSprintBoon", "PoseidonSprintBoon", gods.GetInternalBoonName("PoseidonBlinkTrailBoon"), gods.GetInternalBoonName("ApolloBlinkTrailBoon") },
        }
    },

    SteamBoon = {
        OneFromEachSet = {
            [2] = { "HestiaWeaponBoon", "HestiaSpecialBoon", "HestiaCastBoon", "HestiaSprintBoon", "FireballManaSpecialBoon", "CastProjectileBoon", gods.GetInternalBoonName("HestiaBlinkTrailBoon") },
        }
    },

    ReboundingSparkBoon = {
        OneFromEachSet = {
            [1] = { "FocusLightningBoon", gods.GetInternalBoonName("ZeusBlinkTrailBoon") },
        }
    },

    LightningVulnerabilityBoon = {
        OneFromEachSet = {
            [2] = { "ZeusWeaponBoon", "ZeusSpecialBoon", "ZeusCastBoon", "ZeusSprintBoon", "BoltRetaliateBoon", "CastAnywhereBoon", gods.GetInternalBoonName("ZeusBlinkTrailBoon") },
        }
    },

    BloodRetentionBoon = {
        OneFromEachSet = {
            [1] = { "AresManaBoon", "BloodDropRevengeBoon", "RendBloodDropBoon", gods.GetInternalBoonName("AresBlinkTrailBoon") },
        }
    },
}

function DeepMergeUptoDepth(base, incoming, depth, currentDepth)
    depth = depth or 0
    currentDepth = currentDepth or 0
    local returnTable = game.DeepCopyTable( base )
    for k, v in pairs( incoming ) do
		if type(v) == "table" and currentDepth<depth then
			if next(v) == nil then
				returnTable[k] = {}
			else
				returnTable[k] = DeepMergeUptoDepth( returnTable[k], v, depth, currentDepth + 1 )
			end
		elseif v == "nil" then
			returnTable[k] = nil
		else
			returnTable[k] = v
		end
	end
    return returnTable
end

game.TraitRequirements = DeepMergeUptoDepth(game.TraitRequirements, traitRequirements, 2)

local traitData = {
    SteamBoon = {
        OnEnemyDamagedAction = {
            ValidProjectiles = {"ProjectileCastFireball", "ProjectileFireball", "HestiaSprintPuddle", "BlinkTrailProjectileHestia", "BlinkTrailProjectileFireHestia" },
        }
    },
    -- DoubleBloodDropBoon = {
    --     BloodDropMultiplier = 3
    -- }
}

game.TraitData = DeepMergeUptoDepth(game.TraitData, traitData, 2)