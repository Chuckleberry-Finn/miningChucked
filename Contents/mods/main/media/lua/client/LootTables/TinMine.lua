local miningMod = require('miningMod')

miningMod.resources["Tin Mine"] = {
    mineType = "Tin Mine",
    menuName = getText("ContextMenu_Tin_Mine"),
    menuAction = getText("ContextMenu_Mine_Tin"),
    textures = { "mines_7", "mines_6" },
    lootTables = {
        {
            item = "Base.Stone",
            requireLevel = false,
            fixed = true,
            fixedAmount = 1,
        },
        {
            item = "Mining.MM_RawTin",
            requireLevel = true,
            fixed = false,
            amountPerLevel = {
                { levels = { 0, 1 }, amounts = { min = 0, max = 1 } },
                { levels = { 2, 3 }, amounts = { min = 1, max = 3 } },
                { levels = { 4, 5 }, amounts = { min = 2, max = 4 } },
                { levels = { 6, 7, 8, 9, 10 }, amounts = { min = 3, max = 6 } },
            }
        },
    }
}
