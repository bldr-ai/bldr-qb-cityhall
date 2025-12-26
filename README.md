![City Services](https://bldr.is-pretty.cool/79p5snS.png)
![City Services](https://bldr.is-pretty.cool/8b36Wfd.gif)
![City Services](https://bldr.is-pretty.cool/2QMRBio.gif)
# City Hall Script - QBCore Integration Guide

## Overview
This script is fully integrated with QBCore framework and features:
- License purchasing with player money validation
- Job applications with QBCore job system
- Beautiful React NUI interface
- Multi-location support
- qb-target and PolyZone compatibility

## Setup Instructions

### 1. Server Configuration
In your `server.cfg`, add:
```
setr UseTarget true    # Set to 'false' for PolyZone/key press interaction
```

### 2. Dependencies
Make sure you have these resources running:
- `qb-core`
- `qb-inventory`
- `qb-target` (if UseTarget is enabled)
- `qb-logs` (optional, for purchase logging)

### 3. Configuration
Edit `/config.lua` to:
- Add your city hall locations
- Customize license prices
- Adjust NPC positions and scenarios
- Add or remove jobs

## How It Works

### License Purchase Flow
1. Player interacts with NPC (qb-target or E key)
2. Beautiful menu opens with license options
3. Player clicks "Purchase" on a license
4. Server validates:
   - License exists
   - Player has enough cash
   - Player inventory has space
5. Server:
   - Removes money from player
   - Creates item with player info (name, DOB, etc.)
   - Adds to inventory
   - Shows notification
   - Logs transaction

### Job Application Flow
1. Player opens menu and clicks "Public Jobs"
2. Selects desired job
3. Server:
   - Validates job exists
   - Sets player job
   - Shows confirmation
   - Logs action

## Configuration Details

### License Item Info
Each license type stores specific information:

**ID Card:**
- Citizen ID
- First/Last Name
- Birth Date
- Gender
- Nationality

**Driver License:**
- First/Last Name
- Birth Date
- Gender
- License Type (Class A)

**Weapon License:**
- First/Last Name
- Birth Date
- Expiration (lifetime)

### Adding New Licenses
In `/config.lua` under `Cityhalls[].licenses`:
```lua
['my_license'] = {
    label = 'My License',
    cost = 100,
    description = 'Description here',
    metadata = 'optional_type'
}
```

Server will automatically handle based on the ID and build appropriate item info.

### Adding New Jobs
In `/config.lua` under `Cityhalls[].jobs`:
```lua
{
    id = 'my_job',
    label = 'My Job Title',
    description = 'Job description',
    isManaged = false
}
```

Also add to `Config.Jobs`:
```lua
my_job = { label = 'My Job Title', isManaged = false }
```

### Multiple Cityhalls
Add to `Config.Cityhalls`:
```lua
{
    coords = vector3(x, y, z),
    showBlip = true,
    blipData = { ... },
    licenses = { ... },
    jobs = { ... }
}
```

Add NPCs for each location in `Config.Peds`:
```lua
{
    model = 'a_m_m_hasjew_01',
    coords = vector4(x, y, z, heading),
    scenario = 'WORLD_HUMAN_STAND_MOBILE',
    cityhall = true,
    zoneOptions = { ... }
}
```

## Server Events

### Purchase License
```
Event: 'cityhall:server:purchaseLicense'
Args: licenseType (string), hallIndex (number)
```

### Apply for Job
```
Event: 'cityhall:server:applyJob'
Args: jobId (string), hallIndex (number)
```

## Testing

### With /cityhall command
```
/cityhall
```
Opens the first cityhall location.

### With NPC Interaction
1. Go to city hall location
2. With qb-target: Click on NPC
3. Without qb-target: Stand near NPC and press E

## Customization

### Changing Menu Colors
Edit `/web/App.tsx` - look for `text-red-600` and `from-red-700` to change the red accent color.

### Changing Notifications
QBCore uses built-in `QBCore:Notify` system. You can customize notification style in your qb-core resource.

### Adding Custom Item Info
Edit the `RegisterNetEvent('cityhall:server:purchaseLicense')` function in `/server/main.lua` to add logic for new license types.

## Troubleshooting

### "You don't have enough money" shows incorrectly
- Check qb-core money system is working (`/givecash` command)
- Verify license cost in config

### Items not appearing in inventory
- Check qb-inventory is running
- Verify item names exist in qb-core items
- Check inventory slots available

### NPC not spawning
- Verify ped model name is correct (must be exact case match)
- Check coordinates are valid GTA locations
- Use `Config.Debug = true` to see console errors

### Interaction not working
- If using qb-target: Verify `UseTarget = true` in server.cfg
- If using PolyZone: Verify `UseTarget = false` in server.cfg
- Check player is close enough to NPC (default 2.0 units)

## File Structure
```
root/
├── config.lua           # All configuration
├── fxmanifest.lua       # Resource manifest
├── client/
│   ├── main.lua         # Client logic
│   └── nui.lua          # NUI callbacks
├── server/
│   └── main.lua         # Server logic
└── web/
    ├── App.tsx          # Main UI component
    ├── hooks/
    │   └── useNui.ts    # NUI communication
    └── public/
        └── index.html   # HTML entry point
```

## Support
For issues or questions, check:
1. Console for error messages
2. Server logs for validation errors
3. Player inventory if items missing
4. QBCore documentation for framework-specific issues
