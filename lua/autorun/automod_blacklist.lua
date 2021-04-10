
--Blacklisted models that shouldn't be affected by Automod, such as trains or other vehicles that use prop_vehicle_jeep as their base
AM_Config_Blacklist = {
	["models/nova/airboat_seat.mdl"] = true, --Default gmod seat models
	["models/nova/chair_office01.mdl"] = true,
	["models/nova/chair_office02.mdl"] = true,
	["models/nova/chair_plastic01.mdl"] = true,
	["models/nova/chair_wood01.mdl"] = true,
	["models/nova/jalopy_seat.mdl"] = true,
	["models/nova/jeep_seat.mdl"] = true,
	["models/sligwolf/westernloco/western_locov2.mdl"] = true, --Sligwolf models (since his addons have their own mini vehicle system)
	["models/sligwolf/truck/swtruck001.mdl"] = true,
	["models/sligwolf/truck/swtruck002.mdl"] = true,
	["models/sligwolf/truck/swtruck003.mdl"] = true,
	["models/sligwolf/truck/swtruck004.mdl"] = true,
	["models/sligwolf/truck/swtruck005.mdl"] = true,
	["models/sligwolf/truck/swtruck006.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer001.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer002.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer003.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer004.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer005.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer006.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer007.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer008.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer009.mdl"] = true,
	["models/sligwolf/truck/swtruck_camper.mdl"] = true,
	["models/sligwolf/diesel/dieselv2.mdl"] = true,
	["models/sligwolf/diesel/diesel_wagon.mdl"] = true,
	["models/sligwolf/diesel/diesel_wagon2.mdl"] = true,
	["models/sligwolf/diesel/diesel_wagon3.mdl"] = true,
	["models/sligwolf/unique_props/seat.mdl"] = true,
	["models/sligwolf/garbagetruck/sw_truck.mdl"] = true,
	["models/sligwolf/tram/tram.mdl"] = true,
	["models/sligwolf/tram/tram_half.mdl"] = true,
	["models/sligwolf/forklift_truck/forklift_truck.mdl"] = true,
	["models/lonewolfie/trailer_glass.mdl"] = true, --LW trailers (so they can't get damaged and explode)
	["models/lonewolfie/trailer_livestock.mdl"] = true,
	["models/lonewolfie/trailer_panel.mdl"] = true,
	["models/lonewolfie/trailer_profiliner.mdl"] = true,
	["models/lonewolfie/trailer_schmied.mdl"] = true,
	["models/lonewolfie/trailer_transporter.mdl"] = true,
	["models/lonewolfie/trailer_truck.mdl"] = true,
	["models/sentry/trailers/bevtrailer.mdl"] = true, --SGM trailers
	["models/sentry/trailers/boatcarrier.mdl"] = true,
	["models/sentry/trailers/carcarrier.mdl"] = true,
	["models/sentry/trailers/stortrailer.mdl"] = true,
	["models/sentry/trailers/tanker.mdl"] = true
}

function AM_IsBlackListed( veh )
	if !IsValid( veh ) then return true end --Return blacklisted if the vehicle isn't valid to avoid running IsValid twice
	local class = veh:GetClass()
	local model = veh:GetModel()
	if class == "prop_vehicle_jeep" and AM_Config_Blacklist[model] then
		return true
	end
	if veh.fphysSeat then --Avoid interference with Simfphy's
		return true
	end
	return false
end
