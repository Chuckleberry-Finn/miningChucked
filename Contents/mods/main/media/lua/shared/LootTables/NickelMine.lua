local miningChucked = require('miningChucked')

miningChucked.resources["Nickel"] = {
    mineType = "Nickel",
    textures = { "mines_3", "mines_2" },
    lootTables = {
        {
            item = "Base.Stone",
            requireLevel = false,
            fixedAmount = 1,
        },
        {
            item = "Mining.MM_RawNickel",
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
