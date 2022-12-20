function Recipe.OnGiveXP.Tailoring01(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Tailoring, 1);
end

function Recipe.OnGiveXP.Tailoring05(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Tailoring, 5);
end

function Recipe.OnGiveXP.Tailoring75(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Tailoring, 75);
end

function Recipe.OnGiveXP.Cooking50(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Cooking, 50);
end

function Recipe.OnGiveXP.MetalWelding01(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.MetalWelding, 1);
	player:getXp():AddXP(Perks.Strength, 8);
end

function Recipe.OnGiveXP.MetalWelding03(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.MetalWelding, 3);
	player:getXp():AddXP(Perks.Strength, 12);
end

function Recipe.OnGiveXP.MetalWelding05(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.MetalWelding, 5);
	player:getXp():AddXP(Perks.Strength, 16);
end

function Recipe.OnTest.DismantleFavs(item)
    if not item  then return; end
    if item:getType() == "WeldingMask" or item:getType() == "BlowTorch" then
       return true;
    end
    return not item:isFavorite();
end

function Recipe.OnTest.NotFavourite(item)
	if item:getType() ~= "Screwdriver" and item:getAttachedSlot() > 0 then
		return false
	end
	return not item:isFavorite() and not item:isEquipped()
end

Recipe.OnTest.AlwaysFalse = function() return false end

--getScriptManager():getRecipe('Gather Gunpowder'):setIsHidden(true)
getScriptManager():getRecipe('Gather Gunpowder'):setLuaTest('Recipe.OnTest.AlwaysFalse')

-------------------------------------------------------------------------------------------------
-- Refilling Propane on Large propane
-------------------------------------------------------------------------------------------------
function Recipe.OnTest.RefillFromLargePropaneTank(item)
    if item:getType() == "PropaneTank" then
        if item:getUsedDelta() == 1 then return false; end
    elseif item:getType() == "LargePropaneTank" then
        if item:getUsedDelta() == 0 then return false; end
    end
    return true;
end

-- Fill entirely the blowtorch with the remaining propane
function Recipe.OnCreate.RefillFromLargePropaneTank(items, result, player)
    local previousBT = nil;
    local propaneTank = nil;
    for i=0, items:size()-1 do
       if items:get(i):getType() == "PropaneTank" then
           previousBT = items:get(i);
       elseif items:get(i):getType() == "LargePropaneTank" then
           propaneTank = items:get(i);
       end
    end
    result:setUsedDelta(previousBT:getUsedDelta() + result:getUseDelta() * 1);

    while result:getUsedDelta() < 1 and propaneTank:getUsedDelta() > 0 do
        result:setUsedDelta(result:getUsedDelta() + result:getUseDelta() * 1);
        propaneTank:Use();
    end

    if result:getUsedDelta() > 1 then
        result:setUsedDelta(1);
    end
end

------------------------------------------------------------------------

function Recipe.OnTest.RefillEmptyPropaneTank(item)
    if item:getType() == "HugePropaneTank" then
        if item:getUsedDelta() == 0 then return false; end
    elseif item:getType() == "LargePropaneTank" then
        if item:getUsedDelta() == 0 then return false; end
    end
    return true;
end

-- Fill entirely the blowtorch with the remaining propane
function Recipe.OnCreate.RefillEmptyPropaneTank(items, result, player)
    local previousBT = nil;
    local propaneTank = nil;
    for i=0, items:size()-1 do
        if items:get(i):getType() == "PropaneTankEmpty" then
            previousBT = items:get(i);
        elseif items:get(i):getType() == "LargePropaneTank" then
            propaneTank = items:get(i);
		elseif items:get(i):getType() == "HugePropaneTank" then
			propaneTank = items:get(i);
		end
    end
    result:setUsedDelta(result:getUseDelta() * 1);

    while result:getUsedDelta() < 1 and propaneTank:getUsedDelta() > 0 do
        result:setUsedDelta(result:getUsedDelta() + result:getUseDelta() * 1);
        propaneTank:Use();
    end

    if result:getUsedDelta() > 1 then
        result:setUsedDelta(1);
    end
end

-------------------------------------------------------------------------------

function Recipe.OnTest.StorePropaneinHuge(item)
    if item:getType() == "HugePropaneTank" then
        if item:getUsedDelta() == 1 then return false; end
    elseif item:getType() == "LargePropaneTank" then
        if item:getUsedDelta() == 0 then return false; end
    elseif item:getType() == "PropaneTank" then
        if item:getUsedDelta() == 0 then return false; end
    end
    return true;
end

-- Fill entirely the blowtorch with the remaining propane
function Recipe.OnCreate.StorePropaneinHuge(items, result, player)
    local previousBT = nil;
    local propaneTank = nil;
    for i=0, items:size()-1 do
        if items:get(i):getType() == "HugePropaneTank" then
            previousBT = items:get(i);
        elseif items:get(i):getType() == "LargePropaneTank" then
            propaneTank = items:get(i);
		elseif items:get(i):getType() == "PropaneTank" then
			propaneTank = items:get(i);
		end
    end
    result:setUsedDelta(previousBT:getUsedDelta() + result:getUseDelta() * 1);

    while result:getUsedDelta() < 1 and propaneTank:getUsedDelta() > 0 do
        result:setUsedDelta(result:getUsedDelta() + result:getUseDelta() * 1);
        propaneTank:Use();
    end

    if result:getUsedDelta() > 1 then
        result:setUsedDelta(1);
    end
end

------------------------------------------------------------------------

function Recipe.OnTest.StorePropaneinLarge(item)
    if item:getType() == "LargePropaneTank" then
        if item:getUsedDelta() == 1 then return false; end
    elseif item:getType() == "BlowTorch" then
        if item:getUsedDelta() == 0 then return false; end
    elseif item:getType() == "PropaneTank" then
        if item:getUsedDelta() == 0 then return false; end
    end
    return true;
end

-- Fill entirely the blowtorch with the remaining propane
function Recipe.OnCreate.StorePropaneinLarge(items, result, player)
    local previousBT = nil;
    local propaneTank = nil;
    for i=0, items:size()-1 do
        if items:get(i):getType() == "LargePropaneTank" then
            previousBT = items:get(i);
        elseif items:get(i):getType() == "BlowTorch" then
            propaneTank = items:get(i);
		elseif items:get(i):getType() == "PropaneTank" then
			propaneTank = items:get(i);
		end
    end
    result:setUsedDelta(previousBT:getUsedDelta() + result:getUseDelta() * 1);

    while result:getUsedDelta() < 1 and propaneTank:getUsedDelta() > 0 do
        result:setUsedDelta(result:getUsedDelta() + result:getUseDelta() * 1);
        propaneTank:Use();
    end

    if result:getUsedDelta() > 1 then
        result:setUsedDelta(1);
    end
end