--[[
Made by

      ::::::::  :::    ::: ::::::::: ::::::::::: 
    :+:    :+: :+:    :+: :+:    :+:    :+:      
   +:+        +:+    +:+ +:+    +:+    +:+       
  :#:        +#+    +:+ +#++:++#+     +#+        
 +#+   +#+# +#+    +#+ +#+    +#+    +#+         
#+#    #+# #+#    #+# #+#    #+#    #+#          
########   ########  ######### ###########       

nicolaigubi@gmail.com

		
		INFO:
        This plugin creates a sequence with a range of groups.
        You are asked for the beginning group number and the ending group.
        You are also asked for a name to the sequence.
        You'll get a sequence with cues that have matching cue numbers and 
        labels as you source groups.
        
        WARNING:
        If you give the sequence a name of an exixting sequence then all 
        existing cues WILL BE LOST!!
        Your BlindEdit programmer will be cleared!!
--]]

cmd = gma.cmd
getvar = gma.show.getvar
getobj = gma.show.getobj
progress = gma.gui.progress
confirm = gma.gui.confirm
sleep = gma.sleep
input = gma.textinput
int = math.tointeger

--***********************************************************
-- Progress bar
--***********************************************************
function ProgressRun(n)
   if(n==1) then                                			--Check if first time 
      progress_bar = progress.start('Step number')   		--Create the progress bar
      progress.setrange(progress_bar,1,last_group)          --Creates the range of the bar
      progress.settext(progress_bar,'Groups To Sequence')  	--Sets a text
    elseif(n==lg) then                          			--Last run
      progress.stop(progress_bar)                          	--Ends the progress bar
   else
      progress.set(progress_bar,n);                        	--Not first and not last; Sets a progress value
   end
end

--****************************************************************************************
-- Main looping function
--****************************************************************************************
function CreateCues(x, y, z)
	cmd('BlindEdit On')                                                                   		-- Go into blind edit
	cmd('ClearAll')                                                                       		-- Clear the programmer
	cmd('Store Sequence "'..z..'" Cue 0.001 /o /nc ')                                     		-- Create cue that makes sure we keep an exixting seq assignment
	cmd('Assign Sequence "'..z..'" /CueZero=On')                                          		-- Turns on CueZero in sequence 
	cmd('Delete Sequence "'..z..'" Cue 0.002 thru /nc')                                   		-- Deletes existing cues

	for g = x, y, 1 do                                                                			-- Makes loop with store commands
		if getobj.handle('Group '..int(g)) then                                                	-- Check if group number exists
			local group_handle = getobj.handle('Group '..int(g))                                -- Create local shortcut
			local group_name = 0                                                             	-- Create local name variable
        	ProgressRun(int(g))
		    if getobj.label(group_handle) then                                                  -- This test if the group have a label
				group_name = getobj.label(group_handle)                                         -- If it has a lable use this a cue label
			else
				group_name = getobj.name(group_handle)                                          -- If it doens't have label use the name instead
			end
			cmd('Group '..int(g)..' At Normal')                                             	-- Gives groups the value stored in Setup->User->Settings
			cmd('Store Sequence "'..z..'" cue '..int(g)..' "'..group_name..'" fade 0.5 /o /nc')	-- Store Cue witth group number and label
			sleep(0.02)
			cmd('Group '..int(g)..' Zero')                                                  	-- Turns group to zero
		end
	end

	cmd('Delete Sequence "'..z..'" Cue 0.001 /CueOnly /nc')                               		-- Deletes the 0.1 cue
	sleep(0.02)
	cmd('ClearAll')                                                                       		-- Clear the programmer
	cmd('BlindEdit Off')                                                                  		-- Exits blind edit
end

--****************************************************************************************
-- Get User input
--****************************************************************************************
function GroupToSeq()
	if confirm('!! Please confirm !!','This will delete any existing cues in the specified seq. + clear your BlindEdit programmer - continue?') then
-- Gets information from user
		first_group = input('What is the first group number','Enter Group number')
		last_group = input('What is the last group number','Enter Group number')
		if getvar('LuaGtS_SeqName') then														-- Checks if the plug has run before and there exists a seq name variable
			seq_name = input('What is the name if the sequence',getvar('LuaGtS_SeqName'))		-- Variable exists; use previous input as suggestion
		else
			seq_name = input('What is the name if the sequence','Enter Sequence name')			-- First time plugin runs, 
		end
-- Test the input is strings and exist
		if type(first_group) == 'string' and type(last_group) == 'string' and type(seq_name) == 'string' then
			cmd('setvar $LuaGtS_SeqName = "'..seq_name..'"')									-- Store the seq name input as a show variable
--Test that first is a lower value than last, else reverse
			if first_group > last_group then    
				first_group, last_group = last_group, first_group
			end
-- Run function that creates the cues
			CreateCues(first_group, last_group, seq_name)
		else
--The user input isn't strings - end plugin
			if confirm('!! PLUGIN ERROR !!','Your input was not correct - Try again?') then 	--Input isn't correct, ask if try again
				GroupToSeq() 																	--User tries again
			else
				Cleanup() 																		--User aborts
			end
		end
	else
		Cleanup()
	end
end

--****************************************************************************************
-- CleanUp function
--****************************************************************************************
function Cleanup()
     gma.echo("Cleanup called") 	--Give a feedback in system monitor that plugin has ended
     progress.stop(progress_bar)    --Stops the progress bar if running
end

return GroupToSeq, Cleanup
