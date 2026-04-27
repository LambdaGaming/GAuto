--Will allow airboats, jeeps that aren't in the list, and prisoner pods that are GAuto passenger seats
function GAuto.IsBlackListed( veh )
	if !IsValid( veh ) or !veh:IsVehicle() then return true end
	local class = veh:GetClass()
	local model = veh:GetModel()
	if GAuto.Blacklist[model] and class == "prop_vehicle_jeep" then
		return true
	end
	if class == "prop_vehicle_prisoner_pod" and !veh:GetNWBool( "IsGAutoSeat" ) then
		return true
	end
	if veh.fphysSeat then
		--Avoid interference with Simfphys
		return true
	end
	return false
end

--Will allow all jeeps and airboats
function GAuto.IsDrivable( ent )
	return IsValid( ent ) and ( ent:GetClass() == "prop_vehicle_jeep" or ent:GetClass() == "prop_vehicle_airboat" )
end

function GAuto.IsAirboat( ent )
	return ent:GetClass() == "prop_vehicle_airboat"
end

--Context menu properties
properties.Add( "gauto", {
	MenuLabel = "GAuto",
	Order = 2000,
	MenuIcon = "icon16/car.png",
	Filter = function( self, ent, ply )
		if hook.Run( "CanProperty", ply, "gauto", ent ) == false then return false end
		return ply:IsAdmin() and ent:IsVehicle()
	end,
	MenuOpen = function( self, option, ent, tr )
		local options = {
			{ "Eject All Occupants", "arrow_out.png" },
			{ "Force Unlock Doors", "lock.png" },
			{ "Repair Damage", "wrench.png" },
			{ "Replenish Fuel", "lightning.png" },
			{ "Toggle God Mode", "shield.png" }
		}

		local submenu = option:AddSubMenu()
		for k,v in pairs( options ) do
			local opt1 = submenu:AddOption( v[1] )
			opt1:SetIcon( "icon16/"..v[2] )
			opt1.OnMousePressed = function()
				self:SendData( ent, k )
			end
		end
	end,
	SendData = function( self, ent, id )
		self:MsgStart()
			net.WriteEntity( ent )
			net.WriteUInt( id, 8 )
		self:MsgEnd()
	end,
	Receive = function( self, len, ply )
		local ent = net.ReadEntity()
		local id = net.ReadUInt( 8 )
		if !self:Filter( ent, ply ) then return end
		if id == 1 then
			local d = ent:GetDriver()
			if IsValid( d ) then d:ExitVehicle() end
			for k,v in pairs( ent.seat ) do
				local p = v:GetDriver()
				if IsValid( p ) then p:ExitVehicle() end
			end
		elseif id == 2 then
			ent:Fire( "Unlock", "", 0.01 )
			ent:SetNWBool( "GAuto_DoorsLocked", false )
			ent:SetNWEntity( "GAuto_LockOwner", nil )
		elseif id == 3 then
			local max = ent:GetNWInt( "GAuto_VehicleMaxHealth" )
			GAuto.AddHealth( ent, max )
			GAuto.RepairTire( ent )
		elseif id == 4 then
			GAuto.SetFuel( ent, 100 )
		elseif id == 5 then
			GAuto.ToggleGodMode( ent )
		end
	end
} )

if SERVER then
	util.AddNetworkString( "GAuto_Notify" )
	function GAuto.Notify( ply, text )
		net.Start( "GAuto_Notify" )
		net.WriteString( text )
		net.Send( ply )
	end

	function GAuto.TrimModel( model )
		if isstring( model ) then
			local removeModel = string.gsub( model, "models/", "" )
			local removeExtension = string.StripExtension( removeModel )
			local replaceSlash = string.Replace( removeExtension, "/", "%" )
			return replaceSlash
		end
		return ""
	end

	function GAuto.CreateParticleEffect( veh, effect, pos )
		local p = ents.Create( "info_particle_system" )
		p:SetKeyValue( "effect_name", effect )
		p:SetKeyValue( "start_active", 0 )
		p:SetOwner( veh )
		p:SetPos( pos )
		p:Spawn()
		p:Activate()
		p:SetParent( veh )
		p.DoNotDuplicate = true
		return p
	end
end
