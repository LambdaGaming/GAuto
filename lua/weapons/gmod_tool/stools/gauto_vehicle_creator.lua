TOOL.Name = "GAuto Vehicle Creator"
TOOL.Category = "GAuto"
TOOL.ClientConVar["usejson"] = "0"
TOOL.Seats = {}

if CLIENT then
	language.Add( "tool.gauto_vehicle_creator.name", "GAuto Vehicle Creator" )
	language.Add( "tool.gauto_vehicle_creator.desc", "Generates vehicle configs to help add GAuto support to a vehicle." )
	language.Add( "tool.gauto_vehicle_creator.0", "Left-click: Spawn passenger seat. Click again to save position. Right-click: Spawn engine. Click again to save position. Reload: Remove spawned entities and print generated seat table to console." )

	local convarlist = TOOL:BuildConVarList()
	function TOOL.BuildCPanel( panel )
		panel:AddControl( "CheckBox", { Label = "Generate JSON instead of Lua", Command = "gauto_vehicle_creator_usejson" } )
	end
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
				owner:ChatPrint( "GAuto only supports up to 9 passenger seats!" )
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
	
	local function FormatVector( vec, json )
		if json then
			return '"['..math.Round( vec.x ).." "..math.Round( vec.y ).." "..math.Round( vec.z )..']"'
		end
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

			--This is very messy but the generated code gets formatted nicely
			local tbl
			local enginepos = self.Vehicle:WorldToLocal( self.Engine:GetPos() )
			if self:GetClientBool( "usejson" ) then
				local seat = ""
				local filename = GAuto.TrimModel( self.Vehicle:GetModel() )
				for k,v in pairs( self.Seats ) do
					if !IsValid( v ) then continue end
					local comma = ""
					if k < #self.Seats then comma = "," end
					seat = seat..[[{
			"ang": "{0 0 0}",
			"pos": %s
		}%s
		]]
					seat = string.format( seat, FormatVector( self.Vehicle:WorldToLocal( v:GetPos() ), true ), comma )
				end
				tbl = string.format( [[{
	"EnginePos": %s,
	"Seats": [
		%s
	]
}]],
				FormatVector( enginepos, true ),
				seat )
				file.Write( "gauto/vehicles/"..filename..".json", tbl )
				owner:ChatPrint( "Generated JSON has been printed to the server console and written to the server's data folder." )
			else
				local seat = ""
				for k,v in pairs( self.Seats ) do
					if !IsValid( v ) then continue end
					local comma = ""
					if k < #self.Seats then comma = "," end
					seat = seat..[[{
				pos = %s,
				ang = Angle( 0, 0, 0 )
			}%s
			]]
					seat = string.format( seat, FormatVector( self.Vehicle:WorldToLocal( v:GetPos() ) ), comma )
				end
				tbl = string.format( [[if GAuto.Vehicles then
	GAuto.Vehicles["%s"] = {
		HornSound = "gauto/carhorn.wav",
		MaxHealth = 100,
		EnginePos = %s,
		Seats = {
			%s
		}
	}
end]],
				self.Vehicle:GetModel(),
				FormatVector( enginepos ),
				seat )
				owner:ChatPrint( "Generated code has been printed to the server console. Put it in a Lua file that both the client and server have access to." )
			end
			
			print( tbl )
			self.Vehicle = nil
			SafeRemoveEntity( self.Engine )
			for k,v in pairs( self.Seats ) do
				SafeRemoveEntity( v )
			end
			self.Seats = {}
		end
	end
end
