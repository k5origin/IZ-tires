
	local maxTirehealth = 10000.0	--These can be changed (default 10000.0)
	local maxBrakeheat = 10000.0	
	
	local setBrakeheat = maxBrakeheat
	local setTirehealth0 = maxTirehealth -- FR 0
	local setTirehealth1 = maxTirehealth -- FL 1
	local setTirehealth2 = maxTirehealth -- RR 2
	local setTirehealth3 = maxTirehealth -- RL 3

	local tMaxDamage = 0.0
	local tMinDamage = 0.0
	local brakeDamage = 0.0
	
	local usedCars = {}
	
RegisterCommand("usecar", function(source, args, rawCommand)
	UseCar()
end, false)
	
RegisterCommand("testcar", function(source, args, rawCommand)
	TestCar()
end, false)

RegisterCommand("pit", function(source, args, rawCommand) 
	Pit()
end, false)
	
function IsValidVehicle( veh ) -- Might not need this
    local model = GetEntityModel( veh )
    if ( IsThisModelACar( model ) or IsThisModelABike( model ) or IsThisModelAQuadbike( model ) ) then  
        return true 
    else 
        return false 
    end 
end 
	
function UseCar() 
	newcar = GetVehiclePedIsUsing(GetPlayerPed(-1))
		if not usedCars[newcar] then
			usedCars[newcar] = {
				tirehealth0 = maxTirehealth, tirehealth1 = maxTirehealth, tirehealth2 = maxTirehealth, tirehealth3 = maxTirehealth, brakeheat = maxBrakeheat, 
				mass = GetVehicleHandlingFloat(newcar, 'CHandlingData', 'fMass'), 
				fwd = (GetVehicleHandlingFloat(newcar, 'CHandlingData', 'fDriveBiasFront')*2), 
				defaultMinT = GetVehicleHandlingFloat(newcar, 'CHandlingData', 'fTractionCurveMin'),
				defaultMaxT = GetVehicleHandlingFloat(newcar, 'CHandlingData', 'fTractionCurveMax'), 
				defaultBrake = GetVehicleHandlingFloat(newcar, 'CHandlingData', 'fBrakeForce')
			}
		else
			print("Car already exists!")
		end
end

function TestCar()
	newcar = GetVehiclePedIsUsing(GetPlayerPed(-1))
	if usedCars[newcar] then
		print(usedCars[newcar].brakeheat)
	else 
		print("Not a saved car")
	end
end

function Pit() -- Repairs tires and cools brakes
	veh = GetVehiclePedIsUsing(GetPlayerPed(-1))
	if usedCars[veh] then
		usedCars[veh].tirehealth0 = maxTirehealth
		usedCars[veh].tirehealth1 = maxTirehealth
		usedCars[veh].tirehealth2 = maxTirehealth
		usedCars[veh].tirehealth3 = maxTirehealth
		usedCars[veh].brakeheat = maxBrakeheat
	else 
		print("Not a saved car")
	end
end
	

-- TODO need a method to remove cars and restore default stats
	
Citizen.CreateThread( function()
    while true do 
		veh = GetVehiclePedIsUsing(GetPlayerPed(-1), false)
		if (usedCars[veh]) then
			--print(veh, "Saved car")
			Tires()
		else
			--print(veh, "Not a saved car")
		end
        Citizen.Wait( 0 )
    end 
end )

	
	
function Tires()
		local ped = GetPlayerPed(-1)
		local veh = GetVehiclePedIsUsing( ped, false )
		local speed = GetEntitySpeed(veh)

		--test = tonumber(speed)/10000*angle(veh) --drift angle + speed -- We don't use angle here
		--test2 = math.abs(GetVehicleWheelSpeed(veh,0)+GetVehicleWheelSpeed(veh,1)+GetVehicleWheelSpeed(veh,2)+GetVehicleWheelSpeed(veh,3)) -- total tire friction
		
		if (GetVehicleCurrentGear(veh) <= 0 and IsControlPressed(0, 71)) then -- check if braking in forward and reverse gears
			test3 = (tonumber(speed))/2
		elseif (GetVehicleCurrentGear(veh) > 0 and IsControlPressed(0, 72)) then
			test3 = (tonumber(speed))/2
		--elseif IsControlPressed(0, 76) then -- don't forget handbrake, I think I'll leave it to the tire wear since it just locks the wheels
		--	test3 = (tonumber(speed))/4
		else 
			test3 = 0.0 -- brake resistance TODO: Rename these variables
		end

		test3 = test3 * 1.8 * (usedCars[veh].brakeheat/maxBrakeheat)  -- Used to be 2
			
		--tirehealthtotal = tirehealthtotal - (test2)
		setBrakeheat = usedCars[veh].brakeheat
		
		if IsVehicleOnAllWheels(veh) and usedCars[veh].brakeheat >= 0 then 
			setBrakeheat = setBrakeheat - test3
		end
		
		if setBrakeheat <= maxBrakeheat then
			setBrakeheat = setBrakeheat + 1 + speed/75 -- TODO Increase this for heavy cars?
		end
		
		if setBrakeheat > maxBrakeheat then
			setBrakeheat = maxBrakeheat
		end
		
		--DrawRect(0.5, 0.225, tirehealthtotal/50000.0, 0.025, 0, 255, 0, 255)

		

		
		--DrawRect(0.5, 0.9, test2, 0.025, 0, 0, 255, 255)
		
		--if (test3 > 0.00) then
		--DrawRect(0.5, 0.875, test3, 0.025, 255, 255, 255, 255)
		--else 
		--DrawRect(0.5, 0.875, test3, 0.025, 255, 0, 0, 255)
		--end
		
		--tirehealth0 = tirehealth0 - GetVehicleWheelSpeed(veh,1)
		--tirehealth1 = tirehealth1 - GetVehicleWheelSpeed(veh,0)
		--tirehealth2 = tirehealth2 - GetVehicleWheelSpeed(veh,3)
		--tirehealth3 = tirehealth3 - GetVehicleWheelSpeed(veh,2)		
		
		if usedCars[veh].tirehealth0 > 0 then
			setTirehealth0 = usedCars[veh].tirehealth0 - 1.4*math.abs(GetVehicleWheelSpeed(veh,1)) -- Used to be 1.2*math...
		else
			setTirehealth0 = 0
		end
		
		if usedCars[veh].tirehealth1 > 0 then
			setTirehealth1 = usedCars[veh].tirehealth1 - 1.4*math.abs(GetVehicleWheelSpeed(veh,0))
		else
			setTirehealth1 = 0
		end
		
		if usedCars[veh].tirehealth2 > 0 then
			setTirehealth2 = usedCars[veh].tirehealth2 - 1.4*math.abs(GetVehicleWheelSpeed(veh,3))
		else
			setTirehealth2 = 0
		end

		if usedCars[veh].tirehealth3 > 0 then
			setTirehealth3 = usedCars[veh].tirehealth3 - 1.4*math.abs(GetVehicleWheelSpeed(veh,2))
		else
			setTirehealth3 = 0
		end
		
		
		--setTirehealth0 = usedCars[veh].tirehealth0 - GetVehicleWheelSpeed(veh,1)
		--setTirehealth1 = usedCars[veh].tirehealth1 - GetVehicleWheelSpeed(veh,0)
		--setTirehealth2 = usedCars[veh].tirehealth2 - GetVehicleWheelSpeed(veh,3)
		--setTirehealth3 = usedCars[veh].tirehealth3 - GetVehicleWheelSpeed(veh,2)		

		DrawRect(0.79, 0.78, 0.015, GetVehicleWheelSpeed(veh,1)/40, 255, 128, 0, 128) -- FL 1  Shows tire friction
		DrawRect(0.81, 0.78, 0.015, GetVehicleWheelSpeed(veh,0)/40, 255, 128, 0, 128) -- FR 0  Swapping left and right tires since weight shifting seems to be reversed...
		DrawRect(0.79, 0.83, 0.015, GetVehicleWheelSpeed(veh,3)/40, 255, 128, 0, 128) -- RL 3
		DrawRect(0.81, 0.83, 0.015, GetVehicleWheelSpeed(veh,2)/40, 255, 128, 0, 128) -- RR 2
		
		DrawRect(0.79, 0.78, 0.010, 1/27, 255, 0, 0, 192) -- FL 1  DRAW HEALTH BACKGROUNDS
		DrawRect(0.81, 0.78, 0.010, 1/27, 255, 0, 0, 192) -- FR 0  Swapping left and right tires since weight shifting seems to be reversed...
		DrawRect(0.79, 0.83, 0.010, 1/27, 255, 0, 0, 192) -- RL 3
		DrawRect(0.81, 0.83, 0.010, 1/27, 255, 0, 0, 192) -- RR 2	
		
		DrawRect(0.79, 0.78, 0.010, setTirehealth1/(27*maxTirehealth), 255, 255, 255, 255) -- FL 1  DRAW HEALTH
		DrawRect(0.81, 0.78, 0.010, setTirehealth0/(27*maxTirehealth), 255, 255, 255, 255) -- FR 0  Swapping left and right tires since weight shifting seems to be reversed...
		DrawRect(0.79, 0.83, 0.010, setTirehealth3/(27*maxTirehealth), 255, 255, 255, 255) -- RL 3
		DrawRect(0.81, 0.83, 0.010, setTirehealth2/(27*maxTirehealth), 255, 255, 255, 255) -- RR 2	
		
		--print("Brake damage: ", 0.5+(setBrakeheat/maxBrakeheat)/2) 
		--print("Front damage: ", 0.75+((setTirehealth0/maxTirehealth + setTirehealth1/maxTirehealth)/8)) 
		--print("Rear damage: ", 0.75+((setTirehealth2/maxTirehealth + setTirehealth3/maxTirehealth)/8)) 
		
		tMaxDamage = 0.75+((setTirehealth0/maxTirehealth + setTirehealth1/maxTirehealth)/8) -- Damage to the car's steering affected by front wear
		tMinDamage = 0.5+((setTirehealth0/maxTirehealth + setTirehealth1/maxTirehealth)/4)*usedCars[veh].fwd + ((setTirehealth2/maxTirehealth + setTirehealth3/maxTirehealth)/4)*(1-usedCars[veh].fwd) -- Damage to the car's acceleration based on the car's layout: FWD acceleration is affected by front wear, RWD acceleration is affected by rear wear 
		brakeDamage = (setBrakeheat/maxBrakeheat)
		
		--DrawRect(0.922, 0.96, setBrakeheat/(maxBrakeheat*50), 0.040, 255, 255, 255, 255)
		DrawRect(0.923, 0.96, 0.028, 0.040, 255, math.floor(255*brakeDamage), math.floor(255*brakeDamage), 255)
		
		--print("MIN: ", tMinDamage)
		--print("fwd: ", usedCars[veh].fwd)
		-- TODO make sure the handling stats for Max and Brake don't drop below 0.5
		
		SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMax',	usedCars[veh].defaultMaxT*tMaxDamage)	-- Don't let this drop below 0.5
		SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin',	usedCars[veh].defaultMinT*tMinDamage)	-- Don't let this drop below 1.0
		SetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce', 		usedCars[veh].defaultBrake*brakeDamage)	-- Don't let this drop below 0.5
		
		---print("..") -- Prints the car's current handling floats in real time (FOR DEBUGGING)
		---print(GetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMax'))
		---print(GetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin'))
		---print(GetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce'))
		
		
		--usedCars[veh] = {tirehealth0 = setTirehealth0, tirehealth1 = setTirehealth1, tirehealth2 = setTirehealth2, tirehealth3 = setTirehealth3, brakeheat = setBrakeheat,  -- It's making a new car each time, is this bad?
		--	mass = GetVehicleHandlingFloat(newcar, 'CHandlingData', 'fMass'), -- Mass won't change, ever
		--	defaultMinT = usedCars[veh].defaultMinT,
		--	defaultMaxT = usedCars[veh].defaultMaxT,
		--	defaultBrake = usedCars[veh].defaultBrake,
		--}
		
		usedCars[veh].tirehealth0 = setTirehealth0
		usedCars[veh].tirehealth1 = setTirehealth1
		usedCars[veh].tirehealth2 = setTirehealth2
		usedCars[veh].tirehealth3 = setTirehealth3
		usedCars[veh].brakeheat = setBrakeheat
	end