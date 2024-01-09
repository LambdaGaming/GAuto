TOOL.Name = "GAuto Vehicle Creator"
TOOL.Category = "GAuto"
TOOL.Seats = {}

if CLIENT then
	language.Add( "tool.gauto_vehicle_creator.name", "GAuto Vehicle Creator" )
	language.Add( "tool.gauto_vehicle_creator.desc", "Generates vehicle configs to help add GAuto support to a vehicle." )
	language.Add( "tool.gauto_vehicle_creator.0", "Right-click: Open configuration menu. Left-click: Spawn passenger seat. Reload: Remove spawned seats and print generated vehicle table to console." )

	net.Receive( "GAuto_VehicleCreatorMenu", function()
		local main = vgui.Create( "DFrame" )
		main:SetTitle( "GAuto Vehicle Creator" )
		main:SetSize( 300, 300 )
		main:Center()
		main:MakePopup()
		main.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 64, 64, 64, 190 ) )
		end
	
		local checkBox = vgui.Create( "DCheckBoxLabel", main )
		checkBox:Dock( TOP )
		checkBox:DockMargin( 0, 0, 0, 20 )
		checkBox:SetText( "Generate JSON instead of Lua" )
		checkBox:SizeToContents()
		local hornLabel = vgui.Create( "DLabel", main )
		hornLabel:Dock( TOP )
		hornLabel:SetText( "Horn Sound" )
		local horn = vgui.Create( "DTextEntry", main )
		horn:Dock( TOP )
		horn:DockMargin( 0, 0, 0, 20 )
		horn:SetValue( "gauto/carhorn.wav" )
		local healthLabel = vgui.Create( "DLabel", main )
		healthLabel:Dock( TOP )
		healthLabel:SetText( "Max Health" )
		local health = vgui.Create( "DNumberWang", main )
		health:Dock( TOP )
		health:DockMargin( 0, 0, 0, 20 )
		health:SetMin( 1 )
		health:SetMax( 1000 )
		health:SetValue( 100 )

		local save = vgui.Create( "DButton", main )
		save:Dock( BOTTOM )
		save:SetSize( nil, 20 )
		save:SetText( "Save" )
		save.DoClick = function()
			net.Start( "GAuto_VehicleCreatorMenu" )
			net.WriteBool( checkBox:GetChecked() )
			net.WriteString( horn:GetValue() )
			net.WriteUInt( health:GetValue(), 10 )
			net.SendToServer()
			main:Close()
		end
	end )
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

	util.AddNetworkString( "GAuto_VehicleCreatorMenu" )
	function TOOL:RightClick()
		if IsFirstTimePredicted() then
			net.Start( "GAuto_VehicleCreatorMenu" )
			net.Send( self:GetOwner() )
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
			if !owner:IsAdmin() or !self:CheckValid( tr ) then return end

			--This is very messy but the generated code gets formatted nicely
			local tbl
			if GAuto.Tool.UseJSON then
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
	"HornSound": "%s",
	"MaxHealth": %s,
	"Seats": [
		%s
	]
}]],
				GAuto.Tool.Horn, GAuto.Tool.Health, seat )
				file.CreateDir( "gauto/vehicles" )
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
				tbl = string.format( [[if GAuto and GAuto.Vehicles then
	GAuto.Vehicles["%s"] = {
		HornSound = "%s",
		MaxHealth = %s,
		Seats = {
			%s
		}
	}
end]],
				self.Vehicle:GetModel(), GAuto.Tool.Horn, GAuto.Tool.Health, seat )
				owner:ChatPrint( "Generated code has been printed to the server console. Put it in a Lua file that both the client and server have access to." )
			end
			
			print( tbl )
			self.Vehicle = nil
			for k,v in pairs( self.Seats ) do
				SafeRemoveEntity( v )
			end
			self.Seats = {}
		end
	end

	net.Receive( "GAuto_VehicleCreatorMenu", function( len, ply )
		if !ply:IsAdmin() then return end
		local json = net.ReadBool()
		local horn = net.ReadString()
		local health = net.ReadUInt( 10 )
		GAuto.Tool = {
			UseJSON = json,
			Horn = horn,
			Health = health
		}
		ply:ChatPrint( "Settings saved!" )
	end )
end
