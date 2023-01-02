# Automod
This is a lightweight vehicle system for Garry's Mod. Not many vehicles are supported outside of popular creators including TDM, SGM, and LW, which is one of the reasons why this addon is not on the workshop. My original plan was to add a system that would allow vehicle creators to add support for their own vehicles through their own addon, but I have since moved onto other projects and this is no longer a priority. If you are a vehicle creator who is interested in Automod and would like to see a system like this added, please let me know.

## Features:
- Vehicle health system
    - Vehicles can be damaged through bullets, explosives, physical contact with objects at high speeds, and any other normal means.
    - Players can use the primary fire of the repair tool to repair a vehicle to full health.
    - Repair kits can also be used to restore up to 30% of a damaged vehicle's HP by touching it with the vehicle.
    - Tire damage
        - Tires will deflate after receiving enough damage from either bullets or spike strips.
        - Tires can be repaired with the secondary fire of the repair tool.
        - Deflated tires will cause the vehicle to slow down.
        - Tires will only deflate a little at first and won't deflate any further unless the vehicle keeps moving.
- Brake locking
    - Brakes will lock on a vehicle if the driver holds their jump key as they exit the vehicle.
    - Prevents the vehicle from rolling away when parked on a slope or if the driver jumps out while it's still moving.
    - The brakes can be released by pressing the primary fire of the vehicle management tool for towing purposes if the vehicle is locked and cannot be driven away.
- Steering wheel locking
    - The front wheels will lock into a turned position if the driver keeps them turned as they exit the vehicle.
- Passenger seats
    - Supported vehicles will spawn with passenger seats.
    - Players can switch between seats using the number keys.
    - The driver can kick passengers out by holding alt and pressing the number keys.
- Horns
    - Currently, vehicles can have either a car horn or a truck horn.
- Door locking
    - Drivers can lock their vehicle's doors to prevent any other players from getting in.
    - Locking the doors does not prevent players who are already in the vehicle from getting out.
    - An alarm will sound if a player starts lockpicking a vehicle on DarkRP.
- Customizable controls
   - All controls besides the seat number keys can be reconfigured.
   - By default, all controls are setup to avoid conflicting with Photon controls.
- Fuel system
    - Fuel will be consumed when the throttle is down.
    - Fuel can be replenished through the fuel can entity or SWEP.
- Vehicle HUD
    - HUD appears in the bottom right of the screen when the player enters the driver's seat.
    - HUD adapts it's position based on the current vehicle's Photon support.
    - More detailed features of the HUD are listed below.
- Cruise control
    - Throttle will always start out slow. Drivers can increase/decrease cruise speed by pressing forward/backward.
    - Pressing jump or the cruise toggle key will disable cruise control.
- Vehicle data
    - Data tables for each vehicle that contain info about health, seat positions, horn sound, etc. are stored as linted JSON files to allow for easy editing.
    - A vehicle creation function is also included to add Automod support to your own vehicles.
- Manual vehicle engine toggle
    - Pressing the designated key will turn off the engine without requiring the driver to leave the vehicle.
    - While the engine is off, all default Gmod vehicle controls are disabled.
- Support for other addons
  - Vehicles will ignite when their health reaches 0 if VFire is installed.
  - Simfphy's vehicles are also affected by the spike strip.
  - GChroma support that highlights Automod controls when a player enters the drivers seat of a vehicle.
    - If the GChroma sandbox module is installed, the lighting sequence from that addon will be restored when a player exits a vehicle.

&nbsp;

## Current HUD Features:
Specific features for the vehicle HUD are listed here to avoid overcrowding the features list.
<br>
__Note: All HUD elements for this addon were made for a resolution of 1920x1080. I tried my best to accommodate for most other resolutions but I can't guarantee that they will scale properly.__

- Health is displayed as a fraction. It can be color-coded for certain situations. White indicates that the health is good. Green indicates that the vehicle is in god mode and cannot be damaged. Red indicates that the vehicle is at 25% health or less.
- Door lock status is displayed below the vehicle's health. It can be one of two colors: Orange indicates that the vehicle is unlocked and white indicates that the vehicle is locked.
- Cruise control status is displayed below the door lock status. It can be one of two colors: Green indicates that cruise control is currently active and white indicates that cruise control is disabled. If cruise control is enabled, the HUD will also display the percentage of throttle being used.
- Fuel level is displayed below the cruise control status as a color-coded progress bar. It can be a total of three colors: Green indicates the fuel level is 100%-50%, orange indicates 49%-26%, and red indicates 25%-0%.

&nbsp;

## Issues & Pull Requests
 If you would like to contribute to this repository by creating an issue or pull request, please refer to the [contributing guidelines.](https://lambdagaming.github.io/contributing.html)

&nbsp;

## Credits
- [Simfphy's Lua Vehicle Base](https://github.com/Blu-x92/simfphys_base) for part of the passenger seat spawn code.
- SCS for the horn sounds.
