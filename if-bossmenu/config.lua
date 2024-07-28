Config = Config or {}

Config.Framework = 'qbcore' -- esx or qbcore

Config.RealJob = {
    'police',
    'ambulance',
    'mechanic',
    'taxi',
    'realestateagent',
    'cardealer',
    'banker',
    'reporter',
}

Config.UseCommand = true

Config.PolyData = {
    [1] = {
        name = "bossmenu_1",
        heading = 12.0,
        debugPoly = true,
        minZ = 30.69 - 1,
        maxZ = 30.69 + 1,
        width = 1.5,
        length = 1.6,
        coords = vector3(441.81, -978.95, 30.69),
        job = 'police',
    }
}
