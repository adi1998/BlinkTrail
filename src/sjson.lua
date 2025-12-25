local playerProjectilesFile = rom.path.combine(rom.paths.Content,"Game\\Projectiles\\PlayerProjectiles.sjson")

sjson.hook(playerProjectilesFile,function (data)
    local newdata = {}
    for index, projectile in ipairs(data.Projectiles) do
        if projectile.Name == "ProjectileHeraOmega" then
            local newentry = game.DeepCopyTable(projectile)
            newentry.Name = "BlinkTrail" .. projectile.Name
            newentry.Thing.Graphic = "HeraBlinkTrailProjectileAnimasasd"
            newentry.DetonateFx = "HeraBlinkTrailCastDetonateasdas"
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
        end
    end
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
            table.insert(newdata, newentry)
        end
    end
    for index, value in ipairs(newdata) do
        table.insert(data.Projectiles, value)
    end
end)

local melHeraVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Hera_VFX.sjson")

sjson.hook(melHeraVfxFile, function (data)
    local heraBlinkFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\Melinoe_Hera_VFX.sjson")
    local fileHandle = io.open(heraBlinkFile,"r")
    local heraBlinkContent = fileHandle:read("*a")
    local heraBlinkTable = sjson.decode(heraBlinkContent)
    for key, value in pairs(heraBlinkTable.Animations) do
        table.insert(data.Animations, value)
    end
end)

local melZeusVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Zeus_VFX.sjson")

sjson.hook(melZeusVfxFile, function (data)
    local heraBlinkFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\Melinoe_Zeus_VFX.sjson")
    local fileHandle = io.open(heraBlinkFile,"r")
    local heraBlinkContent = fileHandle:read("*a")
    local heraBlinkTable = sjson.decode(heraBlinkContent)
    for key, value in pairs(heraBlinkTable.Animations) do
        table.insert(data.Animations, value)
    end
end)

local melPoseidonVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Poseidon_VFX.sjson")

sjson.hook(melPoseidonVfxFile, function (data)
    local heraBlinkFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\Melinoe_Poseidon_VFX.sjson")
    local fileHandle = io.open(heraBlinkFile,"r")
    local heraBlinkContent = fileHandle:read("*a")
    local heraBlinkTable, pos, msg = sjson.decode(heraBlinkContent)
    for key, value in pairs(heraBlinkTable.Animations) do
        print("POseidon hook", value.Name)
        table.insert(data.Animations, value)
    end
end)

local melHephVfxFile = rom.path.combine(rom.paths.Content,"Game\\Animations\\Melinoe_Hephaestus_VFX.sjson")

sjson.hook(melHephVfxFile, function (data)
    local heraBlinkFile = rom.path.combine(rom.paths.plugins(), _PLUGIN.guid .. "\\Melinoe_Heph_VFX.sjson")
    local fileHandle = io.open(heraBlinkFile,"r")
    local heraBlinkContent = fileHandle:read("*a")
    local heraBlinkTable, pos, msg = sjson.decode(heraBlinkContent)
    for key, value in pairs(heraBlinkTable.Animations) do
        print("heph hook", value.Name)
        table.insert(data.Animations, value)
    end
end)

local traitTextEnFile = rom.path.combine(rom.paths.Content, "Game\\Text\\en\\TraitText.en.sjson")

sjson.hook(traitTextEnFile, function (data)
    local traitTextOrder = {
        "Id",
        "InheritFrom",
        "DisplayName",
        "Description",
    }
    local traitTextList = {
        {
            Id = "HephMineBlastBoonStatDisplay",
            InheritFrom = "BaseStatLine",
            DisplayName = "{!Icons.Bullet}{#PropertyFormat}Mine Damage:",
            Description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
        }
    }
    for index, value in ipairs(traitTextList) do
        table.insert(data.Texts,sjson.to_object(value,traitTextOrder))
    end
end)