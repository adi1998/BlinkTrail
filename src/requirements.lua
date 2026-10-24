function MergeUptoDepth(incoming, path)
    path = path or {}
    if incoming.Append then
        for index, value in ipairs(incoming) do
            local target = modutil.mod.IndexArray.Get(game, path)
            if target then
                table.insert(target, value)
            end
        end
    end
    for k, v in pairs( incoming ) do
		if type(v) == "table" then
            local newpath = game.DeepCopyTable(path)
            table.insert(newpath, k)
			MergeUptoDepth( v, newpath )
		end
	end
end

local traitRequirements = {
    RandomStatusBoon = {
        OneFromEachSet =
		{
			[3] = { Append = true, gods.GetInternalBoonName("AphroditeBlinkTrailBoon") },
		},
    },

    DoubleExManaBoon = {
        OneFromEachSet = {
            [3] = { Append = true, gods.GetInternalBoonName("ApolloBlinkTrailBoon") },
        }
    },

    InstantRootKill = {
        OneFromEachSet = {
            [3] = { Append = true, gods.GetInternalBoonName("DemeterBlinkTrailBoon") },
        }
    },

    WeaponUpgradeBoon = {
        OneFromEachSet = {
            [3] = { Append = true, gods.GetInternalBoonName("HephaestusBlinkTrailBoon") },
        }
    },

    AllElementalBoon = {
        OneFromEachSet = {
            [3] = { Append = true, gods.GetInternalBoonName("HeraBlinkTrailBoon")},
        }
    },

    BurnSprintBoon = {
        OneFromEachSet = {
            [3] = { Append = true, gods.GetInternalBoonName("HestiaBlinkTrailBoon") },
        }
    },

    AmplifyConeBoon = {
        OneFromEachSet = {
            [2] = { Append = true, gods.GetInternalBoonName("PoseidonBlinkTrailBoon") },
        }
    },

    LightningDebuffGeneratorBoon = {
        OneOf = { Append = true, gods.GetInternalBoonName("ZeusBlinkTrailBoon") }
    },

    SpawnKillBoon = {
        OneFromEachSet = {
            [2] = { Append = true, gods.GetInternalBoonName("ZeusBlinkTrailBoon") },
        }
    },

    DoubleBloodDropBoon = {
        OneFromEachSet = {
            [2] = { Append = true, gods.GetInternalBoonName("AresBlinkTrailBoon") },
        }
    },

    ManaShieldBoon = {
        OneFromEachSet = {
            { Append = true, gods.GetInternalBoonName("HeraBlinkTrailBoon") },
            { Append = true, gods.GetInternalBoonName("HephaestusBlinkTrailBoon") },
        }
    },

    MoneyDamageBoon = {
		OneFromEachSet = {
			{ Append = true, gods.GetInternalBoonName("HeraBlinkTrailBoon") },
			{ Append = true, gods.GetInternalBoonName("PoseidonBlinkTrailBoon")  },
			{ Append = true, gods.GetInternalBoonName("HeraBlinkTrailBoon"), gods.GetInternalBoonName("PoseidonBlinkTrailBoon") },
		},
	},

    GoodStuffBoon = {
        OneFromEachSet = {
            [3] = { Append = true, gods.GetInternalBoonName("DemeterBlinkTrailBoon") },
        }
    },

    PoseidonSplashSprintBoon = {
        OneFromEachSet = {
            [3] = { Append = true, gods.GetInternalBoonName("PoseidonBlinkTrailBoon"), gods.GetInternalBoonName("ApolloBlinkTrailBoon") },
        }
    },

    SteamBoon = {
        OneFromEachSet = {
            [2] = { Append = true, gods.GetInternalBoonName("HestiaBlinkTrailBoon") },
        }
    },

    ReboundingSparkBoon = {
        OneFromEachSet = {
            [1] = { Append = true, gods.GetInternalBoonName("ZeusBlinkTrailBoon") },
        }
    },

    LightningVulnerabilityBoon = {
        OneFromEachSet = {
            [2] = { Append = true, gods.GetInternalBoonName("ZeusBlinkTrailBoon") },
        }
    },

    BloodRetentionBoon = {
        OneFromEachSet = {
            [1] = { Append = true, gods.GetInternalBoonName("AresBlinkTrailBoon") },
        }
    },

    BloodManaBurstBoon = {
        OneFromEachSet = {
            [1] = { Append = true, gods.GetInternalBoonName("AresBlinkTrailBoon") },
        }
    },

    RendBloodDropBoon = {
        OneOf = { Append = true, gods.GetInternalBoonName("AresBlinkTrailBoon") }
    }
}

MergeUptoDepth(traitRequirements, {"TraitRequirements"})

local traitData = {
    SteamBoon = {
        OnEnemyDamagedAction = {
            ValidProjectiles = { Append = true, "BlinkTrailProjectileHestia", "BlinkTrailProjectileFireHestia" },
        }
    },
    LightningVulnerabilityBoon = {
        AddOutgoingDamageModifiers = {
            ValidProjectiles =
			{
				Append = true,
                "BlinkTrailZeusSpark"
			},
        }
    },
    DoubleBloodDropBoon = {
        StatLines = {
            Append = true,
            "AresIncreasesMoveStrikeSpeedDisplay"
        }
    }
}

MergeUptoDepth(traitData, {"TraitData"})