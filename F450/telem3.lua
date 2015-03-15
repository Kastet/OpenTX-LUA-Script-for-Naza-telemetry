
-- ###############################################################
-- #                                                             #
-- #        Telemetry Lua Script 3 Naza, version 0.1             #
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


-- ################ Parameter auslesen ##################################################
   local settings = getGeneralSettings()
   local LatPos = getValue("latitude")                      
   local LatHome = getValue("pilot-latitude")                
   local LonPos =  getValue("longitude")                 
   local LonHome = getValue("pilot-longitude")							
   local RealHeading = getValue("heading")
   local myHeight = getValue("gps-altitude")


if simulation == 1 then
 
  LatPos = getValue("thr")/1000                                      -- for Taranis Simulation (throttle stick to play with values)
  LatHome = 0                                                        -- for Taranis Simulation
  LonPos = getValue("rud")/500                                       -- for Taranis Simulation (rudder stick to play with values)
  LonHome = 0                                                        -- for Taranis Simulation
  RealHeading = 87                                                   -- for Taranis Simulation
  myHeight = 256                                                     -- for Taranis Simulation
  mySpeed = 10.4                                                     -- for Taranis Simulation
end



-- ############ Calcutale Distance #########################################################
	 local d2r = math.pi/180
	 local d_lon = (LonPos - LonHome) * d2r ;
	 local d_lat = (LatPos - LatHome) * d2r ;
	 local a = math.pow(math.sin(d_lat/2.0), 2) + math.cos(LatHome*d2r) * math.cos(LatPos*d2r) * math.pow(math.sin(d_lon/2.0), 2);
	 local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
	 local dist = 6371000 * c;

-- ############ Calculate heading home and to multicopter ###############################
	 local z1 = math.sin(math.rad(LonHome) - math.rad(LonPos)) * math.cos(math.rad(LatHome))
	 local z2 = math.cos(math.rad(LatPos)) * math.sin(math.rad(LatHome)) - math.sin(math.rad(LatPos)) * math.cos(math.rad(LatHome)) * math.cos(math.rad(LonHome) - math.rad(LonPos))
	 local HeadToH = math.deg(math.atan2(z1, z2))
	 if HeadToH < 0 then	HeadToH=HeadToH+360	end
	 local HeadFrH = HeadToH-180
	 if HeadFrH < 0 then	HeadFrH = HeadFrH+360	end

-- ############## Display  ##############################################################
--  lcd.clear()                                        
   lcd.drawLine(0, 12, 210, 12, SOLID, GREY_DEFAULT)   -- Draw Horizontal line 1
   lcd.drawLine(0, 42, 210, 42, SOLID, GREY_DEFAULT)   -- Draw Horizontal line 2
   lcd.drawText(55,2, "Find me:" , 0)       -- Text
   
-- ############## Complete coordinates  ##########################################
	 lcd.drawText(1,15, "   Lat: " , MIDSIZE)
	 lcd.drawText(lcd.getLastPos(),15, tostring(LatPos) , MIDSIZE)
	 lcd.drawText(lcd.getLastPos(),15, "\64 " , MIDSIZE)
	 if LatPos > 0 then 
	 		lcd.drawText(lcd.getLastPos(),15,"N " , MIDSIZE)
	 else
	    lcd.drawText(lcd.getLastPos(),15,"S " , MIDSIZE)
	 end

	 lcd.drawText(1,28, "   Lon: " , MIDSIZE)
	 lcd.drawText(lcd.getLastPos(),28, tostring(LonPos) , MIDSIZE)
	 lcd.drawText(lcd.getLastPos(),28, "\64 " , MIDSIZE)
	 if LonPos > 0 then 
	 		lcd.drawText(lcd.getLastPos(),28,"E " , MIDSIZE)
	 else
	    lcd.drawText(lcd.getLastPos(),28,"W " , MIDSIZE)
	 end

-- ############## Distance to homepoint  ##########################################	 
	 lcd.drawPixmap(143, 44, "/SCRIPTS/BMP/dist.bmp")
	 lcd.drawNumber(165,48, dist * 100, PREC2 + MIDSIZE + LEFT)
	 lcd.drawText(lcd.getLastPos(),52, "m" , 0)

-- ############## Direction to multicopter seen from homepoint ####################
   lcd.drawPixmap(75, 45, "/SCRIPTS/BMP/comp.bmp")   
	 lcd.drawNumber(95,48, HeadFrH , MIDSIZE + LEFT)
	 lcd.drawText(lcd.getLastPos(), 48, "\64" , 0)

-- ############## Multicopter Height  ##############################################
	 lcd.drawPixmap(4, 45, "/SCRIPTS/BMP/hgt.bmp")
	 lcd.drawNumber(20,48, myHeight, MIDSIZE  + LEFT )
	 lcd.drawText(lcd.getLastPos(), 52, "m" , 0)


end

return { run=run }