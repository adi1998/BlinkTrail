function mod.dump(o, depth)
   depth = depth or 0
   if type(o) == 'table' then
      local s = string.rep("\t", depth) .. '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. string.rep("\t",(depth+1)) .. '['..k..'] = ' .. mod.dump(v, depth + 1) .. ',\n'
      end
      return s .. string.rep("\t", depth) .. '} \n'
   else
      return tostring(o)
   end
end

function mod.tprint(tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\n"
  indent = indent + 2 
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "   
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\n"
    elseif (type(v) == "table") then
      toprint = toprint .. mod.tprint(v, indent + 2) .. ",\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end


mod.SprintBoons = {
    "HestiaSprintBoon",
    "AresSprintBoon",
    "ApolloSprintBoon",
    "ZeusSprintBoon",
    "HeraSprintBoon",
    "DemeterSprintBoon",
    "PoseidonSprintBoon",
    "AphroditeSprintBoon",
    "HephaestusSprintBoon",
}


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
    },
    BlinkTrailProjectileHestia =
    {
        InheritFrom = { "HestiaColorProjectile" }
    },
    BlinkTrailProjectileFireHestia =
    {
        InheritFrom = { "HestiaColorProjectile" }
    },
    BlinkTrailProjectileAres =
    {
        InheritFrom = { "AresColorProjectile" }
    },
    BlinkTrailProjectileApollo =
    {
        InheritFrom = { "NoSlowFrameProjectile", "NoShakeProjectile", "NoShakeEffect" },
		CancelArmorSpark = true,
		CancelArmorUnitShake = true,
		CancelUnitShake = true,
		CancelHitSpark = true,
		CancelUnitHitFlash = true,
		CancelVulnerabilitySpark = true,
        DamageTextStartColor = game.Color.Transparent,
        DamageTextColor = game.Color.Transparent,
        IgnoreAllModifiers = true
    },
    BlinkTrailDemeterProjectile =
    {
        InheritFrom = { "NoSlowFrameProjectile", "DemeterColorProjectile" },
		CancelArmorSpark = true,
		CancelHitSpark = true,
		CancelUnitHitFlash = true,
		CancelVulnerabilitySpark = true,
    },
    BlinkTrailDemeterProjectileTracking =
    {
        InheritFrom = { "BlinkTrailDemeterProjectile" },
        OnDeathFunctionName = _PLUGIN.guid .. "." .. "CrystalBeamCleanup"
    }
})

game.ConcatTableValues(game.WeaponSets.OlympianProjectileNames,{
    "BlinkTrailProjectileHeraOmega",
    "BlinkTrailZeusSpark",
    "PoseidonBlinkWave",
    "HephMineBlast",
    "BlinkTrailProjectileHestia",
    "BlinkTrailProjectileFireHestia",
    "BlinkTrailProjectileAres",
    "BlinkTrailDemeterProjectile",
    "BlinkTrailDemeterProjectileTracking"
})

game.OverwriteTableKeys( game.ScreenData.RunClear.DamageSourceMap, {
    BlinkTrailProjectileHeraOmega = gods.GetInternalBoonName("HeraBlinkTrailBoon"),
    BlinkTrailZeusSpark = "ChainLightning_Name",
    PoseidonBlinkWave = gods.GetInternalBoonName("PoseidonBlinkTrailBoon"),
    HephMineBlast = gods.GetInternalBoonName("HephaestusBlinkTrailBoon"),
    BlinkTrailProjectileHestia = gods.GetInternalBoonName("HestiaBlinkTrailBoon"),
    BlinkTrailProjectileFireHestia = "Flame Blink Lava",
    BlinkTrailProjectileAres = gods.GetInternalBoonName("AresBlinkTrailBoon"),
    BlinkTrailDemeterProjectile = gods.GetInternalBoonName("DemeterBlinkTrailBoon"),
    BlinkTrailDemeterProjectileTracking = gods.GetInternalBoonName("DemeterBlinkTrailBoon"),
})

modutil.mod.Path.Wrap("SetupMap", function (base,...)
    game.LoadPackages({Name = _PLUGIN.guid .. "zerp-BlinkTrail"})
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