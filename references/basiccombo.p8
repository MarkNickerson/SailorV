pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	last = false
	combotimer = 60
	combo = ""
	incombo = false
	maxcombo = 10
	happy = false
end

function _update60()
	
	if btn(4) or btn (5) then
 	if last == false then
 		--do the thing here
 		combotimer = 60
 		incombo = true
 		last = true
 		
 		if btn(4) then 
 			combo = (combo.."1")
 		elseif btn(5) then
 			combo = (combo.."0")
 		end
 		
  end
  
	else last = false
	end
	
	if incombo == true then
		combotimer -= 1
	end
	
	if combo == "1101011" then
		happy = true
	else happy = false
	end
	
	if combotimer == 0 or 
		#combo == maxcombo then
		combotimer = 60
		incombo = false
		combo = ""
		happy = false
	end
	
end

function _draw()
	cls()
	print(combotimer)
	print(combo)
	print(happy)
end
