# Hooks
Feel free to request additional hooks if none of these suit your needs.
| Name | Scope | Arguments | Returns | Description |
|------|-------|-----------|---------|-------------|
|GAuto_CanChangeSeats|Server|Player `ply`, Vehicle `veh`, Int `seat`|Bool `allowed`|Gets called when a driver or passenger attempts to change seats.|
|GAuto_CanCruise|Server|Player `ply`, Vehicle `veh`|Bool `allowed`|Gets called when a driver attempts to activate cruise control.|
|GAuto_CanEjectPassenger|Server|Player `ply`, Vehicle `veh`, Int `seat`|Bool `allowed`|Gets called when a driver attempts to eject a passenger.|
|GAuto_CanLockDoors|Server|Player `ply`, Vehicle `veh`|Bool `allowed`|Gets called when a driver attempts to lock the vehicle.|
|GAuto_CanToggleEngine|Server|Player `ply`, Vehicle `veh`|Bool `allowed`|Gets called when a driver attempts to toggle the engine.|
|GAuto_CanUseHorn|Server|Player `ply`, Vehicle `veh`|Bool `allowed`|Gets called when a driver attempts to use the horn.|
|GAuto_OnAddHealth|Server|Vehicle `veh`, Int `hp`|N/A|Gets called when health is added to a vehicle.|
|GAuto_OnTakeDamage|Server|Vehicle `veh`, Int `damage`|N/A|Gets called when a vehicle takes damage.|
|GAuto_OnTirePopped|Server|Vehicle `veh`, Int `wheel`|N/A|Gets called when a tire is popped.|
|GAuto_OnTireRepaired|Server|Vehicle `veh`, Int `wheel`|N/A|Gets called when a tire is repaired. Wheel parameter will return -1 if all tires were repaired at the same time.|
|GAuto_OnVehicleDestroyed|Server|Vehicle `veh`|N/A|Gets called when a vehicle explodes from its health reaching 0.|

# Functions
Functions that are meant to only be used internally are not listed here.
| Name | Scope | Arguments | Returns | Description |
|------|-------|-----------|---------|-------------|
|GAuto.AddHealth|Server|Vehicle `veh`, Int `hp`|N/A|Adds a set amount of health to the specified vehicle. Will automatically clamp health at max value, and check to see if the vehicle should smoke.|
|GAuto.GodModeEnabled|Server|Vehicle `veh`|Bool `enabled`|Returns whether or not the specified vehicle has god mode enabled.|
|GAuto.IsBlacklisted|Shared|Vehicle `veh`|Bool `blacklisted`|Returns whether or not the specified vehicle is considered blacklisted by GAuto.|
|GAuto.Notify|Shared|Player `ply`, String `text`, Bool `broadcast`|N/A|Sends a GAuto notification to the target player. When called on the client, only the text parameter can be used.|
|GAuto.PopTire|Server|Vehicle `veh`, Int `wheel`|N/A|Pops a tire on the specified vehicle.|
|GAuto.RepairTire|Server|Vehicle `veh`, Int `wheel`|N/A|Repairs the specified tire on a vehicle, or repairs all tires if `wheel` parameter isn't specified.|
|GAuto.SetFuel|Server|Vehicle `veh`, Int `fuel`|N/A|Sets the specified vehicle's fuel to the specified amount.|
|GAuto.TakeDamage|Server|Vehicle `veh`, Int `damage`|N/A|Damages the specified vehicle by a set amount, and runs checks to see if the vehicle should smoke or explode.|
|GAuto.ToggleGodMode|Server|Vehicle `veh`|N/A|Toggles god mode on the specified vehicle.|
|GAuto.TrimModel|Server|String `model`|String `trimmedModel`|Trims a model path down to the format that GAuto uses for data files.|

# Vehicle Parameters
These are various values tied to GAuto vehicles that might be useful. 
| Name | Scope | Type | Description |
|------|-------|------|-------------|
|GAuto_DoorsLocked|Shared|Networked Bool|Whether or not the vehicle is currently locked.|
|GAuto_HasExploded|Shared|Networked Bool|Whether or not the vehicle has exploded.|
|GAuto_HornSound|Shared|Networked String|Sound path for the vehicle's horn.|
|GAuto_IsSmoking|Shared|Networked Bool|Whether or not the vehicle is currently smoking.|
|GAuto_VehicleHealth|Shared|Networked Int|Current value of the vehicle's health.|
|GAuto_VehicleMaxHealth|Shared|Networked Int|Max value the vehicle's health can be.|
|Vehicle.FuelCooldown|Server|Int|Used internally to determine when fuel should be consumed next.|
|Vehicle.FuelInit|Server|Bool|Indicates that the vehicle's fuel system has been initialized. Only false for a split second when the vehicle first spawns.|
|Vehicle.FuelLoss|Server|Int|Current rate at which fuel is being consumed.|
|Vehicle.particles|Server|Table|Holds the particle system entities for each wheel.|
|Vehicle.seat|Server|Table|Holds all of the passenger seat entities.|
