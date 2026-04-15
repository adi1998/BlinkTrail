local wrathRequirements = {
    ["Wistiti-WrathOfOlympus" .. "-" .. "AresWrathBoon"] = {
        OneFromEachSet = {
            [2] = { "AresManaBoon", "BloodDropRevengeBoon", gods.GetInternalBoonName("AresBlinkTrailBoon")},
        }
    }
}

if rom.mods["Wistiti-WrathOfOlympus"] and rom.mods["Wistiti-WrathOfOlympus"].config and rom.mods["Wistiti-WrathOfOlympus"].config.enabled then
    if game.TraitRequirements["Wistiti-WrathOfOlympus" .. "-" .. "AresWrathBoon"] then
        game.TraitRequirements = MergeUptoDepth(game.TraitRequirements, wrathRequirements, 2)
    end
end