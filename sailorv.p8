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
        state = game_states.game
    elseif state == game_states.game then
        state = game_states.gameover
    elseif state == game_states.gameover then
        state = game_states.splash
    end
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
  accel = 0.5
  -- player control
   if (btn(0)) then
       player.dx = player.dx - accel
       --pl.d=-1
     end
   if (btn(1)) then
     player.dx = player.dx + accel
     --pl.d=1
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
	if btn(4) or btn(5) then
  	if player.last == false then
 			--do the thing here
 			player.combotimer = 60
 			player.incombo = true
 			player.last = true


  		if btn(4) then
					if #player.combo.attac == 4 then
						player.combo = root.left
						player.combotimer=60
					else
						player.combo = player.combo.left end
				end

				if btn(5) then
					if #player.combo.attac == 4 then
						player.combo = root.right
						player.combotimer=60
					else
						player.combo = player.combo.right end
				end
			end

		else player.last = false
		end

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
  spr(1, player.x, player.y-8, 1, 2)
		print('combo:'..player.combo.attac)
		print('combo timer:'..player.combotimer)
		print(player.incombo)
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
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000800000808820288080000080882028800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700088202880029aaaa088202880029aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700829aaaa008aa8f80829aaaa008aa8f800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000088aa8f8008aac8c088aa8f8008aac8c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000008aac8c00aaffff008aac8c00aaffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaffff00aa788000aaffff00aa788000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aa788a0aaf787000aa788a0aa7787000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000af787a000f777ff0af787a000ff77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000f777000001110000f777f0000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000111000011111000011100001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000111100000f00f000111100000f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ff00000f00800000f0f00008000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000880000080000000080800000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000888001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000888001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000888001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000080001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000080001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700008888801000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008080801000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008080801111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0ff0f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ffffff5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555585000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555855000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05558555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06585556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06855556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00550550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00550550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00550550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06660666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
