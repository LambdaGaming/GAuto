# GAuto
GAuto is a lightweight vehicle system for Garry's Mod that extends the default functionality of vehicles based on the built-in jeep and airboat entities. All vehicles made by popular creators TDM, SGM, and LW before September 2023 are supported out of the box. A few select vehicles outside of these creators are also supported. I will not be adding support to any more vehicles myself, but contributions that add support are welcome, and vehicle creators are encouraged to add support to their own addons. A full list of supported addons can be found [here.](https://steamcommunity.com/sharedfiles/filedetails/?id=3018834846) GAuto is now also available on the [Steam workshop.](https://steamcommunity.com/sharedfiles/filedetails/?id=3048040907)

# Features
### Vehicle Health System
- Vehicles will smoke when their health drops to 30% or below, and they will catch fire and explode when their health reaches 0.
- If VFire is installed, vehicles that remain on fire for too long will become charred and permanently unfixable.
- Vehicles can be damaged through bullets, explosives, collisions, etc.
- The repair tool weapon and repair kit entity can be used to restore vehicle health.
### Tire Damage
- Tires will deflate after receiving enough damage from either bullets or spike strips.
- Tires can be repaired with the secondary fire of the repair tool.
- Deflated tires will cause the vehicle to slow down and become harder to control.
### Vehicle HUD
- HUD appears on the right when player enters the driver's seat.
- Displays vehicle's health, fuel level, door lock status, and cruise control status.
### Brake Locking
- Brakes will only lock on a vehicle if the driver holds their jump key as they exit the vehicle.
- Brakes can be released with the vehicle management tool for towing purposes if the vehicle is locked and cannot be driven away.
### Steering Wheel Locking
- The front wheels will lock into a turned position if the driver keeps them turned as they exit the vehicle.
- Doesn't work on airboats since it causes them to spin forever.
### Passenger Seats
- Supported vehicles will spawn with multiple passenger seats.
- Players can switch between seats using the number keys.
- The driver can kick passengers out by holding alt and pressing the number keys.
- Unsupported vehicles will have a single passenger seat automatically placed next to the driver's seat if there's enough room.
### Horns
- All vehicles, both supported and unsupported, have a horn that can be used by pressing J.
- GAuto comes with 3 horn sounds, but when adding support to a vehicle, any sound can be used.
### Door Locking
- Drivers can lock their doors to prevent any other players from getting in, even when the driver leaves, by pressing N.
- Locking the doors does not prevent passengers from getting out.
### Fuel System
- Fuel is consumed when the throttle is pressed.
- Fuel can be replenished through the fuel can entity or weapon.
### Cruise Control
- Toggled by pressing V as the driver.
- Throttle will always start out slow. Drivers can increase/decrease cruise speed by pressing forward/backward.
### Vehicle Data
- Data tables for each vehicle that contain info about health, seat positions, horn sound, etc. are stored in formatted JSON files for easy editing.
- A vehicle creation tool is also included to easily add GAuto support to your own vehicles.
### Engine Toggle
- Pressing P will turn off the engine without requiring the driver to leave the vehicle.
### Customizable Controls
- All controls besides the seat number keys can be reassigned.
### Particles
- Dust will emit from the wheels when driving on certain surfaces including dirt, grass, and sand.
- Engine emits a plume of smoke when vehicle is heavily damaged.
- Engine emits a small flame when vehicle is destroyed.
- Charred vehicles will emit a small cloud of smoke.
- All particles can be disabled server-side if it causes performance issues.
- Not supported on airboats due to the lack of an engine attachment (and wheels).

# FAQs
### Is a lighting system planned?
No. Not only is that outside of my scope, it would also ruin the 'lightweight' aspect of the addon. If you want a lighting system to use with GAuto, I recommend [Photon 1](https://steamcommunity.com/sharedfiles/filedetails/?id=339648087) or [Photon 2](https://steamcommunity.com/sharedfiles/filedetails/?id=3128242636).
### Will you add support to [this car]?
Probably not. Any vehicle I add support to going forward is only because I personally want to use it with GAuto. If you would like to add support yourself, I will accept a PR on GitHub, but otherwise it's up to vehicle creators to add support to their own vehicles, because I simply cannot fulfil every request.
### Will you add [this feature]?
At this point, new features are a low priority. GAuto has been in development since 2019 and I've added everything that I originally wanted to add, and more. I'll gladly take suggestions but there's no guarantee that they will be added.
### Why is smoke and fire sometimes floating above the car?
The smoke and fire effects are placed at the position of the engine attachment that is built into the vehicle's model. If the attachment isn't aligned properly, the smoke won't be aligned properly either. Some vehicle creators do this intentionally to make the vehicle drivable in deep water. Supported vehicles can have an engine offset parameter applied so the smoke appears in the right place.

# Development
### Adding Vehicle Support
 If you are a vehicle creator and would like to add GAuto support to your addons, you can use the GAuto Vehicle Creator tool to easily create a table to place in your vehicle's Lua file. When using this tool, left click will spawn passenger seats that you can physgun into place, right click will open a menu to edit values such as the vehicle's health and horn sound, and reload will remove the seats and generate vehicle data as either a Lua script or JSON table. Lua scripts need placed in a Lua file with a shared scope, and JSON files are automatically generated in the game's data folder. If you do add GAuto support to your vehicles, send me a link and I will add them to the collection linked at the top!
### Interfacing
If you want to interface with this addon through Lua, see the [documentation](dev.md) for hooks, functions, and other things you can use.

# Addon Compatibilities & Integrations
__Photon 1__  
GAuto's HUD and default controls were designed to avoid conflicts with Photon 1.

__Photon 2__  
GAuto's HUD was designed to avoid conflicts with Photon 2's HUD, however to avoid conflicts with controls, seat switching and ejection are disabled on Photon 2 vehicles.

__Simfphys & LVS__  
Checks are in place to ensure GAuto can be used with these addons without issue. The spike strip will also pop tires from both systems.

__VFire__  
Some destruction effects rely on hooks from VFire to work. For the best experience it's recommended that you have it installed.

__DarkRP__  
The door lock status of vehicles is properly synced when using keys, an alarm will sound when lock picking a vehicle, and passengers will be ejected when using a battering ram on a vehicle.

__Sligwolf's Vehicles__  
Most vehicles should work fine with GAuto, but there are a handful that are unsupported because they don't use prop_vehicle_jeep as a base.

__VCMod, SVMod, Vehicle Damage 2, Etc__  
Vehicle systems like these are NOT compatible. They will likely interfere with GAuto and cause various systems to break.

# Issues & Pull Requests
 If you would like to contribute to this repository by creating an issue or pull request, please refer to the [contributing guidelines.](https://lambdagaming.github.io/contributing.html)

# Credits
- Lambda Gaming Community - Beta testing and feature suggestions
- rp_truenorth_v1a - Map used in screenshots and thumbnail on the Steam workshop
- SGM - Feature suggestions
