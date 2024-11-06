Config = Config or {}

Config.Framework = '' -- esx or qbcore

Config.RealJob = {
    'police',
    'ambulance',
    'mechanic',
    'taxi',
    'realestateagent',
    'cardealer',
    'banker',
    'reporter'
}

Config.MenuInteraction = {
    type = 'target',                  -- 'command' or 'target' or 'poly'. 'command' = access using /bossmenu, 'target' access using target, 'poly' access using ox_lib Zones.
    targetResourceName = 'ox_target', -- if using target, sets the resource. Suported: 'ox_target', 'qb-target'
    commandName = 'bossmenu'          -- if using command, sets the command.
}

-- Interact menu locations (used for poly and target)
Config.MenuLocations = {
    {
        name = "bossmenu_1",
        heading = 12.0,
        debugPoly = false,
        minZ = 30.69 - 1,
        maxZ = 30.69 + 1,
        width = 1.5,
        length = 1.6,
        coords = vector3(441.81, -978.95, 30.69),
        job = 'police',
        -- minGrade = 3 -- * optional, using it if you want to manually determine the minimum grade/level for opening the menu
    }
}
