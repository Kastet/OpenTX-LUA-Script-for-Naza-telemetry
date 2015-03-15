
-- ###############################################################
-- #                                                             #
-- #        Telemetry Lua Script 2 Naza, version 0.1             #
-- #                                                             #
-- #  + tested: F550, Zenmuse H3-3D                              #
-- #  + tested with X8R, Naze v2 GPS and Zaggometry              #
-- #                                                             #
-- #  License (Script & images): Share Alike                     #
-- #  Can be used and changed non commercial	         		 #
-- #                                                             #
-- #  Inspired by SockEye                                        #
-- #  Questions: Richard@hetnet.nl                               #
-- #                                                             #
-- ###############################################################


local function run(event)

-- local simulation= 1 						--1 for companion simulation
-- local simulation= 0 						--0 for use on transmitter

local simulation= 0 						-- DO NOT FORGET TO PUT TO ZERO if not in simulation with companion



-- ############### read settings from taranis #################
  local settings = getGeneralSettings()
  local RealHeading = getValue("heading")                            -- GPS Heading
  local LatPos = getValue("latitude")                                -- Latitude
  local LatHome = getValue("pilot-latitude")                         -- latitude home position
  local LonPos =  getValue("longitude")                              -- Longitude
  local LonHome = getValue("pilot-longitude")				         -- Longitude home position
  local mySpeed = getValue("gps-speed")                              -- GPS Speed in Meter / second  
  local myHeight = getValue("gps-altitude")                          -- GPS Height

-- ############ My speedsettings ##############################
  local myMaxDescRate = 1.9                                          -- Maximum descent speed in Meter/Sekunde
  local myAvgAirSpeed = 8                                            -- Average speed

-- ################## For Companion Taranis Simulation ########

if simulation == 1 then
 
  LatPos = getValue("thr")/1000                                      -- for Taranis Simulation (throttle stick to play with values)
  LatHome = 0                                                        -- for Taranis Simulation
  LonPos = getValue("rud")/500                                       -- for Taranis Simulation (rudder stick to play with values)
  LonHome = 0                                                        -- for Taranis Simulation
  RealHeading = 180                                                  -- for Taranis Simulation
  myHeight = 56                                                      -- for Taranis Simulation
  mySpeed = 10.4                                                     -- for Taranis Simulation
end

-- ############ Distance calculation   ########################
	local d2r = math.pi/180
	local d_lon = (LonPos - LonHome) * d2r ;
	local d_lat = (LatPos - LatHome) * d2r ;
	local a = math.pow(math.sin(d_lat/2.0), 2) + math.cos(LatHome*d2r) * math.cos(LatPos*d2r) * math.pow(math.sin(d_lon/2.0), 2);
	local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
	local dist = 6371000 * c;                                        -- Distance in meters
   
-- ############ Miniumum time to come home ####################
  local mySecToGrnd = 0                                              -- Time to descend from current height
  local myMinToHome = 0                                              -- Time in minutes to return home
  local mySecToHome = 0                                              -- Time in seconds to return home
  
  if myHeight > 0 then mySecToGrnd = myHeight / myMaxDescRate end    -- Height has to be > 0
  if (dist > 10 and mySpeed == 0) then                               -- Distance needs to be futher then 10 meters
  		 mySecToHome = math.max(dist / myAvgAirSpeed, mySecToGrnd)   -- If hovering, then calculate time back avg speed
  else 
  		mySecToHome = math.max(dist / mySpeed, mySecToGrnd)          -- If speed > 0 then calculate time back current speed
  end
  
  if mySecToHome > 60 then
  		myMinToHome = math.max(0, math.floor(mySecToHome/60))        -- Format minutes and seconds for time
  		mySecToHome = mySecToHome - (myMinToHome * 60)
  end
  
  mySecToHome = math.max(0, math.floor(mySecToHome))                 -- Just show a positive time
  
-- ############ calculate Heading and heading homepostion #####

	local z1 = math.sin(math.rad(LonHome) - math.rad(LonPos)) * math.cos(math.rad(LatHome))
	local z2 = math.cos(math.rad(LatPos)) * math.sin(math.rad(LatHome)) - math.sin(math.rad(LatPos)) * math.cos(math.rad(LatHome)) * math.cos(math.rad(LonHome) - math.rad(LonPos))
	local HeadToH = math.deg(math.atan2(z1, z2))                     -- Direction to home
	if HeadToH < 0 then	HeadToH=HeadToH+360	end
	local HeadFrH = HeadToH-180                                      -- Direction to multicopter
	if HeadFrH < 0 then	HeadFrH = HeadFrH+360	end

-- ############## Ausgaben auf Display ########################
  lcd.drawLine(0, 14, 210, 14, SOLID, GREY_DEFAULT)   		         -- Draw Horizontal line 1
  lcd.drawLine(0, 44, 210, 44, SOLID, GREY_DEFAULT)                  -- Draw Horizontal line 2

-- ############## Calulate arrow relative to homeposition #####
   local ArrowHeading = HeadToH - RealHeading
   if ArrowHeading < 0 then ArrowHeading = ArrowHeading + 360 end
   local myPixXPos = 98    
   if ArrowHeading > 270 then
    	myPixXPos = myPixXPos + ( ArrowHeading - 360)
    	lcd.drawPixmap(myPixXPos, 16, "/SCRIPTS/BMP/dir.bmp")
   elseif ArrowHeading < 90 then
      myPixXPos = myPixXPos +  ArrowHeading
      lcd.drawPixmap(myPixXPos, 16, "/SCRIPTS/BMP/dir.bmp")
   elseif ArrowHeading > 180 then
    	lcd.drawPixmap(2, 16, "/SCRIPTS/BMP/dirl.bmp")
   else
   		lcd.drawPixmap(195, 16, "/SCRIPTS/BMP/dirr.bmp")
   end

-- ############## Show values #################################

-- Time to Home	
	 lcd.drawText(30,1, "Time to home " , MIDSIZE)
	 if myMinToHome < 10 then
	 		lcd.drawText(lcd.getLastPos(),1, "0"  , MIDSIZE)
	 end
	 lcd.drawText(lcd.getLastPos(),1, tostring(myMinToHome)  , MIDSIZE)
	 lcd.drawText(lcd.getLastPos(),1, ":"  , MIDSIZE)
	 if mySecToHome < 10 then
	 		lcd.drawText(lcd.getLastPos(),1, "0"  , MIDSIZE)
	 end
	 lcd.drawText(lcd.getLastPos(),1, tostring(mySecToHome)  , MIDSIZE)

-- Distance
	 lcd.drawPixmap(152, 46, "/SCRIPTS/BMP/dist.bmp")
	 lcd.drawNumber(170,49, dist, MIDSIZE + LEFT)
	 lcd.drawText(lcd.getLastPos(),53, "m" , 0)

-- Speed in Km/h
   mySpeed = mySpeed * 3.6                                           -- 1ms = 3,6 kmh  
   lcd.drawPixmap(75, 46, "/SCRIPTS/BMP/speed.bmp")   
	 lcd.drawNumber(95,49, mySpeed , MIDSIZE + LEFT)
	 lcd.drawText(lcd.getLastPos(), 53, "Kmh" , 0)

-- Height
	 lcd.drawPixmap(4, 46, "/SCRIPTS/BMP/hgt.bmp")
	 lcd.drawNumber(20,49, myHeight, MIDSIZE  + LEFT )
	 lcd.drawText(lcd.getLastPos(), 53, "m" , 0)

-- Target Crosshairs
  lcd.drawLine(105, 14, 105, 43, SOLID, 0)                           -- Crosshair 1
  lcd.drawLine(90, 29, 120, 29, DOTTED, GREY_DEFAULT)                -- Crosshair 2
  
  lcd.drawLine(142, 43, 142, 62, SOLID, GREY_DEFAULT)                -- Crosshair 1
  lcd.drawLine(70, 43, 70, 62, SOLID, GREY_DEFAULT)                  -- Crosshair 1

end

return { run=run }