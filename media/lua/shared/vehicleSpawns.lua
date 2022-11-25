-- Vehicle Event Spawn for Filibuster Rhyme's Used Cars mod and Vielspring's M113a1 mod
-- WIP; not all features are fully implmented, and the list is incomplete
-- Please don't resdistribute, as it's unfinsihed and intended to be "privately shared" with friends :)
-- Please use as a emample of how you can implement your own similar ideas

-- TODO: included mod maps as well
-- TODO: inlcude Soul Filcher's, and Mr Danny's, and other b41 vehicles when available
-- TODO: include a means for multiple vehicles tospawn from one random check
-- TODO: inclde a means for an instance of a "class" of vehicles spawn,instead of a specific model
local function isMod(mod_Name)
    local mods = getActivatedMods();
    for i=0, mods:size()-1, 1 do
        if mods:get(i) == mod_Name then
            return true;
        end
    end
    return false;
end

-- declares used functions as local; this will improve performance
local print = print
local getPlayer = getPlayer
local Say = Say
local ZombRand = ZombRand
local addVehicleDebug = addVehicleDebug
local tostring = tostring
local SandboxVars = SandboxVars
local setFallOnFront = setFallOnFront
local AddWorldInventoryItem = AddWorldInventoryItem
local getCell = getCell
local getGridSquare = getGridSquare
local createRandomDeadBody = createRandomDeadBody
local table = table
local format = string.format -- NOTE: we need this
local ipairs = ipairs
local getActivatedMods = getActivatedMods
local size = size
local get = get

-- used to determine which direction spawned vehicles are orientated
local Dir = IsoDirections -- NOTE: dont pull every direction into local space, just the enum will do.

    
-- CONSTANT VALUES 
-- NOTE: constants that do not change should be uppercase, always. unviversal law for all languages. For clarification from standard variables


local IS_VEHICLE = 1 -- primary intent of this mod; spawning vehicles at specific locations; also used to spawn out burned out/wrecked vehicles
-- TODO: spawn groups of vehicles as one unit
local IS_ITEM = 2 -- spawns items, on the ground, that can be interacted with, equipped, and placed in the inventory.
local IS_SPRITE = 3 -- spawns "world object" sprites, such as blood spatter, barricades, and durniture; only spawns "ghost" sprites that can't be interacted with at this point
local IS_BODY = 4
local IS_BODIES = 5
local IS_DRESSEDBODIES = 6 -- not implemnted; intended to spawn bodies in specific outfits, but might not be possible
local IS_ZED = 7 -- not implemented yet

-- declare the *constants* used by this file
local DEBUG_MSG = false -- sets whether there's information outputted on screen that is used to evaluate the mod's performance
local DEBUG = false
local FLAMING_WRECKS = true -- not used at this point
local ALWAYS_OVERRIDE -- used to override spawn table entries with the Always spawn flag
local MAX_RAND = 200 -- this is used to dictate the odds of all of the vehicles spawning; the higher the number, the less chance they spawn

do -- NOTE: isolate this block of code
    -- with all settings at default, vehicles should spawn 50% of the time
    local mode =  DEBUG and 5 or SandboxVars.CarSpawnRate -- ovveride sandbox settings when in debug mode so that ALL vehicles spawn, since Blair always forgets to set vehicle spawn to High when testing
    if mode == 2 then
        MAX_RAND = MAX_RAND * 10 -- with other settings at default, vehicles should spawn 5% of the time
    elseif mode == 3 then 
        MAX_RAND = MAX_RAND * 1.5-- with other settings at default, vehicles should spawn ~33% of the time
    elseif mode == 5 then 
        MAX_RAND = MAX_RAND / 2-- with other settings at default, vehicles should always spawn
    end
end


local cargo = {
    "f700box",
    "f700flatbed",
    "isuzubox",
    "86fordE150",
};

local construction = {
    "f700dump",
    "isuzuboxmccoy",
    "cargo",
    "86fordE150",
};


local delivery = {
    "f700box",
    "isuzubox",
    "86fordE150slide"
};

local storage = {
    "f700box",
    "isuzubox",
	"moveurself",
    "86fordE150long",
};



if isMod("ZIL130PACK2") then
	table.insert(cargo, "zil130")
	table.insert(cargo, "zil130furgon")
	table.insert(cargo, "zil130g")
	table.insert(cargo, "zil130gtent")
	table.insert(cargo, "zil130tent")
	
	table.insert(construction, "zil130mmz555")	
	
	table.insert(delivery, "zil130furgon")	
	
	table.insert(storage, "zil130furgon")
end



-- The below modifies spawn chance for specific models of vehicles; increase or decrease the Chance variable to increase or decrease the chance of vehicles of that model spawning
local ModifierTable = {
    { type = "87bounder", chance = 1.0 },
    { type = "f700box", chance = 1.0 },
    { type = "f700dump", chance = 1.0 },
    { type = "f700flatbed", chance = 1.0 },
    { type = "92amgeneralM998", chance = 1.0 },
    { type = "92amgeneralM998", chance = 1.0 },
    { type = "isuzubox", chance = 1.0 },
    { type = "isuzuboxmccoy", chance = 1.0 },
    { type = "isuzuboxfood", chance = 1.0 },
    { type = "m113a1", chance = 1.0 },
    { type = "74amgeneralM151A2", chance = 1.0 },
    { type = "78amgeneralM35A2", chance = 1.0 }, 
    { type = "78amgeneralM35A2", chance = 1.0 },
    { type = "schoolbus", chance = 1.0 },
    { type = "schoolbusshort", chance = 1.0 },
}

-- eventually this list of vehicles to spawn could be migrated to a seperate file, or set as a configuration file that the function loads, to clean up the code
-- TODO: clean up and better organize the order
local SpawnTable = { }

-- NOTE: function adding spawns, instead of nasty manual table inserts
-- this way we can define default values
local function addSpecialSpawn(data)
    data.spawn = data.spawn or IS_VEHICLE
    data.skin = data.skin or nil
    data.z = data.z or 0
    data.chance = data.chance or 100
    data.always = data.always or false
    
    -- instead of a list table, use a dict table. build the key off the string x,y,z position
    -- theres a number of ways of generating this string, in real lua this is fastest (kahlua needs confirmation) 
    local key = format("%i,%i,%i", data.x, data.y, data.z)
    SpawnTable[key] = data
end

-- basic function redundancy.
local function debugSay(text)
    if not DEBUG_MSG then return end
    print("DEBUG: ".. text)
    getPlayer():Say(text, 1.0, 1.0, 0.0, UIFont.Dialogue, 30.0, "radio")
    
end
 
 
local function checkSpawn(square)
    if not square then return end
    if square:getModData().spawnVehicle then return end
    square:getModData().spawnVehicle = true
    local x, y, z = square:getX(), square:getY(), square:getZ()
    -- NOTE: build the key, and check the table, no need to itterate, or store mod data in the square 
    local key = format("%i,%i,%i", x, y, z)
    local spawn = SpawnTable[key]
    if not spawn then return end

    local roll = ZombRand(0, MAX_RAND)
    local chance = spawn.chance

    for _, modifier in ipairs(ModifierTable) do 
        -- NOTE: we can add additional checks here as well, not just for the 'type'
        if modifier.type == spawn.type then
            chance = chance * modifier.chance
        end
    end
    debugSay(format("Check Spawn (type: %s), roll vs chance: %s vs %s (always: %s)", spawn.type or "nil", roll, spawn.chance, tostring(spawn.always)))
    
    -- NOTE: reversed the check logic. why? its just cleaner. saves a indentation level
	if not spawn.always then 
		if roll > chance and (not spawn.always or not ALWAYS_OVERRIDE) then 
			SpawnTable[key] = nil
			return
		end
	end
    debugSay("Roll passed, attempting spawn..")

    if spawn.spawn == IS_VEHICLE then
        -- NOTE does addVehicleDebug(spawn.type, spawn.dir, nil, square) not work?
        -- NOTE yes it does!
        
        if spawn.type == "burnt" then
            local roll = ZombRand(0,19)
            if roll == 0 then
                spawn.type = "PickupBurnt"
            elseif roll == 1 then 
                spawn.type = "PickUpVanBurnt"
            elseif roll == 2 then 
                spawn.type = "CarNormalBurnt"
            elseif roll == 3 then 
                spawn.type = "TaxiBurnt"
            elseif roll == 4 then 
                spawn.type = "ModernCar02Burnt"
            elseif roll == 5 then 
                spawn.type = "ModernCarBurnt"
            elseif roll == 6 then 
                spawn.type = "SportsCarBurnt"
            elseif roll == 7 then 
                spawn.type = "SmallCar02Burnt"
            elseif roll == 8 then 
                spawn.type = "SmallCarBurnt"
            elseif roll == 18 then 
                spawn.type = "VanSeatsBurnt"
            elseif roll == 9 then 
                spawn.type = "VanBurnt"
            elseif roll == 10 then 
                spawn.type = "SUVBurnt"
            elseif roll == 11 then 
                spawn.type = "VanSeatsBurnt"
            elseif roll == 12 then 
                spawn.type = "OffRoadBurnt"
            elseif roll == 13 then 
                spawn.type = "LuxuryCarBurnt"
            elseif roll == 14 then 
                spawn.type = "PickUpVanLightsBurnt"
            elseif roll == 15 then 
                spawn.type = "AmbulanceBurnt"
            elseif roll == 16 then 
                spawn.type = "VanRadioBurnt"
            elseif roll == 17 then 
                spawn.type = "PickupSpecialBurnt"
            else
                spawn.type = "NormalCarBurntPolice"
            end
        end
        
        if spawn.type == "burntcivilian" then
            local roll = ZombRand(0,14)
            if roll == 0 then
                spawn.type = "PickupBurnt"
            elseif roll == 1 then 
                spawn.type = "PickUpVanBurnt"
            elseif roll == 2 then 
                spawn.type = "CarNormalBurnt"
            elseif roll == 3 then 
                spawn.type = "TaxiBurnt"
            elseif roll == 4 then 
                spawn.type = "ModernCar02Burnt"
            elseif roll == 5 then 
                spawn.type = "ModernCarBurnt"
            elseif roll == 6 then 
                spawn.type = "SportsCarBurnt"
            elseif roll == 7 then 
                spawn.type = "SmallCar02Burnt"
            elseif roll == 8 then 
                spawn.type = "SmallCarBurnt"
            elseif roll == 13 then 
                spawn.type = "VanSeatsBurnt"
            elseif roll == 9 then 
                spawn.type = "VanBurnt"
            elseif roll == 10 then 
                spawn.type = "SUVBurnt"
            elseif roll == 11 then 
                spawn.type = "VanSeatsBurnt"
            elseif roll == 12 then 
                spawn.type = "OffRoadBurnt"
            else 
                spawn.type = "LuxuryCarBurnt"
            end
        end

        if spawn.type == "policerandom" then
            if ZombRand(0,2) == 0 then
                spawn.type = "policeburnt"
            else
                spawn.type = "police"
            end
        end

        if spawn.type == "emergencyrandom" then
            if ZombRand(0,2) == 0 then
                spawn.type = "emergencyburnt"
            else
                spawn.type = "emergency"
            end
        end

        if spawn.type == "policeburnt" then
            local roll = ZombRand(0,6)
            if roll == 0 then
                spawn.type = "PickUpVanLightsBurnt"
                spawn.skin = 2
            elseif roll == 1 then
                spawn.type = "PickupSpecialBurnt"
                spawn.skin = 2
            else
                spawn.type = "NormalCarBurntPolice"
            end
        end

        if spawn.type == "emergencyburnt" then
            local roll = ZombRand(0,4)
            if roll == 0 then
                spawn.type = "PickUpVanLightsBurnt"
                if ZombRand(0,2) == 0 then
                    spawn.skin = 0
                else
                    spawn.skin = 2
                end
            elseif roll == 1 then
                spawn.type = "PickupSpecialBurnt"
                if ZombRand(0,2) == 0 then
                    spawn.skin = 0
                else
                    spawn.skin = 2
                end
            elseif roll == 2 then 
                spawn.type = "AmbulanceBurnt"
            else
                spawn.type = "NormalCarBurntPolice"
            end
        end

        if spawn.type == "police" then
            local roll = ZombRand(0,4)
            if roll == 0 then
                spawn.type = "91blazerpd"
            elseif roll == 1 then
                spawn.type = "PickUpVanLightsPolice"
            elseif roll == 2 then
                spawn.type = "85vicsheriff"
            else
                spawn.type = "CarLightsPolice"
            end
        end

        if spawn.type == "emergency" then
            local roll = ZombRand(0,8)
            if roll == 0 then
                spawn.type = "91blazerpd"
            elseif roll == 1 then
                spawn.type = "PickUpTruckLightsFire"
            elseif roll == 2 then
                spawn.type = "PickUpVanLightsFire"
                spawn.skin = 0
            elseif roll == 3 then
                spawn.type = "PickUpVanLightsPolice"
                spawn.skin = 2
            elseif roll == 4 then 
                spawn.type = "VanAmbulance"
            elseif roll == 5 then 
                spawn.type = "firepumper"
            elseif roll == 6 then
                spawn.type = "PickUpTruckLightsFire"
            else
                spawn.type = "CarLightsPolice"
            end
        end

        if spawn.type == "storage" then
            local roll = ZombRand(0,3)
            if roll == 0 then
                spawn.type = "f700box"
            elseif roll == 1 then
                spawn.type = "isuzubox"
            else
                spawn.type = "moveurself"
            end
        end
        if spawn.type == "delivery" then

            spawn.type = delivery[ZombRand(1,#delivery)]
        end
        -- if spawn.type == "delivery" then
            -- local roll = ZombRand(0,2)
            -- if roll == 0 then
                -- spawn.type = "f700box"
            -- else
                -- spawn.type = "isuzubox"
            -- end
        -- end
         if spawn.type == "construction" then

            spawn.type = construction[ZombRand(1,#construction)]
        end       
        -- if spawn.type == "construction" then
            -- local roll = ZombRand(0,5)
            -- if roll == 0 then
                -- spawn.type = "f700dump"
            -- elseif roll == 1 then 
                -- spawn.type = "isuzuboxmccoy"
            -- else
                -- spawn.type = "cargo"
            -- end
        -- end

        if spawn.type == "cargo" then

            spawn.type = cargo[ZombRand(1,#cargo)]
            -- local roll = ZombRand(0,3)
            -- if roll == 0 then
            --     spawn.type = "f700box"
            -- elseif roll == 1 then 
            --     spawn.type = "f700flatbed"
            -- else
            --     spawn.type = "isuzubox"
            -- end
        end

        if spawn.type == "school" then
            local roll = ZombRand(0,3)
            if roll == 0 then
                spawn.type = "schoolbusshort"
            else
                spawn.type = "schoolbus"
            end
        end

        if spawn.type == "hummer" then
            local roll = ZombRand(0,2)
            if roll == 0 then
                spawn.type = "92amgeneralM998"
            end
        end

        if spawn.type == "military" then
            local roll = ZombRand(0,5)
            if roll == 0 then
                spawn.type = "92amgeneralM998"
            else
                spawn.type = "78amgeneralM35A2"
            end
        end

        if spawn.type == "militarynocargo" then
            local roll = ZombRand(0,3)
            if roll == 0 then
                spawn.type = "92amgeneralM998"
            elseif roll == 1 then
                spawn.type = "74amgeneralM151A2"
            end
        end
        
        if spawn.type == "militarycargo" then
            local roll = ZombRand(0,3)
            if roll == 0 then
                spawn.type = "92amgeneralM998"
            elseif roll == 1 then 
                spawn.type = "78amgeneralM35A2"
            end
        end

        if spawn.type == "militarytruck" then
            local roll = ZombRand(0,2)
            if roll == 0 then 
                spawn.type = "78amgeneralM35A2"
            end
        end

        --local car = addVehicleDebug(spawn.type, spawn.dir, nil, getCell():getGridSquare(x, y, 0))
        local car = addVehicleDebug(spawn.type, spawn.dir, spawn.skin, square)

    elseif spawn.spawn == IS_ITEM then
        square:AddWorldInventoryItem(spawn.type, 0.3, 0.3, 0.0)

    elseif spawn.spawn == IS_SPRITE then -- currently world object sprites spawned are "ghost" sprites that canot be interacted with
        --square:AddTileObject(IsoObject.new(square, spawn.type))
		local newSprite = (IsoObject.new(getCell(), square, spawn.type));	
		if newSprite:getProperties():Val("ContainerType") or newSprite:getProperties():Val("container") then
			 newSprite:createContainersFromSpriteProperties() 	
		end
		square:getObjects():add(newSprite);
		square:RecalcProperties();
		--MapCollisionData.instance:squareChanged(square)
		-- if newSprite:getProperties():Val("TileBlockStyle") then
			-- MapCollisionData.instance:squareChanged(square)
		-- end

    elseif spawn.spawn == IS_ZED then -- currently zombie spawning is not implmented
        
    elseif spawn.spawn == IS_BODY then
        local body = createRandomDeadBody(square, spawn.blood )
        if body and ZombRand(0,3) == 0 then -- used so that all spawned bodies are not on their rbacks
            body:setFallOnFront(true)
        end

    elseif spawn.spawn == IS_BODIES then -- Note: sometimes does not function properly when teleporting?
        -- TODO: better body spawning pattern algorithims
        for i=1, (spawn.amount or 0) do -- NOTE: default to 0 just incase of nil
            local xx = ZombRand( spawn.x,  spawn.x2 )
            local yy = ZombRand( spawn.y,  spawn.y2 )
            local body = createRandomDeadBody( getCell():getGridSquare( xx, yy, z ), spawn.blood ) 
            if ZombRand(0,2) == 0 then
                body:setFallOnFront(true) -- Will sometimes throw errors when teleporting into an area where bodies are supposed to spawn
            end
        end

    elseif spawn.spawn == IS_DRESSEDBODIES then -- not implemented yet; might not be possible
        -- local zombie = {}
        -- for i=1, spawn.amount do
        --     local xx = ZombRand( spawn.x,  spawn.x2 )
        --     local yy = ZombRand( spawn.y,  spawn.y2 )
        --     --local zeds = addZombiesInOutfit(xx, yy, z, 1, spawn.type, 50)
        --     --local zombie = zeds:get(0)
        --     --zombie:setFakeDead(true)
				--zombie:setHealth(0)

        --     --local XX = ZombRand( vehicle_Test.X,  vehicle_Test.X2 )
        --     --local YY = ZombRand( vehicle_Test.Y,  vehicle_Test.Y2 )
        --     local zeds = addZombiesInOutfit(xx, yy, z, 1, "Police", 50)
        --     zombie[i] = zeds:get(0)
        --     zombie[i]:setFakeDead(true)

        -- end
    end

    SpawnTable[key] = nil
end


Events.LoadGridsquare.Add(checkSpawn) -- every time a grid square is loaded, checks for any vehicle spawn list entries
-- TODO: change specific vehicles to categories as appropriate

--NW Roadblock
-- These are an example of table entries that use the Always flag to always spawn
addSpecialSpawn({type = "militarytruck", x = 3603, y = 5998, Dir.SE, chance = 100, always = true})
addSpecialSpawn({type = "militarynocargo", x = 3614, y = 5997, dir = Dir.SE, chance = 100, always = true})
addSpecialSpawn({type = "militarynocargo", x = 3612, y = 6004, dir = Dir.NE, chance = 100, always = true})
addSpecialSpawn({type = "militarynocargo", x = 3606, y = 5992, dir = Dir.E, chance = 100, always = true})
addSpecialSpawn({type = "school", x = 3641, y = 6000, dir = Dir.NW, chance = 100, always = true})
addSpecialSpawn({type = "burnt", x = 3630, y = 5996, dir = Dir.SW, chance = 100, always = true})
addSpecialSpawn({type = "burnt", x = 3625, y = 6002, dir = Dir.W, chance = 100, always = true})
addSpecialSpawn({type = "burnt", x = 3635, y = 6007, dir = Dir.SW, chance = 100, always = true})
addSpecialSpawn({spawn = IS_SPRITE, type = "street_decoration_01_29", x = 3616, y = 5994, chance = 100, always = true})
addSpecialSpawn({spawn = IS_SPRITE, type = "street_decoration_01_29", x = 3616, y = 5996, chance = 100, always = true})
addSpecialSpawn({spawn = IS_SPRITE, type = "street_decoration_01_29", x = 3616, y = 5998, chance = 100, always = true})
addSpecialSpawn({spawn = IS_SPRITE, type = "street_decoration_01_29", x = 3616, y = 6000, chance = 100, always = true})
addSpecialSpawn({spawn = IS_SPRITE, type = "street_decoration_01_29", x = 3616, y = 6002, chance = 100, always = true})
addSpecialSpawn({spawn = IS_SPRITE, type = "street_decoration_01_29", x = 3616, y = 6004, chance = 100, always = true})

addSpecialSpawn({spawn = IS_SPRITE, type = "construction_01_9", x = 3618, y = 5994, chance = 100, always = true})
addSpecialSpawn({spawn = IS_SPRITE, type = "construction_01_9", x = 3618, y = 5996, chance = 100, always = true})
addSpecialSpawn({spawn = IS_SPRITE, type = "construction_01_9", x = 3618, y = 5998, chance = 100, always = true})
addSpecialSpawn({spawn = IS_SPRITE, type = "construction_01_9", x = 3618, y = 6000, chance = 100, always = true})
addSpecialSpawn({spawn = IS_SPRITE, type = "construction_01_9", x = 3618, y = 6002, chance = 100, always = true})
addSpecialSpawn({spawn = IS_SPRITE, type = "construction_01_9", x = 3618, y = 6004, chance = 100, always = true})

-- addSpecialSpawn({spawn = IS_SPRITE, type = "furniture_storage_02_1", x = 3618, y = 5994, chance = 100, always = true})
-- addSpecialSpawn({spawn = IS_SPRITE, type = "furniture_storage_02_9", x = 3618, y = 5996, chance = 100, always = true})
-- addSpecialSpawn({spawn = IS_SPRITE, type = "furniture_storage_02_17", x = 3618, y = 5998, chance = 100, always = true})
-- addSpecialSpawn({spawn = IS_SPRITE, type = "furniture_storage_02_1", x = 3618, y = 6000, chance = 100, always = true})
-- addSpecialSpawn({spawn = IS_SPRITE, type = "furniture_storage_02_9", x = 3618, y = 6002, chance = 100, always = true})
-- addSpecialSpawn({spawn = IS_SPRITE, type = "furniture_storage_02_29", x = 3618, y = 6004, chance = 100, always = true})

-- addSpecialSpawn({spawn = IS_SPRITE, type = "greensupplybarrels_1", x = 3618, y = 5994, chance = 100, always = true})
-- addSpecialSpawn({spawn = IS_SPRITE, type = "greensupplybarrels_1", x = 3618, y = 5996, chance = 100, always = true})
-- addSpecialSpawn({spawn = IS_SPRITE, type = "greensupplybarrels_1", x = 3618, y = 5998, chance = 100, always = true})
-- addSpecialSpawn({spawn = IS_SPRITE, type = "greensupplybarrels_1", x = 3618, y = 6000, chance = 100, always = true})
-- addSpecialSpawn({spawn = IS_SPRITE, type = "greensupplybarrels_1", x = 3618, y = 6002, chance = 100, always = true})
-- addSpecialSpawn({spawn = IS_SPRITE, type = "greensupplybarrels_1", x = 3618, y = 6004, chance = 100, always = true})

addSpecialSpawn({spawn = IS_BODIES, x = 3600, x2 = 3650, y = 5990, y2 = 6010, chance = 100, amount = 100, blood = 35, always = true})
addSpecialSpawn({spawn = IS_BODIES, x = 3618, x2 = 3650, y = 5985, y2 = 6015, chance = 100, amount = 100, blood = 35, always = true})

-- West Point
addSpecialSpawn({type = "isuzubox", x = 11880, y = 6872, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "isuzubox", x = 11969, y = 6923, dir = Dir.S, chance = 100})
-- Giga Mart
addSpecialSpawn({type = "delivery", x = 12040, y = 6843, dir = Dir.W, chance = 100})
addSpecialSpawn({type = "delivery", x = 12049, y = 6849, dir = Dir.N, chance = 100})
-- Elementary School
addSpecialSpawn({type = "school", x = 11748, y = 6903, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "school", x = 11770, y = 6930, dir = Dir.S, chance = 100})
-- Construction Site
addSpecialSpawn({type = "construction", x = 12101, y = 6939, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "construction", x = 12057, y = 6957, dir = Dir.S, chance = 100})
-- Gun Shop
addSpecialSpawn({type = "86bounder", x = 12086, y = 6765, dir = Dir.S, chance = 100})
-- Warehouse
addSpecialSpawn({type = "cargo", x = 12161, y = 7079, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "cargo", x = 12162, y = 7101, dir = Dir.E, chance = 100})
-- Picnic Area
addSpecialSpawn({type = "86bounder", x = 12050, y = 7390, dir = Dir.E, chance = 100})
--Church
addSpecialSpawn({type = "school", x = 11965, y = 7013, dir = Dir.W, chance = 100})
-- Police Station
addSpecialSpawn({type = "policeburnt", x = 11916, y = 6957, dir = Dir.NE, chance = 100, always = true})
addSpecialSpawn({type = "policeburnt", x = 11915, y = 6951, dir = Dir.SE, chance = 100, always = true})
addSpecialSpawn({type = "policeburnt", x = 11918, y = 6953, dir = Dir.S, chance = 100, always = true})
addSpecialSpawn({spawn = IS_ITEM, type = "Pistol", x = 11920, y = 6953, chance = 100})
--Farms
addSpecialSpawn({type = "burntcivilian", x = 10934, y = 6645, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "f700flatbed", x = 11163, y = 6850, dir = Dir.NE, chance = 100})
-- 
 addSpecialSpawn({spawn = IS_DRESSEDBODIES, type = "Police", x = 11908, x2 = 11925, y = 6950, y2 = 6967, chance = 100, amount = 100, blood = 35})

-- March Ridge
-- Entrance
addSpecialSpawn({type = "78amgeneralM35A2", x = 10359, y = 12401, dir = Dir.W, chance = 100})
addSpecialSpawn({type = "78amgeneralM35A2", x = 10370, y = 12401, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "m113a1", x = 10355, y = 12409, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "92amgeneralM998", x = 10370, y = 12408, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "92amgeneralM998", x = 10358, y = 12415, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "74amgeneralM151A2", x = 10355, y = 12404, dir = Dir.E, chance = 100})
--School
addSpecialSpawn({type = "schoolbus", x = 10008, y = 12687, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "schoolbusshort", x = 10012, y = 12678, dir = Dir.W, chance = 100})
-- Church
addSpecialSpawn({type = "schoolbus", x = 10357, y = 12788, dir = Dir.SW, chance = 100})

-- Riverside
-- Gated Community
addSpecialSpawn({type = "schoolbus", x = 6613, y = 5444, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "schoolbus", x = 6613, y = 5453, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "schoolbus", x = 6689, y = 5445, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "schoolbus", x = 6691, y = 5451, dir = Dir.S, chance = 100})
-- Construction Site East
addSpecialSpawn({type = "construction", x = 6736, y = 5258, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "construction", x = 6714, y = 5267, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "construction", x = 6733, y = 5277, dir = Dir.S, chance = 100})
-- Construction Site West
addSpecialSpawn({type = "construction", x = 6192, y = 5252, dir = Dir.W, chance = 100})
addSpecialSpawn({type = "construction", x = 6200, y = 5245, dir = Dir.N, chance = 100})
--Factories and Warehouse
addSpecialSpawn({type = "cargo", x = 5635, y = 5942, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "cargo", x = 5635, y = 5932, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "cargo", x = 5634, y = 5920, dir = Dir.N, chance = 100})
--School
addSpecialSpawn({type = "schoolbusshort", x = 6472, y = 5440, dir = Dir.N, chance = 100})
--Farm
addSpecialSpawn({type = "f700flatbed", x = 5777, y = 5709, dir = Dir.S, chance = 100})
--Trailer Park
addSpecialSpawn({type = "86bounder", x = 5325, y = 5939, dir = Dir.W, chance = 100})
--Police Station
addSpecialSpawn({type = "m113a1", x = 6105, y = 5245, dir = Dir.S, chance = 100})
-- Junkyard
addSpecialSpawn({type = "VanSeatsBurnt", x = 5798, y = 5391, dir = Dir.SW, chance = 100,})
--Country Club
addSpecialSpawn({type = "f700box", x = 5964, y = 6500, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "isuzubox", x = 5972, y = 6525, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "isuzuboxfood", x = 5745, y = 6416, dir = Dir.N, chance = 100})
--Giga Mart
addSpecialSpawn({type = "isuzuboxfood", x = 6496, y = 5366, dir = Dir.S, chance = 100})

-- Dixies
addSpecialSpawn({type = "86bounder", x = 11626, y = 8854, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "f700flatbed", x = 11580, y = 8808, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "burntcivilian", x = 11497, y = 8916, dir = Dir.SE, chance = 100})

-- Valley Station
-- Mall
addSpecialSpawn({type = "delivery", x = 13887, y = 5899, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "delivery", x = 14006, y = 5798, dir = Dir.NE, chance = 100})
--Construction Site West
addSpecialSpawn({type = "construction", x = 12598, y = 5380, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "86bounder", x = 12593, y = 5412, dir = Dir.E, chance = 100})
--Construction Site East
addSpecialSpawn({type = "construction", x = 14118, y = 5470, dir = Dir.W, chance = 100})
--Warehouse
addSpecialSpawn({type = "cargo", x = 12629, y = 4692, dir = Dir.W, chance = 100})
--Muddy Bank
addSpecialSpawn({type = "PickupBurnt", x = 12339, y = 7360, dir = Dir.SW, chance = 100})
--NW Farms
addSpecialSpawn({type = "burntcivilian", x = 14619, y = 4542, dir = Dir.NW, chance = 100})
addSpecialSpawn({type = "f700flatbed", x = 13866, y = 4635, dir = Dir.W, chance = 100})
addSpecialSpawn({type = "burntcivilian", x = 13556, y = 5020, dir = Dir.N, chance = 100})
-- Lumber Heap
addSpecialSpawn({type = "86bounder", x = 14267, y = 5737, dir = Dir.S, chance = 100})
-- Gun Range
addSpecialSpawn({type = "burntcivilian", x = 13316, y = 5445, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "burntcivilian", x = 13322, y = 5452, dir = Dir.W, chance = 100})
addSpecialSpawn({type = "burntcivilian", x = 13307, y = 5449, dir = Dir.NE, chance = 100})


--Rosewood
--Construction Site
addSpecialSpawn({type = "86bounder", x = 8224, y = 11805, dir = Dir.W, chance = 100})
addSpecialSpawn({type = "construction", x = 8241, y = 11846, dir = Dir.W, chance = 100})
addSpecialSpawn({type = "construction", x = 8242, y = 11852, dir = Dir.E, chance = 100})
--School
addSpecialSpawn({type = "schoolbus", x = 8310, y = 11607, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "schoolbusshort", x = 8338, y = 11587, dir = Dir.W, chance = 100})

--Westies
addSpecialSpawn({type = "86bounder", x = 4601, y = 8604, dir = Dir.N, chance = 100})
-- Camp
addSpecialSpawn({type = "schoolbusshort", x = 4989, y = 8009, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "schoolbus", x = 5017, y = 8020, dir = Dir.W, chance = 100})
--Central Farm
addSpecialSpawn({type = "cargo", x = 6801, y = 9988, dir = Dir.NW, chance = 100})
addSpecialSpawn({type = "cargo", x = 6801, y = 9988, dir = Dir.N, chance = 100})

--Central Farm
addSpecialSpawn({type = "cargo", x = 6770, y =10037, dir = Dir.SE, chance = 100})

--Small Town
addSpecialSpawn({type = "isuzubox", x = 7241, y = 8328, dir = Dir.SW, chance = 100})
addSpecialSpawn({type = "isuzuboxmccoy", x = 7255, y = 8347, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "f700box", x = 7278, y = 8556, dir = Dir.W, chance = 100})
--Farm Worker Dorms?
addSpecialSpawn({type = "schoolbusshort", x = 7476, y = 7985, dir = Dir.N, chance = 100})

--Farm With Well
addSpecialSpawn({type = "PickupBurnt", x = 8615, y = 8896, dir = Dir.S, chance = 100})
-- Van Down By The River
addSpecialSpawn({type = "VanSeatsBurnt", x = 6443, y = 8301, dir = Dir.NW, chance = 100})

-- Muldraugh
--Big Warehouse
addSpecialSpawn({type = "isuzubox", x = 10632, y = 9310, dir = Dir.E, chance = 100})
--Electronics Store
addSpecialSpawn({type = "isuzubox", x = 10631, y = 9893, dir = Dir.E, chance = 100})
--Soccer Field
addSpecialSpawn({type = "school", x = 10680, y = 9960, dir = Dir.SW, chance = 100})
--Small Storage
addSpecialSpawn({type = "storage", x = 10768, y = 10348, dir = Dir.NE, chance = 100})
--Warhouses
addSpecialSpawn({type = "isuzubox", x = 10719, y = 10438, dir = Dir.S, chance = 100})

-- Construction Site West
addSpecialSpawn({type = "construction", x = 10079, y = 9598, dir = Dir.NW, chance = 100})
addSpecialSpawn({type = "construction", x = 10053, y = 9595, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "construction", x = 10109, y = 9567, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "86bounder", x = 10125, y = 9540, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "construction", x = 10109, y = 9552, dir = Dir.S, chance = 100})
-- Warehouses West
addSpecialSpawn({type = "cargo", x = 10027, y = 10934, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "cargo", x = 10027, y = 10955, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "cargo", x = 10120, y = 10856, dir = Dir.W, chance = 100})
addSpecialSpawn({type = "cargo", x = 10259, y = 10974, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "cargo", x = 10261, y = 11017, dir = Dir.N, chance = 100})
addSpecialSpawn({type = "cargo", x = 10098, y = 10896, dir = Dir.W, chance = 100})
-- Dirt
addSpecialSpawn({type = "f700dump", x = 10459, y = 10072, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "86bounder", x = 10413, y = 10211, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "schoolbusshort", x = 10410, y = 10232, dir = Dir.N, chance = 100})
-- Railyard
addSpecialSpawn({type = "cargo", x = 11706, y = 9829, dir = Dir.N, chance = 100})
-- NE Rail Crossing
addSpecialSpawn({type = "ModernCar02Burnt", x = 11107, y = 9315, dir = Dir.SE, chance = 100})
--Abandoned Cabins
addSpecialSpawn({type = "schoolbusshort", x = 10976, y = 9135, dir = Dir.SW, chance = 100})
--North Farm
addSpecialSpawn({type = "f700flatbed", x = 10833, y = 9144, dir = Dir.N, chance = 100})
-- South Trailers
addSpecialSpawn({type = "86bounder", x = 10842, y = 10357, dir = Dir.N, chance = 100})
-- Pond
addSpecialSpawn({type = "burntcivilian", x = 10985, y = 10249, dir = Dir.NE, chance = 100})
--NW Forest Lot
addSpecialSpawn({type = "86bounder", x = 10288, y = 8790, dir = Dir.W, chance = 100})

-- Secret Base
addSpecialSpawn({type = "78amgeneralM35A2", x = 5530, y = 12496, dir = Dir.W, chance = 100})
addSpecialSpawn({type = "92amgeneralM998", x = 5520, y = 12487, dir = Dir.NE, chance = 100})
addSpecialSpawn({type = "f700box", x = 5527, y = 12490, dir = Dir.W, chance = 100})
addSpecialSpawn({type = "78amgeneralM35A2", x = 5787, y = 12491, dir = Dir.NE, chance = 100})
addSpecialSpawn({type = "m113a1", x = 5606, y = 12484, dir = Dir.NE, chance = 100})
addSpecialSpawn({type = "74amgeneralM151A2", x = 5612, y = 12492, dir = Dir.SW, chance = 100})
addSpecialSpawn({type = "78amgeneralM35A2", x = 5613, y = 12483, dir = Dir.NE, chance = 100})
addSpecialSpawn({type = "92amgeneralM998", x = 5587, y = 12477, dir = Dir.NW, chance = 100})
addSpecialSpawn({type = "78amgeneralM35A2", x = 5588, y = 12490, dir = Dir.W, chance = 100})
addSpecialSpawn({type = "92amgeneralM998", x = 5824, y = 12485, dir = Dir.N, chance = 100})
--Western Gas Station
addSpecialSpawn({type = "school", x = 3702, y = 8486, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "cargo", x = 3751, y = 8404, dir = Dir.SW, chance = 100})
--Rural Warehouses South
addSpecialSpawn({type = "cargo", x = 9195, y = 11811, dir = Dir.W, chance = 100})

-- NE Firebreak
addSpecialSpawn({type = "burntcivilian", x = 12097, y = 7912, dir = Dir.NE, chance = 100})
addSpecialSpawn({type = "burntcivilian", x = 12081, y = 7920, dir = Dir.S, chance = 100})
addSpecialSpawn({type = "burntcivilian", x = 12100, y = 7923, dir = Dir.W, chance = 100})

addSpecialSpawn({type = "burntcivilian", x = 12127, y = 7924, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "burntcivilian", x = 12047, y = 7909, dir = Dir.NW, chance = 100})
addSpecialSpawn({type = "burntcivilian", x = 12114, y = 7943, dir = Dir.E, chance = 100})

-- Paul's Diner
addSpecialSpawn({type = "cargo", x = 10150, y = 11182, dir = Dir.SW, chance = 100})

-- Railyard
addSpecialSpawn({type = "cargo", x = 11849, y = 9793, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "cargo", x = 11850, y = 9788, dir = Dir.E, chance = 100})
addSpecialSpawn({type = "cargo", x = 11850, y = 9783, dir = Dir.E, chance = 100})

if isMod("Dunebuggywindows") then
	local dunebug = "Dunebuggywindows"	
	addSpecialSpawn({type = dunebug, x = 12844, y = 6437, dir = Dir.NE, chance = 100})
	addSpecialSpawn({type = dunebug, x = 12875, y = 6438, dir = Dir.N, chance = 100})
	addSpecialSpawn({type = dunebug, x = 12881, y = 6438, dir = Dir.NW, chance = 100})
	addSpecialSpawn({type = dunebug, x = 12861, y = 6416, dir = Dir.SE, chance = 100})	
	
	addSpecialSpawn({type = dunebug, x = 5815, y = 6426, dir = Dir.E, chance = 100})
	addSpecialSpawn({type = dunebug, x = 5820, y = 6438, dir = Dir.NE, chance = 100})
		
	addSpecialSpawn({type = dunebug, x = 8030, y = 12487, dir = Dir.E, chance = 100})
	addSpecialSpawn({type = dunebug, x = 8040, y = 12515, dir = Dir.E, chance = 100})
elseif  isMod("Dunebuggy") then
	local dunebug = "Dunebuggy"	
	addSpecialSpawn({type = dunebug, x = 12844, y = 6437, dir = Dir.NE, chance = 100})
	addSpecialSpawn({type = dunebug, x = 12875, y = 6438, dir = Dir.N, chance = 100})
	addSpecialSpawn({type = dunebug, x = 12881, y = 6438, dir = Dir.NW, chance = 100})
	addSpecialSpawn({type = dunebug, x = 12861, y = 6416, dir = Dir.SE, chance = 100})
	
	addSpecialSpawn({type = dunebug, x = 5815, y = 6426, dir = Dir.E, chance = 100})
	addSpecialSpawn({type = dunebug, x = 5820, y = 6438, dir = Dir.NE, chance = 100})

	addSpecialSpawn({type = dunebug, x = 8030, y = 12487, dir = Dir.E, chance = 100})
	addSpecialSpawn({type = dunebug, x = 8040, y = 12515, dir = Dir.E, chance = 100})
end

-- if dunebug then
	
	-- addSpecialSpawn({type = dunebug, x = 12844, y = 6437, dir = Dir.NE, chance = 100})
	-- addSpecialSpawn({type = dunebug, x = 12875, y = 6438, dir = Dir.N, chance = 100})
	-- addSpecialSpawn({type = dunebug, x = 12881, y = 6438, dir = Dir.NW, chance = 100})
	-- addSpecialSpawn({type = dunebug, x = 12861, y = 6416, dir = Dir.SE, chance = 100})

-- end



if isMod("FORTREDSTONE") then
    -- Highway Turnoff
    addSpecialSpawn({type = "78amgeneralM35A2", x = 5548, y = 11215, dir = Dir.E, chance = 100})
    -- Front Gate
    addSpecialSpawn({type = "78amgeneralM35A2", x = 5548, y = 11597, dir = Dir.W, chance = 100})
    -- Hangar
    addSpecialSpawn({type = "78amgeneralM35A2", x = 5594, y = 11814, dir = Dir.E, chance = 100})
    -- Bunkers
    addSpecialSpawn({type = "78amgeneralM35A2", x = 5487, y = 11791, dir = Dir.E, chance = 100})
    -- Garage
    --addSpecialSpawn({type = "78amgeneralM35A2", x = 5499, y = 11764, dir = Dir.S, chance = 100})
    addSpecialSpawn({type = "78amgeneralM35A2", x = 5493, y = 11766, dir = Dir.SE, chance = 100})
    --addSpecialSpawn({type = "92amgeneralM998", x = 5514, y = 11761, dir = Dir.S, chance = 100})
    -- Helipad
    addSpecialSpawn({type = "78amgeneralM35A2", x = 5542, y = 11656, dir = Dir.NW, chance = 100})
    --Loading Dock
    addSpecialSpawn({type = "78amgeneralM35A2", x = 5475, y = 11614, dir = Dir.S, chance = 100})
end

if isMod("BedfordFalls") then
end

if isMod("Mod_Phoenix") then
    --Quarentined Apartment Building
    addSpecialSpawn({type = "militarytruck", x = 11225, y = 11232, dir = Dir.S, chance = 100})
    addSpecialSpawn({type = "militarytruck", x = 11233, y = 11230, dir = Dir.SE, chance = 100})
    addSpecialSpawn({type = "military", x = 11251, y = 11219, dir = Dir.E, chance = 100})
    addSpecialSpawn({type = "cargo", x = 11215, y = 11220, dir = Dir.W, chance = 100})
    --Quarentine East
    addSpecialSpawn({type = "militarynocargo", x = 11331, y = 11127, dir = Dir.N, chance = 100})
    addSpecialSpawn({type = "militarynocargo", x = 11330, y = 11239, dir = Dir.SE, chance = 100})
    addSpecialSpawn({type = "militarynocargo", x = 11331, y = 11247, dir = Dir.E, chance = 100})
    addSpecialSpawn({type = "militarynocargo", x = 11371, y = 11333, dir = Dir.EE, chance = 100})
    --Quarentine South
    addSpecialSpawn({type = "militarynocargo", x = 11303, y = 11372, dir = Dir.W, chance = 100})
    --Quarentine West
    addSpecialSpawn({type = "militarynocargo", x = 11153, y = 11247, dir = Dir.SW, chance = 100})
    addSpecialSpawn({type = "militarynocargo", x = 11154, y = 11298, dir = Dir.N, chance = 100})
    --Quarentine North
    addSpecialSpawn({type = "militarynocargo", x = 11207, y = 11104, dir = Dir.NW, chance = 100})
    addSpecialSpawn({type = "militarynocargo", x = 11266, y = 11105, dir = Dir.E, chance = 100})

    addSpecialSpawn({type = "cargo", x = 11512, y = 11087, dir = Dir.E, chance = 100})
    addSpecialSpawn({type = "cargo", x = 11501, y = 11138, dir = Dir.S, chance = 100})
    addSpecialSpawn({type = "cargo", x = 11513, y = 11126, dir = Dir.S, chance = 100})
    addSpecialSpawn({type = "cargo", x = 11520, y = 11127, dir = Dir.S, chance = 100})
    addSpecialSpawn({type = "cargo", x = 11548, y = 11132, dir = Dir.S, chance = 100})
    addSpecialSpawn({type = "cargo", x = 11616, y = 11115, dir = Dir.N, chance = 100})
    addSpecialSpawn({type = "cargo", x = 11618, y = 11136, dir = Dir.E, chance = 100})
    addSpecialSpawn({type = "storage", x = 11765, y = 11022, dir = Dir.S, chance = 100})
    addSpecialSpawn({type = "cargo", x = 11662, y = 10953, dir = Dir.NE, chance = 100})

    --CST Construction Site
    addSpecialSpawn({type = "construction", x = 11875, y = 11219, dir = Dir.N, chance = 100})
    addSpecialSpawn({type = "construction", x = 11876, y = 11243, dir = Dir.S, chance = 100})
    addSpecialSpawn({type = "construction", x = 11893, y = 11245, dir = Dir.SE, chance = 100})

    --SE Retail
    addSpecialSpawn({type = "cargo", x = 12013, y = 11489, dir = Dir.W, chance = 100})
    addSpecialSpawn({type = "cargo", x = 12013, y = 11525, dir = Dir.W, chance = 100})
    addSpecialSpawn({type = "cargo", x = 12018, y = 11569, dir = Dir.W, chance = 100})
    addSpecialSpawn({type = "cargo", x = 12097, y = 11578, dir = Dir.S, chance = 100})
    addSpecialSpawn({type = "cargo", x = 12109, y = 11577, dir = Dir.S, chance = 100})

    --Self Storage
    addSpecialSpawn({type = "storage", x = 11681, y = 11308, dir = Dir.W, chance = 100})

    --South Construction Site
    addSpecialSpawn({type = "86bounder", x = 11779, y = 11502, dir = Dir.SE, chance = 100})
    addSpecialSpawn({type = "construction", x = 11810, y = 11465, dir = Dir.E, chance = 100})
    addSpecialSpawn({type = "construction", x = 11801, y = 11453, dir = Dir.SE, chance = 100})
    addSpecialSpawn({type = "construction", x = 11734, y = 11517, dir = Dir.SE, chance = 100})

end