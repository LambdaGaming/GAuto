# Hooks
Feel free to request additional hooks if none of these suit your needs.
| Name | Scope | Arguments | Returns | Description |
|------|-------|-----------|---------|-------------|
|GAuto_CanChangeSeats|Server|Player `ply`, Vehicle `veh`, Number `seat`|Bool `allowed`|Gets called when a driver or passenger attempts to change seats.|
|GAuto_CanCruise|Server|Player `ply`, Vehicle `veh`|Bool `allowed`|Gets called when a driver attempts to activate cruise control.|
|GAuto_CanEjectPassenger|Server|Player `ply`, Vehicle `veh`, Number `seat`|Bool `allowed`|Gets called when a driver attempts to eject a passenger.|
|GAuto_CanLockDoors|Server|Player `ply`, Vehicle `veh`|Bool `allowed`|Gets called when a driver attempts to lock the vehicle.|
|GAuto_CanToggleEngine|Server|Player `ply`, Vehicle `veh`|Bool `allowed`|Gets called when a driver attempts to toggle the engine.|
|GAuto_CanUseHorn|Server|Player `ply`, Vehicle `veh`|Bool `allowed`|Gets called when a driver attempts to use the horn.|
|GAuto_OnAddHealth|Server|Vehicle `veh`, Number `hp`|N/A|Gets called when health is added to a vehicle.|
|GAuto_OnTakeDamage|Server|Vehicle `veh`, Number `damage`|N/A|Gets called when a vehicle takes damage.|
|GAuto_OnTirePopped|Server|Vehicle `veh`, Number `wheel`|N/A|Gets called when a tire is popped.|
|GAuto_OnTireRepaired|Server|Vehicle `veh`, Number `wheel`|N/A|Gets called when a tire is repaired. Wheel parameter will return -1 if all tires were repaired at the same time.|
|GAuto_OnVehicleDestroyed|Server|Vehicle `veh`|N/A|Gets called when a vehicle explodes from its health reaching 0.|

# Functions
Functions that are meant to only be used internally are not listed here.
| Name | Scope | Arguments | Returns | Description |
|------|-------|-----------|---------|-------------|
|GAuto.AddHealth|Server|Vehicle `veh`, Number `hp`|N/A|Adds a set amount of health to the specified vehicle. Will automatically clamp health at max value, and check to see if the vehicle should smoke.|
|GAuto.GodModeEnabled|Server|Vehicle `veh`|Bool `enabled`|Returns whether or not the specified vehicle has god mode enabled.|
|GAuto.IsBlackListed|Shared|Vehicle `veh`|Bool `blacklisted`|Returns whether or not the specified vehicle is considered blacklisted by GAuto.|
|GAuto.IsDrivable|Shared|Entity `ent`|Bool `drivable`|Returns whether or not the specified entity is a drivable vehicle such as a jeep or airboat.|
|GAuto.Notify|Shared|Player `ply`, String `text`|N/A|Sends a GAuto notification to the target player. When called on the client, only the text parameter can be used.|
|GAuto.PopTire|Server|Vehicle `veh`, Number `wheel`|N/A|Pops a tire on the specified vehicle.|
|GAuto.RepairTire|Server|Vehicle `veh`, Number `wheel`|N/A|Repairs the specified tire on a vehicle, or repairs all tires if `wheel` parameter isn't specified.|
|GAuto.SetFuel|Server|Vehicle `veh`, Number `fuel`|N/A|Sets the specified vehicle's fuel to the specified amount.|
|GAuto.TakeDamage|Server|Vehicle `veh`, Number `damage`|N/A|Damages the specified vehicle by a set amount, and runs checks to see if the vehicle should smoke or explode.|
|GAuto.ToggleGodMode|Server|Vehicle `veh`|N/A|Toggles god mode on the specified vehicle.|
|GAuto.TrimModel|Server|String `model`|String `trimmedModel`|Trims a model path down to the format that GAuto uses for data files.|
|GAuto.Explode|Server|Vehicle `veh`|N/A|Explodes the specified vehicle from the engine position.|
|GAuto.CreateCharredProp|Server|Vehicle `veh`|N/A|Replaces the vehicle with a non-functional model that looks like it's been burnt.|

# Vehicle Parameters
These are various values tied to GAuto vehicles that might be useful. 
| Name | Scope | Type | Description |
|------|-------|------|-------------|
|GAuto_DoorsLocked|Shared|Networked Bool|Whether or not the vehicle is currently locked.|
|GAuto_EngineOffset|Shared|Networked Vector|Offset of the engine position used for particle effects.|
|GAuto_HasExploded|Shared|Networked Bool|Whether or not the vehicle has exploded.|
|GAuto_HornSound|Shared|Networked String|Sound path for the vehicle's horn.|
|GAuto_IsSmoking|Shared|Networked Bool|Whether or not the vehicle is currently smoking.|
|GAuto_VehicleHealth|Shared|Networked Int|Current value of the vehicle's health.|
|GAuto_VehicleMaxHealth|Shared|Networked Int|Max value the vehicle's health can be.|
|Vehicle.FuelCooldown|Server|Number|Used internally to determine when fuel should be consumed next.|
|Vehicle.FuelInit|Server|Bool|Indicates that the vehicle's fuel system has been initialized. Only false for a split second when the vehicle first spawns.|
|Vehicle.FuelLoss|Server|Number|Current rate at which fuel is being consumed.|
|Vehicle.particles|Server|Table|Holds the particle system entities for each wheel.|
|Vehicle.seat|Server|Table|Holds all of the passenger seat entities.|

# ConVars
| Name | Scope | Description |
|------|-------|-------------|
|gauto_health_enabled|Server|Vehicles will take damage.|
|gauto_damage_explosion_enabled|Server|Vehicles explode when their health reaches 0.|
|gauto_brake_lock_enabled|Server|Brakes will stay locked when the driver holds jump while exiting.|
|gauto_wheel_lock_enabled|Server|Front wheels will remain turned when the driver exits the vehicle.|
|gauto_seats_enabled|Server|Supported vehicles will spawn with passenger seats.|
|gauto_horn_enabled|Server|Drivers will be able to sound a horn by pressing a specific button.|
|gauto_lock_enabled|Server|Drivers will be able to lock their vehicles by pressing a specific button.|
|gauto_lock_alarm_enabled|Server|Lockpicking a vehicle in DarkRP will sound an alarm.|
|gauto_tire_damage_enabled|Server|Vehicle tires will take damage and eventually pop.|
|gauto_fuel_enabled|Server|Vehicles will consume fuel and stop working when out of fuel.|
|gauto_cruise_enabled|Server|Drivers will be able to activate cruise control by pressing a specific button.|
|gauto_particles_enabled|Server|Particles such as engine smoke and wheel dust will be emitted.|
|gauto_phys_damage_multiplier|Server|Multiplier for physical damage done to vehicles. Does nothing if gauto_health_enabled is disabled.|
|gauto_bullet_damage_multiplier|Server|Multiplier for vehicle bullet damage. Does nothing if gauto_health_enabled is disabled.|
|gauto_player_damage_multiplier|Server|Damage multiplier for players in vehicles.|
|gauto_tire_health|Server|Amount of health each wheel/tire has.|
|gauto_charring_time|Server|How long a vehicle has to be on fire for until it becomes charred and permanently disabled. Set to -1 to disable. (Requires VFire)|
|gauto_explode_remove_time|Server|Time it takes in seconds for a destroyed vehicle to get removed. Set to -1 to disable.|
|gauto_no_fuel_god|Server|Vehicles that are out of fuel cannot be damaged.|
|gauto_health_override|Server|Amount of health every vehicle spawns with no matter what. Set to 0 to disable.|
|gauto_fuel_amount|Server|Amount of fuel vehicles spawn with.|
|gauto_fuel_loss_rate|Server|How fast fuel should drain when the throttle is being pressed.|
|gauto_spike_model|Server|The model of the spikestrip.|
|gauto_spike_model_offset|Server|Yaw offset that the spikestrip should be placed at.|
|gauto_driver_seat|Server|Players will automatically enter the drivers seat if it is not taken. If set to 0, players will enter the closest detected seat.|
|gauto_auto_passenger|Server|Unsupported vehicles will receive a single passenger seat next to the driver, if there is room for one.|
|gauto_horn_key|Client|Sets the key for the horn.|
|gauto_lock_key|Client|Sets the key for locking the doors.|
|gauto_cruise_key|Client|Sets the key for toggling cruise control.|
|gauto_engine_key|Client|Sets the key for toggling the engine.|
|gauto_eject_modifier|Client|Sets the modifier key that needs to be held while pressing a number key to kick a passenger out.|
|gauto_cruise_mph|Client|Enable or disable displaying cruise speed in MPH. Disable to set to KPH.|
