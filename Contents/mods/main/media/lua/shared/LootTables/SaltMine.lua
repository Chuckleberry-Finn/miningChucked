local miningChucked = require('miningChucked')

miningChucked.resources["Salt"] = {
    mineType = "Salt Mine",
    menuName = getText("ContextMenu_Salt_Mine"),
    menuAction = getText("ContextMenu_Mine_Salt"),
    textures = { "mines_15", "mines_14" },
    lootTables = {
        {
            item = "Base.Stone",
            requireLevel = false,
            fixedAmount = 1,
        },
        {
            item = "Mining.MM_RawSalt",
            requireLevel = true,
            amountPerLevel = {
                { levels = { 0, 1 }, amounts = { min = 0, max = 1 } },
                { levels = { 2, 3 }, amounts = { min = 1, max = 3 } },
                { levels = { 4, 5 }, amounts = { min = 2, max = 4 } },
                { levels = { 6, 7, 8, 9, 10 }, amounts = { min = 3, max = 6 } },
            }
        },
    }
}
