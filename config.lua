--[[
    City Hall Configuration
    Complete config for licenses, jobs, NPCs, and blips
]]

Config = {
    -- Use qb-target for interactions
    UseTarget = GetConvar('UseTarget', 'false') == 'true',
    
    -- Debug Settings
    Debug = false,
    
    -- City Hall Locations with per-location license configuration
    Cityhalls = {
        {
            coords = vector3(-265.0, -963.6, 31.2),
            showBlip = true,
            blipData = {
                sprite = 487,
                display = 4,
                scale = 0.65,
                colour = 0,
                title = 'City Services'
            },
            licenses = {
                ['id_card'] = {
                    label = 'ID Card',
                    cost = 50,
                    description = 'Official government identification'
                },
                ['driver_license'] = {
                    label = 'Driver License',
                    cost = 50,
                    description = 'Required to drive vehicles legally',
                    metadata = 'driver'
                },
                ['weaponlicense'] = {
                    label = 'Weapon License',
                    cost = 150,
                    description = 'Required to legally carry firearms',
                    metadata = 'weapon'
                }
            },
            jobs = {
                {
                    id = 'trucker',
                    label = 'Trucker',
                    description = 'Transport cargo across the map',
                    isManaged = false
                },
                {
                    id = 'taxi',
                    label = 'Taxi Driver',
                    description = 'Provide transportation services to citizens',
                    isManaged = false
                },
                {
                    id = 'tow',
                    label = 'Tow Truck Driver',
                    description = 'Recover and tow abandoned vehicles',
                    isManaged = false
                },
                {
                    id = 'reporter',
                    label = 'News Reporter',
                    description = 'Report on breaking news events',
                    isManaged = false
                },
                {
                    id = 'garbage',
                    label = 'Garbage Collector',
                    description = 'Collect waste from around the city',
                    isManaged = false
                },
                {
                    id = 'bus',
                    label = 'Bus Driver',
                    description = 'Operate public bus routes',
                    isManaged = false
                }
            }
        }
        -- Add more cityhalls below this
        -- {
        --     coords = vector3(x, y, z),
        --     showBlip = true,
        --     blipData = { ... },
        --     licenses = { ... },
        --     jobs = { ... }
        -- }
    },

    -- NPCs at City Halls
    Peds = {
        {
            model = 'a_m_m_hasjew_01',
            coords = vector4(-262.79, -964.18, 30.22, 181.71),
            scenario = 'WORLD_HUMAN_STAND_MOBILE',
            cityhall = true,
            zoneOptions = {
                length = 3.0,
                width = 3.0,
                debugPoly = false
            }
        }
        -- Add more NPCs below this
        -- {
        --     model = 'a_m_m_business_1',
        --     coords = vector4(x, y, z, heading),
        --     scenario = 'WORLD_HUMAN_CLIPBOARD',
        --     cityhall = true,
        --     zoneOptions = { ... }
        -- }
    },

    -- Job definitions (used by server for validation)
    Jobs = {
        trucker = { label = 'Trucker', isManaged = false },
        taxi = { label = 'Taxi', isManaged = false },
        tow = { label = 'Tow Truck', isManaged = false },
        reporter = { label = 'News Reporter', isManaged = false },
        garbage = { label = 'Garbage Collector', isManaged = false },
        bus = { label = 'Bus Driver', isManaged = false }
    }
}
