
if VehicleZoneDistribution then -- check if the table exists for backwards compatibility


VehicleZoneDistribution.militarytruck = VehicleZoneDistribution.militarytruck or {}
VehicleZoneDistribution.militarytruck.vehicles = VehicleZoneDistribution.militarytruck.vehicles or {}
VehicleZoneDistribution.militarytruck.vehicles["Base.78amgeneralM35A2"] = {index = -1, spawnChance = 50};
VehicleZoneDistribution.militarytruck.vehicles["Base.78amgeneralM49A2"] = {index = -1, spawnChance = 50};
VehicleZoneDistribution.militarytruck.vehicles["Base.m35a2bed"] = nil;
VehicleZoneDistribution.militarytruck.vehicles["Base.m35a2covered"] = nil;
VehicleZoneDistribution.militarytruck.chanceToSpawnSpecial = 0;
VehicleZoneDistribution.militarytruck.spawnRate = 25;

VehicleZoneDistribution.militarycar = VehicleZoneDistribution.militarycar or {}
VehicleZoneDistribution.militarycar.vehicles = VehicleZoneDistribution.militarycar.vehicles or {}
VehicleZoneDistribution.militarycar.vehicles["Base.92amgeneralM998"] = {index = -1, spawnChance = 30};
VehicleZoneDistribution.militarycar.vehicles["Base.74amgeneralM151A2"] = {index = -1, spawnChance = 40};
VehicleZoneDistribution.militarycar.vehicles["Base.hmmwvht"] = nil;
VehicleZoneDistribution.militarycar.vehicles["Base.hmmwvtr"] = nil;
VehicleZoneDistribution.militarycar.vehicles["Base.m151canvas"] = nil;
VehicleZoneDistribution.militarycar.chanceToSpawnSpecial = 0;
VehicleZoneDistribution.militarycar.spawnRate = 25;

VehicleZoneDistribution.militaryfuel = VehicleZoneDistribution.militaryfuel or {}
VehicleZoneDistribution.militaryfuel.vehicles = VehicleZoneDistribution.militaryfuel.vehicles or {}
VehicleZoneDistribution.militaryfuel.vehicles["Base.78amgeneralM49A2C"] = {index = -1, spawnChance = 80};
VehicleZoneDistribution.militaryfuel.vehicles["Base.Trailerfuelmedium"] = {index = -1, spawnChance = 20};
VehicleZoneDistribution.militaryfuel.vehicles["Base.m35a2fuel"] = nil;
VehicleZoneDistribution.militaryfuel.vehicles["Base.TrailerM967tanker"] = nil;
VehicleZoneDistribution.militaryfuel.chanceToSpawnSpecial = 0;
VehicleZoneDistribution.militaryfuel.spawnRate = 25;

VehicleZoneDistribution.militarytank = VehicleZoneDistribution.militarytank or {}
VehicleZoneDistribution.militarytank.vehicles = VehicleZoneDistribution.militarytank.vehicles or {}
VehicleZoneDistribution.militarytank.vehicles["Base.67commando"] = nil;
VehicleZoneDistribution.militarytank.vehicles["Base.67commandoT50"] = nil;
VehicleZoneDistribution.militarytank.vehicles["Base.M113_APC"] = nil;
VehicleZoneDistribution.militarytank.chanceToSpawnSpecial = 0;
VehicleZoneDistribution.militarytank.spawnRate = 10;

-- TrailerM1082, TrailerM1082tarp, TrailerM1095, TrailerM1095tarp
VehicleZoneDistribution.militaryp19 = VehicleZoneDistribution.militaryp19 or {}
VehicleZoneDistribution.militaryp19.vehicles = VehicleZoneDistribution.militaryp19.vehicles or {}
VehicleZoneDistribution.militaryp19.vehicles["Base.86oshkoshUSMC"] = {index = -1, spawnChance = 30};
VehicleZoneDistribution.militaryp19.vehicles["Base.86oshkoshFRTR55"] = nil;
VehicleZoneDistribution.militaryp19.vehicles["Base.TrailerM1082tarp"] = {index = -1, spawnChance = 15};
VehicleZoneDistribution.militaryp19.vehicles["Base.TrailerM101A3cargo"] = {index = -1, spawnChance = 15};
VehicleZoneDistribution.militaryp19.vehicles["Base.TrailerM1095"] = {index = -1, spawnChance = 15};
VehicleZoneDistribution.militaryp19.vehicles["Base.TrailerM1095tarp"] = {index = -1, spawnChance = 15};
VehicleZoneDistribution.militaryp19.chanceToSpawnSpecial = 0;
VehicleZoneDistribution.militaryp19.spawnRate = 10;

VehicleZoneDistribution.militarysemi = VehicleZoneDistribution.militarysemi or {}
VehicleZoneDistribution.militarysemi.vehicles = VehicleZoneDistribution.militarysemi.vehicles or {}
VehicleZoneDistribution.militarysemi.vehicles["Base.86oshkoshUSMC"] = {index = -1, spawnChance = 20};
VehicleZoneDistribution.militarysemi.vehicles["Base.82oshkoshM911B"] = nil;
VehicleZoneDistribution.militarysemi.vehicles["Base.TrailerM1082"] = {index = -1, spawnChance = 25};
VehicleZoneDistribution.militarysemi.vehicles["Base.TrailerM101A3cargo"] = {index = -1, spawnChance = 25};
VehicleZoneDistribution.militarysemi.vehicles["Base.TrailerM747lowbed"] = nil;
VehicleZoneDistribution.militarysemi.vehicles["Base.82oshkoshM911"] = nil;
VehicleZoneDistribution.militarysemi.vehicles["Base.TrailerM128van"] = nil;
VehicleZoneDistribution.militarysemi.vehicles["Base.TrailerM129van"] = nil;
VehicleZoneDistribution.militarysemi.chanceToSpawnSpecial = 0;
VehicleZoneDistribution.militarysemi.spawnRate = 10;


end