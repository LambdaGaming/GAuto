
--[[
    Planned features for this system:
    1. Vehicle health system (explodes when damaged by an explosive weapon, otherwise the engine just stops working and the vehicle can be repaired) *NOT DONE* (needs physical damage and smoke particles)
    2. Brakes lock when the player exits the vehicle (can be released by a brake release swep for towing purposes) *DONE*
    3. Steering wheel remains in the position it was in when the player leaves the vehicle *DONE*
    4. Vehicle seat system *DONE*
    5. Horns *DONE*
    6. Vehicle locking system (with alarm) *DONE*
	7. Customizable controls *NOT DONE*
]]

CreateConVar( "AM_Config_HealthEnabled", 1, FCVAR_REPLICATED, "Enable or disable vehicles taking damage." )
CreateConVar( "AM_Config_BulletDamageEnabled", 1, FCVAR_REPLICATED, "Enable or disable allowing vehicles to take damage from bullets." )
CreateConVar( "AM_Config_DamageExplosionEnabled", 1, FCVAR_REPLICATED , "Enable or disable vehicles exploding when damaged by an explosive.")
CreateConVar( "AM_Config_ExplodeRemoveEnabled", 0, FCVAR_REPLICATED, "Enable or disable destroyed vehicles being removed after a certain time." )
CreateConVar( "AM_Config_ExplodeRemoveTime", 600, FCVAR_REPLICATED, "Time it takes in seconds for a destroyed vehicle to get removed. AM_Config_ExplodeRemoveEnabled needs to be set to 1 for this to work." )

CreateConVar( "AM_Config_BrakeLockEnabled", 1, FCVAR_REPLICATED, "Enable or disable the brakes locking when a player exits a vehicle." )
CreateConVar( "AM_Config_WheelLockEnabled", 1, FCVAR_REPLICATED, "Enable or disable the steering wheel locking in a certain position when a player exits a vehicle." )
CreateConVar( "AM_Config_SeatsEnabled", 1, FCVAR_REPLICATED, "Enable or disable vehicles spawning with passenger seats." )
CreateConVar( "AM_Config_HornEnabled", 1, FCVAR_REPLICATED, "Enable or disable players being able to use their horns." )
CreateConVar( "AM_Config_LockEnabled", 1, FCVAR_REPLICATED, "Enable or disable players being able to lock their vehicles." )
CreateConVar( "AM_Config_LockAlarmEnabled", 1, FCVAR_REPLICATED, "Enable or disable the alarm going off when a player lockpicks a vehicle." )

CreateClientConVar( "AM_Control_ModifierKey", KEY_LALT, true, false, "Sets the key to hold when pressing another key to perform a function." )
CreateClientConVar( "AM_Control_HornKey", KEY_H, true, false, "Sets the key for the horn." )
CreateClientConVar( "AM_Control_LockKey", KEY_N, true, false, "Sets the key for locking the doors." )
