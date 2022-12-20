require 'ISUI/Maps/ISMapDefinitions'

local MINZ = 0

local function overlayPNG(mapUI, x, y, scale, layerName, tex, alpha)
	local texture = getTexture(tex)
	if not texture then return end
	local mapAPI = mapUI.javaObject:getAPIv1()
	local styleAPI = mapAPI:getStyleAPI()
	local layer = styleAPI:newTextureLayer(layerName)
	layer:setMinZoom(MINZ)
	layer:addFill(MINZ, 255, 255, 255, (alpha or 1.0) * 255)
	layer:addTexture(MINZ, tex)
	layer:setBoundsInSquares(x, y, x + texture:getWidth() * scale, y + texture:getHeight() * scale)
end

local FlyerX1 = 10
local FlyerY1 = 10

local FlyerX2 = 1200
local FlyerY2 = 1600;

local FlyerX3 = 1280
local FlyerY3 = 1080;

-- Spawn Map Definitions

LootMaps.Init.APBpack_Manifest = function(mapUI)
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(FlyerX1, FlyerY1, FlyerY2, FlyerX2)
	overlayPNG(mapUI, FlyerX1, FlyerY1, 1.0, "lootMapPNG", "media/ui/LootableMaps/APBPack_Manifest.png", 1.0)
end

LootMaps.Init.Map_FoldCoffee = function(mapUI)
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(FlyerX1, FlyerY1, FlyerX3, FlyerY3)
	overlayPNG(mapUI, FlyerX1, FlyerY1, 1.0, "lootMapPNG", "media/ui/LootableMaps/Map_FoldCoffee.png", 1.0)
end

LootMaps.Init.Map_FoldCrumple = function(mapUI)
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(FlyerX1, FlyerY1, FlyerX3, FlyerY3)
	overlayPNG(mapUI, FlyerX1, FlyerY1, 1.0, "lootMapPNG", "media/ui/LootableMaps/Map_FoldCrumple.png", 1.0)
end

LootMaps.Init.Map_FoldCrumpleCoffee = function(mapUI)
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(FlyerX1, FlyerY1, FlyerX3, FlyerY3)
	overlayPNG(mapUI, FlyerX1, FlyerY1, 1.0, "lootMapPNG", "media/ui/LootableMaps/Map_FoldCrumpleCoffee.png", 1.0)
end

LootMaps.Init.Map_FoldCrumpleCoffeeDirt = function(mapUI)
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(FlyerX1, FlyerY1, FlyerX3, FlyerY3)
	overlayPNG(mapUI, FlyerX1, FlyerY1, 1.0, "lootMapPNG", "media/ui/LootableMaps/Map_FoldCrumpleCoffeeDirt.png", 1.0)
end

LootMaps.Init.Map_FoldCrumpleDirt = function(mapUI)
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(FlyerX1, FlyerY1, FlyerX3, FlyerY3)
	overlayPNG(mapUI, FlyerX1, FlyerY1, 1.0, "lootMapPNG", "media/ui/LootableMaps/Map_FoldCrumpleDirt.png", 1.0)
end

-- Event Order Definitions

LootMaps.Init.Mission_Orders = function(mapUI)
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(FlyerX1, FlyerY1, FlyerX2, FlyerY2)
	overlayPNG(mapUI, FlyerX1, FlyerY1, 1.0, "lootMapPNG", "media/ui/LootableMaps/Mission_Orders.png", 1.0)
end

LootMaps.Init.Mission_Orders2 = function(mapUI)
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(FlyerX1, FlyerY1, FlyerX2, FlyerY2)
	overlayPNG(mapUI, FlyerX1, FlyerY1, 1.0, "lootMapPNG", "media/ui/LootableMaps/Mission_Orders2.png", 1.0)
end
