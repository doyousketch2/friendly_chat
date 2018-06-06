
print( '[friendly_chat]  CSM loading...' )
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local PmColor      = {'#99FF99', '#66CC66'}  -- friend, other  (Light Green)
local joinColor    = {'#00DD00', '#008800'}  --   "   ,   "    (Green)
local exitColor    = {'#DD0000', '#880000'}  --   "   ,   "    (Red)
local timeoutColor = {'#880000', '#660000'}  --   "   ,   "    (Dark Red)

local serverColor  = {'#EE9900', '#CC3300'}  -- playernames, server messages  (Orange)

local adminColor     = {'#FFFF00', '#BBBB00'}  -- chat, /me   (Yellow)
local modColor       = {'#AAAA00', '#888800'}  --  "  ,  "    (Dark Yellow)
local myColor        = {'#00DDDD', '#008888'}  --  "  ,  "    (Diamond Blue)

local bestColor      = {'#00DDDD', '#008888'}  --  "  ,  "    (Diamond Blue)
local friendColor    = {'#3399FF', '#0055FF'}  --  "  ,  "    (Light Blue)
local aquaintColor   = {'#FFFFFF', '#BBBBBB'}  --  "  ,  "    (White)

local noobColor      = {'#DD8888', '#887777'}  --  "  ,  "    (Dark Pink)
local annoyColor     = {'#FF9999', '#AA8888'}  --  "  ,  "    (Pink)
local hackerColor    = {'#FF55EE', '#BB44AA'}  --  "  ,  "    (Magenta)
local enemyColor     = {'#FF5555', '#BB4444'}  --  "  ,  "    (Red)

local foreignColor   = {'#444444', '#666666'}  --  "  ,  "    (Black)
local otherColor     = {'#6600CC', '#400080'}  --  "  ,  "    (Purple)
local untaggedColor  = {'#AAAAAA', '#999999'}  --  "  ,  "    (Grey)

local tier  = ''
local colortext
local shown  = false
local player_names  = {}
local player1name  = ''

local parted_players  = {}
local part_timer = 180
-- time in seconds before a parted player is removed from list

local singleplayer  = false
local selected_player  = ''

  -- set this here, you decide if you want it to
local print2console  = true

--=========================================================
--  Note to self:     use  :set_string()  &  :get_string()  because
--  the command names for  :from_table()  &  :to_table()  appear to be reversed...

local mod_storage  = minetest .get_mod_storage()

--  uncomment next line to PRINT out the contents of [friendly_chat] mod_storage.
--print( dump( mod_storage :to_table() ))

--  WARNING:  uncomment the next line to COMPLETELY CLEAR [friendly_chat] mod_storage, if need be.
--mod_storage :from_table()

--=========================================================
-- Note to self:  don't use spaces in formspec,
-- or else you'll need to pad corresponding commands w/ spaces as well...

local function show_main_dialog()
  local current_time  = minetest .get_us_time()

  for index, playername in ipairs( player_names ) do
    if parted_players [playername] then
      local time_since_departure  = ( current_time - parted_players [playername] ) / 1000000

      if time_since_departure >= part_timer then
        print( 'removed :: ' ..playername )
        table.remove( player_names,  index )
        parted_players [playername]  = nil
      end  --  >= part_timer
    end  -- if parted_players [playername]
  end  -- ipairs( player_names )

  local compare  = function( a,b ) return string.lower(a) < string.lower(b) end
  table .sort( player_names,  compare )

  local size  = 'size[5.5,8]'
  local tierlabel  = ''  -- colored label at bottom of menu

  if selected_player ~= '' and selected_player ~= player1name then

    xpcall(  function() tier  = mod_storage :get_string( selected_player ) end, 
             function() tier  = '' end  )

    if tier == 'admin' then
      tierlabel  = minetest .colorize( adminColor[1],  tier )
    elseif tier == 'mod' then
      tierlabel  = minetest .colorize( modColor[1],  tier )

    elseif tier == 'best' then
      tierlabel  = minetest .colorize( bestColor[1],  tier )
    elseif tier == 'friend' then
      tierlabel  = minetest .colorize( friendColor[1],  tier )
    elseif tier == 'aquaint' then
      tierlabel  = minetest .colorize( aquaintColor[1],  tier )

    elseif tier == 'noob' then
      tierlabel  = minetest .colorize( noobColor[1],  tier )
    elseif tier == 'annoy' then
      tierlabel  = minetest .colorize( annoyColor[1],  tier )
    elseif tier == 'hacker' then
      tierlabel  = minetest .colorize( hackerColor[1],  tier )
    elseif tier == 'enemy' then
      tierlabel  = minetest .colorize( enemyColor[1],  tier )

    elseif tier == 'foreign' then
      tierlabel  = minetest .colorize( foreignColor[2],  tier )
    elseif tier == 'ignore' then
      tierlabel  = minetest .colorize( enemyColor[2],  tier )
    elseif tier == 'other' then
      tierlabel  = minetest .colorize( otherColor[2],  tier )
    else
      tierlabel  = minetest .colorize( untaggedColor[2],  tier )
    end  -- if...elseif tier

    size  = 'size[8,8]'
    ..'label[3.1,7.8;' ..tierlabel ..']' -- colored label that shows tier of current selection
  end -- increase formspec size and print tier if selected_player isn't you

  local formspec  = size
    ..'bgcolor[#080808BB;true]'
    ..'background[5,5;1,1;gui_formbg.png;true]'
    ..'button_exit[0,7.9;2.2,0.2;close;Close]'

    if singleplayer then
      formspec  = formspec
      ..'label[0.1,0;Single Player]'
    else  -- .is_singleplayer()
      formspec  = formspec
      ..'label[0.1,0;' ..#player_names ..'  Players]'
    end -- if singleplayer

    formspec  = formspec
    ..'tableoptions[background=#314D4F]'
    ..'tablecolumns[color;text,align=center,width=10]'
    ..'table[0,0.6;5.3,7;player_list;'

  local formspec_table  = {}

  for index, playername in ipairs( player_names ) do

    xpcall(  function() tier  = mod_storage :get_string( playername ) end, 
             function() tier  = '' end  )

    if playername == player1name then
      formspec_table[index]  = myColor[2] ..',' ..playername

    elseif parted_players [playername] then
      formspec_table[index]  = '#000000' ..',' ..playername

    elseif tier == 'admin' then
      formspec_table[index]  = adminColor[2] ..',' ..playername

    elseif tier == 'mod' then
      formspec_table[index]  = modColor[2] ..',' ..playername


    elseif tier == 'best' then
      formspec_table[index]  = bestColor[2] ..',' ..playername

    elseif tier == 'friend' then
      formspec_table[index]  = friendColor[2] ..',' ..playername

    elseif tier == 'aquaint' then
      formspec_table[index]  = aquaintColor[2] ..',' ..playername


    elseif tier == 'noob' then
      formspec_table[index]  = noobColor[2] ..',' ..playername

    elseif tier == 'annoy' then
      formspec_table[index]  = annoyColor[2] ..',' ..playername

    elseif tier == 'hacker' then
      formspec_table[index]  = hackerColor[2] ..',' ..playername

    elseif tier == 'enemy' then
      formspec_table[index]  = enemyColor[2] ..',' ..playername


    elseif tier == 'foreign' then
      formspec_table[index]  = foreignColor[2] ..',' ..playername

    elseif tier == 'ignore' then
      formspec_table[index]  = '#000000' ..',' ..playername

    elseif tier == 'other' then
      formspec_table[index]  = otherColor[2] ..',' ..playername

    else
      formspec_table[index]  = untaggedColor[1] ..',' ..playername
    end
  end

  formspec  = formspec ..table .concat( formspec_table, ',' ) ..';]'

  if selected_player ~= '' and selected_player ~= player1name then

    if not singleplayer then
      formspec  = formspec
      ..'button[3.3,0.1;1.0,0.2;tpr;'
        ..minetest .colorize(  exitColor[2],  '/tpr'  ) ..']'
      ..'button[4.3,0.1;1.2,0.2;tphr;'
        ..minetest .colorize(  exitColor[2],  '/tphr'  ) ..']'
      end -- if not singleplayer

    formspec  = formspec
      ..'button[5.6,0.0;2.5,0.2;admin;Admin]'
      ..'button[5.6,0.6;2.5,0.2;mod;Moderator]'

      ..'button[5.6,1.2;2.5,0.2;best;Besty]'
      ..'button[5.6,1.8;2.5,0.2;friend;Friend]'
      ..'button[5.6,2.4;2.5,0.2;aquaint;Aquaintance]'

      ..'button[5.6,3.2;2.5,0.2;noob;Noob]'
      ..'button[5.6,3.8;2.5,0.2;annoy;Annoyance]'
      ..'button[5.6,4.4;2.5,0.2;hacker;Hacker]'
      ..'button[5.6,5.0;2.5,0.2;enemy;Enemy]'

      ..'button[5.6,6.0;2.5,0.2;foreign;Foreign]'
      ..'button[5.6,6.6;2.5,0.2;ignore;Ignore]'
      ..'button[5.6,7.2;2.5,0.2;other;Other]'

      ..'button[5.6,7.9;2.5,0.25;clear;'
      ..minetest .colorize(  exitColor[2],  'CLEAR'  ) ..']'
  end

  minetest .show_formspec(  'friendly_chat:player_list',  formspec  )
end

--=========================================================

minetest .register_on_receiving_chat_messages(  function(message)
  local msg  = minetest .strip_colors(message)
  colortext  = ''
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if msg :sub(1, 1) == '<' then  -- Normal messages
    local playername  = msg :sub( 2,  msg:find('>') -1 )  -- after '<' up to, not including '>'

    xpcall(  function() tier  = mod_storage :get_string( playername ) end, 
             function() tier  = '' end  )

    if playername == player1name then
      colortext  = minetest .colorize( myColor[1],  msg )

    elseif msg :sub( 1, 9 ) .lower == '<invalid ' then
      print( '[friendly_chat]  deleted: ' ..msg )

    elseif tier == 'admin' then
      colortext  = minetest .colorize( adminColor[1],  msg )
    elseif tier == 'mod' then
      colortext  = minetest .colorize( modColor[1],  msg )

    elseif tier == 'best' then
      colortext  = minetest .colorize( bestColor[1],  msg )
    elseif tier == 'friend' then
      colortext  = minetest .colorize( friendColor[1],  msg )
    elseif tier == 'aquaint' then
      colortext  = minetest .colorize( aquaintColor[1],  msg )

    elseif tier == 'noob' then
      colortext  = minetest .colorize( noobColor[1],  msg )
    elseif tier == 'annoy' then
      colortext  = minetest .colorize( annoyColor[1],  msg )
    elseif tier == 'hacker' then
      colortext  = minetest .colorize( hackerColor[1],  msg )
    elseif tier == 'enemy' then
      colortext  = minetest .colorize( enemyColor[1],  msg )

    elseif tier == 'foreign' then
      if print2console then
        print( '[friendly_chat]  trans'
          ..msg :sub( msg:find('>') +1, -1 ) ..'  ::  ' .. playername )
      else
        colortext  = minetest .colorize( foreignColor[1],  msg )
      end  -- if print2console
    elseif tier == 'ignore' then
      print( '[friendly_chat]  deleted: ' ..msg )
    elseif tier == 'other' then
      colortext  = minetest .colorize( untaggedColor[1],  msg )

    else
      colortext  = minetest .colorize( untaggedColor[1],  msg )
    end  -- .playername
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  elseif msg :sub(1, 4) == '*** ' then  -- join/leave messages
    local playername  = msg :sub(  5,  msg:find( ' ', 5 ) -1  )  -- after '*** ' up to not including ' '

    xpcall(  function() tier  = mod_storage :get_string( playername ) end, 
             function() tier  = '' end  )

    if msg :sub(-16, -1) == 'joined the game.' then  -- join
      if parted_players [playername] then
        parted_players [playername]  = nil
      end  -- parted_players

      if playername ~= player1name then
        local found  = false  -- find out if name is already in list
        for i = 1, #player_names do
          if player_names[i] == playername then
            found  = true
            break
          end  -- if == playername
        end  -- iterate through player_names

        if not found then  -- if not, add name to list
          table.insert( player_names, playername )
          -- print( '[friendly_chat]  added: ' ..playername )
          if shown then  -- if formspec is currently showing,
            show_main_dialog()  -- refresh it with new playername.
          end  -- shown
        end  -- not found
      end  -- not player1name

      if tier == 'admin' or tier == 'mod' or tier == 'best' or tier == 'friend' then
        colortext  = minetest .colorize( joinColor[1],  msg )
      elseif tier ~= 'ignore'  then
        colortext  = minetest .colorize( joinColor[2],  msg )
      end

    elseif msg :sub(-14, -1) == 'left the game.' then  -- leave
      local part_time  = minetest .get_us_time()
      parted_players [playername]  = part_time

      if tier == 'admin' or tier == 'mod' or tier == 'best' or tier == 'friend' then
        colortext  = minetest .colorize( exitColor[1],  msg )
      else
        colortext  = minetest .colorize( exitColor[2],  msg )
      end

    else                                           -- timed out
      local part_time  = minetest .get_us_time()
      parted_players [playername]  = part_time

      if tier == 'admin' or tier == 'mod' or tier == 'best' or tier == 'friend' then
        colortext  = minetest .colorize( timeoutColor[1],  msg )
      else
        colortext  = minetest .colorize( timeoutColor[2],  msg )
      end
    end  -- .playername
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  elseif msg :sub(1, 2) == '* ' then  -- /me messages
    local playername  = msg :sub(3, msg:find(' ') -1 )

    xpcall(  function() tier  = mod_storage :get_string( playername ) end, 
             function() tier  = '' end  )

    if playername == player1name then
      colortext  = minetest .colorize( myColor[2],  msg )
    elseif tier == 'admin' then
      colortext  = minetest .colorize( adminColor[2],  msg )
    elseif tier == 'mod' then
      colortext  = minetest .colorize( modColor[2],  msg )

    elseif tier == 'best' then
      colortext  = minetest .colorize( bestColor[2],  msg )
    elseif tier == 'friend' then
      colortext  = minetest .colorize( friendColor[2],  msg )
    elseif tier == 'aquaint' then
      colortext  = minetest .colorize( aquaintColor[2],  msg )

    elseif tier == 'noob' then
      colortext  = minetest .colorize( noobColor[2],  msg )
    elseif tier == 'annoy' then
      print( '[friendly_chat]  action deleted: ' ..msg )
    elseif tier == 'hacker' then
      colortext  = minetest .colorize( hackerColor[2],  msg )
    elseif tier == 'enemy' then
      colortext  = minetest .colorize( enemyColor[2],  msg )

    elseif tier == 'foreign' then
      if print2console then
        print( '[friendly_chat]  trans'
          ..msg :sub( playername, -1 ) ..'  ::  ' ..playername )
      else
        colortext  = minetest .colorize( enemyColor[1],  msg )
      end  -- if print2console
    elseif tier == 'ignore' then
      print( '[friendly_chat]  action deleted: ' ..msg )
    elseif tier == 'other' then
      colortext  = minetest .colorize( otherColor[2],  msg )
    else
      colortext  = minetest .colorize( untaggedColor[2],  msg )
    end  -- .playername
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  elseif msg :sub(1, 3) == 'PM ' then  -- /msg
    local playername  = msg :sub( 4, msg:find(' ') -1 )

    xpcall(  function() tier  = mod_storage :get_string( playername ) end, 
             function() tier  = '' end  )

    if tier == 'admin' then
      colortext  = minetest .colorize( PmColor[1],  msg )
    elseif tier == 'mod' then
      colortext  = minetest .colorize( PmColor[1],  msg )

    elseif tier == 'best' then
      colortext  = minetest .colorize( PmColor[1],  msg )
    elseif tier == 'friend' then
      colortext  = minetest .colorize( PmColor[1],  msg )
    elseif tier == 'aquaint' then
      colortext  = minetest .colorize( PmColor[1],  msg )

    elseif tier == 'noob' then
      colortext  = minetest .colorize( noobColor[1],  msg )
    elseif tier == 'annoy' then
      colortext  = minetest .colorize( annoyColor[2],  'PM deleted' )
      print( '[friendly_chat]  PM deleted: ' ..msg )
    elseif tier == 'enemy' then
      colortext  = minetest .colorize( enemyColor[2],  'PM deleted' )
      print( '[friendly_chat]  PM deleted: ' ..msg )
    elseif tier == 'ignore' then
      colortext  = minetest .colorize( enemyColor[2], 'PM deleted' )
      print( '[friendly_chat]  PM deleted: ' ..msg )

    else
      colortext  = minetest .colorize( PmColor[2],  msg )
    end  -- .playername
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  elseif msg :sub(1, 1) == '[' then  -- server messages
    colortext  = minetest .colorize( serverColor[2],  msg )
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  elseif msg :sub(1, 3) == '-!-' then  -- error messages
    colortext  = minetest .colorize( serverColor[1],  msg )
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  elseif msg :sub(1, 2) == '# ' then  -- announce messages

    if msg:find('clients={') then
      local alpha, beta  = msg:find( 'clients={' )  -- beta = where '{' is.

      local pre  = msg :sub( 1, beta )  -- block of text, up to, and including 'clients={'
      local online  = msg :sub(  beta +1,  msg:find('}') -1  )
      local post  = msg :sub(  msg:find('}'),  -1  )  -- text after '}'
      --~~~~~~~~~~~~~~~~~~~~~
      -- if name isn't in player_list
      for name in string.gmatch( online, '%S+' ) do  -- select word, up to space
        if name:find(',') then  -- if trailing comma
          name = name:sub( 1,  name:find(',') -1  )  -- strip it
        end  -- comma

        local found  = false
        for i = 1, #player_names do
          if player_names[i] == name then
            found  = true
            break
          end  -- if == name
        end  -- iterate through player_names

        if not found then  -- add it to list
          table.insert( player_names, name )
        end  -- not found
      end -- name in ( online )
      --~~~~~~~~~~~~~~~~~~~~~
      -- pretty-print players
      local M1 = minetest .colorize( serverColor[2],  pre )
      local M2 = minetest .colorize( serverColor[1],  online )
      local M3 = minetest .colorize( serverColor[2],  post )
      colortext  = M1..M2..M3
    else
      colortext  = minetest .colorize( serverColor[2],  msg )
    end  -- if online
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  else
    local playername  = ''
    if msg :match(' ') then
      playername  = msg :sub( 1,  msg:find(' ') -1  )
    end

    xpcall(  function() tier  = mod_storage :get_string( playername ) end, 
             function() tier  = '' end  )

    if msg :sub( 1, 7 ) == 'Player ' or msg :sub( 1, 5 ) == 'Jail 'then
      colortext  = minetest .colorize( exitColor[1],  msg )

    elseif tier == 'admin' then
      colortext  = minetest .colorize( adminColor[2],  msg )

    elseif tier == 'mod' then
      colortext  = minetest .colorize( modColor[2],  msg )


    elseif tier == 'best' then
      colortext  = minetest .colorize( bestColor[2],  msg )

      local nextfewletters  = msg :sub( #playername +2, #playername +14 )
      if nextfewletters == 'is requesting' then -- to teleport...
        minetest .send_chat_message( '/tpy' )
      end  -- nextfewletters

    elseif tier == 'friend' then
      colortext  = minetest .colorize( friendColor[2],  msg )

    elseif tier == 'noob' then
      colortext  = minetest .colorize( noobColor[2],  msg )

    elseif tier == 'annoy' then
      colortext  = minetest .colorize( annoyColor[2],  msg )

      local nextfewletters  = msg :sub( #playername +2, #playername +14 )
      if nextfewletters == 'is requesting' then -- to teleport...
        minetest .send_chat_message( '/tpn' )
      end  -- nextfewletters

    elseif tier == 'hacker' then
      colortext  = minetest .colorize( hackerColor[2],  msg )

      local nextfewletters  = msg :sub( #playername +2, #playername +14 )
      if nextfewletters == 'is requesting' then -- to teleport...
        minetest .send_chat_message( '/tpn' )
      end  -- nextfewletters

    elseif tier == 'enemy' then
      colortext  = minetest .colorize( enemyColor[2],  msg )

      local nextfewletters  = msg :sub( #playername +2, #playername +14 )
      if nextfewletters == 'is requesting' then -- to teleport...
        minetest .send_chat_message( '/tpn' )
      end  -- nextfewletters

    elseif tier == 'foreign' then
      if print2console then
        print( '[friendly_chat]  trans'
          ..msg :sub( #playername +2, -1 ) ..'  ::  ' .. playername )
      else
        colortext  = minetest .colorize( foreignColorColor[2],  msg )
      end  -- if print2console

    elseif tier == 'ignore' then
      print( '[friendly_chat]  deleted: ' ..msg )

      local nextfewletters  = msg :sub( #playername +2, #playername +14 )
      if nextfewletters == 'is requesting' then -- to teleport...
        minetest .send_chat_message( '/tpn' )
      end  -- nextfewletters

    elseif tier == 'other' then
      colortext  = minetest .colorize( otherColor[2],  msg )

    elseif playername :find(player1name) then
      colortext  = minetest .colorize( myColor[2],  msg )

    elseif msg :sub(1, 5) == 'Your ' then  -- anvil
      if msg :sub(6, 15 ) == 'workpiece ' then  -- improves
        colortext  = minetest .colorize( otherColor[2],  msg )
      else  -- tool is fixed
        colortext  = minetest .colorize( joinColor[1],  msg )
      end  -- anvil

    else
      colortext  = minetest .colorize( serverColor[2],  msg )
    end  -- playername
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- possibly put in block of code here to color *IRC chat.
  -- will need to see a few examples first.
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  end  -- if...elseif msg :sub()
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if #colortext > 0 then
    minetest .display_chat_message(colortext)
  end -- #colortext > 0

  return true
end  -- function(message)
)  -- register_on_receiving_chat_messages

--=========================================================

minetest .register_on_formspec_input(  function( formname, fields )
  if formname ~= 'friendly_chat:player_list' then return false

  elseif fields .quit then
    selected_player  = ''
    shown  = false
    return true

  elseif fields .player_list then
    local selected  = fields .player_list
    if selected :sub(1,3) == 'CHG' then  -- example: CHG:1:2
      -- get # from first ':'  @ pos 5.  Up to, but not including second ':'
      local index  = selected :sub( 5,  selected :find(':', 5) -1 )
      selected_player  = player_names[ tonumber(index) ]
      show_main_dialog()
    end  -- 'CHG'
    return true


  elseif fields .tpr then
-- Client-Side Mods don't use  minetest .chat_send_all() -- thanks user2
    minetest .send_chat_message( '/tpr ' ..selected_player )
    return true

  elseif fields .tphr then
    minetest .send_chat_message( '/tphr ' ..selected_player )
    return true


  elseif fields .admin then
    print( '[friendly_chat]  clicked admin on ' ..selected_player )
    mod_storage :set_string( selected_player, 'admin' )
    show_main_dialog()
    return true

  elseif fields .mod then
    print( '[friendly_chat]  clicked mod on ' ..selected_player )
    mod_storage :set_string( selected_player, 'mod' )
    show_main_dialog()
    return true


  elseif fields .best then
    print( '[friendly_chat]  clicked best friend on ' ..selected_player )
    mod_storage :set_string( selected_player, 'best' )
    show_main_dialog()
    return true

  elseif fields .friend then
    print( '[friendly_chat]  clicked friend on ' ..selected_player )
    mod_storage :set_string( selected_player, 'friend' )
    show_main_dialog()
    return true

  elseif fields .aquaint then
    print( '[friendly_chat]  clicked aquaintance on ' ..selected_player )
    mod_storage :set_string( selected_player, 'aquaint' )
    show_main_dialog()
    return true


  elseif fields .noob then
    print( '[friendly_chat]  clicked noob on ' ..selected_player )
    mod_storage :set_string( selected_player, 'noob' )
    show_main_dialog()
    return true

  elseif fields .annoy then
    print( '[friendly_chat]  clicked annoyance on ' ..selected_player )
    mod_storage :set_string( selected_player, 'annoy' )
    show_main_dialog()
    return true

  elseif fields .hacker then
    print( '[friendly_chat]  clicked hacker on ' ..selected_player )
    mod_storage :set_string( selected_player, 'hacker' )
    show_main_dialog()
    return true

  elseif fields .enemy then
    print( '[friendly_chat]  clicked enemy on ' ..selected_player )
    mod_storage :set_string( selected_player, 'enemy' )
    show_main_dialog()
    return true


  elseif fields .foreign then
    print( '[friendly_chat]  clicked foreign on ' ..selected_player )
    mod_storage :set_string( selected_player, 'foreign' )
    show_main_dialog()
    return true

  elseif fields .ignore then
    print( '[friendly_chat]  clicked ignore on ' ..selected_player )
    mod_storage :set_string( selected_player, 'ignore' )
    show_main_dialog()
    return true

  elseif fields .other then
    print( '[friendly_chat]  clicked other on ' ..selected_player )
    mod_storage :set_string( selected_player, 'other' )
    show_main_dialog()
    return true


  elseif fields .clear then
    print( '[friendly_chat]  clicked clear on ' ..selected_player )
    mod_storage :set_string( selected_player, '' )
    show_main_dialog()
    return true
  end  -- .other

end  -- function(formname, fields)
)  -- register_on_formspec_input()

--=========================================================
--  Note:  I would rather this block of code be at the beginning, right after variable declaration,
--  however, it uses  show_main_dialog()  to refresh formspec, 
--  in case the player happens to type in  .l  before initialized,
--  so that has to be defined first.

minetest .register_on_connect(  function()
  -- delay a moment for Minetest to initialize player, and have a chance to count player_names
  minetest .after( 3,  function()
    player1name  = minetest .localplayer :get_name()

    local found  = false
    for i = 1, #player_names do
      if player_names[i] == player1name then
        found  = true
        break
      end  -- if == player1name
    end  -- iterate through player_names

    if not found then  -- add it to list
      table.insert( player_names, player1name )
    end  -- not found

    -- minetest.is_singleplayer()  seems to crash Minetest.  thanks LaCosa
    if #player_names < 2 then
      singleplayer  = true

      table.insert( player_names, '@fake_admin' )
      mod_storage :set_string( '@fake_admin', 'admin' )

      table.insert( player_names, '@fake_moderator' )
      mod_storage :set_string( '@fake_moderator', 'mod' )

      table.insert( player_names, '@fake_best_friend' )
      mod_storage :set_string( '@fake_best_friend', 'best' )

      table.insert( player_names, '@fake_friend' )
      mod_storage :set_string( '@fake_friend', 'friend' )

      table.insert( player_names, '@fake_aquaintance' )
      mod_storage :set_string( '@fake_aquaintance', 'aquaint' )

      table.insert( player_names, '@fake_name' )

      table.insert( player_names, '@fake_noob' )
      mod_storage :set_string( '@fake_noob', 'noob' )

      table.insert( player_names, '@fake_annoyance' )
      mod_storage :set_string( '@fake_annoyance', 'annoy' )

      table.insert( player_names, '@fake_hacker' )
      mod_storage :set_string( '@fake_hacker', 'hacker' )

      table.insert( player_names, '@fake_enemy' )
      mod_storage :set_string( '@fake_enemy', 'enemy' )

      table.insert( player_names, '@fake_foreign' )
      mod_storage :set_string( '@fake_foreign', 'foreign' )

      table.insert( player_names, '@fake_ignore' )
      mod_storage :set_string( '@fake_ignore', 'ignore' )

      table.insert( player_names, '@fake_other' )
      mod_storage :set_string( '@fake_other', 'other' )

      table.insert( player_names, '@fake_parted' )
      mod_storage :set_string( '@fake_parted', 'other' )
      parted_players ['@fake_parted']  = minetest .get_us_time()
    end

    local M1  = minetest .colorize( '#BBBBBB', 'friendly_chat loaded, type ' )
    local M2  = minetest .colorize( '#FFFFFF', '.l ' )
    local M3  = minetest .colorize( '#BBBBBB', 'or ' )
    local M4  = minetest .colorize( '#FFFFFF', '.list ' )
    local M5  = minetest .colorize( '#BBBBBB', "to list players you've seen." )
    minetest .display_chat_message( M1..M2..M3..M4..M5 )

    if shown then
      show_main_dialog()  -- refresh
    end
  end  -- function()
  )  -- .after(1)

end  -- function()
)  -- .register_on_connect()

--=========================================================

minetest .register_chatcommand( 'l',
  {
    func  = function(param)
      shown  = true
      show_main_dialog()
    end,
  }
)

minetest .register_chatcommand( 'list',
  {
    func  = function(param)
      shown  = true
      show_main_dialog()
    end,
  }
)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
