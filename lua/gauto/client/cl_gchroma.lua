local function InitGChroma()
	if gchroma then
		local keys = {
			gchroma.KeyConvert( GetConVar( "GAuto_Control_HornKey" ):GetInt() ),
			gchroma.KeyConvert( GetConVar( "GAuto_Control_LockKey" ):GetInt() ),
			gchroma.KeyConvert( GetConVar( "GAuto_Control_CruiseKey" ):GetInt() ),
			gchroma.KeyConvert( GetConVar( "GAuto_Control_EngineKey" ):GetInt() )
		}
		for k,v in pairs( keys ) do
			gchroma.SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_WHITE, v, 0 )
		end
		gchroma.CreateEffect( true )
	end
end
net.Receive( "GAuto_InitGChroma", InitGChroma )
