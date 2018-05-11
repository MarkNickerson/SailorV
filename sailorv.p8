pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--------------------------------------------------------------------------------
-- acknowledgements
    -- misato for the base game outline
    -- advanced micro platformer - starter kit by mhughson
        -- https://www.lexaloffle.com/bbs/?pid=37158#p37402

--------------------------------------------------------------------------------
game_states = {
    splash = 0,
    game = 1,
    gameover = 2
}

state = game_states.splash

function change_state()
    cls()
    if state == game_states.splash then
        music(4)
        state = game_states.game
    elseif state == game_states.game then
        state = game_states.gameover
    elseif state == game_states.gameover then
        state = game_states.splash
    end
end

--------------------------------------------------------------------------------
---------------------------------- animation -----------------------------------
--------------------------------------------------------------------------------
actor = {} -- initalize the sprite object
actor.sprt = 0 -- sprite starting frame
actor.tmr = 1 -- internal timer for managing animation
actor.flp = false -- used for flipping the sprite

function idle()
  actor.tmr = actor.tmr+1 -- interal timer to activate waiting animations
  if actor.tmr>=10 then -- after 1/3 of sec, jump to sprite 6
    actor.sprt = 6
  end
  if actor.tmr >= 60 then -- after 2 sec jump frame 8
    actor.sprt = 7
  end
  if actor.tmr >= 62 then -- and jump back to frame 6,
    actor.sprt = 6
    actor.tmr = 0 -- restart timer
  end
end

function punch1()
  actor.sprt = 4
  actor.sprt += sprite_animator(0.2)
  actor.tmr = 0
  if actor.sprt>=7 then
    actor.sprt = 4
  end
  
  if actor.flp == true then
  	player.x -= 4
  else player.x += 4
  end
end

function punch2()
  actor.sprt = 5
  actor.sprt += sprite_animator(0.2)
  actor.tmr = 0
  if actor.sprt>=7 then
    actor.sprt = 5
  end
  
  if actor.flp == true then
  	player.x -= 4
  else player.x += 4
  end
end

function sprite_animator(x) -- this function receives the number of frames to animate by, increaments by the supplied amount and returns the value back calling user input function
	local y = 0
	y += x
	return y
end

--------------------------------------------------------------------------------
---------------------------------- player --------------------------------------
--------------------------------------------------------------------------------
function make_player(x,y)
  local p = {
    x=x,
    y=y,
    dx=0,
    dy=0,
    gravity=0.15,
    combotimer = 60,
    incombo = false,
    last = false,
    combo = root,
  }
  return p
end

-- player input

function move_player()

  accel = 0.25

  --idle
  idle()

  -- player control

  if btn(4) or btn(5) then
  	if player.last == false then
 			--do the thing here
 			player.combotimer = 60
 			player.incombo = true
 			player.last = true


  		if btn(4) then
          punch1()

					if #player.combo.attac == 4 then
						player.combo = root.left
						player.combotimer=60
					else
						player.combo = player.combo.left end
				end

				if btn(5) then
										punch2()
										
					if #player.combo.attac == 4 then
						player.combo = root.right
						player.combotimer=60
					else
						player.combo = player.combo.right end
				end
			end

		else player.last = false
		
  
  	if (btn(0)) then
       player.dx = player.dx - accel
       --pl.d=-1

        actor.flp = true -- flip the direction of the sprite
        actor.sprt+=sprite_animator(0.2)
        actor.tmr = 0

        if actor.sprt>=4 then
          actor.sprt = 0
        end

   	end
   	if (btn(1)) then
     player.dx = player.dx + accel
     --pl.d=1

       actor.flp = false -- set deafult direction of sprite
       actor.sprt += sprite_animator(0.2) -- animate the sprite by calling the sprite_animator function
       actor.tmr = 0 -- reset internal timer

       if actor.sprt>=4 then -- set the max number frames to animate
         actor.sprt = 0 -- reset the frame number, creating a loop
       end
   	end
   
   end

   -- gravity and friction
   player.dy+=player.gravity
   player.dy*=0.95

   -- x friction
   player.dx*=0.8

  -- if ((btn(4) or btn(2)) and pl.standing) then
  --   pl.dy = -0.7
  --end
  player.x+=player.dx
  player.y+=player.dy

  if player.y >= 120 then
    player.y = 120
  end
  
  handle_combo()

end

function handle_combo()
		if player.incombo == true then
			player.combotimer -= 1
		end

		if player.combotimer==0 then
			player.combotimer=60
			player.incombo = false
			player.combo = root
		end
end

function solid (x, y)
	if (x < 0 or x >= 128 ) then
		return true end

	val = mget(x, y)
	return fget(val, 1)
end

function collisions()

end


-- pico8 game funtions

function _init()
    t = 0
    cls()
    music(1)
    player = make_player(1,1)
    ninja=make_ninja(100,100)
end

function _update60()
    if state == game_states.splash then
        update_splash()
    elseif state == game_states.game then
        update_game()
    elseif state == game_states.gameover then
        update_gameover()
    end
end

function _draw()
    cls()
    if state == game_states.splash then
        draw_splash()
    elseif state == game_states.game then
        draw_game()
    elseif state == game_states.gameover then
        draw_gameover()
    end
end


------------------------------------------------ enemies

function make_ninja(x,y)
  local ninja = {
    x=x,                 -- x position
    y=y,                 -- y position
    p_jump=-1.75,           -- jump velocity
    dx=0,
    dy=0,
    max_dx=1,             -- max x speed
    --max_dy=2,             -- max y speed
    --p_width=8,            -- sprite width
    --p_height=16,          -- sprite height
    p_speed=0.02,         -- acceleration force
    drag=0.02,            -- drag force
    gravity=0.15,         -- gravity

    jump_button={
      update=function(self)
        if(btn(2)) then
          self.is_jumping=true
        else
          self.is_jumping=false
        end
      end
    },

    update=function(self)
      local b_left=btn(0)
      local b_right=btn(1)

      -- ninja spawns and runs to the left
      if(player.x < self.x and self.dx > -self.max_dx) then
        self.dx-=self.p_speed
      elseif(player.x > self.x and self.dx < self.max_dx) then
      	self.dx += self.p_speed
      end

      self.x+=self.dx
      self.jump_button:update()

      if self.jump_button.is_jumping then
        self.dy=self.p_jump
      end

      self.dy+=self.gravity
      self.y+=self.dy


      if self.y>=120 then
        self.y = 120
      end
    end,

    draw=function(self)
      spr(64, self.x, self.y-8, 1, 2)
      print ('self.y:'..(self.y), 80, 10, 5)
    end
  }
  add(allninjas, ninja)
  return ninja
end

------------------------------- end enemies

-- splash

function update_splash()
    -- usually we want the player to press one button
     if btn(5) then
         change_state()
     end
     t+= 1
end

function draw_splash()
    rectfill(0,0,screen_size,screen_size,1)
    spr(96, 4, 32, 15, 4)
    if(t % 60 >= 10) then
      local text = "press x to play"
      write(text, text_x_pos(text), 72,7)
    end
end

-- game

function update_game()
  move_player()
  collisions()
  ninja:update()
end

function draw_game()
	rectfill(0, 0, 127, 127, 13)
 spr(actor.sprt,player.x,player.y-8,1,2,actor.flp)
	print('combo:'..player.combo.attac,0,0,7)
	print('combo timer:'..player.combotimer,0,8,7)
	print(player.incombo,0,16,7)
  ninja:draw()
end


-- game over

function update_gameover()
end

function draw_gameover()
end

-- utils

-- change this if you use a different resolution like 64x64
screen_size = 128


-- calculate center position in x axis
-- this is asuming the text uses the system font which is 4px wide
function text_x_pos(text)
    local letter_width = 4

    -- first calculate how wide is the text
    local width = #text * letter_width

    -- if it's wider than the screen then it's multiple lines so we return 0
    if width > screen_size then
        return 0
    end

   return screen_size / 2 - flr(width / 2)

end

-- prints black bordered text
function write(text,x,y,color)
    for i=0,2 do
        for j=0,2 do
            print(text,x+i,y+j, 0)
        end
    end
    print(text,x+1,y+1,color)
end


-- returns if module of a/b == 0. equals to a % b == 0 in other languages
function mod_zero(a,b)
   return a - flr(a/b)*b == 0
end
-->8
--combo tree
root = {}
root.attac= " "
left = {}
root.left = left

right = {}
right.attac = "b"
root.right = right

left.attac = "a"
left.left = {}
left.left.attac = "aa"
left.right = {}
left.right.attac = "ab"
left.left.left = {}
left.left.left.attac = "aaa"
left.left.right = {}
left.left.right.attac = "aab"
left.right.left = {}
left.right.left.attac = "aba"
left.right.right = {}
left.right.right.attac = "abb"
left.left.left.left = {}
left.left.left.left.attac="aaaa"
left.left.left.right = {}
left.left.left.right.attac="aaab"
left.left.right.left = {}
left.left.right.left.attac="aaba"
left.left.right.right = {}
left.left.right.right.attac="aabb"
left.right.left.left = {}
left.right.left.left.attac="abaa"
left.right.left.right = {}
left.right.left.right.attac="abab"
left.right.right.left = {}
left.right.right.left.attac="abba"
left.right.right.right = {}
left.right.right.right.attac="abbb"


right.left = {}
right.left.attac = "ba"
right.right = {}
right.right.attac = "bb"
right.left.left = {}
right.left.left.attac = "baa"
right.left.right = {}
right.left.right.attac = "bab"
right.right.left = {}
right.right.left.attac = "bba"
right.right.right = {}
right.right.right.attac = "bbb"
right.left.left.left = {}
right.left.left.left.attac="baaa"
right.left.left.right = {}
right.left.left.right.attac="baab"
right.left.right.left = {}
right.left.right.left.attac="baba"
right.left.right.right = {}
right.left.right.right.attac="babb"
right.right.left.left = {}
right.right.left.left.attac="bbaa"
right.right.left.right = {}
right.right.left.right.attac="bbab"
right.right.right.left = {}
right.right.right.left.attac="bbba"
right.right.right.right = {}
right.right.right.right.attac="bbbb"
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000208000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000080882028808000008088202880002288008000008008000080080000800000000000000000000000000000000000000000000000000000000000000000
88202880029aaaa088202880029aaaa000888aa08820288008200280082002800000000000000000000000000000000000000000000000000000000000000000
829aaaa008aa8f80829aaaa008aa8f8002a88aa0829aaaa0029aaaa0029aaaa00000000000000000000000000000000000000000000000000000000000000000
88aa8f8008aac8c088aa8f8008aac8c0008aafa088aa8f8008a8f8a008a8f8a00000000000000000000000000000000000000000000000000000000000000000
08aac8c00aaffff008aac8c00aaffff000a7ffff08aac8c008ac8ca008af8fa00000000000000000000000000000000000000000000000000000000000000000
0aaffff00aa788000aaffff00aa788000aa777000affffff0aafffa00aafffa00000000000000000000000000000000000000000000000000000000000000000
0aa788a0aaf787000aa788a0aa7787000aa777000af788000aa888a00aa888a00000000000000000000000000000000000000000000000000000000000000000
0af787a000f777ff0af787a000ff7700aa077600aaf787000af878f00af878f00000000000000000000000000000000000000000000000000000000000000000
00f777000001110000f777f00001110000011100000777000af777f00af777f00000000000000000000000000000000000000000000000000000000000000000
00011100001111100001110000111110001111000001111000011100000111000000000000000000000000000000000000000000000000000000000000000000
00111100000f00f000111100000f0f00000ffff00011111000111100001111000000000000000000000000000000000000000000000000000000000000000000
000ff00000f00800000f0f00008000f08ff000f0000f00f0000f0f00000f0f000000000000000000000000000000000000000000000000000000000000000000
00088000008000000008080000000080080000880080008000080800000808000000000000000000000000000000000000000000000000000000000000000000
00000000000000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555550000005000000000000555550000000000055555000000000005555500000000000000000000000000000000000000000000000000000000000000000
08888888000055000000000008888888000000000888888800000000088888880000000000000000000000000000000000000000000000000000000000000000
0f0ff0f505555500000000000f0ff0f5000000000f0ff0f5000000000f0ff0f50000000000000000000000000000000000000000000000000000000000000000
0ffffff500550550000000000ffffff5000000000ffffff5000000000ffffff50000000000000000000000000000000000000000000000000000000000000000
05555555000555550000000005555555000000000555555500000000055555550000000000000000000000000000000000000000000000000000000000000000
00555550000550000000000000555550000000000055555000000000005555500000000000000000000000000000000000000000000000000000000000000000
05555585000500000000066555555585000000000555558500000000055555850000000000000000000000000000000000000000000000000000000000000000
05555855000000000000000000555855000000665555585500000000055558550000000000000000000000000000000000000000000000000000000000000000
05558555000000000000000000558555000000000055855500000066555585550000000000000000000000000000000000000000000000000000000000000000
06585556000000000000000000585556000000000058555600000000005855560000000000000000000000000000000000000000000000000000000000000000
06855556000000000000000000855556000000000085555600000000008555560000000000000000000000000000000000000000000000000000000000000000
00550550000000000000000000550550000000000055055000000000005505500000000000000000000000000000000000000000000000000000000000000000
00550550000000000000000000550550000000000055055000000000005505500000000000000000000000000000000000000000000000000000000000000000
00550550000000000000000000550550000000000055055000000000005505500000000000000000000000000000000000000000000000000000000000000000
06660666000000000000000006660666000000000666066600000000066606660000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777770000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777777770000000000788888788870000000000
00000000000000000000000000000000000000000000000000000000000077700000000000000000000000788888888870000000007888887888700000000000
00000000000000000000077700000000000000000000000000000000000779770000000000000000000000788888888870000000078888878887000000000000
00000000000000000000079970000000000000000000007777000000000799977000000000000000000000788888888870000000788888788870000000000000
00000000777777777770077970000000000000000000077997000000000779997000000777777770000000788888888870000007888887888777777700000000
00000007779999999977007970000000000007777000079997000000000077997000000799999970000000788888888870000078888878888888888700000000
00000077999999999997707970000000000077997700079997000000000007997700007799999977000000788888888870000788888777777888887000000000
00000779999999999999770770777777007799999970079977000000000007999700007997777997000000788888888870007888888888887888870000000000
00007799999777779999970077799997777999999977079970000000000007799700007997777997000000788888888870078888888888878888700000000000
00007999997700007799970079999999977997799997079970000000000000799700007997777997000000788888888870077778888888788887000000000000
00007999977000000779970079977779977997777997079970000000000000799700007997777997777000788888888870000788888887888870000000000000
00007999970000000077770079977779977997707777779977770000000000799700007999999999997000788888888870007888888878888700000000000000
00007999770000000000000079999999977799770079999999970000000000799700007799999779997000788888888870078888888788887000000000000000
00007999700000000000000079977777770799970079999999970000000000799700000777777777777000788888888870788888887888870000000000000000
00007999700000000000000079977777700779970077779977770000000000799700000000000000000000788888888877888888878888700000000000000000
00007999700000000000000079999999970079997700079970000000000000799700007777777700000000788888888888888888788887000000000000000000
00007999700000000000000077999999777077999770079970077770000007799700777999999777000000788888888888888887888870000000000000000000
00007999700000000000000007777777777707799970079970079970000077999777799999999997000000788888888888888878888700000000000000000000
00007999770000000000007777777777779707799970079970779970000079999779999999999997700000788888888888888788887000000000000000000000
00007999977000000000777999999997799777999970079977799770000079999999999997777999700000788888888888887888870000000000000000000000
00007799997777777777799999999999799999999970079999999700000079999999777777007777700000788888888888878888700000000000000000000000
00000799999999999999999997777799779999999770077999997700000079999977700000000000000000788888888888788887000000000000000000000000
00000779999999999999999777000779777777777700007777777000000079997770000000000000000000788888888887888870000000000000000000000000
00000077999999999999977700000077000000000000000000000000000077770000000000000000000000777777777777777700000000000000000000000000
00000007777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010c032000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f0500000024050000002805000000
01180020155551855515555185551555518555155551855510555175551355517555105551755513555175551055517555135551755510555175551355517555155551c555185551c555155551c555185551c555
011800001f5501f5501f5501d5501d5501d5501c550185001a5501a5501d5501d55018500175501a5501d5502155021550215502355023550215501f5501d5501c5501c5501f5501f5501850013550185501c550
01180000155501c550185501c550155501c550185501c5500e55015550115500050000500005000050000500105501d550115501d55011550135501f550155501555000500105551055510555105551055510555
0118000024550245500050024550235502355000500235502355023550215502155018500215501f5501d5501f5501f5501d5501d5501c5501a5501a55018550185501850018500185001850015550185501c550
011800080c605000051c6350000510605000051c63500005106050000500005000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800002b0502b0502b050290502905029050280502400026050260502905029050240002305026050290502d0502d0502d0502f0502f0502d0502b0502905028050280502b0502b050240001f0502405028050
010c0000281750010029175001000010000100241052410529175001002817500100281750010029175001002d175001002b175245052450524505305050050500500005001f5501f55024550245502855028550
010c0000187030070000700187031a7731a7731a7731877318773187031c773187031d773187031f7731870321773187032377318703187031870318703187031870318703007000070000700007000070000700
010c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000b57000000105700000015570000001a570000001f5701c600245701d6001d6001f000000001c0001c000000001d0001d000000002100000000000000000000000000000000000000000000000000000
0116000028120241002b1002612028120261202410026120261202312026120281202d120241002b120241002812024100241002612028120231202112021120211201a1201d1202112023120181002612000100
0116000010150001001c1050010010150001001c1050e1500e1502d100001002b100151501c105131501c10510150211001c1051a1001015000100001000e1500e150001001c1053c1000b150001000e15000100
011600001550000000106350000015500000001063511500115000000010635000001850010635106350000000000000001063500000000000000010635000000000000000106350000000000106351063500000
01160000180500e000180500e000180500e0001805017050170500b000170500500011050000000e050000000b050000001805000000180500000018050170501705000000170500000013050000001705000000
0116000028120261202b120281202812028120281202812528120261202b12028120281202812028120281252812026120281202b1202b1202d1202b1202f120000002f120240002f1202d1202d1202b12028120
011600000c1400c1400c140181400c140181400c14028100171401714017140181401714018140171400000015140151401514017140171401714018140171001714017140171401814018140181401c14018100
011000001d6230000000000000000000000000000001a6031d623006031c603006031a603006031c6031c6031c6231a6030060300603006030060300603006031c6231d603006030060300603006030060300603
0110000010540000001054000000000000000000000185000e540005000e540000000000000000000000050010540005001054000000000000000000000000001154000500115400050010540005001054000000
01100000211550010500105001051f1550010500105001051c1550010500105001051815500105001050010518155001051a15500105001050010518155001001c1551c1551a15500100181551a1550010018155
01100000100451004510045100450e0450e0450e0450e0451004510045100451004513045130451304513045100451004510045100450e0450e0450e0450e0451004510045100451004515045150451504515045
011000001515517155181551a1550000000000000000000017155181551a1551c15500000000000000000000181551a1551c1551d15500000000000000000000181551a1551c1551a15518155171551515500000
011000001515515155171551715518155171551515518100171551715518155181551a15518155171551a10018155181551a1551a1551c1551a155181551a1001c1551a155181551715518155171551515500000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001c6531a633186133460031600306002d6002b60029600276002560023600216001f6001e6001c6001a600186001760016600146001360011600116000f6000e6000c6000b6000a600086000660000000
000400000010029150221501d15019150121000c1000b10023100011002d1002f10033100331002e10027100221001f1001c1001a10019100191001a1001d10022100281002b1002f10031100321003210032100
0003000015050180501b0501f05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400001f75310700107001070010700107001070000700007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
01140000217530e600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400002475310600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002875024750207502075022750277502c7502e730147000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 07084044
01 01020544
02 03040544
00 41424344
00 090a4344
00 4b0d0c4e
01 4b0d0c0e
00 0b0d0c0e
00 0b0d0c0e
00 0f0d100e
02 0b0d0c0e
01 11125314
00 11121314
00 11125314
00 11121314
00 11125314
00 11121514
00 11125314
02 11121614

