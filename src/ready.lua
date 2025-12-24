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

game.OverwriteTableKeys( game.ProjectileData, {
    BlinkTrailProjectileHeraOmega =
    {
        InheritFrom = { "HeraColorProjectile" },
    },
    BlinkTrailZeusSpark =
    {
        InheritFrom = { "ZeusColorProjectile" },
    },
    PoseidonBlinkWave =
    {
        InheritFrom = { "PoseidonColorProjectile" },
    },
    HephMineBlast =
    {
        InheritFrom = { "HephaestusColorProjectile" }
    }
})

game.ConcatTableValues(game.WeaponSets.OlympianProjectileNames,{
    "BlinkTrailProjectileHeraOmega",
    "BlinkTrailZeusSpark",
    "PoseidonBlinkWave",
    "HephMineBlast"
})

game.OverwriteTableKeys( game.ScreenData.RunClear.DamageSourceMap, {
    BlinkTrailProjectileHeraOmega = gods.GetInternalBoonName("HeraBlinkTrailBoon"),
    BlinkTrailZeusSpark = "ChainLightning_Name",
    PoseidonBlinkWave = gods.GetInternalBoonName("PoseidonBlinkTrailBoon"),
    HephMineBlast = gods.GetInternalBoonName("HephaestusColorProjectile")
})

modutil.mod.Path.Wrap("SetupMap", function (base,...)
    LoadPackages({Name = _PLUGIN.guid .. "zerp-BlinkTrail"})
    LoadPackages({Name = "BiomeOBoss"})
    base(...)
end)

modutil.mod.Path.Wrap("StartBlinkTrailPresentation",function (base, ...)
    local isBlinkFired = false
    for _, data in pairs( game.GetHeroTraitValues( _PLUGIN.guid .. "OnSprintAction")) do
        print(data.FunctionName, data.FunctionArgs.DamageMultiplier)
        game.CallFunctionName( data.FunctionName, data.FunctionArgs )
        isBlinkFired = true
        break
    end
    if not isBlinkFired then
        base(...)
    end
end)

function mod.CheckNoExistingBlinkBoons( source, args )
    local blinktrait = game.HasHeroTraitValue(_PLUGIN.guid .. "OnSprintAction")
    if blinktrait ~= nil and blinktrait.Name ~= source.Name then
        return false
    end
    return true
end