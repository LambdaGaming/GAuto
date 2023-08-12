# Automod
This is a lightweight vehicle system for Garry's Mod. All vehicles made by popular creators TDM, SGM, and LW within a certain time period are planned to be supported. Currently, the majority of LW's vehicles, about half of TDM's packs, and a handful of SGM's vehicles are supported. A few select vehicles outside of these creators are also supported. Requests for adding support for new vehicles will not be accepted, but PRs that add support are welcome. A full list of supported addons can be found [here.](https://steamcommunity.com/sharedfiles/filedetails/?id=3018834846)

# Features:
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

## HUD Features:
__Note: All HUD elements for this addon were made for a resolution of 1920x1080. I tried my best to accommodate for most other resolutions but I can't guarantee that they will scale properly.__

- Health is displayed as a fraction. It can be color-coded for certain situations. White indicates that the health is good. Green indicates that the vehicle is in god mode and cannot be damaged. Red indicates that the vehicle is at 25% health or less.
- Door lock status is displayed below the vehicle's health. It can be one of two colors: Orange indicates that the vehicle is unlocked and white indicates that the vehicle is locked.
- Cruise control status is displayed below the door lock status. It can be one of two colors: Green indicates that cruise control is currently active and white indicates that cruise control is disabled. If cruise control is enabled, the HUD will also display the percentage of throttle being used.
- Fuel level is displayed below the cruise control status as a color-coded progress bar. It can be a total of three colors: Green indicates the fuel level is 100%-50%, orange indicates 49%-26%, and red indicates 25%-0%.

# For Vehicle Developers:
 If you are a vehicle developer and would like to add Automod support to your addons, tweak the following code to suit your needs and then add it to the main Lua file of your vehicle:
 ```lua
 if AM_Vehicles then --This check is necessary to prevent errors for players who don't have Automod
	AM_Vehicles[""] = { --The model path of your vehicle goes within the quotes.
		HornSound = "automod/carhorn.wav", --Automod comes with two horn sounds: automod/carhorn.wav and automod/truckhorn.wav, but you can use any sound you'd like.
		MaxHealth = 100, --Max amount of health that the vehicle can have, and what it initially spawns with.
		EnginePos = Vector( 0, 0, 0 ), --Local vector for the engine position. This is where smoke and explosions will emit from when the vehicle is damaged.
		Seats = {
			{ --You need one of these for each passenger seat you want the vehicle to spawn with. Note that the drivers seat is defined with the vehicle itself and not here, so a 4 seat vehicle will need 3 seats defined here.
				pos = Vector( 0, 0, 0 ), --Local vector for the seat position.
				ang = Angle( 0, 0, 0 ) --Local angles for the seat position. Typically everything will be 0 unless you have a seat that doesn't face forward.
			},
			{
				pos = Vector( 0, 0, 0 ),
				ang = Angle( 0, 0, 0 )
			},
			{
				pos = Vector( 0, 0, 0 ),
				ang = Angle( 0, 0, 0 )
			}
		}
	}
 end
 ```
If you do add Automod support to your vehicles, send me a link and I will add them to the collection linked above!

# Issues & Pull Requests
 If you would like to contribute to this repository by creating an issue or pull request, please refer to the [contributing guidelines.](https://lambdagaming.github.io/contributing.html)

# Credits
- [Simfphy's Lua Vehicle Base](https://github.com/Blu-x92/simfphys_base) for part of the passenger seat spawn code.
- SCS for the horn sounds.
