-- gods.CreateBoon({
--     internalBoonName = "HeraBlinkTrailBoon",
--     isLegendary = false,
--     Elements = {"Air"},
--     characterName = "Hera",
--     addToExistingGod = true,

--     BlockStacking = false,
--     displayName = "Sworn Blink",
--     description = "Creates small rifts from the blink trail upto {#BoldFormatGraft}4 times",
--     StatLines = {"HeraRiftDamageStatDisplay1"},
--     ExtractValues = 
--     {
--         {
--             Key = "ReportedMultiplier",
--             ExtractAs = "Damage",
--             Format = "MultiplyByBase",
--             BaseType = "Projectile",
--             BaseName = "ProjectileHeraOmega",
--             BaseProperty = "Damage",
--         },
--     },
--     RarityLevels =
--     {
--         Common =
--         {
--             Multiplier = 1.0,
--         },
--         Rare =
--         {
--             Multiplier = 1.25,
--         },
--         Epic =
--         {
--             Multiplier = 1.5,
--         },
--         Heroic =
--         {
--             Multiplier = 1.75,
--         }
--     },
-- })

function mod.CheckBlinkTrailProjectile()
    if true then
        game.MapState[_PLUGIN.guid .. "BlinkTrailBoon"] = true
        local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
        local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.08
        local startTime = game._worldTime
        local maxProjectiles = 4
        local currentProjectiles = 0
        while currentProjectiles < maxProjectiles and game.MapState[_PLUGIN.guid .. "BlinkTrailBoon"] and (game._worldTime - startTime) < waitPeriod do
            
            game.CreateProjectileFromUnit({ Name = "BlinkTrailProjectileHeraOmega", Id = game.CurrentRun.Hero.ObjectId, DamageMultiplier = {
                BaseValue = 1,
                DecimalPlaces = 4, -- Needs additional precision due to the number being operated on
                AbsoluteStackValues = 
                {
                    [1] = 0.25,
                    [2] = 0.125,
                    [3] = 10/120,
                },
            }})
            currentProjectiles = currentProjectiles + 1
            game.wait(0.15, "BlinkTrailBoon")
        end
        game.MapState[_PLUGIN.guid .. "BlinkTrailBoon"] = false
    end
end

modutil.mod.Path.Wrap("WeaponBlinkFunction",function (base,...)
    base(...)
    game.thread( mod.CheckBlinkTrailProjectile )
end)

modutil.mod.Path.Wrap("TerminateBlinkTrail", function (base,...)
    game.MapState[_PLUGIN.guid .. "BlinkTrailBoon"] = false
    base(...)
end)

modutil.mod.Path.Wrap("SetupMap", function (base,...)
    LoadPackages({Name = _PLUGIN.guid .. "zerp-BlinkTrail"})
    base(...)
end)