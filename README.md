# GAuto
GAuto is a lightweight vehicle system for Garry's Mod that extends the default functionality of vehicles based on the default jeep and airboat entities. All vehicles made by popular creators TDM, SGM, and LW before September 2023 are supported out of the box. A few select vehicles from other creators are also supported. A full list of supported addons can be found [here.](https://steamcommunity.com/sharedfiles/filedetails/?id=3018834846) GAuto is now also available on the [Steam workshop.](https://steamcommunity.com/sharedfiles/filedetails/?id=3048040907)

# Features
### Vehicle Health System
Vehicles can be damaged by bullets, explosives, collisions, and more. Vehicles will start smoking when their health is 30% or less, and will catch fire and explode when their health reaches 0. Health can be restored with the repair tool weapon or repair kit entity. If VFire is installed, vehicles that remain on fire for too long will become charred and permanently unfixable.

### Tire Damage
Tires can be popped by bullets and spike strips. Deflated tires will cause the vehicle to slow down and become harder to control. They can be fixed with the secondary fire of the vehicle repair tool.

### Passenger Seats
Most vehicles have at least one passenger seat, supported vehicles can have up to 9. You can switch between them using the number keys. Drivers are able to eject players by holding alt and pressing any of the number keys.

### Vehicle HUD
A small HUD will appear on the right side of the screen when you enter the driver's seat. It displays vehicle info including health, fuel level, door lock status, speed, and cruise control status.

### Door Locking
Drivers can lock their doors to prevent other players from entering by pressing N. This will not prevent passengers from leaving.

### Brake Locking
Brakes can be locked by holding jump when leaving the driver's seat. Not doing this could cause the vehicle to roll away. Locked brakes will automatically release when entering the driver's seat again, but they can also be released from the outside using the vehicle management tool.

### Steering Wheel Locking
The front wheels will lock into a turned position if the driver keeps them turned as they exit the vehicle. This doesn't work on airboat-based vehicles since it causes them to spin forever.

### Horns
All vehicles have a horn that can be used by pressing J. GAuto comes with 3 horn sounds, but when adding support to a vehicle, any sound can be used.

### Fuel System
All vehicles spawn with a full fuel tank by default. Fuel is consumed when the throttle is pressed. It can be replenished through the fuel can entity or weapon.

### Cruise Control
Cruise control allows you to keep the throttle at a certain position for more precise speed control. It can be toggled by pressing V. Cruise speed can be increased/decreased by pressing forward/backward.

### Vehicle Data
Data tables for each vehicle that contain info about health, seat positions, horn sound, etc. are stored in formatted JSON files for easy editing. A vehicle creation tool is also included to easily add GAuto support to your own vehicles. (More info about that below.)

### Engine Toggle
Pressing P will turn off the engine without requiring the driver to leave the vehicle. Useful for when you're trying to talk to someone.

### Customizable Controls
All controls besides the seat number keys can be reassigned through the Options tab in the spawn menu.

### Particles
Dust will emit from wheels when driving on dirt, grass, and sand. The engine will emit smoke or fire depending on how damaged the vehicle is. Charred vehicles will emit a small cloud of smoke. All particle effects can be disabled server-side if needed. Particles aren't supported on airboat-based vehicles due to the lack of an engine attachment and wheels.

# FAQs
### Is a lighting system planned?
No. Large systems like this are outside the scope of this addon. If you want a lighting system to use with GAuto, I recommend [Photon 1](https://steamcommunity.com/sharedfiles/filedetails/?id=339648087) or [Photon 2](https://steamcommunity.com/sharedfiles/filedetails/?id=3128242636).
### Will you add support to [this car]?
I occasionally add support for more vehicles but I usually don't take requests for it. Ideally, vehicle creators should be adding support to their own vehicles. You can also add support by submitting a PR for it on GitHub.
### Will you add [this feature]?
At this point, new features are a low priority. GAuto has been in development since 2019 and I've added everything that I originally wanted to add, and more. I'll gladly take requests but there's no guarantee that they will be added.
### Why is smoke and fire sometimes floating above the car?
The smoke and fire effects are placed at the position of the engine attachment that is built into the vehicle's model. If the attachment isn't aligned properly, the effects won't be aligned properly either. Some vehicle creators do this intentionally to make the vehicle drivable in deep water. Supported vehicles can have an engine offset parameter applied so the effects appear in the right place.

# Development
### Interfacing
If you want to interface with this addon through Lua, see the [documentation](dev.md) for hooks, functions, and other things you can use.

### Customization
There are [many ConVars](dev.md#convars) you can use to disable and tweak certain systems. Feel free to request more if these aren't enough to fit your needs.

### Adding Vehicle Support
You can use the vehicle creator tool to easily create a Lua table or JSON file that contains custom vehicle data such as seat positions, horn sounds, and engine offsets. When using this tool, left click will spawn passenger seats that you can physgun into place, right click will open a menu to edit certain parameters, and reload will remove the seats and generate vehicle data in the selected format. Lua scripts need placed in a Lua file with a shared scope, and JSON files are automatically generated in the game's data folder. If you do add GAuto support to your vehicles, send me a link and I will add them to the collection linked at the top!

# Addon Compatibilities & Integrations
__Photon 1__  
GAuto's HUD and default controls were designed to avoid conflicts with Photon 1.

__Photon 2__  
GAuto's HUD was designed to avoid conflicts with Photon 2's HUD, however to avoid conflicts with controls, seat switching and ejection are disabled on Photon 2 vehicles.

__Simfphys / LVS / Glide__  
Checks are in place to ensure GAuto can be used with these addons without issue. The spike strip will also pop tires from all three systems.

__VFire__  
Some destruction effects rely on hooks from VFire to work. For the best experience it's recommended that you have it installed.

__DarkRP__  
The door lock status of vehicles is properly synced when using keys, an alarm will sound when lock picking a vehicle, and passengers will be ejected when using a battering ram on a vehicle.

__Sligwolf's Vehicles__  
Most vehicles should work fine with GAuto, but there are a handful that are unsupported because they don't use prop_vehicle_jeep as a base.

__VCMod, SVMod, Vehicle Damage 2, Etc__  
Vehicle systems like these are NOT compatible. They will likely interfere with GAuto and cause various systems to break.

# Credits
- Lambda Gaming Community - Beta testing and feature suggestions
- rp_truenorth_v1a - Map used in screenshots and thumbnail on the Steam workshop
- SGM - Feature suggestions
