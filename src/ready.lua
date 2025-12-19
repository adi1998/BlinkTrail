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

function mod.dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. mod.dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function mod.CheckBlinkTrailProjectile()
    if false then
        game.MapState[_PLUGIN.guid .. "BlinkTrailBoon"] = true
        local nextClipRegenTime  = game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "ClipRegenInterval" }) or 0
        local waitPeriod = nextClipRegenTime + (game.GetWeaponDataValue({ Id = game.CurrentRun.Hero.ObjectId, WeaponName = "WeaponBlink", Property = "BlinkDuration" }) or 0) - 0.08
        local startTime = game._worldTime
        local maxProjectiles = 5
        local currentProjectiles = 0
        local location = GetLocation({ Id = CurrentRun.Hero.ObjectId })
        location.X = 0
        location.Y = 0
        local fireFromId = SpawnObstacle({ Name = "InvisibleTarget", DestinationId = CurrentRun.Hero.ObjectId })
        local angle = GetAngle({ Id = CurrentRun.Hero.ObjectId })
        game.wait(0.12, "BlinkTrailBoon")
        while currentProjectiles < maxProjectiles and game.MapState[_PLUGIN.guid .. "BlinkTrailBoon"] and (game._worldTime - startTime) < waitPeriod do
            local newlocation = GetLocation({ Id = CurrentRun.Hero.ObjectId })
            print("new location", mod.dump(newlocation))
            print("old location", mod.dump(location))
            if not (location.X == newlocation.X and location.Y == newlocation.Y) then
                game.CreateProjectileFromUnit({ Name = "BlinkTrailProjectileHeraOmega", Id = game.CurrentRun.Hero.ObjectId, Angle = angle, FireFromId = fireFromId, DamageMultiplier = {
                    BaseValue = 1,
                    DecimalPlaces = 4, -- Needs additional precision due to the number being operated on
                    AbsoluteStackValues = 
                    {
                        [1] = 0.25,
                        [2] = 0.125,
                        [3] = 10/120,
                    },
                }})
                location = newlocation
                Destroy({Id = fireFromId})
                fireFromId = SpawnObstacle({ Name = "InvisibleTarget", DestinationId = CurrentRun.Hero.ObjectId })
                angle = GetAngle({ Id = CurrentRun.Hero.ObjectId })
                game.wait(0.17, "BlinkTrailBoon")
            end
            currentProjectiles = currentProjectiles + 1
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

-- modutil.mod.Path.Wrap("StartBlinkTrailPresentation",function (base, ...)
-- end)

modutil.mod.Path.Wrap("ClearBlinkAlpha", function (base,triggerArgs)
    if not triggerArgs.PostFire then
        game.MapState[_PLUGIN.guid .. "BlinkTrailBoon"] = false
    end
    base(triggerArgs)
end)