pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- catch it!
-- can you catch them all? :3

function _init()
 spawn_fruit()
 
 spawn_clouds()
end

function _update()
 if state == game.playing then
  update_eggy()
 end
end

function _draw()
 if state == game.paused then
  draw_menu()
 end
 
 if state == game.playing then
  draw_eggy()
 end
 
 if state == game.dead then
  draw_death()
 end
 
 if state == game.know then
  draw_know()
 end
end
-->8
--> states

game = {
 playing = "eggy",
 dead = "dead",
 menu = "menu",
 know = "butto"
}

state = game.paused

function draw_eggy()
 cls(12)
 map(0, 0, 0, 0, 128, 128)
 
 spr(p.sprite, p.x, p.y)
 
 if p.is_dev then
  rect(p.box.x, p.box.y, p.box.x + p.box.w, p.box.y + p.box.h, 8)
 end
 
 handle_lives()
 print("points:" .. p.points, 4, 15, 1)
 
 draw_fruits()
 draw_clouds()
 
 -- dev 
 if p.is_dev then
  print(p.lives, 5, 25, 1)
  print(count(fruits), 15, 25, 1)
  print(c_dat.move_time, 25, 25, 1)
  print(p.x, 35, 25, 1)
  
  print("dev mode", 7, 35, 8)
 end
end

function update_eggy()
 move()
 
 p.box.x = p.x
 p.box.y = p.y
 
 if btn(4) then 
  p.speed = 4
  p.sprite = 2
 else
  p.speed = 2
  p.sprite = 1
 end
 
 handle_screen()
 
 update_fruits()
 update_clouds()
 
 if p.lives == 0 then
  state = game.dead
 end 
end

function draw_menu()
 cls(12)
 map(16, 0, 0, 0, 128, 128)
 
 print("catch the fruit", 5, 5, 11)
 print("❎ to start", 83, 120, 11)
 print("🅾️ for controls", 30, 85, 11)
 
 if btnp(5) then
  state = game.playing
 end
 
 if btnp(4) then 
  state = game.know
 end
end

function draw_death()
 cls(12)
 map(32, 0, 0, 0, 128, 128)
 
 print("you died :(", 45, 55, 11)
 print("press 🅾️ to try again", 25, 65, 11)

 print("score: " .. p.points, 50, 75, 11)
 
 if btnp(4) then
  state = game.playing
  
  -- reset player stats
  p.x = orig_x
  p.y = orig_y
  
  p.points = 0
  p.lives = 3
  
  -- reset fruit stats
  f_data.diff = 5
  for fruit in all(fruits) do
   del(fruits, fruit)
  end
  
  spawn_fruit()
  f_data.gravity = 1
 end
end

function draw_know()
 cls(12)
 map(0, 16, 0, 0, 128, 128)
 
 print("how to play", 41, 40, 11)
 print("⬅️ ➡️ - move", 39, 50, 11)
 print("🅾️ - boost", 43, 60, 11)
 print("fruits speed up over time!", 12, 70, 11)
 
 print("❎ to play", 5, 118, 11)
 
 if btnp(5) then
  state = game.playing
 end
end
-->8
--> player

orig_x = 128/2 - 8
orig_y = 112

p = {
 x = orig_x,
 y = orig_y,
 
 vx = 0,
 
 speed = 2,
 
 lives = 3,
 points = 0,
 
 sprite = 1,
 
 is_dev = false,
 
 box = {
  x = orig_x,
  y = orig_y,
  
  w = 7,
  h = 7
 }
}

function move()
 p.vx = 0
 
 if btn(0) then
  p.vx -= p.speed
 end
 
 if btn(1) then
  p.vx += p.speed
 end
 
 p.x += p.vx
end

function handle_screen()
 if p.x > 120 then
  p.x = 120
 end
 
 if p.x < 0 then
  p.x = 0
 end
end

function handle_lives()
 ind = 5
 for i = 1, 3 do
 
  if i <= p.lives then
   spr(48, ind, 5)
  else
   spr(49, ind, 5)
  end
  
  ind += 10
 end
end

-- tysm popax :33
function is_col(b1, b2)
 ol_min_x = max(b1.x, b2.x)
 ol_min_y = max(b1.y, b2.y)
 
 ol_max_x = min(b1.x + b1.w, b2.x + b2.w)
 ol_max_y = min(b1.y + b1.h, b2.y + b2.h)

 if ol_min_x <= ol_max_x and ol_min_y <= ol_max_y then
  return true
 end
 
 return false
end
-->8
--> fruits

-- keep in mind im using
-- a tutorial here, im trying
-- my best qwq

-- fruit table
fruits = {}

f_data = {
 start = 16,
 fcount = 3,
 
 diff = 5,
 
 interval = 40,
 
 gravity = 1
}

function calc_fruit_sprite()
 return flr(rnd(f_data.fcount) + f_data.start)
end

function spawn_fruit()
 for i = 1, f_data.diff do
  local f_x = flr(rnd(115) + 5)
  local f_y = i * (-f_data.interval)
  
  fruit = {
   sprite = calc_fruit_sprite(),
   
   x = f_x,
   y = f_y,
   
   box = {
    x = f_x,
    y = f_y,
    
    w = 7,
    h = 5
   }
  }
  
  add(fruits, fruit)
 end
end

function update_fruits()
 for fruit in all(fruits) do
  fruit.y += f_data.gravity
  fruit.box.y = fruit.y
  
  if(fruit.y > 130) then
   p.lives -= 1
   sfx(0)
   
   del(fruits, fruit)
  end
  
  if is_col(p.box, fruit.box) then
   sfx(1)
   
   p.points += 1
   del(fruits, fruit)
  end
 end
 
 if count(fruits) == 0 then
  f_data.diff += 1
  f_data.gravity += 0.04
  spawn_fruit()
 end
end

function draw_fruits() 
 for fruit in all(fruits) do
  spr(fruit.sprite, fruit.x, fruit.y)
  
  if p.is_dev then
   rect(fruit.box.x, fruit.box.y, fruit.box.x + fruit.box.w, fruit.box.y + fruit.box.h, 9)
   print(is_col(p.box, fruit.box))
  end
 end
end
-->8
--> clouds

clouds = {}

c_dat = {
 start = 40,
 ccount = 3,
 
 spawn_count = 7,
 
 move_time = 10
}

function calc_cloud_sprite()
 return flr(rnd(c_dat.ccount) + c_dat.start)
end

function spawn_clouds()
 for i = 1, c_dat.spawn_count do
  cloud = {
   sprite = calc_cloud_sprite(),
   
   x = flr(rnd(120) + 3),
   y = flr(rnd(110) + 3)
  }
  
  add(clouds, cloud)
 end
end

function update_clouds()
 c_dat.move_time -= 1
 
 if c_dat.move_time == 0 then
  clouds[flr(rnd(count(clouds))) + 1].x += 1
  c_dat.move_time = 10
 end
 
 -- reset cloud if off screen
 for cloud in all(clouds) do
  if cloud.x > 130 then
   cloud.x = -10
   cloud.y = flr(rnd(110) + 3)
  end
 end
end

function draw_clouds()
 for cloud in all(clouds) do
  spr(cloud.sprite, cloud.x, cloud.y)
 end
end
__gfx__
0000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000005555555555555555555555550000000000000000000000000000000000000000
000000005444444554444445bbbbb33bb3bbb3bbb3bb33b3b33bbbbb000000005444444444444444444444450000000000000000000000000004440000000000
00700700544444455444aa45bbb333333333b33b333b333333333bbb000000005444444444444444444444450000000000000000000000000044440000000000
00077000555555555555aa55bb33b33333333333333333b3333333bb000000005555555555555555555555550000000054444000400444000444544500000000
0007700054444445544aa445b33b33333b3333333b333b333b3333bb000000005444444444444444444444450000000054444404455544044445544500000000
0070070055555555555a5555b33b3b3333b333b333333b33b33b333b000000000555555555555555555555500000000005555540444554444454445000000000
000000000544445005444450bb3b33b333b33b3333b33b33b33b33bb000000000054444444444444444445000000000000544445444444544444450000000000
000000000055550000555500b33b33b333b33b33333b3333b3b3333b000000000005555555555555555550000000000000055555555555555555500000000000
0044b3b003b3b3b000b33b00bb3333b33333b33333b33b33b333333b000000000000000000000000000000000000000000000000000000000000000000000000
00088300003bb30003b33b30bb3b333b33333b333b33b3333b333b3b000000000000000000000000000000000000000000000000000000000000000000000000
0888888000999900b3b33b3bb33b3b3b33333b333b3333333b33bbbb000000000000000000000000000000000000000000000000000000000000000000000000
8888888e099999a0b3b33b3bb3333b3333b333333333333b33333bbb000000000000000707777700770000000000000000000000000000000000000000000000
8888888e099999a0b3b33b3bbb333b33333b333b333b33b3333333bb000000000000077777777777777000000000000000000000000000000000000000000000
888888ee099999a0b3b33b3bbbb3b333333b33b33333b3b33b33333b000000000000777777777777777770000000000000000000000000000000000000000000
888888ee09999aa003b33b30b333333bb33b33b33b33b3b3b3333bbb000000000077777777777777777777700000000000000000000000000000000000000000
08800ee00099aa0000b33b00b3bb33333b3333333b333333b33333bb000000007777777777777777777777770000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000077700000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000777770000077000077000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000007777777000777770777707700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000007777777777777777777777770000000000000000000000000000000000000000
08000080050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88800888555005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880055555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800005555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccbbcbbbcbbbccbbcbcbcccccbbbcbcbcbbbcccccbbbcbbbcbcbcbbbcbbbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccbcccbcbccbccbcccbcbccccccbccbcbcbcccccccbcccbcbcbcbccbcccbccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccbcccbbbccbccbcccbbbccccccbccbbbcbbccccccbbccbbccbcbccbcccbccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccbcccbcbccbccbcccbcbccccccbccbcbcbcccccccbcccbcbcbcbccbcccbccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccbbcbcbccbcccbbcbcbccccccbccbcbcbbbcccccbcccbcbccbbcbbbccbccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc7c77777cc77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccc77777777777777ccccccccccccccccccccccccccccccccccccccc777ccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc77777777777777777cccccccccccccccccccccccccccccccccccc77777cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccc777777777777777777777ccccccccccccccccccccccccccccccccc7777777ccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccc777777777777777777777777cccccccccccccccccccccccccccccccc77777777cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b3b3bccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bb3cccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999cccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999accccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999accccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999accccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999aaccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99aacccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc3b3b3bccccccccccccccccccccccccccc44b3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc3bb3ccccccccccccccccccccccccccccc883cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc9999ccccccccccccccccccccccccccc888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc99999accccccccccccccccccccccccc8888888ecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc99999accccccccccccccccccccccccc8888888ecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc99999accccccccccccccccccccccccc888888eecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc9999aaccccccccccccccccccccccccc888888eecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc99aaccccccccccccccccccccccccccc88cceeccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b3b3bccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bb3cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999cccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999accccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999accccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999accccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999aaccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99aacccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44b3bccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc883cccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc888888ccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8888888ecccccccccccccccc
cccccccccccccccccccccccccccccccccc777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8888888ecccccccccccccccc
ccccccccccccccccccccccccccccccccc77777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc888888eecccccccccccccccc
cccccccccccccccccccccccccccccccc7777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc888888eecccccccccccccccc
cccccccccccccccccccccccccccccccc77777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc88cceeccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b3b3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bb3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999accccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999accccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999acccccccccccccccccccccccccc77ccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999aaccccccccccccccccccccccccc7777c77ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99aacccccccccccccccccccccccccc77777777cccccccccccccccccccccccccccccccc
cccccccccccccccccc44b3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccc883cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc8888888ecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc8888888ecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc888888eecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc888888eecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc88cceeccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7c77777cc77cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777777777777ccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccbbbbbccccccbbbccbbcbbbccccccbbccbbcbbccbbbcbbb77bb7b7777bb7777ccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccbbcccbbcccccbcccbcbcbcbcccccbcccbcbcbcbccbccb7b7b7b7b777b77777777ccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccbbcbcbbcccccbbccbcbcbbccccccbcccbcbcbcbccb77bb77b7b7b777bbb7777777cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccbbcccbbcccccbcccbcbcbcbcccccbcccbcbcbcbccbccbcbcbcbcbcccccbccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccbbbbbccccccbcccbbccbcbccccccbbcbbccbcbccbccbcbcbbccbbbcbbcccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc555555555555555555555555cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc544444444444444444444445cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc544444444444444444444445cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc555555555555555555555555cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc544444444444444444444445cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc5555555555555555555555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc54444444444444444445cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccc555555555555555555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccbbbbb33bb3bbb3bbb3bbb3bbb3bbb3bbb33bbbbbcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccbbb333333333b33b3333b33b3333b33b33333bbbcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccbb33b333333333333333333333333333333333bbcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccb33b33333b3333333b3333333b3333333b3333bbcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccb33b3b3333b333b333b333b333b333b3b33b333bccccccccccccccccccc77ccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccbb3b33b333b33b3333b33b3333b33b33b33b33bbcccccccccccccccccc77777ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccb33b33b333b33b3333b33b3333b33b33b3b3333bcccccccccccccccc77777777cccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccbb3333b333b33b333333b33333b33b33b333333bcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccbb3b333b3b33b33333333b333b33b3333b333b3bcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccb33b3b3b3b33333333333b333b3333333b33bbbbcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccc7c77777cc77ccccccccccccccb3333b333333333b33b333333333333b33333bbbcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccc77777777777777cccccccccccccbb333b33333b33b3333b333b333b33b3333333bbcccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc77777777777777777cccccccccccbbb3b3333333b3b3333b33b33333b3b33b33333bcccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc777777777777777777777cccccccccb333333b3b33b3b3b33b33b33b33b3b3b3333bbbcccccccccccccccccccccccccccccccccccccccccccccccc
cccccccc777777777777777777777777ccccccccb3bb33333b3333333b3333333b333333b33333bbcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccbb3333b33333b33333b33b333333b333b333333bccccbbbbbccccccbbbccbbccccccbbcbbbcbbbcbbbcbbbcc
ccccccccccccccccccccccccccccccccccccccccbb3b333b33333b333b33b33333333b333b333b3bcccbbcbcbbccccccbccbcbcccccbccccbccbcbcbcbccbccc
ccccccccccccccccccccccccccccccccccccccccb33b3b3b33333b333b33333333333b333b33bbbbcccbbbcbbbccccccbccbcbcccccbbbccbccbbbcbbcccbccc
ccccccccccccccccccccccccccccccccccccccccb3333b3333b333333333333b33b3333333333bbbcccbbcbcbbccccccbccbcbcccccccbccbccbcbcbcbccbccc
ccccccccccccccccccccccccccccccccccccccccbb333b33333b333b333b33b3333b333b333333bbccccbbbbbcccccccbccbbccccccbbcccbccbcbcbcbccbccc
ccccccccccccccccccccccccccccccccccccccccbbb3b333333b33b33333b3b3333b33b33b33333bcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccb333333bb33b33b33b33b3b3b33b33b3b3333bbbcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccb3bb33333b3333333b3333333b333333b33333bbcccccccccccccccccccccccccccccccccccccccccccccccc

__gff__
0001000000000000000000000000000002020200000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000018191a00000000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000290000000018191a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000018191a000000000000001100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000002a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000280000000000000000100000000000000000000000000000000029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0018191a00000000000000000000000000000000000000110000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000100000000000000000000000000000002a000018191a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000018191a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000018191a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000003434003400000000000000000000000000000008090a00000000000000000000000000000000000018191a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003400340000000000000000000000000003040404060000290000000000000000000c0d0e110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000018191a0013151415160000000000000018191a0003050504060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304040405050504040404050505040600000000001314151416000000000000000000000013141515160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000018191a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000028000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000028000018191a000000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0007000011050110500e0500a050070500705004000000000d0000800007000050000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700001e7502175029750297502d7502020020200212002320020200262002a200342002d20039200382003a2000000021700237002a7002a70033700157001570000000000001470000000000000000000000
