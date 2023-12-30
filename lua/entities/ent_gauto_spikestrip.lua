AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spikestrip"
ENT.Author = "Lambda Gaming"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "GAuto"

local vehicles = {
	["prop_vehicle_jeep"] = true,
	["prop_vehicle_jeep_old"] = true,
	["jeep_owned_by_reckless_driver_kleiner"] = true
}

function ENT:Initialize()
    self:SetModel( GetConVar( "GAuto_Config_SpikeModel" ):GetString() )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		if DarkRP then --RP support that removes the spikestrip after 10 minutes to prevent abuse, should work with any DarkRP-based gamemode even if it's name was changed
			local index = self:EntIndex()
			if !timer.Exists( "Spike_Remove_Timer"..index ) then
				timer.Create( "Spike_Remove_Timer"..index, 600, 1, function()
					if !IsValid( self:GetOwner() ) then --Checks to see if the player is still on the server
						self:Remove()
						return
					end
					if self:GetOwner():isCP() then --Makes sure the player is still a cop so a civi doesn't get a free spikestrip
						self:GetOwner():Give( "weapon_gauto_spikestrip" )
						GAuto.Notify( self:GetOwner(), "Your spikestrip has been returned to you." )
					end
					self:Remove()
				end )
			end
		end
	end
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableMotion( false )
	end
end

function ENT:Use( ply )
	if !IsValid( self:GetOwner() ) then
		GAuto.Notify( ply, "The owner of this spikestrip has disconnected. Removing." )
		self:EmitSound( "items/ammocrate_close.wav" )
		self:Remove()
		return
	end
	if self:GetOwner() == ply then
		if DarkRP and !ply:isCP() then --Prevents former cops from taking back their old strips as a civi
			GAuto.Notify( ply, "You are no longer a cop. Your old spikestrip will be removed." )
			self:Remove()
			return
		end
		ply:Give( "weapon_gauto_spikestrip" )
		ply:SelectWeapon( "weapon_gauto_spikestrip" )
		GAuto.Notify( ply, "You have collected your spikestrip." )
		self:EmitSound( "items/ammocrate_close.wav" )
		self:Remove()
	else
		local nick = self:GetOwner():Nick()
		local index = self:EntIndex()
		local time = string.ToMinutesSeconds( timer.TimeLeft( "Spike_Remove_Timer"..index ) )
		GAuto.Notify( ply, "This spikestrip is owned by "..nick.." and will be automatically removed in "..time.."." )
	end
end

function ENT:StartTouch( ent )
	if GAuto.IsBlackListed( ent ) then return end
	local class = ent:GetClass()
	if vehicles[class] then
		local wheelpos = {}
		for i = 0, ent:GetWheelCount() - 1 do
			local wheel = ent:GetWheel( i )
			if !IsValid( wheel ) then return end
			local sqrpos = wheel:GetPos():DistToSqr( self:GetPos() )
			table.insert( wheelpos, { i, sqrpos } )
		end
		table.sort( wheelpos, function( a, b ) return a[2] < b[2] end ) --Checks to see what wheel is closest to the strip since there's no easy way of finding out which wheel is actually touching
		GAuto.PopTire( ent, wheelpos[1][1] )
	elseif class == "gmod_sent_vehicle_fphysics_wheel" then --Simfphy's support
		ent:SetDamaged( true )
	elseif class == "lvs_wheeldrive_wheel" or scripted_ents.IsBasedOn( class, "lvs_wheeldrive_wheel" ) then --LVS support
		ent:SetSuspensionHeight( -1 )
		ent:SetSuspensionStiffness( 1 )
	end
end

function ENT:OnRemove()
	local index = self:EntIndex()
	if timer.Exists( "Spike_Remove_Timer"..index ) then timer.Remove( "Spike_Remove_Timer"..index ) end
end
