# Automod
Simple and lightweight vehicle system for Garry's Mod.

## Features:
<ul>
	<li>Vehicle health system. Vehicles can be damaged through physical contact with objects at high speeds, bullets, explosives, and any other means that trigger the EntityTakeDamage hook. Players can use the primary fire of the repair tool to repair a vehicle to full health. (Still working out the kinks with physical damage.)</li>
	<li>Brakes lock when the player exits the vehicle if they hold the jump key. The brakes can be released by a brake release SWEP for towing purposes if the vehicle is locked and cannot be driven away.</li>
	<li>Steering wheel remains in the position it was in when the player leaves the vehicle.</li>
	<li>Seat system with support for switching seats via the number keys while already inside the vehicle.</li>
	<li>Horns.</li>
	<li>Door locking. An alarm will sound if a player starts lockpicking a vehicle on DarkRP.</li>
	<li>Tire popping with bullet damage and spike strips. Players can use the secondary fire of the repair tool to repair any damage done to tires. The spike strip can either be used as a SWEP or a separate entity.</li>
	<li>Customizable controls.</li>
	<li>Fuel system with dynamic fuel consumption rates. Idling will still use fuel but not as much as a full throttle.</li>
	<li>Vehicle HUD that adapts it's position based on the current vehicles Photon support. Detailed features of the HUD are listed below.</li>
	<li>Cruise control. (Currently uses throttle instead of speed, which makes it a bit more sensitive. This will probably change later. Also needs a place on the vehicle HUD.)</li>
	<li>Data tables for each vehicle that contain info about health, seat positions, horn sound, etc. are stored as linted JSON files to allow for easy editing. A vehicle creation function is also included to add Automod support to your own vehicles.</li>
</ul>

## Planned Features:
<ul>
	<li>Overhaul of the repair tool so it gradually repairs a vehicle instead of healing in increments of 10, and also shows the vehicle's health on a HUD.</li>
</ul>

## Current HUD Features:
Specific features for the vehicle HUD are listed here to avoid overcrowding the features list.
<ul>
	<li>Health is displayed as a fraction. It can be color-coded for certain situations. White indicates that the health is good. Green indicates that the vehicle is in god mode and cannot be damaged. Red indicates that the vehicle is at 25% health or less.</li>
	<li>Door lock status is displayed below the vehicle's health. It can be one of two colors: Orange indicates that the vehicle is unlocked and white indicates that the vehicle is locked.</li>
	<li>Fuel level is displayed below the door lock status as a color-coded progress bar. It can be a total of three colors: Green indicates the fuel level is 75% to 100%, orange indicates 26% to 74%, and red indicates 0% to 25%.</li>
</ul>