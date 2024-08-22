# GAuto
GAuto is a lightweight vehicle system for Garry's Mod that extends the default functionality of vehicles based on the built-in jeep and airboat entities. All vehicles made by popular creators TDM, SGM, and LW before September 2023 are supported out of the box. A few select vehicles outside of these creators are also supported. I will not be adding support to any more vehicles myself, but contributions that add support are welcome, and vehicle creators are encouraged to add support to their own addons. A full list of supported addons can be found [here.](https://steamcommunity.com/sharedfiles/filedetails/?id=3018834846) GAuto is now also available on the [Steam workshop.](https://steamcommunity.com/sharedfiles/filedetails/?id=3048040907)

# Features
### Vehicle Health System
- Vehicles will smoke when their health drops below 25%, and explode when their health reaches 0.
- Vehicles can be damaged through bullets, explosives, collisions, etc.
- The repair tool weapon and repair kit entity can be used to restore vehicle health.
#### Tire Damage
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
- Not supported on airboats since it causes them to spin indefinitely.
### Passenger Seats
- Supported vehicles will spawn with multiple passenger seats.
- Players can switch between seats using the number keys.
- The driver can kick passengers out by holding alt and pressing the number keys.
- Unsupported vehicles will have a single passenger seat automatically placed next to the driver's seat if there's enough room.
### Horns
- All vehicles, both supported and unsupported, have a horn that can be used by pressing J.
- GAuto comes with 2 horn sounds, but when adding support to a vehicle, any sound can be used.
### Door Locking
- Drivers can lock their vehicle's doors to prevent any other players from getting in by pressing N.
- Locking the doors does not prevent passengers from getting out.
- An alarm will sound if a player starts lockpicking a vehicle on DarkRP.
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
- Engine emits a large cloud of smoke when vehicle is heavily damaged.
- Can be disabled server-side if it causes performance issues.
- Not supported on airboats due to the lack of an engine attachment (and wheels).

# FAQs
### Is a lighting system planned?
No. For both regular and emergency lighting, I recommend [Photon Legacy](https://steamcommunity.com/sharedfiles/filedetails/?id=339648087) or [Photon 2](https://steamcommunity.com/sharedfiles/filedetails/?id=3128242636).
### Will you add support to [this car]?
Probably not. Any vehicle I add support to going forward is only because I personally want to use it with GAuto. If you would like to add support yourself, I will accept a PR on GitHub, but otherwise it's up to vehicle creators to add support to their own vehicles, because I simply cannot fulfil every request.
### Will you add [this feature]?
Maybe. If it'll make a significant improvement to the addon there's a good chance it will be added.
### Why is smoke sometimes floating above the car?
The smoke effect is placed at the position of the engine attachment that is built into the model. If the attachment isn't aligned properly, the smoke won't be aligned properly either. Some vehicle creators do this intentionally to make the vehicle drivable in deep water. Supported vehicles can have an engine offset parameter applied so the smoke appears in the right place.
### Why isn't my car smoking or catching fire when damaged?
If your car isn't smoking, its model likely does not have an engine attachment, or the attachment is located at the vehicle's origin and has been disabled to prevent it from looking weird. If your car isn't catching fire when its health reaches 0, you likely don't have VFire installed.

# Development
### Vehicle Creation
 If you are a vehicle creator and would like to add GAuto support to your addons, you can use the GAuto Vehicle Creator tool to easily create a table to place in your vehicle's Lua file. When using this tool, left click will spawn passenger seats that you can physgun into place, right click will open a menu to edit values such as the vehicle's health and horn sound, and reload will remove the seats and generate vehicle data as either a Lua script or JSON table. Lua scripts need placed in a Lua file with a shared scope, and JSON files are automatically generated in the game's data folder. If you do add GAuto support to your vehicles, send me a link and I will add them to the collection linked at the top!
### Interfacing
If you want to interface with this addon through Lua, see the [documentation](dev.md) for hooks, functions, and other things you can use.

# Compatibilities
 - Photon Legacy is fully compatible. Both the HUD and default controls were designed to avoid conflicts with it.
 - Photon 2 is mostly compatible. The HUD will not overlap, but seat switching and ejection are disabled on Photon 2 vehicles due to how the controls are setup. All other controls should not conflict.
 - Simfphys and LVS vehicles are fully compatible. Nothing should conflict, and the spikestrip will pop tires from both systems.
 - VFire is supported. For the best destruction effects, it's recommended you have it installed.
 - Sligwolf's vehicles are compatible but blacklisted, meaning they can be installed alongside GAuto without any issues, but they won't use any GAuto features.
 - Other vehicle systems such as VCMod, SVMod, and Vehicle Damage 2 are NOT compatible. They will likely interfere with GAuto and cause various systems to break.

# Issues & Pull Requests
 If you would like to contribute to this repository by creating an issue or pull request, please refer to the [contributing guidelines.](https://lambdagaming.github.io/contributing.html)

# Credits
- [Simfphys Base](https://github.com/Blu-x92/simfphys_base) - Reference for coding various systems including passenger seats and particle effects.
- Valve - Particle effects
- SGM - Feature suggestions
