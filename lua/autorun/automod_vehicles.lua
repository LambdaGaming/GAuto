
AM_Vehicles = {}

AM_Vehicles["models/buggy.mdl"] = {
	HornSound = "automod/carhorn.wav",
	MaxHealth = 100,
	EnginePos = Vector( 21, 12, 63 ),
	Seats = {
		{
			pos = Vector( 0, 0, 0 ),
			ang = Angle( 0, 0, 0 )
		}
	}
}

AM_Vehicles["models/lonewolfie/dodge_monaco.mdl"] = {
	HornSound = "vcmod/horn/light.wav",
	MaxHealth = 100,
	EnginePos = Vector( 42, -75, -2 ),
	Seats = {
		{
			pos = Vector( 30, -20, 6 ),
			ang = Angle( 0, 0, 0 )
		},
		{
			pos = Vector( -17, 21, -11 ),
			ang = Angle( 6, 6, 6 )
		}
	}
}