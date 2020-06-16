
--[[
	This is a simple chat command that allows you to add your own vehicle to Automod's seat support.
	To use, spawn in airboat seats from the vehicles tab and place them where you want your Automod seats to be.
	Then, type in the chat command and coords for each seat will print out in chat. (Going by the order of when they were spawned.)
	This can also work for the engine position if you spawn a single seat.
]]

hook.Add( "PlayerSay", "AM_VehCreation", function( ply, text, len )
	if text == "!createseats" then
		local findseats = ents.FindByClass( "prop_vehicle_prisoner_pod" )
		local findjeep = ents.FindByClass( "prop_vehicle_jeep" )
		if #findjeep > 1 then --Only allows one vehicle to be spawned since it looks at all vehicles currently spawned, and if theres more than one it will give multiple coords for the same seat
			ply:ChatPrint( "ERROR: Cannot generate seats, more than one vehicle is spawned." )
			return
		elseif #findjeep < 1 then
			ply:ChatPrint( "ERROR: Cannot generate seats, no vehicle detected." )
			return
		end
		if #findseats > 10 then --Only allows up to 10 seats since thats how many number keys there are
			ply:ChatPrint( "ERROR: Cannot generate seats, more than 9 seats are spawned." )
			return
		elseif #findseats < 1 then
			ply:ChatPrint( "ERROR: Cannot generate seats, no seat detected." )
			return
		end
		for k,v in ipairs( findseats ) do
			for a,b in ipairs( findjeep ) do
				v:SetParent( b )
				local pos = b:WorldToLocal( v:GetPos() )
				local posfancy = "Vector( "..math.Round( pos.x )..", "..math.Round( pos.y )..", "..math.Round( pos.z ).." )"
				ply:ChatPrint( posfancy )
				timer.Simple( 0.1, function() v:SetParent( nil ) end ) --Removes parent so the seat can be moved on its own again if needed
			end
		end
	end
end )
