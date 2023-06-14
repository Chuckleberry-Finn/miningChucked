-- require('NPCs/MainCreationMethods');
require('MiningMod')

MiningTraits = {}

local function initBadMinerTrait()
    TraitFactory.addTrait(
        "BadMiner",
        getText("UI_trait_badminer"),
        -6,
        getText("UI_trait_badminerdesc"),
        false,
        false
    );
end

local function initGoodMinerTrait()
    TraitFactory.addTrait(
        "GoodMiner",
        getText("UI_trait_goodminer"),
        6,
        getText("UI_trait_goodminerdesc"),
        false,
        false
    );
end

local function initExclution()
    TraitFactory.setMutualExclusive("BadMiner", "GoodMiner");
end

MiningTraits.init = function()
    initGoodMinerTrait()
    initBadMinerTrait()
    initExclution()
end

Events.OnGameBoot.Add(MiningTraits.init);
