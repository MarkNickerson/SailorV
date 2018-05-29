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
    level1 = 1, --
    level2 = 2, -- dungeon
    level3 = 3, -- factory
    level4 = 4, -- factory escape
    lose_screen = 5,
    win_screen = 6,
    loading_screen = 7,
}

cam = {
  x = 0,
  y = 0
}

state = game_states.splash

next_state = game_states.splash -- level to load after loading screen

loading_end_time = 0 -- keeps track of when loading screen ends automatically
loading_time = 5 -- wait about 5 seconds before advancing

function change_state(desired_state)
  cls()
  camera(0,0)
  cam.x = 0
  cam.y = 0
  enemycount = 0
    -- if loading a level that's not the win, lose, or splash screen, show the loading screen before hand
    -- change music based on desired scene as well
    if state != game_states.loading_screen and is_battle_state(desired_state) then
        -- requesting a new level but not in loading screen yet
        loading_end_time = time() + loading_time -- wait loading_time seconds before automatically moving on
        change_music(music_states.loading_screen)
        next_state = desired_state -- store the desired scene
        state = game_states.loading_screen -- and go to loading screen instead
    elseif state == game_states.loading_screen and is_battle_state(desired_state) then
        init_game()

        if desired_state == game_states.level1 then
            change_music(music_states.city)
        elseif desired_state == game_states.level2 then
            change_music(music_states.dungeon)
        elseif desired_state == game_states.level3 then
            change_music(music_states.factory)
        elseif desired_state == game_states.level4 then
            -- todo speed up this
            change_music(music_states.factory)
        end

        -- -- temp for now to enjoy all musics
        -- music_randomizer = rnd(10)
        -- if music_randomizer < 2 then
        --     change_music(music_states.city)
        -- elseif music_randomizer < 4 then
        --     change_music(music_states.dungeon)
        -- elseif music_randomizer < 6 then
        --     change_music(music_states.factory)
        -- elseif music_randomizer < 8 then
        --     change_music(music_states.miniboss)
        -- else
        --     change_music(music_states.final_boss)
        -- end

        state = next_state
    elseif desired_state == game_states.splash then
        state = game_states.splash
        change_music(music_states.splash_screen)
    elseif desired_state == game_states.lose_screen then
        state = game_states.lose_screen
        change_music(music_states.lose_screen)
    elseif desired_state == game_states.win_screen then
        state = game_states.win_screen
        change_music(music_states.win_screen)
    else
        -- unrecognized state
        throw("unrecogonized state")
    end
end


function is_battle_state(desired_state)
    return desired_state == game_states.level1 or desired_state == game_states.level2
      or desired_state == game_states.level3 or desired_state == game_states.level4
end

--------------------------------------------------------------------------------
---------------------------------- animation -----------------------------------
--------------------------------------------------------------------------------
actor = {} -- initalize the sprite object
actor.sprt = 0 -- sprite starting frame
actor.idletmr = 1 -- internal timer for managing animation
actor.flp = false -- used for flipping the sprite

function idle()
  actor.idletmr = actor.idletmr+1 -- interal timer to activate waiting animations
  if actor.idletmr>=10 then -- after 1/3 of sec, jump to sprite 6
    actor.sprt = 8
  end
  if actor.idletmr >= 60 then -- after 2 sec jump frame 8
    actor.sprt = 9
  end
  if actor.idletmr >= 62 then -- and jump back to frame 6,
    actor.sprt = 8
    actor.idletmr = 0 -- restart timer
  end
end

function block()
  actor.sprt = 6
  actor.idletmr = 0
  actor.sprt += sprite_animator(1)
  if actor.sprt>=8 then
    actor.sprt = 7
  end
end

function kick()

  -- play finishing punch sound
  play_sound_effect(sound_effects.player_finisher)

  actor.sprt = 11
  actor.idletmr = 0
  actor.sprt += sprite_animator(1)
  if actor.sprt>=13 then
    actor.sprt = 12
  end

  -- play non finishing punch sound
  play_sound_effect(sound_effects.player_punch)

  if actor.flp == true then
    if player.x-4 <= 0  or (solid(player, player.x-6, player.y-0.5, 1)) then
      player.x = player.x
    else
      player.x -= 6
    end
  else
    if (solid(player, player.x+6, player.y-0.5, 1)) then
      player.x = player.x
    else
    player.x += 6
    end
  end

  obs_collision(allninjas, player)
end

function punch()

   -- play finishing punch sound
   play_sound_effect(sound_effects.player_finisher)
  	actor.sprt = player.combo.sprt
  	actor.sprt += sprite_animator(0.2)
  	actor.idletmr = 0
  	if actor.sprt>=7 then
    	actor.sprt = 4
  	end

   -- play non finishing punch sound
   play_sound_effect(sound_effects.player_punch)

  if actor.flp == true then
    if player.x-4 <= 0  or (solid(player, player.x-4, player.y-0.5, 1)) then
      player.x = player.x
    else
      player.x -= 4
    end
  else
    if (solid(player, player.x+4, player.y-0.5, 1)) then
      player.x = player.x
    else
    player.x += 4
    end
  end

  obs_collision(allninjas, player)
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
    tag=1,
    x=x,
    y=y-8,
    dx=0,
    dy=0,
    gravity=0.15,
    combotimer = 30,
    kicktimer = 10,
    incombo = false,
    last = false,
    combo = root,
    isgrounded = false,
    hearts=3,
    time=0
  }
  return p
end

-- player input

function move_player()

  accel = 0.25


  --idle
  idle()

  if btn(3) then
    if outter == 9 then
        play_sound_effect(sound_effects.shield_activate)
    elseif outter < 8.8 and outter > 0then
        play_sound_effect(sound_effects.shield_hold)
    end
    if outter > 0 and inner  > 0 then
        blocking = true
    else blocking = false
    end
    outter -= .05
    inner -= .05
    block()

    -- player control
  elseif btn(4) or btn(5) then
    if player.last == false then
      --do the thing here
      player.combotimer = 30
 			player.incombo = true
 			player.last = true

      if btn(4) then
        if #player.combo.attac == 4 then
          player.combo = root.left
          player.combotimer=30
        else
          player.combo = player.combo.left
        end
        punch()

      end

    if player.kicktimer == 10 then
      if btn(5) then
            if #player.combo.attac == 4 then
                player.combo = root.right
                player.combotimer=30
            else
                player.combo = player.combo.right
            end
            kick()
            player.kicktimer -= 1
        end
    end

    end
    else player.last = false
    blocking = false
    outter = 9
    inner = 6
    if player.kicktimer < 10 then
            player.kicktimer -= 1
        if player.kicktimer <=  0 then
            player.kicktimer = 10
            end
      end
    -- move player left
    if (btn(0)) then
      player.dx = player.dx - accel

      actor.flp = true -- flip the direction of the sprite
      actor.sprt+=sprite_animator(0.2)
      actor.idletmr = 0


      if actor.sprt>=4 then
          play_sound_effect(sound_effects.footstep) -- play walking sound
        actor.sprt = 0
      end
    end
    -- move player right
    if (btn(1)) then
      player.dx = player.dx + accel

      actor.flp = false -- set default direction of sprite
      actor.sprt += sprite_animator(0.2) -- animate the sprite by calling the sprite_animator function
      actor.idletmr = 0 -- reset internal timer
      if actor.sprt>=4 then -- set the max number frames to animate
          play_sound_effect(sound_effects.footstep) -- play walking sound
        actor.sprt = 0 -- reset the frame number, creating a loop
      end
    end
  end

  -- gravity and friction
  --if not solid_tile(player.x, player.y + 9, 1) then
  --  player.dy+=player.gravity
  --  player.dy*=0.95
  --  player.isgrounded = false
  --else
  --  player.isgrounded = true
  --  player.dy=0
  --end

  -- player jumping
  if (btn(2)) then
        if jumplast == false then
        jumplast = true
        if player.isgrounded then
            play_sound_effect(sound_effects.player_jump) -- play jump sound
        player.dy-=4
        end
        end
else
  jumplast = false
      end

  -- x friction
  player.dx*=0.8

  -- if ((btn(4) or btn(2)) and pl.standing) then
  --   pl.dy = -0.7
  --end

  --player.x+=player.dx
  --player.y+=player.dy
  --player.dy = player.dy * -0.7

  --if player.y >= 120 then
    --player.y = 120
  --end
  player.time+=1

  if player.hearts == 0 or player.y >= 180 then
    change_state(game_states.lose_screen)
  end

  if(solid(player, player.x, player.y-0.5, 7)) then
    change_state(game_states.win_screen)
  end

  handle_combo()

end

function handle_combo()
		if player.incombo == true then
			player.combotimer -= 1
		end

		if player.combotimer==0 then
			player.combotimer=30
			player.incombo = false
			player.combo = root
		end
end

function solid(obs, x, y, tag)
  local tilex1 = ((x - (x % 8)) / 8)
  local tilex2 = ((x - (x % 8) + 8) / 8)
  local tiley1 = ((y - (y % 8)) / 8)
  local tiley2 = ((y - (y % 8) - 8) / 8)

  if ((obs.tag == 1) or (obs.tag == 2)) then
    if (fget(mget(tilex1, tiley1), tag)) or (fget(mget(tilex2, tiley1), tag)) or (fget(mget(tilex1, tiley2), tag)) or (fget(mget(tilex2, tiley2), tag))then
      return true
    else
      return false
    end
  elseif (obs.tag == 3) or (obs.tag == 4) then
    if (fget(mget(tilex1, tiley1), tag)) then
      return true
    else
      return false
    end
  end
end

function obs_collision(obj1, obj2)
  for f in all(obj1) do
    if obj1.tag == 4 then
      if((f.y <= obj2.y) and (f.y >= obj2.y-16)) and ((f.x <= obj2.x+4) and (f.x >= obj2.x-4)) then
        if obj2.hearts < 3 then
          play_sound_effect(sound_effects.health_pickup)
          obj2.hearts += 1
          del(obj1, f)
        end
      end
    elseif obj1.tag == 3 then
      if((f.y <= obj2.y) and (f.y >= obj2.y-16)) and ((f.x <= obj2.x+4) and (f.x >= obj2.x-4)) then

        del(obj1, f)
        if blocking == false then
          if obj2.hearts > 0 then
            taking_damage = true
            play_sound_effect(sound_effects.player_damaged)
            camera(cos(t/3), cos(t/2))
            obj2.hearts -= 1
          end
        else
        	outter -= 4
          inner -= 4
        end
      end

    elseif obj1.tag == 2 then
      if((f.y <= obj2.y+8) and (f.y >= obj2.y-8)) and ((f.x <= obj2.x+8) and (f.x >= obj2.x-8)) then
        if actor.flp == true then
            f.x -= 6.5
        else
            f.x += 6.5
        end
        f.health -= obj2.combo.dmg
        play_sound_effect(sound_effects.enemy_damaged)
        if f.health <= 0 then
            del(obj1, f)
        end
      end
    end

    if (f.x<=0) del(obj1, f)
  end
end


function move_actor(actor)
  -- check actor tag
  -- 1: player
  -- 2: ninja
  if(actor.tag == 1) then
    move_player()
  end
  if (actor.tag == 2) then
    update_ninja(actor)
  end


  -- begin actor.x movement
  local x1 = actor.x + actor.dx + sgn(actor.dx)*0.3

  if(not solid(actor, x1, actor.y-0.5, 1)) then
    actor.x += actor.dx
  else
    while(not solid(actor, actor.x + sgn(actor.dx)*0.3, actor.y-0.5, 1)) do
      actor.x += sgn(actor.dx)*0.1
    end
    actor.dx = 0
  end
  -- end actor.x movement

  -- begin actor.y movement
  actor.isgrounded = false
  if (actor.dy < 0) then
    -- cieling collision detection
    if (solid(actor, actor.x-0.2, actor.y+(actor.dy-1), 1) or solid(actor, actor.x+0.2, actor.y+(actor.dy-1), 1)) then
      actor.dy = 0

      -- search up for collision point
      while ( not (solid(actor, actor.x-0.2, actor.y-8, 1) or solid(actor, actor.x+0.2, actor.y-8, 1))) do
        actor.y -= 0.01
      end
    else
      actor.y += actor.dy
    end
  else
    -- floor collision detection
    if (solid(actor, actor.x-0.2, actor.y+actor.dy, 1) or solid(actor, actor.x+0.2, actor.y+actor.dy, 1)) then
      -- if is jumping, don't change dy
      if (actor.dy > 3) then
        actor.dy = actor.dy
      else

        actor.isgrounded=true
        actor.dy = 0
      end

      -- remove ability to sneak through walls
      while (not (solid(actor, actor.x-0.2,actor.y, 1) or solid(actor, actor.x+0.2,actor.y, 1))) do
        actor.y += 0.05
      end
      while(solid(actor, actor.x+0.2,actor.y-0.1, 1)) do
        actor.y -= 0.05
      end
    else
      actor.y += actor.dy
    end
  end

  -- vertical friction
  actor.dy += actor.gravity
  actor.dy *= 0.95

  -- horizontal friction
  if (actor.isgrounded) then
    actor.dx *= 0.8
  else
    actor.dx *= 0.9
  end
end



-- pico8 game funtions

function _init()
    t = 0
    taking_damage = false
    enemycount = 0
    cls()
    camera(0, 0)
    change_music(music_states.splash_screen)
end

function _update60()
    if state == game_states.splash then
        update_splash()
    elseif state == game_states.loading_screen then
        update_loading()
    elseif is_battle_state(state) then
        update_game()
    elseif state == game_states.lose_screen then
        update_gameover()
    elseif state == game_states.win_screen then
        update_win()
    end
end

function _draw()
    cls()

    if state == game_states.splash then
        draw_splash()
    elseif state == game_states.loading_screen then
        draw_loading()
    elseif is_battle_state(state) then
        draw_game()
    elseif state == game_states.lose_screen then
        draw_gameover()
    elseif state == game_states.win_screen then
        draw_win()
    else
        assert("unknown scene to draw") -- throw aerror
    end
end

health_pack = {
  tag = 4
}

function update_health_pack(obj)
  obs_collision(health_pack, player)
  if not solid(obj, obj.x, obj.y+8, 1) then
    obj.y += 2 * obj.dx
  else
    if (t%25 == 0) then
      obj.y = obj.y-1
    end
  end
end


------------------------------------------------ enemies
shuriken = {
  tag = 3
}

allninjas = {
  tag = 2
}

function update_shuriken(obj)
  if t - obj.birthdate >= 500 then
    del(shuriken, obj)
  end

  -- deletes shurikens when they go off screen
  if(obj.dx < 0) then
  	if (obj.x > (player.x + 128)) then 
  		del(shuriken, obj)
  	end
  elseif (obj.dx > 0) then
  	if (obj.x < (player.x - 128)) then
  		del(shuriken, obj)
  	end
  end

  obs_collision(shuriken, player)
	if(t % 6 == 0) then
    if solid(obj, obj.x, obj.y, 1) then
      obj.x = obj.x
      obj.flip = false
    else
      obj.x -= 8 * obj.dx

    end
		if(obj.flip == true) then
			obj.flip = false
		else
			obj.flip = true
		end
	end
end

function draw_obj(obj)
  	spr(obj.sprite, obj.x, obj.y, 1, 1, obj.flip)
end

function create_obs(obj, sprite, x, y, dx, tag)
  -- empty table to fill with below values
  local o = {}
  o.x = x
  o.y = y
  o.dx = dx
  o.sprite = sprite
  o.flip = false
  o.tag = tag
  o.birthdate = t

  add(obj, o)
  return o
end

function make_ninja(x,y)
  local ninja = {
    tag=2,
    x=x,                 -- x position
    y=y,                 -- y position
    dx=0,
    dy=0,
    max_dx=.2,             -- max x speed
    p_speed=0.02 + (rnd(0.075)),         -- acceleration force
    drag=0.02,            -- drag force
    gravity=0.15,         -- gravity
    flip = false,		-- false == left facing, true == right facing
    health = 20,
    sprite = 67,
    is_throwing = false,
    is_walking = true,
    throw_mod = 250 + flr(rnd(150)),
    throw_timer = 0,
    hearts = 5
  }
  add(allninjas, ninja)
  return ninja
end

function walk_ninja(ninja)
  if(ninja.is_walking) then
  	if(ninja.dx == 0) then
  		ninja.sprite = 64
    elseif(t % 10 == 0 and ninja.sprite != 72) then
      ninja.sprite = ninja.sprite + 1
    elseif(t % 10 == 0 and ninja.sprite == 72) then
      play_sound_effect(sound_effects.footstep)
      ninja.sprite = 67
    end
  end
end

function throw_ninja(ninja)
  	if(ninja.is_throwing == true) then
    if(ninja.throw_timer == 0) then -- spawn a shuriken once animation finishes
            play_sound_effect(sound_effects.ninja_throw)
  			if(ninja.flip) then -- facing right
  				create_obs(shuriken, 79, ninja.x+4, ninja.y-10, -1, 3)
  			else -- facing left
  				create_obs(shuriken, 79, ninja.x-4, ninja.y-10, 1, 3)
  			end
  			ninja.is_throwing = false
        ninja.is_walking = true
  			ninja.throw_mod = 250 + flr(rnd(200))
  			ninja.sprite = 67
  		elseif(ninja.throw_timer > 13) then
  			ninja.sprite = 65
  		elseif(ninja.throw_timer > 0) then
  			ninja.sprite = 66
  		end
  		ninja.throw_timer -= 2
    elseif(t % ninja.throw_mod == 0) then -- cannot throw while previous throw is being completed
      ninja.is_throwing=true
      ninja.is_walking = false
      ninja.throw_timer =20
    end
end

function update_ninja(ninja)
  -- ninja spawns and runs to the left

  if(player.x < ninja.x and ninja.dx > -ninja.max_dx) then
  	if((ninja.x - player.x) < 8) then --player isnt moving, ninja stops at player location
  		ninja.dx = 0
  	else
    	ninja.flip = false
      ninja.dx-=ninja.p_speed
  end
  elseif(player.x > ninja.x and ninja.dx < ninja.max_dx) then
    if((player.x - ninja.x) < 8) then
  		ninja.dx = 0
  	else
    	ninja.flip = true
    	ninja.dx += ninja.p_speed
    end
  end

  ninja.dy+=ninja.gravity
  -- delete ninja if it falls into the abyss
  if(ninja.y >= 150) then
    del(allninjas, ninja)
  end
end

function draw_ninja(ninja)
    walk_ninja(ninja)
    throw_ninja(ninja)
  	spr(ninja.sprite, ninja.x, ninja.y-16, 1, 2, ninja.flip)
end



function spawnbrawl(xlock)
  if brawl_spawn == false then

    brawl_spawn = true
    brawl_clear = false
    enemycount = #allninjas

    make_ninja(player.x - 50, 0)
    make_ninja(player.x + 50, 0)
    make_ninja(player.x - 100, 0)
    make_ninja(player.x + 100, 0)

    if (xlock-cam.x>64+25) then cam.x+=1 end
  end

  if not brawl_clear then
    if #allninjas <= enemycount then
      brawl_clear = true
      enemycount = 0
    end
  end
end


------------------------------- end enemies

-- splash

function update_splash()
    -- usually we want the player to press one button
     if btnp(5) then
         change_state(game_states.level1)
     end
     t+= 1
end

function draw_splash()
  rectfill(0,0,screen_size,screen_size,1)
  local x = t / 8
  x = x % 128
  local y=0
  map(21, 16, -x, y, 16, 16, 0)
  map(21, 16, 128-x, y, 16, 16, 0)

  --static skyline
  palt(0, false)
  palt(1, true)
  pal(13,2)
  y = 0
  map(0, 17, 0, y-8, 128, 32)
  pal()
  palt(1,false)
  palt(0, true)

  palt(0, false)
  palt(1, true)
  map(0, 17, (-x)/2, y, 128, 32, 0x5)
  map(0, 17, 128-((x)/2), y, 128, 32, 0x5)
  palt(1, false)
  palt(0, true)

  spr(208, 4, 32, 15, 3)
  if(t % 60 >= 10) then
    local text = "press x to play"
    write(text, text_x_pos(text), 72,7)
  end
end

-- loading

function update_loading()
    -- after enough time has passed, move on to the level
     if time() > loading_end_time then
         change_state(next_state)
     end
end

function draw_loading()
    rectfill(0,0,screen_size,screen_size,0)
    local level_name = ""
    local level_description = ""
    if next_state == game_states.level1 then
        level_name = "episode 1:"
        level_description = "\146save the city, sailor v!\146"
    elseif next_state == game_states.level2 then
        level_name = "episode 2:"
        level_description = "\146escape the dungeon, sailor v!!\146"
    elseif next_state == game_states.level3 then
        level_name = "episode 3:"
        level_description = "\146beat the evil boss, sailor v!\146"
    elseif next_state == game_states.level3 then
        level_name = "episode 4:"
        level_description = "\146escape the factory, sailor v!\146"
    else
        throw("unknown level")
    end
    write(level_name, text_x_pos(level_name), 50,7)
    write(level_description, text_x_pos(level_description), 64,7)
end

-- game

function init_game()
	player = make_player(20,1)
  -- location to spawn first ninja
  ninjaspawn = 0
  make_ninja(469, 0) -- because dan wanted a ninja here
  brawl_spawn = false
  brawl_clear = true

  create_obs(health_pack, 39, 180, 4, 1, 4)
  create_obs(health_pack, 39, 300, 4, 1, 4)
  create_obs(health_pack, 39, 400, 4, 1, 4)
  create_obs(health_pack, 39, 500, 4, 1, 4)
  create_obs(health_pack, 39, 700, 4, 1, 4)
end

function update_game()
  -- spawn more ninjas at randomized x locations
  if(player.x >= ninjaspawn) then
    make_ninja(player.x + 100, 0)
    ninjaspawn += 50
    ninjaspawn += flr(rnd(200))
  end
  foreach(shuriken, update_shuriken)
  foreach(health_pack, update_health_pack)
  move_actor(player)
  foreach(allninjas, move_actor)

  if(player.x >= 300 and player.x <= 350) then
    spawnbrawl(300)
  end
  if(player.x >= 700 and player.x <= 750) then
    spawnbrawl(700)
  end
  if (player.x >= 500 and player.x <= 550) then
    brawl_spawn = false
  end
  t+= 1
end

function draw_game()
  rectfill(0, 0, 127, 127, 1)

  --stars
  local x = t / 8
  x = x % 128
  local y=0
  map(21, 16, 0, y, 16, 16, 0)

  --static skyline
  palt(0, false)
  palt(1, true)
  pal(13,2)
  y = 0
  map(0, 17, 0, y-8, 128, 32)
  pal()
  palt(1,false)
  palt(0, true)

  palt(0, false)
  palt(1, true)
  map(0, 17, (-cam.x)/6, y, 128, 32, 0x5)
  map(0, 17, 128-((cam.x)/6), y, 128, 32, 0x5)
  palt(1,false)
  palt(0, true)

  camera(0,0)
  if(brawl_clear) then
    if ((player.x-cam.x<64-20) and (player.x>45))then cam.x-=1 end
    if (player.x-cam.x>64+25) then cam.x+=1 end
  end
  camera(cam.x, cam.y)


  map(0, 0, 0, 0, 128, 32)
  foreach(allninjas, draw_ninja)
  foreach(shuriken, draw_obj)
  foreach(health_pack, draw_obj)
  if(blocking == true) then
    if actor.flp == true then
      circfill(player.x+4, player.y-8, outter, 10)
      circfill(player.x+7, player.y-8, inner, 0)
    else
      circfill(player.x+2, player.y-8, outter, 10)
      circfill(player.x-1, player.y-8, inner, 0)
    end
  end
 	draw_player()



	print('combo:'..player.combo.attac,cam.x,0,7)
	print('combo timer:'..player.combotimer,cam.x,8,7)
	print(player.incombo,cam.x,16,7)
  print(brawl_clear, cam.x + 5,24,0)
  print(brawl_spawn,cam.x + 5,32,0)
  print(#allninjas,cam.x + 5,40,0)
  print(enemycount,cam.x + 5,48,0)
  draw_hearts()
  camera(0,0)
end


-- game over

function update_gameover()
     if btnp(5) then
         change_state(game_states.splash)
     end
end

function draw_gameover()
    local text = "c'est la vie..."
    local restart_text = "press x to restart"
    write(text, text_x_pos(text), 50,7)
    write(restart_text, text_x_pos(restart_text), 64,7)
    -- deletes ninjas and shurikens
    for obj in all(allninjas) do
      del(allninjas, obj)
    end
    for obj in all(shuriken) do
      del(shuriken, obj)
    end
    for obj in all(health_pack) do
      del(health_pack, obj)
    end

end

-- win
function update_win()

end

function draw_win()
    local text = "c'est la vie..."
    write(text, text_x_pos(text), 50,7)
end



function draw_player()
  if(taking_damage) then
      for j=2,15 do
        pal(j,7+((player.time/2) % 4))
      end

      if(t%10==0) then
        taking_damage = false
      end
    end

  spr(actor.sprt,player.x,player.y-16,1,2,actor.flp)
  pal()
end

-- draw hearts ui
function draw_hearts()
  if(player.hearts == 3) then
    spr(36, cam.x+110, 1)
    spr(36, cam.x+101, 1)
    spr(36, cam.x+92, 1)
  elseif (player.hearts == 2) then
    spr(37, cam.x+110, 1)
    spr(36, cam.x+101, 1)
    spr(36, cam.x+92, 1)
  elseif (player.hearts == 1) then
    spr(37, cam.x+110, 1)
    spr(37, cam.x+101, 1)
    spr(36, cam.x+92, 1)
  elseif (player.hearts == 0) then
    spr(37, cam.x+110, 1)
    spr(37, cam.x+101, 1)
    spr(37, cam.x+92, 1)
  end
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
root.sprt = 0
left = {}
root.left = left

right = {}
right.attac = "b"
right.sprt = 10
right.dmg = 2
root.right = right

left.attac = "a"
left.sprt = 4
left.dmg = 1
left.left = {}
left.left.attac = "aa"
left.left.sprt = 5
left.left.dmg = 1
left.right = {}
left.right.attac = "ab"
left.right.dmg = 2
left.left.left = {}
left.left.left.attac = "aaa"
left.left.left.sprt = 4
left.left.left.dmg = 1
left.left.right = {}
left.left.right.attac = "aab"
left.left.right.dmg = 2
left.right.left = {}
left.right.left.attac = "aba"
left.right.left.sprt = 5
left.right.left.dmg = 1
left.right.right = {}
left.right.right.attac = "abb"
left.right.right.dmg = 2
left.left.left.left = {}
left.left.left.left.attac="aaaa"
left.left.left.left.sprt = 5
left.left.left.left.dmg = 3
left.left.left.right = {}
left.left.left.right.attac="aaab"
left.left.left.right.dmg = 6
left.left.right.left = {}
left.left.right.left.attac="aaba"
left.left.right.left.sprt = 4
left.left.right.left.dmg = 3
left.left.right.right = {}
left.left.right.right.attac="aabb"
left.left.right.right.dmg = 6
left.left.right.right.sprt = 10
left.right.left.left = {}
left.right.left.left.attac="abaa"
left.right.left.left.sprt = 4
left.right.left.left.dmg = 3
left.right.left.right = {}
left.right.left.right.attac="abab"
left.right.left.right.dmg = 6
left.right.right.left = {}
left.right.right.left.attac="abba"
left.right.right.left.sprt = 5
left.right.right.left.dmg = 3
left.right.right.right = {}
left.right.right.right.attac="abbb"
left.right.right.right.dmg = 6


right.left = {}
right.left.attac = "ba"
right.left.sprt = 4
right.left.dmg = 1
right.right = {}
right.right.attac = "bb"
right.right.dmg = 2
right.left.left = {}
right.left.left.attac = "baa"
right.left.left.sprt = 5
right.left.left.dmg = 1
right.left.right = {}
right.left.right.attac = "bab"
right.left.right.dmg = 2
right.right.left = {}
right.right.left.attac = "bba"
right.right.left.sprt = 4
right.right.left.dmg = 1
right.right.right = {}
right.right.right.attac = "bbb"
right.right.right.dmg = 2
right.left.left.left = {}
right.left.left.left.attac="baaa"
right.left.left.left.sprt = 4
right.left.left.left.dmg = 3
right.left.left.right = {}
right.left.left.right.attac="baab"
right.left.left.right.dmg = 6
right.left.right.left = {}
right.left.right.left.attac="baba"
right.left.right.left.sprt = 5
right.left.right.left.dmg = 3
right.left.right.right = {}
right.left.right.right.attac="babb"
right.left.right.right.dmg = 6
right.right.left.left = {}
right.right.left.left.attac="bbaa"
right.right.left.left.sprt = 5
right.right.left.left.dmg = 3
right.right.left.right = {}
right.right.left.right.attac="bbab"
right.right.left.right.dmg = 6
right.right.right.left = {}
right.right.right.left.attac="bbba"
right.right.right.left.sprt = 4
right.right.right.left.dmg = 3
right.right.right.right = {}
right.right.right.right.attac="bbbb"
right.right.right.right.dmg = 6
-->8
--music stuff

-- enum for all possible music states
music_states = {
    splash_screen = 0,
    city = 1,
    dungeon = 2,
    miniboss = 3,
    factory = 4,
    final_boss = 5,
    lose_screen = 6,
    win_screen = 7,
    loading_screen = 8,
}

sound_effects = {
   shield_activate = 0,
   player_punch = 1,
   player_damaged = 2,
   ninja_throw = 3,
   enemy_damaged = 4,
   player_jump = 5,
   footstep = 6,
   shield_hold = 7,
   health_pickup = 8,
   player_finisher = 9,
}

-- call this to change music based on given music_state
function change_music(music_state)
    pattern_num = -1
    if music_state == music_states.splash_screen then
        pattern_num = 0
    elseif music_state == music_states.city then
        pattern_num = 4
    elseif music_state == music_states.dungeon then
        pattern_num = 10
    elseif music_state == music_states.miniboss then
        pattern_num = 20
    elseif music_state == music_states.factory then
        pattern_num = 26
    elseif music_state == music_states.final_boss then
        pattern_num = 41
    elseif music_state == music_states.lose_screen then
        pattern_num = 2
    elseif music_state == music_states.win_screen then
        pattern_num = 37
    elseif music_state == music_states.loading_screen then
        -- shows level name and amount of lives
        pattern_num = 3
    end
    -- begin playing the selected song from channel 0 or throw an error if still -1
    music(pattern_num,0)
end

function play_sound_effect(sound_effect)
    sfx_num = -1
    length = -1
    offset = -1
    channel_num = 3 -- always use last channel because first 3 are for music

    if sound_effect == sound_effects.shield_activate then
        sfx_num = 58
        length = 8
        offset = 0
    elseif sound_effect == sound_effects.player_punch then
        sfx_num = 60
        length = 1

        -- alternate between 2 sounds
        if rnd(10) > 5 then
            offset = 0
        else
            offset = 1
        end

    elseif sound_effect == sound_effects.player_damaged then
        sfx_num = 57
        length = 4
        offset = 0
    elseif sound_effect == sound_effects.ninja_throw then
        sfx_num = 59
        length = 4
        offset = 0
    elseif sound_effect == sound_effects.enemy_damaged then
        sfx_num = 57
        length = 4
        offset = 8
    elseif sound_effect == sound_effects.player_jump then
        sfx_num = 59
        length = 6
        offset = 8
    elseif sound_effect == sound_effects.footstep then
        sfx_num = 55
        length = 1
        offset = 0
    elseif sound_effect == sound_effects.shield_hold then
        sfx_num = 54
        length = 6
        offset = 0
    elseif sound_effect == sound_effects.health_pickup then
        sfx_num = 63
        length = 8
        offset = 0
    elseif sound_effect == sound_effects.player_finisher then
        sfx_num = 60
        length = 2
        offset = 1
    end

    sfx(sfx_num, channel_num, offset, length)
end

__gfx__
0000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000002080000000000000208000002080a00000000000000000000000000000000080008000000000000000000000000000
800000808820288080000080882028800228800080000080022880000228800a0800008008000080882028808820288082028000000000000000000000000000
88202880029aaaa088202880029aaaa00888aa00882028800888aa000888aa0a0820028008200280029aaaa0029aaaa029aaaa00000000000000000000000000
829aaaa008aa8f80829aaaa008aa8f802a88aa00829aaaa02a88a8002a88a80a029aaaa0029aaaa008aa8f8008aa8f808aa8f800000000000000000000000000
88aa8f8008aac8c088aa8f8008aac8c008aafa0088aa8f8008aafc0008aafc0a08a8f8a008a8f8a008aac8c008aac8c08aac8c00000000000000000000000000
08aac8c00aaffff008aac8c00aaffff00a7fffff08aac8c00aafff000aafff0a08ac8ca008af8fa00aaffff00aaafff0aaafff00000000000000000000000000
0aaffff00aa788000aaffff00aa788000a7770000affffff0aa770900aa7709a0aafffa00aafffa00aa788000af78800af788f00000000000000000000000000
0aa788a0aaf787000aa788a0aa778700aa7770000af78800aaa7ff90aaa7ff9a0aa888a00aa888a0aaf787000af787f00a787000000000000000000000000000
0af787a000f777ff0af787a000ff7700a0776000aaf78700a0776090a077609a0af878f00af878f000f777ff0077770007777100000000000000000000000000
00f777000001110000f777f0000111000011100000077700001110000011100a0af777f00af777f0000111000011111001111ff8000000000000000000000000
000111000011111000011100001111100111100000011110011110000111100a00011100000111000011111001111ff011111000000000000000000000000000
00111100000f00f000111100000f0f0000ffff000011111000f0f00000f0f00a0011110000111100000f00f000fff8000f000000000000000000000000000000
000ff00000f00800000f0f00008000f00f000f00000f00f00f00f0000f00f0a0000f0f00000f0f0000f0080000f080000f000000000000000000000000000000
0008800000800000000808000000008080000800008000800800800008008a000008080000080800008000000080000008000000000000000000000000000000
5555555577777777777776777777777708800880055005507666666d0ee00ee00000000000000000000000000007777777777000000000000000000000000000
5999999566666666666665667677777d888887885555575565555552eeeee7ee0000000000000000000000000006555555556000000000000000000000000000
594444454441444159444445766777d6888888785555557565222552eeeeee7e0000000000000000000000000075999999995700000000000000000000000000
59444445111111115944444576667d66888888885555555565200652eeeeeeee0000000000000000000000000065444444445600000000000000000000000000
555555551444144455555555766656660888888005555550652006520eeeeee00000000000000000000000000759455555549570000000000000000000000000
995599991111111199559999766dd56600888800005555006556675200eeee00000000000000000000000000065445a5aa544560000000000000000000000000
44559444444144414455944476dddd56000880000005500065555552000ee0000000000000000000000000007594455555544957000000000000000000000000
4455944411111111445594447dddddd500000000000000005222222200000000000000000000000000000000654445aa5a544456000000000000000000000000
1111000000000000000000000dddddddddd05000dddddddddddd0000000000000000000000000000000000006544455555544456000000000000000000000000
1110055555555555555555000d9999999dd00000ddd99999ddd00555000000000000a0000000000000a000006544944444444456000000000000000000000000
1105555555555555555550000dddddddddd00050dddddddddd055555000000000000a00000a0a000000000006549a94444444456000000000000000000000000
0055555555555555555500000dddddddddd00500dddddddd005555550000000000a0a0a0000a0000000000006544944444444456000000000000000000000000
0000000000000000000000000dddddddddd05000dddddddd00000000000000000000a00000a0a000000000006544444444444456000000000000000000000000
0dddddddddddddddddd000000d9999999dd00000ddd999990ddddddd00a000000000a0000000000000000a006544444444444456000000000000000000000000
0dddddddddddddddddd000500dddddddddd00050dddddddd0ddddddd000000000000000000000000000000006544444444444456000000000000000000000000
0dddddddddddddddddd005000dddddddddd00500dddddddd0ddddddd000000000000000000000000000000006544444444444456000000000000000000000000
00000000000000000000000000000000005550000000000000000000005550000000000000000000000000000000000000000000000000000000000000000000
00555000005550880000000800555000088888000055500000555000088888000055500000000000000000000000000000000000000000000000000000000600
088888000888880000055508088888000f4f558008888800088888000f4f55800888880000000000000000000000000000000000000000000000000000006600
0f4f45800f455500008888800f4f55800fff55800f4f55880f4f55800fff55800f4f558800000000000000000000000000000000000000000000000006677700
0ffff5800ff5550000f4f4500fff5580055555000fff55000fff5508055555000fff550000000000000000000000000000000000000000000000000000670760
055555000555550500ffff5005555500005850000555550005555500005850000555550000000000000000000000000000000000000000000000000000077766
00555000005550505055555000585000008650000058500000585000008650000058500000000000000000000000000000000000000000000000000000066000
05555800005565000505550000865000005650000086500000865000005650000086500000000000000000000000000000000000000000000000000000060000
05558600666680000055556000556000005560000056500000565000005650000055600000000000000000000000000000000000000000000000000000000000
05585600005850000005556000555600005560000065500000655000005650000055560000000000000000000000000000000000000000000000000000000000
05855600008550000005860006555600005550000065500006555600005550000655560000000000000000000000000000000000000000000000000000000000
06555600005550000008550000555000005650000055500000555000005650000055500000000000000000000000000000000000000000000000000000000000
00505000005550000055560000565000005650000056500000565000006650000056500000000000000000000000000000000000000000000000000000000000
00505000060055000050060000605000000600000005600000506000000600000006000000000000000000000000000000000000000000000000000000000000
00505000060000500050006600600500005600000005600000500600006600000060500000000000000000000000000000000000000000000000000000000000
06606600660006600660000606600500006600000056600005500600005500000665500000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43333353534353433353430000334333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43333353534353433353430000334333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000077700000000000000000000000777777777770000000000777777777770000000000
00000000000000000000077700000000000000000000000000000000000779770000000000000000000000788888888870000000007888887222700000000000
00000000000000000000079970000000000000000000007777000000000799970000000000000000000000788888888870000000078888872227000000000000
00000000777777777770077970000000000000000000077997000000000779997000000000000000000000788888888870000000788888722270000000000000
00000007779999999977007970000000000007777000079997000000000077997000000777777770000000788888888870000007888887222777777700000000
00000077999999999997707970000000000077997700079997000000000007997000000799999970000000788888888870000078888872222222222700000000
00000779999999999999770770777777007799999970079977000000000007997700007799999977000000788888888870000788888777777222227000000000
00007799999777779999970077799997777999999977079970000000000007799700007997777997000000788888888870007888888888887222270000000000
00007999997700007799970079999999977997799997079970000000000000799700007997777997000000788888888870078888888888872222700000000000
00007999977000000779970079977779977997777997079970000000000000799700007997777997000000788888888870077778888888722227000000000000
00007999970000000077770079977779977997707777779977770000000000799700007997777997777000788888888870000788888887222270000000000000
00007999770000000000000079999999977799770079999999970000000000799700007999999999997000788888888870007888888872222700000000000000
00007999700000000000000079977777770799970079999999970000000000799700007799999779997000788888888870078888888722227000000000000000
00007999700000000000000079977777700779970077779977770000000000799700000777777777777000788888888870788888887222270000000000000000
00007999700000000000000079999999970079997700079970000000000000799700000000000000000000788888888877888888872222700000000000000000
00007999700000000000000077999999777077999770079970077770000007799700007777777700000000788888888888888888722227000000000000000000
00007999700000000000000007777777777707799970079970079970000077999700777999999777000000788888888888888887222270000000000000000000
00007999770000000000007777777777779707799970079970779970000079999777799999999997000000788888888888888872222700000000000000000000
00007999977000000000777999999997799777999970079977799770000079999779999999999997700000788888888888888722227000000000000000000000
00007799997777777777799999999999799999999970079999999700000079999999999997777999700000788888888888887222270000000000000000000000
00000799999999999999999997777799779999999770077999997700000079999999777777007777700000788888888888872222700000000000000000000000
00000779999999999999999777007779777777777700007777777000000079999977700000000000000000788888888888722227000000000000000000000000
00000077999999999999977700000077000000000000000000000000000077777770000000000000000000788888888887222270000000000000000000000000
00000007777777777777770000000000000000000000000000000000000000000000000000000000000000777777777777777700000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000020202020000020000000080800000000404040404040400000000808000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cfcfcfcfcfcfcf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cfcfcf0000000000000000002222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cfcf00000000000000002020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002928282828282828222222222222222222222020202000000000cf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222282828282828282a0000000000000000000000000000cf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000026220000000000000000000000000000cf2222222200000000000000000000000000000000000000000000cf20202020222828282828282a0000000000000000000000000000cf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000262200000000000000000000000000222020202022000000cfcf2222cf000000000000000000cfcfcfcfcf29282020202228282828282a0000000000000000000000000000cf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
200000000000000000002600000000000000000020202020202022cfcfcf22202022cf0000000000000000000000000029282828282828282828282a0000000000000000000000000000cf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20000000000000000000260000000000000000cf2020202020202022222220202020cf00000000000000000000000000292828282828282828222222cfcf000000000000000000000000cf0000000000cf26cfcfcfcf260000000000000000002323000000000000000000000000000000000000000000000000000000000000
20000000000000cfcf222222220000000000002220202020202020202020202828282a000000000000000000000000002928282828282828222020200000000000000000000000000000cf000000cf222222cf00cfcf222222000000000000230000230000000000000000000000000000000000000000000000000000000000
20000000000000000000000000000000000000002020202020202020202020282828282a222222222222222222222222282828282222222220202020cfcf000000000000000000000000000000000000000000cfcfcf000000000000000000002b2c000000000000000000000000000000000000000000000000000000000000
20000000001e000000000000000000000000000020202020202020202020202828282822202020202020202020202020222828282020202020202020cfcfcfcfcfcfcf00000000000000000000000000000000cfcfcf000000000000000000003b3c000000000000000000000000000000000000000000000000000000000000
202222222222222222222222222222222222222220202020202020202020202222222220202020202020202020202020202228282020202020202020cfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcf22222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000003900370000003a0000000000000000000000000000000000000000000000000000cfcf000000000000000000000000000000cfcf20202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000037000000003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cfcf20202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000038000000000000390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000003a00000000000037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000037370000390000003700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000003700000000000000000037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000003700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000003700cf00000000003a0039000000370000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000370000000000000000380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000039000000003837000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000303200000000000000000000000000000000000000000000000000000037003a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000033340000003031320000000000000000000000003800003a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0030323334000000333534000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0033343334303132333534000030320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
323336313132353433353400003334302d2d2d000000002d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
343333353534353433353400003334332d2d2d000000002d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01180020155551855515555185551555518555155551855510555175551355517555105551755513555175551055517555135551755510555175551355517555155551c555185551c555155551c555185551c555
011800001f5501f5501f5501d5501d5501d5501c550185001a5501a5501d5501d55018500175501a5501d5502155021550215502355023550215501f5501d5501c5501c5501f5501f5501850013550185501c550
01180000155501c550185501c550155501c550185501c5500e55015550115500050000500005000050000500105501d550115501d55011550135501f550155501555000500105551055510555105551055510555
0118000024550245500050024550235502355000500235502355023550215502155018500215501f5501d5501f5501f5501d5501d5501c5501a5501a55018550185501850018500185001850015550185501c550
011800080c605000051c6350000510605000051c63500005106050000500005000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01240020155551855515555185551555518555155551855510555175551355517555105551755513555175551055517555135551755510555175551355517555155551c555185551c555155551c555185551c555
01080000155001850015500185001550018500155001850010500175001350017500105001750013500175001050017500135001750010500175001350017500155001c500185001c500155001c500185001c500
011200000b5700b570105701057015570155701a5701a5701f5701f570245701d6001f000000001c0001c000000001d0001d00000000210000000000000000000000000000000000000000000000000000000000
0116000028120241002b1002612028120261202410026120261202312026120281202d120241002b120241002812024100241002612028120231202112021120211201a1201d1202112023120181002612000100
01160000101500010010635001001015000100106350e1500e1502d100106352b100151501063513150106351015021100106351a1001015000100106350e1500e1500010010635000000b150106350e15010635
011600001550000000106350000015500000001063511500115000000010635000001850010635106350000000000000001063500000000000000010635000000000000000106350000000000106351063500000
0116000018050106051805010605180500e0001805017050170500b000170501060511050000000e050000000b050000001805010605180500000018050170501705000000170501060513050106351705010635
0116000028120261202b120281202812028120281202812528120261202b12028120281202812028120281252812026120281202b1202b1202d1202b1202f120000002f120240002f1202d1202d1202b12028120
011600000c1400c1400c140181400c140181400c14000000171401714017140181401714018140171401060515140151401514017140171401714018140106051714017140171401814018140181401c14018100
01100000105400000010540000001d6230000000000185000e540005000e540000001d623000000000000500105400050010540000001d623000000000000000115400050011540005001d6231d6031054029603
01100000211550010500105001051f1550010500105001051c1550010500105001051815500105001050010518155001051a15500105001050010518155001001c1551c1551a15500100181551a1550010018155
01100000100451004510045100450e0450e0450e0450e0451004510045100451004513045130451304513045100451004510045100450e0450e0450e0450e0451004510045100451004515045150451504515045
011000001515517155181551a1550000000000000000000017155181551a1551c15500000000000000000000181551a1551c1551d15500000000000000000000181551a1551c1551a15518155171551515500000
011000001515515155171551715518155171551515518100171551715518155181551a15518155171551a10018155181551a1551a1551c1551a155181551a1001c1551a155181551715518155171551515500000
010a0000215201f50000000000001f5200000021520000002152000000000001f5001f5201f500215201f500215201f5001f5201f5002152000000235200000000000000001f520000001d520000001c52000000
010a002025530005001c50027500235303c500255301c500255301c5001c500005002353010500255301c500255301c5002353010500255302150026530215002150021500235300050023530000002353000000
010a00001d6231c6031d7331d7431d7531c6031c710000001d6231c6031d7431d7431d7531c6031c710000001d6231c6031d7531d7531d7531c6031c710000001d6231c6031d7531d7531d753000001c70000000
010a0000235201f5000000000000215200000023520000002352000000000001f500215201f500235201f500235201f500215201f50023520000002652000000000000000021520000001f520000001d52000000
010a0020275200050000500005002452010500275200050027520275001c50000500245201c500275201c50027520005002452010500275201c5002a5201c5001c50010500245202a50022520005002052000000
010a0000235202352023500235002152021520215002150023520235202350023500215202152023520235202152021520215002150023520235202652026520265002650021520215001f5201f5001d5201d500
010a00202153500505005050050521535005050050500505215350050500505005052153500505005050050521535005052153524505215352450521535245052153521535215352153521535215052150521505
010a0000215202152021500215001f5201f5202152021520215002150021500215001f5201f520215202152021500215001f5201f5202152021520235202352023500235001f5201f5201d5201d5201c5201c520
010a00002552000000255200000027520000000000000000255200000025520000002a520000000000000000255200000025520000002a520000002c520000002752000000255200000022520000000000000000
011000001c1551a1551f1551c155180001800018000180001c1551a1551f1551c1551c1051c1051c1051c1051c1551a1551c1551f1551f105211551f155231551800523155180052315521155211051f1551c155
0112000009420104200c4201040009420104200c42010400024200942005420004000040000400004000040004420114200542011420054200742013420094200942000400044250442504425044250442504425
0112000024140241400010024140231402314000100231402314023140211402114018100211401f1401d1401f1401f1401d1401d1401c1401a1401a14018140181401810018100181000c10015140181401c140
01120020094200c420094200c400094200c420094200c400044200b420074200b400044200b420074200b400044200b420074200b400044200b420074200b40009420104200c4201040009420104200c42010420
011200001f1401f1001f1001d1401d1001d1001c140181001a1401a1001d1401d10018100171401a1401d1402114021100211002314023100211401f1401d1401c1401c1001f1401f1001810013140181401c140
011200001f1401f1001f1001d1401d1001d1001c1401c1001a1401a1001d1401d1001f20013140171401a1401d1401d1001d1001c1401c1001c1001a1401a10018140181001c1401c1000000013140171401c140
010e00000e7430000010643000000e7430000010643007000e7430000010643000000e7430000010643007000e7430000010643000000e7430000010643007000c74300700116451164500700116451164500000
010e000004440044401a4000444002440044400744018400094400944018400074400744018400184001840007440074401a4000944007440094400c440184000e4400e440184000c4400c440004000040000400
010e000028500295002850029500285001f5001850023500255402554026500235402354024500265002850018500000000000000000000000000000000000002a5402a540240002854028540000000000000000
010e000004440044401a400044400440004400094001840004440044401a400044400440004400094000740004440044401a4000444004400044000c400004000944009440000000744000000054400444002400
010e000004440044401a4000444002400044400740018400094400940018400074400740018400184001840007440000001a4000944007400094400c440184000e4400e400184000c4400c400004000040000400
010e000004440044401a4000444002400044000740018400094000940018400074000740018400184001840007440074401a4000944007440094400c440184000e4000e400184000c4000c400004000040000400
010e000004440044401a4000444002440044400744018400000000000009440094400744007440184001840007440074401a4000944007440094400c4401840000000000000e4400e4400c4400c4400040000000
010e0000255402554000000255402554000000000002650027540275400000027540275400000000000000002a5402a540000002a5402a540000002c5402c54000000000002c54000000000002a5402754025540
010e000028500295002850029500285001f50018500235000000000000255402554023540235400000024500265002850018500000000000000000000000000000000000002a5402a54028540285400000000000
010e000028540265402b500285402854028500285002850528540265402b50028540285402850028500285052854026540285402b5402b5002d5402b5402f540005002f540245002f5402d5402d5002b54028540
010e00000044000440004000c440004000c44000440004000b4400b4400b4000c4400b4000c4400b440044000944009440094000b4400b4400b4000c440044000b4400b4400b4000c4400c4400c4001044018400
01120000280200000028020000002b020000002902000000280200000026020000002402000000280202802128021280210000000000240200000026020260212602100000260200000026020000000000000000
01120000280200000028020000002b02000000290200000028020000002602000000240200000028020280212802128021000000000024020000002b0202b0212b0212b0212b021000002d020000000010000100
011200002b020000002b020000002d020000002b020000002b00029020280200000029020000002d0202d0212d0212d021000000000024020000002b0202b0212b0212b0212b021000002d020000000000000000
01120000280200000028020000002b020000002902000000280200000026020000002402000000280202802128021280210000000000240200000026020260202402000000240200000000000000000000000000
01120000005000050000500005002d5250050000500005002452500500245250050000500005000050000500005000050000500005002d5250050000500005002452500500245250050000500005000050000500
011200001851018511185111851118511185111a5101a5111a5111a5111a5111a5111a5111a5111c5101c5111c5111c5111c5111c5111c5111c5111a5101a5111a5111a5111a5111a5111a5111a5111a5111a511
011200001851018511185111851118511185111a5101a5111a5111a5111a5111a5111a5111a5111c5101c5111c5111c5111c5111c5111c5111c51100000000001851000000185100000000000000000000000000
011200001851018511185111851118511185111a5101a5111a5111a5111a5111a5111a5111a5111c5101c5111c5111c5111c5111c5111c5111c5111f5101f5111f5111f5111f5111f5111f5111f5111f5111f511
011200001f1401f1001f1001d1401d1001d1001c1401c1001a1401a1001d1401d1001f20013140171401a1401d1401d1001f1401d1401c1401a1401a1001c1401c100181001c1001c1000000013140171401a140
000a00060e7501175014750127500e7500d75002700027000270000700007000c70000700007000c70000700007000c70000700007000c70000700007000c7000070000700007000070000700007000070000700
000400000763008600026000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000155501a5501f5502155000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0105000029750287502675024750000000000000000000001c6531a63318613146031360311603116030000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002422024230242402425025250282502c2502f250002000020000200002000020000200002000020000200002000020000200002000020000200002000000000000000000000000000000000000000000
0003000015050180501b0501f05000000000000000000000180501c0501e050210502305023050230001f00000000000000000015000180001b0001f00000000000000000000000295001d5000f5000250000000
010c00001e04323043230431070010700107001070000700007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
010a0000230430e600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002505310600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002875024750207502075022750277502c7502e730147000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00010444
02 02030444
03 05424344
04 46074344
00 0a094c4e
01 0a090b4e
00 080b094d
00 080b094d
00 0c0b0d4d
02 080b094d
01 100e5c54
00 100e0f5c
00 0e104e51
00 100e0f51
00 0e104e51
00 100e1151
00 0e104e51
00 10120e51
00 0e104e51
02 101c0e51
00 19155a44
01 1a611544
00 185c1544
00 13141544
00 16171544
02 1b421544
00 22256444
01 24232244
00 26682244
00 2a282244
00 24232244
00 27292244
00 24232244
02 2c2b2244
00 41424344
00 41424344
00 41424344
01 2d313276
00 2e313444
00 2f313244
04 30313344
01 1f5d5f60
00 1d5d5f60
01 5f4a1f20
00 1e1d5f44
00 211f4344
02 1d354344
