Events.OnNewGame.Add(function(player, square)

	local map = { "APBpack.Map_FoldCoffee","APBpack.Map_FoldCrumple","APBpack.Map_FoldCrumpleCoffee","APBpack.Map_FoldCrumpleCoffeeDirt","APBpack.Map_FoldCrumpleDirt" }

	player:getInventory():AddItem(map[ZombRand(1,#map+1)])

end)