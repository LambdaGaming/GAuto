TOOL.Name = "Automod Vehicle Creator"
TOOL.Category = "Automod"
TOOL.Seats = {}

if CLIENT then
	language.Add( "tool.automod_vehicle_creator.name", "Automod Vehicle Creator" )
	language.Add( "tool.automod_vehicle_creator.desc", "Generates vehicle configs to help add Automod support to a vehicle." )
	language.Add( "tool.automod_vehicle_creator.0", "Left-click: Spawn passenger seat. Click again to save position. Right-click: Spawn engine. Click again to save position. Reload: Remove spawned entities and print generated seat table to console." )
end

if SERVER then
	function TOOL:CheckValid( tr )
		local owner = self:GetOwner()
		if !owner:IsAdmin() then
			owner:ChatPrint( "Only admins can use this tool!" )
			return false
		end
		if !IsValid( tr.Entity ) or tr.Entity:GetClass() != "prop_vehicle_jeep" then
			owner:ChatPrint( "Look at a vehicle to spawn items for it." )
			return false
		end
		self.Vehicle = tr.Entity
		return true
	end

	function TOOL:LeftClick( tr )
		if IsFirstTimePredicted() then
			if !self:CheckValid( tr ) then return end
			local owner = self:GetOwner()
			if #self.Seats >= 9 then
				owner:ChatPrint( "Automod only supports up to 9 passenger seats!" )
				return
			end
			local e = ents.Create( "prop_physics" )
			e:SetPos( owner:GetPos() + owner:GetForward() * 20 + owner:GetUp() * 20 )
			e:SetModel( "models/nova/airboat_seat.mdl" )
			e:Spawn()
			table.insert( self.Seats, e )
			constraint.NoCollide( self.Vehicle, e, 0, 0 )
			owner:ChatPrint( "Passenger seat spawned and no-collided with vehicle. Physgun it into position." )
		end
	end
	
	function TOOL:RightClick( tr )
		if IsFirstTimePredicted() then
			if !self:CheckValid( tr ) then return end
			local owner = self:GetOwner()
			if IsValid( self.Engine ) then
				owner:ChatPrint( "The engine is already spawned!" )
				return
			end
			local e = ents.Create( "prop_physics" )
			e:SetPos( owner:GetPos() + owner:GetForward() * 20 + owner:GetUp() * 20 )
			e:SetModel( "models/props_c17/trappropeller_engine.mdl" )
			e:Spawn()
			e:SetAngles( Angle( 90, 0, 0 ) )
			self.Engine = e
			constraint.NoCollide( self.Vehicle, e, 0, 0 )
			owner:ChatPrint( "Engine spawned and no-collided with vehicle. Physgun it into position." )
		end
	end
	
	local function FormatVector( vec )
		return "Vector( "..math.Round( vec.x )..", "..math.Round( vec.y )..", "..math.Round( vec.z ).." )"
	end

	function TOOL:Reload( tr )
		if IsFirstTimePredicted() then
			local owner = self:GetOwner()
			if !owner:IsAdmin() or !IsValid( self.Vehicle ) then return end
			if table.IsEmpty( self.Seats ) or !IsValid( self.Engine ) then
				owner:ChatPrint( "Spawn the engine and at least 1 seat to finalize the vehicle." )
				return
			end

			local seat = ""
			for k,v in pairs( self.Seats ) do
				if !IsValid( v ) then continue end
				seat = seat..[[{
				pos = %s,
				ang = Angle( 0, 0, 0 )
			},
			]]
				seat = string.format( seat, FormatVector( self.Vehicle:WorldToLocal( v:GetPos() ) ) )
			end
			
			local enginepos = self.Vehicle:WorldToLocal( self.Engine:GetPos() )
			local tbl = string.format( [[if AM_Vehicles then
	AM_Vehicles["%s"] = {
		HornSound = "automod/carhorn.wav",
		MaxHealth = 100,
		EnginePos = %s,
		Seats = {
			%s
		}
	}
end]],
				self.Vehicle:GetModel(),
				FormatVector( enginepos ),
				seat
			)
			print( tbl )
			owner:ChatPrint( "Generated code has been printed to the server console. Put it in a Lua file that both the client and server have access to." )
			self.Vehicle = nil
			SafeRemoveEntity( self.Engine )
			for k,v in pairs( self.Seats ) do
				SafeRemoveEntity( v )
			end
			self.Seats = {}
		end
	end
end
