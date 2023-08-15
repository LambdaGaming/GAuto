
function AM_Notify( text )
	local textcolor1 = Color( 180, 0, 0, 255 )
	local textcolor2 = color_white
	chat.AddText( textcolor1, "[Automod]: ", textcolor2, text )
end

net.Receive( "AM_Notify", function()
	local text = net.ReadString()
	AM_Notify( text )
end )

local smokevelocity = Vector( 0, 0, 50 )
local function AM_SmokeThink()
	local ply = LocalPlayer()
	local findjeep = ents.FindByClass( "prop_vehicle_jeep" )
	for k,v in pairs( findjeep ) do
		local model = v:GetModel()
		local enginepos = v:GetNWVector( "AM_EnginePos" )
		if enginepos == vector_origin then return end
		if v:GetNWBool( "AM_IsSmoking" ) then
			local carpos = v:GetPos()
			local plypos = ply:GetPos()
			if plypos:DistToSqr( carpos ) < 4000000 then --Only displays particles if the player is within a certain distance of the vehicle, helps with optimization
				local rand = math.random( 1, 9 )
				local pos = v:LocalToWorld( enginepos )
				local smoke = ParticleEmitter( pos ):Add( "particle/smokesprites_000"..rand, pos )
				local dietime = math.Rand( 0.6, 1.3 )
				local startsize = math.random( 0, 5 )
				local endsize = math.random( 33, 55 )
				smoke:SetVelocity( smokevelocity )
				smoke:SetDieTime( dietime )
				smoke:SetStartSize( startsize )
				smoke:SetEndSize( endsize )
				smoke:SetColor( 72, 72, 72 )
			end
		end
	end
end
hook.Add( "Think", "AM_SmokeThink", AM_SmokeThink )
