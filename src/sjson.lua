function mod.readSjson(file,data,key)
    local fileHandle = io.open(file,"r")
    if fileHandle ~= nil then
        local sjsonContent = fileHandle:read("*a")
        local sjsonTable = sjson.decode(sjsonContent)
        for _, value in pairs(sjsonTable[key]) do
            table.insert(data[key], value)
        end
    end
end

local playerProjectilesFile = rom.path.combine(rom.paths.Content,"Game\\Projectiles\\PlayerProjectiles.sjson")

sjson.hook(playerProjectilesFile,function (data)
    local newdata = {}
    for index, projectile in ipairs(data.Projectiles) do
        if projectile.Name == "ProjectileHeraOmega" then
            local newentry = game.DeepCopyTable(projectile)
            newentry.Name = "BlinkTrail" .. projectile.Name
            newentry.Thing.Graphic = "HeraBlinkTrailProjectileAnimasasd"
            newentry.DetonateFx = "HeraBlinkTrailCastDetonateasdas"
            newentry.DetonateSound = nil
            newentry.StartDelay = 0.5
            newentry.Thing.Tallness = 7
            newentry.Thing.Points = {
                {
                    X = -55,
                    Y = 45,
                },
                {
                    X = -55,
                    Y = -45,
                },
                {
                    X = 55,
                    Y = -45,
                },
                {
                    X = 55,
                    Y = 45,
                }
            }
            newentry.Thing.OffsetZ = 30
            table.insert(newdata,newentry)
        elseif projectile.Name == "ProjectileZeusSpark" then
            local newentry = game.DeepCopyTable(projectile)
            newentry.Name = "BlinkTrailZeusSpark"
            newentry.Range = 750
            -- newentry.StartDelay = 1
            table.insert(newdata,newentry)
        elseif projectile.Name == "PoseidonOmegaWave" then
            local newentry = game.DeepCopyTable(projectile)
            newentry.Name = "PoseidonBlinkWave"
            newentry.DetonateFx = "PoseidonBlinkWaveDissipate"
            newentry.Thing.Graphic = "PoseidonBlinkWaveFxIn"
            newentry.Range = 300
            newentry.Damage = 30
            newentry.Thing.Points = {
                {
                    X = 20,
                    Y = 140,
                },
                {
                    X = 20,
                    Y = 140,
                },
                {
                    X = -50,
                    Y = -180,
                },
                {
                    X = -50,
                    Y = 180,
                }
            }
            table.insert(newdata, newentry)
        elseif projectile.Name == "AresProjectile" then
            local newentry = game.DeepCopyTable(projectile)
            newentry.Name = "BlinkTrailProjectileAres"
            newentry.Speed = 200
            newentry.MaxAdjustRate = 200
            newentry.DamageRadius = 180
            newentry.Thing.Graphic = "AresBlinkBladeSpinIn"
            newentry.Thing.AttachedAnim = "AresBlinkBladeSpinShadow"
            newentry.ImpactFx = nil
            table.insert(newdata,newentry)
        elseif projectile.Name == "ApolloCast" then
            local newentry = game.DeepCopyTable(projectile)
            newentry.Name = "BlinkTrailProjectileApollo"
            newentry.Damage = 1
            newentry.Fuse = 0.25
            newentry.TotalFuse = 0.75
            newentry.DamageRadius = 250
            newentry.DetonateFx = "ApolloAoEStrikeBlink"
            newentry.DissipateFx = "ApolloAoEGroundBurnLongBlink"
            newentry.ImpactFx = nil
            newentry.Thing.Graphic = "ApolloAoECircleBlink"
            newentry.Thing.Points = {
                {
					X = 16,
					Y = 8,
				},
				{
					X = 16,
					Y = -8,
				},
				{
					X = -16,
					Y = -8,
				},
				{
					X = -16,
					Y = 8,
				},
            }
            table.insert(newdata,newentry)
        elseif projectile.Name == "ArtemisCastVolley" then
            local newentry = game.DeepCopyTable(projectile)
            newentry.Name = "BlinkTrailProjectileAphrodite"
            newentry.Thing.Graphic = "AphroditeBlinkTrailArrow"
            newentry.Thing.Color = {
                Red = 1.0,
				Green = 0.2,
				Blue = 0.63,
				Opacity = 1.0,
            }
            table.insert(newdata,newentry)
        end
    end

    local projectileFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\projectile\\Projectiles.sjson")
    mod.readSjson(projectileFile, data, "Projectiles")
    for index, value in ipairs(newdata) do
        table.insert(data.Projectiles, value)
    end
end)

local biomeOProjectileFile = rom.path.combine(rom.paths.Content, "Game\\Projectiles\\Enemy_BiomeO_Projectiles.sjson")

sjson.hook(biomeOProjectileFile, function (data)
    local newdata = {}
    for index, projectile in ipairs(data.Projectiles) do
        if projectile.Name == "GunBombWeapon" then
            local newentry = game.DeepCopyTable(projectile)
            newentry.Name = "HephMineBlast"
            newentry.DamageRadius = 230
            newentry.Damage = 40
            newentry.DetonateFx = "HephMassiveHit"
            newentry.DetonateSound = nil
            newentry.Effects[1].Name = "OnHitStun"
            newentry.Effects[1].DisableAttack = true
            newentry.Effects[1].FrontFx = "null"
            table.insert(newdata, newentry)
        end
    end
    for index, value in ipairs(newdata) do
        table.insert(data.Projectiles, value)
    end
end)

local enemyGeneralProjectileFile = rom.path.combine(rom.paths.Content, "Game\\Projectiles\\Enemy_General_Projectiles.sjson")

sjson.hook(enemyGeneralProjectileFile, function (data)
    local newdata = {}
    for index, projectile in ipairs(data.Projectiles) do
        if projectile.Name == "DevotionHestia" then
            local newentry = game.DeepCopyTable(projectile)
            newentry.Name = "BlinkTrailProjectileHestia"
            newentry.Damage = 15
            newentry.SpawnOnDetonate = "BlinkTrailProjectileFireHestia"
            newentry.Range = 300
            newentry.Speed = 600
            newentry.SpawnCap = 4
		    newentry.FizzleOldSpawnsOnDetonate = true
            table.insert(newdata,newentry)
        elseif projectile.Name == "DevotionHestiaFire" then
            local newentry = game.DeepCopyTable(projectile)
            newentry.Name = "BlinkTrailProjectileFireHestia"
            newentry.TotalFuse = 3
            table.insert(newdata,newentry)
        end
    end
    for index, value in ipairs(newdata) do
        table.insert(data.Projectiles, value)
    end
end)

local melHeraVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Hera_VFX.sjson")

sjson.hook(melHeraVfxFile, function (data)
    local blinkAnimFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\vfx\\Melinoe_Hera_VFX.sjson")
    local fileHandle = io.open(blinkAnimFile,"r")
    if fileHandle ~= nil then
        local heraBlinkContent = fileHandle:read("*a")
        local heraBlinkTable = sjson.decode(heraBlinkContent)
        for key, value in pairs(heraBlinkTable.Animations) do
            table.insert(data.Animations, value)
        end
    end
end)

local melZeusVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Zeus_VFX.sjson")

sjson.hook(melZeusVfxFile, function (data)
    local blinkAnimFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\vfx\\Melinoe_Zeus_VFX.sjson")
    mod.readSjson(blinkAnimFile,data,"Animations")
end)

local melPoseidonVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Poseidon_VFX.sjson")

sjson.hook(melPoseidonVfxFile, function (data)
    local blinkAnimFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\vfx\\Melinoe_Poseidon_VFX.sjson")
    mod.readSjson(blinkAnimFile,data,"Animations")
end)

local melHestiaVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Hestia_VFX.sjson")

sjson.hook(melHestiaVfxFile, function (data)
    local blinkAnimFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\vfx\\Melinoe_Hestia_VFX.sjson")
    mod.readSjson(blinkAnimFile,data,"Animations")
end)

local melHephVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Hephaestus_VFX.sjson")

sjson.hook(melHephVfxFile, function (data)
    local blinkAnimFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\vfx\\Melinoe_Hephaestus_VFX.sjson")
    mod.readSjson(blinkAnimFile,data,"Animations")
end)

local melAresVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Ares_VFX.sjson")

sjson.hook(melAresVfxFile, function (data)
    local blinkAnimFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\vfx\\Melinoe_Ares_VFX.sjson")
    mod.readSjson(blinkAnimFile,data,"Animations")
end)

local melApolloVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Apollo_VFX.sjson")

sjson.hook(melApolloVfxFile, function (data)
    local blinkAnimFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\vfx\\Melinoe_Apollo_VFX.sjson")
    mod.readSjson(blinkAnimFile,data,"Animations")
end)

local melDemeterVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Demeter_VFX.sjson")

sjson.hook(melDemeterVfxFile, function (data)
    local blinkAnimFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\vfx\\Melinoe_Demeter_VFX.sjson")
    mod.readSjson(blinkAnimFile,data,"Animations")
end)

local melAphroditeVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Aphrodite_VFX.sjson")

sjson.hook(melAphroditeVfxFile, function (data)
    local blinkAnimFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\vfx\\Melinoe_Aphrodite_VFX.sjson")
    mod.readSjson(blinkAnimFile,data,"Animations")
end)

local traitTextOrder = {
    "Id",
    "InheritFrom",
    "DisplayName",
    "Description",
}

local traitTextEnFile = rom.path.combine(rom.paths.Content, "Game\\Text\\en\\TraitText.en.sjson")

sjson.hook(traitTextEnFile, function (data)

    local traitTextList = {
        {
            Id = "HephMineBlastBoonStatDisplay",
            InheritFrom = "BaseStatLine",
            DisplayName = "{!Icons.Bullet}{#PropertyFormat}Mine Damage:",
            Description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
        },
        {
            Id = "HestiaLavaPoolStatDisplay",
            InheritFrom = "BaseStatLine",
            DisplayName = "{!Icons.Bullet}{#PropertyFormat}Lava Damage:",
            Description = "{#UpgradeFormat}{$TooltipData.StatDisplay1} {#Prev}{#ItalicFormat}(every {$TooltipData.ExtractData.Fuse} Sec.)",
        },
        {
            Id = "ApolloBlinkCooldownStatDisplay",
            InheritFrom = "BaseStatLine",
            DisplayName = "{!Icons.Bullet}{#PropertyFormat}Blind cooldown per foe:",
            Description = "{#UpgradeFormat}{$TooltipData.StatDisplay1} Sec.",
        },
        {
            Id = "DemeterCrystalBeamStatDisplay",
            InheritFrom = "BaseStatLine",
            DisplayName = "{!Icons.Bullet}{#PropertyFormat}Beam damage:",
            Description = "{#UpgradeFormat}{$TooltipData.StatDisplay1} {#Prev}{#ItalicFormat}(every {$TooltipData.ExtractData.Fuse} Sec.)"
        },
    }
    for index, value in ipairs(traitTextList) do
        table.insert(data.Texts, sjson.to_object(value, traitTextOrder))
    end
end)

-- local helpTextFile = rom.path.combine(rom.paths.Content, "Game/Text/en/HelpText.en.sjson")

-- sjson.hook(helpTextFile, function (data)
--     local helpTextList = {
--         {
--             Id = "BlinkTrailProjectileHeraOmega",
--             DisplayName = "Sworn Blink"
--         },
--         {
--             Id = "PoseidonBlinkWave",
--             DisplayName = "Wave Blink"
--         },
--         {
--             Id = "HephMineBlast",
--             DisplayName = "Volcanic Blink"
--         },
--         {
--             Id = "BlinkTrailProjectileHestia",
--             DisplayName = "Flame Blink"
--         },
--         {
--             Id = "BlinkTrailProjectileFireHestia",
--             DisplayName = "Flame Blink Lava"
--         },
--         {
--             Id = "BlinkTrailProjectileAres",
--             DisplayName = "Bloody Blink"
--         },
--         {
--             Id = "BlinkTrailZeusSpark",
--             DisplayName = "Thunder Blink"
--         },
--     }
--     for index, value in ipairs(helpTextList) do
--         table.insert(data.Texts, sjson.to_object(value, traitTextOrder))
--     end
-- end)