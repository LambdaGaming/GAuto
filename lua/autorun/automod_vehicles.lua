
AM_Vehicles = {}

AM_Vehicles["models/buggy.mdl"] = { --HL2 jeep
	HornSound = "automod/carhorn.wav",
	MaxHealth = 100,
	EnginePos = Vector( 21, 12, 63 ),
	Seats = {
		{
			pos = Vector( 15, -35, 23 ),
			ang = Angle( 0, 0, 0 )
		}
	}
}

AM_Vehicles["models/lonewolfie/dodge_monaco.mdl"] = { --LW Dodge Monaco
	HornSound = "automod/carhorn.wav",
	MaxHealth = 100,
	EnginePos = Vector( 0, 97, 38 ),
	Seats = {
		{
			pos = Vector( 20, 7, 23 ),
			ang = Angle( 0, 0, 0 )
		},
		{
			pos = Vector( 21, -40, 22 ),
			ang = Angle( 0, 0, 0 )
		},
		{
			pos = Vector( -20, -40, 22 ),
			ang = Angle( 0, 0, 0 )
		}
	}
}