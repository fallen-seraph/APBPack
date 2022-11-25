--require "recipecode";

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