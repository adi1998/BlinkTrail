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


modutil.mod.Path.Wrap("SetupMap", function (base,...)
    LoadPackages({Name = _PLUGIN.guid .. "zerp-BlinkTrail"})
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

function mod.CheckExistingBlinkBoons()
    if #( game.GetHeroTraitValues( _PLUGIN.guid .. "OnSprintAction" ) ) > 0 then
        return false
    end
    return true
end