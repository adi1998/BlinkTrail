local playerProjectilesFile = rom.path.combine(rom.paths.Content,"Game\\Projectiles\\PlayerProjectiles.sjson")

sjson.hook(playerProjectilesFile,function (data)
    for index, projectile in ipairs(data.Projectiles) do
        if projectile.Name == "ProjectileHeraOmega" then
            local newentry = game.DeepCopyTable(projectile)
            newentry.Name = "BlinkTrail" .. projectile.Name
            newentry.Thing.Graphic = "HeraBlinkTrailProjectileAnim"
            newentry.DetonateFx = "HeraBlinkTrailCastDetonate"
            newentry.StartDelay = 0.4
            newentry.Thing.Tallness = 10
            newentry.Thing.Points = {
                {
					X = -200,
					Y = 90,
				},
				{
					X = -200,
					Y = -90,
				},
				{
					X = 200,
					Y = -90,
				},
				{
					X = 200,
					Y = 90,
				}
            }
            table.insert(data.Projectiles,newentry)
            return
        end
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