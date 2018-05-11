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
						player.combo = root
						player.combotimer=60
						player.incombo = false
					else
						player.combo = player.combo.left end
				end
	
				if btn(5) then
					if #player.combo.attac == 4 then
						player.combo = root
						player.combotimer=60
						player.incombo = false
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
    cls()
    player = make_player(1,1)

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


-- splash

function update_splash()
    -- usually we want the player to press one button
     if btn(5) then
         change_state()
     end
end

function draw_splash()
    rectfill(0,0,screen_size,screen_size,11)
    local text = "hello world"
    write(text, text_x_pos(text), 52,7)
end

-- game

function update_game()
  move_player()
  collisions()
end

function draw_game()
  spr(1, player.x, player.y-8, 1, 2)
		print('combo:'..player.combo.attac)
		print('combo timer:'..player.combotimer)
		print(player.incombo)
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
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
