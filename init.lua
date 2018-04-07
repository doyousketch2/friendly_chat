
print( '[friendly_chat]  CSM loading...' )
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local PmColor      = {'#99FF99', '#66CC66'}  -- friend, other  (Light Green)
local joinColor    = {'#00DD00', '#008800'}  --   "   ,   "    (Green)
local exitColor    = {'#DD0000', '#880000'}  --   "   ,   "    (Red)
local timeoutColor = {'#880000', '#660000'}  --   "   ,   "    (Dark Red)

local serverColor  = {'#EE9900', '#CC3300'}  -- playernames, server messages  (Orange)

local adminColor     = {'#FFFF00', '#BBBB00'}  -- chat, /me   (Yellow)
local modColor       = {'#0055DD', '#003388'}  --  "  ,  "    (Blue)
local myColor        = {'#00DDDD', '#008888'}  --  "  ,  "    (Diamond Blue)
local aquaintColor   = {'#FFFFFF', '#BBBBBB'}  --  "  ,  "    (White)
local friendColor    = {'#3399FF', '#0055FF'}  --  "  ,  "    (Light Blue)
local annoyColor     = {'#999999', '#888888'}  --  "  ,  "    (Dark Grey)
local enemyColor     = {'#000000', '#444444'}  --  "  ,  "    (Black)
local otherColor     = {'#6600CC', '#400080'}  --  "  ,  "    (Purple)
local untaggedColor  = {'#AAAAAA', '#999999'}  --  "  ,  "    (Grey)

local tier  = ''
local colortext
local shown  = false
local player_names  = {}
local player1name  = ''
local selected_player  = ''

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
  local compare  = function( a,b ) return string.lower(a) < string.lower(b) end
	table .sort( player_names,  compare )

	local size  = 'size[5,8]'
	if selected_player ~= '' and selected_player ~= player1name then

    xpcall(  function() tier  = mod_storage :get_string( selected_player ) end, 
             function() tier  = '' end  )

    if tier == 'admin' then
      colortext  = minetest .colorize( adminColor[1],  tier )
    elseif tier == 'mod' then
      colortext  = minetest .colorize( modColor[1],  tier )
    elseif tier == 'aquaint' then
      colortext  = minetest .colorize( aquaintColor[1],  tier )
    elseif tier == 'friend' then
      colortext  = minetest .colorize( friendColor[1],  tier )
    elseif tier == 'annoy' then
      colortext  = minetest .colorize( annoyColor[1],  tier )
    elseif tier == 'enemy' then
      colortext  = minetest .colorize( enemyColor[1],  tier )
    elseif tier == 'ignore' then
      colortext  = minetest .colorize( enemyColor[2], tier )
    elseif tier == 'other' then
      colortext  = minetest .colorize( otherColor[2], tier )
    else
      colortext  = minetest .colorize( untaggedColor[2], tier )
    end  -- if...elseif tier

		size  = 'size[7,8]'
		..'label[3.1,7.8;' ..colortext ..']' -- colored label that shows current selection
	end -- increase formspec size and print tier if selected_player isn't you

	local formspec  = size
		..'bgcolor[#080808BB;true]'
		..'background[5,5;1,1;gui_formbg.png;true]'
		..'button_exit[0,7.9;2.2,0.2;close;Close]'

    if #player_names < 2 then
      formspec  = formspec
		  ..'label[0.1,0;Single Player]'
	  else  -- .is_singleplayer()
      formspec  = formspec
		  ..'label[0.1,0;' ..#player_names ..'  Players]'
    end  -- #player_names

    formspec  = formspec
		..'tableoptions[background=#314D4F]'
		..'tablecolumns[color;text,align=center,width=10]'
		..'table[0,0.6;4.8,7;player_list;'

	local formspec_table  = {}

	for index, playername in ipairs(player_names) do

    xpcall(  function() tier  = mod_storage :get_string( playername ) end, 
             function() tier  = '' end  )

		if playername == player1name then
			formspec_table[index]  = myColor[2] ..',' ..playername

		elseif tier == 'admin' then
			formspec_table[index]  = adminColor[2] ..',' ..playername

		elseif tier == 'mod' then
			formspec_table[index]  = modColor[2] ..',' ..playername

		elseif tier == 'aquaint' then
			formspec_table[index]  = aquaintColor[2] ..',' ..playername

		elseif tier == 'friend' then
			formspec_table[index]  = friendColor[2] ..',' ..playername

		elseif tier == 'annoy' then
			formspec_table[index]  = annoyColor[2] ..',' ..playername

		elseif tier == 'enemy' then
			formspec_table[index]  = enemyColor[2] ..',' ..playername

		elseif tier == 'ignore' then
			formspec_table[index]  = untaggedColor[2] ..',' ..playername

		elseif tier == 'other' then
			formspec_table[index]  = otherColor[2] ..',' ..playername

		else
			formspec_table[index]  = untaggedColor[1] ..',' ..playername
		end
	end

	formspec  = formspec ..table .concat( formspec_table, ',' ) ..';]'

	if selected_player ~= '' and selected_player ~= player1name then
	  formspec  = formspec
	    ..'button[5,0.8;2.2,0.25;admin;Admin]'
		  ..'button[5,1.6;2.2,0.25;mod;Moderator]'
	    ..'button[5,2.4;2.2,0.25;aquaint;Aquaintance]'
	    ..'button[5,3.2;2.2,0.25;friend;Friend]'
	    ..'button[5,4.0;2.2,0.25;annoy;Annoyance]'
		  ..'button[5,4.8;2.2,0.25;enemy;Enemy]'
		  ..'button[5,5.6;2.2,0.25;ignore;Ignore]'
		  ..'button[5,6.4.5;2.2,0.25;other;Other]'
		  ..'button[5,7.9;2.2,0.25;clear;' ..minetest .colorize( exitColor[2], 'CLEAR' ) ..']'
	end

	minetest .show_formspec( 'friendly_chat:player_list', formspec )
end

--=========================================================

minetest .register_on_receiving_chat_messages(  function(message)
  local msg  = minetest .strip_colors(message)
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if msg :sub(1, 1) == '<' then  -- Normal messages
    local playername  = msg :sub(2, msg:find('>') -1 )  -- after '<' up to, not including '>'

    xpcall(  function() tier  = mod_storage :get_string( playername ) end, 
             function() tier  = '' end  )

    if playername == player1name then
      colortext  = minetest .colorize( myColor[1],  msg )
    -- in case someone decides to use '__fake_' prefix in their name
    elseif playername :sub(1, 7) == '__fake_' then
      colortext  = minetest .colorize( enemyColor[2], 'fake message deleted' )
      print( '[friendly_chat]  fake message deleted: ' ..msg )
    elseif tier == 'admin' then
      colortext  = minetest .colorize( adminColor[1],  msg )
    elseif tier == 'mod' then
      colortext  = minetest .colorize( modColor[1],  msg )
    elseif tier == 'aquain' then
      colortext  = minetest .colorize( aquaintColor[1],  msg )      
    elseif tier == 'friend' then
      colortext  = minetest .colorize( friendColor[1],  msg )
    elseif tier == 'annoy' then
      colortext  = minetest .colorize( annoyColor[1],  msg )
    elseif tier == 'enemy' then
      colortext  = minetest .colorize( enemyColor[1],  msg )
    elseif tier == 'ignore' then
      colortext  = minetest .colorize( enemyColor[2], 'message deleted' )
      print( '[friendly_chat]  deleted: ' ..msg )
    elseif tier == 'other' then
      colortext  = minetest .colorize( untaggedColor[1],  msg )
    elseif msg == '<invalid multibyte string>' then
      colortext  = minetest .colorize( exitColor[2],  msg )
    elseif msg == '<invalid wstring>' then
      colortext  = minetest .colorize( exitColor[2],  msg )
    else
      colortext  = minetest .colorize( untaggedColor[1],  msg )
    end  -- .playername
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  elseif msg :sub(1, 4) == '*** ' then  -- join/leave messages
    local playername  = msg :sub(  5,  msg:find( ' ', 5 ) -1  )  -- after '*** ' up to not including ' '

    xpcall(  function() tier  = mod_storage :get_string( playername ) end, 
             function() tier  = '' end  )

    if msg :sub(-16, -1) == 'joined the game.' then  -- join

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
          print( '[friendly_chat]  added: ' ..playername )
          if shown then  -- if formspec is currently showing,
            show_main_dialog()  -- refresh it with new playername.
          end  -- shown
        end  -- not found
      end  -- not player1name

      if tier == 'admin' or tier == 'mod' or tier == 'friend' then
        colortext  = minetest .colorize( joinColor[1],  msg )
      else
        colortext  = minetest .colorize( joinColor[2],  msg )
      end

    elseif msg :sub(-14, -1) == 'left the game.' then  -- leave
      if tier == 'admin' or tier == 'mod' or tier == 'friend' then
        colortext  = minetest .colorize( exitColor[1],  msg )
      else
        colortext  = minetest .colorize( exitColor[2],  msg )
      end

    else                                           -- timed out
      if tier == 'admin' or tier == 'mod' or tier == 'friend' then
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
    elseif tier == 'aquaint' then
      colortext  = minetest .colorize( aquaintColor[2],  msg )
    elseif tier == 'friend' then
      colortext  = minetest .colorize( friendColor[2],  msg )
    elseif tier == 'annoy' then
      colortext  = minetest .colorize( annoyColor[2],  msg )
    elseif tier == 'enemy' then
      colortext  = minetest .colorize( enemyColor[2],  msg )
    elseif tier == 'ignore' then
      colortext  = minetest .colorize( enemyColor[2], 'action deleted' )
      print( '[friendly_chat]  action deleted: ' ..msg )
    elseif tier == 'other' then
      colortext  = minetest .colorize( otherColor[2],  msg )
    else
      colortext  = minetest .colorize( untaggedColor[2],  msg )
    end  -- .playername
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  elseif msg :sub(1, 2) == 'PM' then  -- /msg
    local playername  = msg :sub(3, msg:find(' ') -1 )

    xpcall(  function() tier  = mod_storage :get_string( playername ) end, 
             function() tier  = '' end  )

    if tier == 'admin' then
      colortext  = minetest .colorize( adminColor[2],  msg )
    elseif tier == 'mod' then
      colortext  = minetest .colorize( modColor[2],  msg )
    elseif tier == 'aquaintance' then
      colortext  = minetest .colorize( aquaintColor[2],  msg )
    elseif tier == 'friend' then
      colortext  = minetest .colorize( friendColor[2],  msg )
    elseif tier == 'annoyance' then
      colortext  = minetest .colorize( annoyColor[2],  'PM deleted' )
      print( '[friendly_chat]  PM deleted: ' ..msg )
    elseif tier == 'enemy' then
      colortext  = minetest .colorize( enemyColor[2],  'PM deleted' )
      print( '[friendly_chat]  PM deleted: ' ..msg )
    elseif tier == 'ignore' then
      colortext  = minetest .colorize( enemyColor[2], 'PM deleted' )
      print( '[friendly_chat]  PM deleted: ' ..msg )
    elseif tier == 'other' then
      colortext  = minetest .colorize( joinColor[2],  msg )
    else
      colortext  = minetest .colorize( untaggedColor[2],  msg )
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
          name = name:sub(  1,  name:find(',') -1  )  -- strip it
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
    local playername  = msg :sub( 1,  msg:find(' ')  )

    xpcall(  function() tier  = mod_storage :get_string( playername ) end, 
             function() tier  = '' end  )

    if msg :sub( 1, 7 ) == 'Player ' or msg :sub( 1, 5 ) == 'Jail 'then
      colortext  = minetest .colorize( exitColor[1],  msg )
    elseif tier == 'admin' then
      colortext  = minetest .colorize( adminColor[2],  msg )
    elseif tier == 'mod' then
      colortext  = minetest .colorize( modColor[2],  msg )
    elseif tier == 'friend' then
      colortext  = minetest .colorize( friendColor[2],  msg )
    elseif tier == 'enemy' then
      colortext  = minetest .colorize( enemyColor[2],  msg )
    elseif tier == 'ignore' then
      colortext  = minetest .colorize( enemyColor[2], 'occurrence deleted' )
      print( '[friendly_chat]  deleted: ' ..msg )
    elseif tier == 'other' then
      colortext  = minetest .colorize( otherColor[2],  msg )     
    elseif playername :find(player1name) then
      colortext  = minetest .colorize( myColor[2],  msg )
    else
      colortext  = minetest .colorize( serverColor[2],  msg )
    end  -- playername
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- possibly put in block of code here to color *IRC chat.
  -- will need to see a few examples first.
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  end  -- if...elseif msg :sub()
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  minetest .display_chat_message(colortext)
  return true
end  -- function(message)
)  -- register_on_receiving_chat_messages

--=========================================================

minetest .register_on_formspec_input(  function(formname, fields)
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

  elseif fields .aquaint then
    print( '[friendly_chat]  clicked aquaintance on ' ..selected_player )
    mod_storage :set_string( selected_player, 'aquaint' )
	  show_main_dialog()
	  return true

  elseif fields .friend then
    print( '[friendly_chat]  clicked friend on ' ..selected_player )
    mod_storage :set_string( selected_player, 'friend' )
	  show_main_dialog()
	  return true

  elseif fields .annoy then
    print( '[friendly_chat]  clicked annoyance on ' ..selected_player )
    mod_storage :set_string( selected_player, 'annoy' )
	  show_main_dialog()
	  return true

  elseif fields .enemy then
    print( '[friendly_chat]  clicked enemy on ' ..selected_player )
    mod_storage :set_string( selected_player, 'enemy' )
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
  minetest .after( 2,  function()
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
      table.insert( player_names, '__fake_admin' )
      mod_storage :set_string( '__fake_admin', 'admin' )

      table.insert( player_names, '__fake_moderator' )
      mod_storage :set_string( '__fake_moderator', 'mod' )

      table.insert( player_names, '__fake_aquaintance' )
      mod_storage :set_string( '__fake_aquaintance', 'aquaint' )

      table.insert( player_names, '__fake_friend' )
      mod_storage :set_string( '__fake_friend', 'friend' )

      table.insert( player_names, '__fake_name' )

      table.insert( player_names, '__fake_annoyance' )
      mod_storage :set_string( '__fake_annoyance', 'annoy' )

      table.insert( player_names, '__fake_enemy' )
      mod_storage :set_string( '__fake_enemy', 'enemy' )
      
      table.insert( player_names, '__fake_ignore' )
      mod_storage :set_string( '__fake_ignore', 'ignore' )

      table.insert( player_names, '__fake_other' )
      mod_storage :set_string( '__fake_other', 'other' )
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
