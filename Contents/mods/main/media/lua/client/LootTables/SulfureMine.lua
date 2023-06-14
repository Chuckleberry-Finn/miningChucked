if not getMiningModInstance then
    require('MiningMod')
end

MiningMod = getMiningModInstance()

MiningMod.resources["Sulfure Mine"] = {
    mineType = "Sulfure Mine",
    menuName = getText("ContextMenu_Sulfure_Mine"),
    menuAction = getText("ContextMenu_Mine_Sulfure"),
    textures = { "mines_9", "mines_8" },
    lootTables = {
        {
            item = "Base.Stone",
            requireLevel = false,
            fixed = true,
            fixedAmount = 1,
        },
        {
            item = "Mining.MM_RawSulfure",
            requireLevel = true,
            fixed = false,
            amountPerLevel = {
                {
                    levels = { 0, 1 },
                    amounts = {
                        min = 0,
                        max = 1
                    }
                },
                {
                    levels = { 2, 3 },
                    amounts = {
                        min = 1,
                        max = 3
                    }
                },
                {
                    levels = { 4, 5 },
                    amounts = {
                        min = 2,
                        max = 4
                    }
                },
                {
                    levels = { 6, 7, 8, 9, 10 },
                    amounts = {
                        min = 3,
                        max = 6
                    }
                }
            }
        },
    }
}
