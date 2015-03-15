
-- Telemetry Lua Script for DJI Naza
-- Version 0.1
-- Kostia Kim
-- kostia.kim@me.com

local function run(event)

local simulation = 1 -- DO NOT FORGET TO SET TO ZERO if not in simulation mode

-- Draw Frames
lcd.drawLine(37, 0, 37, 64, SOLID, GREY_DEFAULT)    -- Vertical line 1
lcd.drawLine(100, 0, 100, 64, SOLID, GREY_DEFAULT)  -- Vertical line 2
lcd.drawLine(162, 0, 162, 64, SOLID, GREY_DEFAULT)  -- Vertical line 3

lcd.drawLine(37, 21, 162, 21, SOLID, GREY_DEFAULT)   -- Horizointal line 1
lcd.drawLine(37, 42, 162, 42, SOLID, GREY_DEFAULT)   -- Horizontal line 2

-- the low value is my prefered low value 
local cellEmpty = 3.5
local cellFull = 4.2

-- Battery Display
local cellMin = getValue("cell-min")
local mySpeed = getValue("gps-speed")
local myHeight = getValue("gps-altitude")

if simulation == 1 then
  cellMin = 3.9
  mySpeed = 12
  myHeight = 35
end

local percent = (cellMin-cellEmpty)*(100/(cellFull-cellEmpty))

local myPxHeight = math.floor(percent * 0.37)            	
local myPxY = 11 + 37 - myPxHeight

lcd.drawPixmap(3, 1, "/SCRIPTS/BMP/battery.bmp")

if percent > 0 then
	lcd.drawFilledRectangle(8, myPxY, 21, myPxHeight, FILL_WHITE) 
end

local blinkAttr = 0
if (percent < 15) then
  blinkAttr = BLINK
end

lcd.drawNumber(8, 55, cellMin * 100  ,PREC2 + LEFT + blinkAttr)
lcd.drawText(lcd.getLastPos(), 55, "v ", blinkAttr)

-- ################### Flightmode ###############################
-- Change Switches down here for you personal configuration
-- Currently configued with:
-- IOC on Swith SA
-- Failsave on Switch SF
-- Manual, Atti and GPS ons switch SE

lcd.drawPixmap(46, 3, "/SCRIPTS/BMP/fm.bmp")                        -- Flight mode bmp

if getValue("rssi") > 20 then                                       -- RSSI > 20 then show rest 
   if getValue("sf") > 0 then                                       -- If Failsave (Switch SF)
      lcd.drawText(66, 5, "RTH", BLINK+MIDSIZE)                     -- Show blinking RTH
   else                                                             -- RTH not selected
      if getValue("sa") < 0 then                                    -- NO IOC Selected (Switch sg)
         if getValue("se") > 0 then                                 -- Manual mode on switch (Switch sb)
            lcd.drawText(66, 5, "Man", MIDSIZE)                     -- Show mode
         else                                                       
            if getValue("se") == 0 then                             -- Atti mode (Switch sg)
               lcd.drawText(66, 5, "Atti", MIDSIZE)                 -- show mode
            else                                                    
               lcd.drawText(66, 5, "GPS", MIDSIZE)                  -- show mode
            end                                                      
         end
      else                                                          -- Switch IOC is selected 
         if getValue("sa") == 0 then                                -- If HomeLock? (Switch sa)
            lcd.drawText(64, 1, "Home", 0)                          -- Show Homelock
            lcd.drawText(64, 10, "lock", 0)                         -- 
         else                                                       -- If Courselock? (Switch sa)
            lcd.drawText(64, 1, "Course", 0)                        -- Show Courselock
            lcd.drawText(64, 10, "lock", 0)                         -- 
         end                                                        
     end                                                            
   end                                                             
else                                                                -- RSSI < 20
  lcd.drawText(66, 5, "FAIL", BLINK+MIDSIZE)                        -- show FAIL
end                                                                 

-- ####################### Height  ##########################
lcd.drawPixmap(46, 46, "/SCRIPTS/BMP/hgt.bmp")
lcd.drawNumber(62, 46, myHeight , LEFT + DBLSIZE)
lcd.drawText(lcd.getLastPos(), 50, "m" , MIDSIZE)

-- ############## Speed ########################################
mySpeed = mySpeed * 3.6                                          -- 1ms = 3,6 kmh  
lcd.drawNumber(110, 46, mySpeed , LEFT + DBLSIZE)
lcd.drawText(lcd.getLastPos(), 52, "Kmh" , SMLSIZE)

-- ############## Distance ########################################
lcd.drawPixmap(110, 0, "/SCRIPTS/BMP/dist.bmp")
lcd.drawNumber(130, 4, getValue("distance"), LEFT + MIDSIZE)         -- Distance in meters
lcd.drawText(lcd.getLastPos(), 4, "m", MIDSIZE)

-- ################# GPS Quality ##################################
local myNumSat =  getValue("temp1")                                   -- Temp1 is number of sats
local myQualSat =  getValue("temp2")                                  -- Temp2 is quality of Satfix
 
if simulation == 1 then
  myNumSat = 8
  myQualSat = 4
end
 
for i=0,myQualSat do
  if i > 3 then 
    i = 3 
  end
  local imagePath = "/SCRIPTS/BMP/sat" .. i .. ".bmp"
  lcd.drawPixmap(46, 24, imagePath) 
end

for i=0,myNumSat do
  if i > 6 then
   i = 6 
  end
  local imagePath = "/SCRIPTS/BMP/gps_" .. i .. ".bmp"
  lcd.drawPixmap(66, 25, imagePath)              
end
			
lcd.drawNumber(73, 24, myNumSat,  SMLSIZE)

-- ################### Home Point ################################
if simulation == 1 then
    lcd.drawPixmap(110, 24, "/SCRIPTS/BMP/home.bmp")
    lcd.drawPixmap(130, 24, "/SCRIPTS/BMP/check.bmp")
else
  if getValue("pilot-longitude") == getValue("pilot-latitude") then -- this check is dodgy
    lcd.drawPixmap(110, 24, "/SCRIPTS/BMP/home1.bmp")
    lcd.drawText(132, 26, "?", MIDSIZE + BLINK)
  else
    lcd.drawPixmap(110, 24, "/SCRIPTS/BMP/home.bmp")
    lcd.drawText(132, 26, "X",  BLINK+ MIDSIZE)
  end

  if myNumSat > 5 then
    lcd.drawPixmap(110, 24, "/SCRIPTS/BMP/home.bmp")
    lcd.drawPixmap(130, 24, "/SCRIPTS/BMP/check.bmp")
  end
end

-- ############### RSSI ##############################################
local maxBarCount = 8
local startY = 47
local startX = 182
local smallestBarWidth = 10
local barHeight = 3

local rssi = getValue("rssi")
local barCount = maxBarCount * rssi / 100 -- assuming that 100 is max RSSI value

for i=0,barCount-1 do
  local marginDelta = 2 * i
  lcd.drawFilledRectangle(startX - marginDelta, startY - (barHeight * 2 * i), smallestBarWidth + marginDelta * 2, barHeight, 0)
end

lcd.drawNumber(179, 55, rssi, LEFT)
lcd.drawText(lcd.getLastPos(), 56, "dB", SMLSIZE)

end

return { run=run }