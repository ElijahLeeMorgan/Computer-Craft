--slots.lua

-- This is a modified verison of MERCWEAR's slot machine. The original can be found at https://pastebin.com/6HBmgNZx
--Should this program create the image files needed for it to run. Change to false after first run
local create_images = "true"

--Where to send the terminal output
term.redirect(peripheral.wrap("top"))

--Set the background color of the monitor
term.setBackgroundColor(colors.black)

--Monitor variable
local mon = peripheral.wrap("top")

--Set the text size of the monitor
mon.setTextScale(0.5)

--Clear the monitor
mon.clear()

--Set the minimum bet amount
local min_bet = 5

--Currency this machine will accept
--Display name (what the users will see)
local accepted_currency = "Coal"

--Minecraft name. Note: Most items have 2 names, one can be edited (display_name) with the anvil and the other cannot (id). It's
-- important to 
-- use the name that cannot be edited here to prevent cheating. Look at the item in a computer craft terminal to 
-- determine what item name to use.
local real_currency_name = "minecraft:coal"

--Image options for the reel (these are files on the computer that controls the slot)
options = {"pig","sheep","creeper","steve","cow"}

--Chest that the user will deposit currency into so they can play
deposit_chest = peripheral.wrap("container_barrel_0")

--Where to push the users deposit for safe keeping
collections_chest_push_direction = "north"
--Where to send redstone signal while bet is being paid.
collections_chest_redstone_direction = "left"

--What color of More Red cable to pulse when a jackpot is won.
jackpotColor = colors.blue
--What color of More Red cable to pulse for a normal win.
winnerColor = colors.yellow

--Chest where winners can collect their winnings and it's push direction
--payout_chest = peripheral.wrap("container_chest_1")
--payout_chest_push_direction = "west"

--All variables that typically will not be changed by the user are defined here
local currency = nil

--Variables for detecting a button press. Not currently used
local mouseWidth = 0
local mouseHeight = 0
local w,h=mon.getSize()
local curx, cury
local amnt_due
local winner_payout
local bet_amount
local bet_type
local winning_amount
local slot_one_contents
local winner
local n_one
local n_two
local n_three
local image
local slot_image
local money_image
local slot_one_check_contents
local bet_status
local cheater


--Function to center text on screen. The Y position (1,Y) of the cursor should be set BEFORE this function is called
local function center_printing (text)
	curx, cury = term.getCursorPos()
	term.setCursorPos((w-#text)/2,cury)
	term.write(text) --write the text
	term.setCursorPos(curx,cury+1)
	term.setCursorPos(1,math.floor(h/2))

end

local function paywinner(winType)
	term.setCursorPos(1,13)
	center_printing ("You won!!")
    if winType == 1 then
        center_printing("Jackpot!")
	    rs.setBundledOutput("back",jackpotColor, true)
        sleep(1)
	    rs.setBundledOutput("back",jackpotColor, false)
    elseif winType == 2 then
        center_printing("Winner!")
        rs.setBundledOutput("back",winnerColor, true)
        sleep(1)
        rs.setBundledOutput("back",winnerColor, false)
    else
        center_printing("Sorry. Better luck next time.")
    end
	sleep(3)
end

local function outcome()	
	--Check for winner and print results
	if (n_one == n_two) and (n_one == n_three) then
		winner = 1
	elseif n_one == n_two then
		winner = 2
	else
		winner = 0
	end
	
	--Output the results
	term.setCursorPos(1,14)
    paywinner(winner)
end

local function roll()
	mon.clear()
	options = {"pig","sheep","creeper","steve","cow"}
	i = 1
	while i < 7 do
		image = math.random(1,#options)
		slot_image = paintutils.loadImage((options[image]))
		paintutils.drawImage(slot_image, 2,1)
		n_one = image
	
		image = math.random(1,#options)
		slot_image = paintutils.loadImage((options[image]))
		paintutils.drawImage(slot_image, 22,1)
		n_two = image
	
		image = math.random(1,#options)
		slot_image = paintutils.loadImage((options[image]))
		paintutils.drawImage(slot_image, 42,1)
		n_three = image
	
		sleep(0.5)
		term.setBackgroundColor(colors.black)
		i = i + 1
	end
	outcome()
end

local function paid()
	term.clear()
	term.setCursorPos(1,2)
	center_printing ("You are betting "..min_bet.." "..accepted_currency..". Good luck!")
	money_image = paintutils.loadImage("money")
	paintutils.drawImage(money_image, 21,8)
	--paintutils.drawBox(28, 19, 27, 23, colors.lime)
	term.setCursorPos(1,4)
	--mon.setBackgroundColour((colours.lime))
	center_printing (" Right click the screen to spin ")
	mon.setBackgroundColour((colours.black))
	event,p1,p2,p3 = os.pullEvent()
	if event=="monitor_touch" then
		mouseWidth = p2 -- sets mouseWidth
		mouseHeight = p3 -- and mouseHeight
		term.setCursorPos(1,1)
		checkClickPosition()
	end

end


function checkClickPosition()
	--Used for placing a button. I am not using a button, the user can just click anywhere on the screen to spin
	--if mouseWidth > 25 and mouseWidth < 30 and mouseHeight == 21 then
	if mouseWidth > 1 and mouseWidth < 3000 and mouseHeight > 0 then
		term.setCursorPos(1,2)
		roll()
	else
		paid()
	end
end

while true do
	--Determine if the image files for the reels need to be created
	if create_images == "true" then
		--Create images for slot machine
		local image_files = {cow = "ccccccccccccccc\nccccccccccccccc\nccccccccccccccc\n0000ccccccc0000\nff00ccccccc00ff\nccccccccccccccc\ncccc0000000cccc\ncc00ff888ff00cc\ncc00888888800cc\ncc00888888800cc", creeper = "555555555555555\n55dffd555dffd55\n55ffff555ffff55\n55ffff555ffff55\n555555fff555555\n5555fffffff5555\n5555fffffff5555\n5555fffffff5555\n5555ff55dff5555\n555555555555555", pig = "222222222222222\n222222222222222\n222222222222222\n222222222222222\nff00222222200ff\n222266666662222\n2222ff666ff2222\n222266666662222\n222222222222222\n222222222222222"
, sheep = "000000000000000\n000000000000000\n00ccccccccccc00\n00ff00ccc00ff00\n00ccccccccccc00\n0000cc666cc0000\n0000cc666cc0000\n000000000000000\n000000000000000\n000000000000000", steve = "ccccccccccccccc\nccccccccccccccc\ncc11111111111cc\ncc11111111111cc\n111111111111111\n1100bb111bb0011\n111111777111111\n1111cc666cc1111\n1111ccccccc1111\n1111ccccccc1111", money = "ffffffffffffff\nfff5fff5fff5fff\nff555f555f555ff\nff5fff5fff5ffff\nff555f555f555ff\nffff5fff5fff5ff\nff555f555f555ff\nfff5fff5fff5fff\nfffffffffffffff\nfffffffffffffff"}
		for k,v in pairs (image_files) do
        		-- Create a new file on the computer craft computer to save the contents of the remote file to
		        local fHandle = fs.open(k, "w")
 
	        	-- Write the contents of the remote file to the new file we just created
		        fHandle.writeLine(v)
 
        		-- Close the new file, saving the contents of the remote file to it
		        fHandle.close()
		end
	end

	term.setCursorPos(1,16)
	center_printing ("Please deposit "..min_bet.." "..accepted_currency.." to play.")

	term.setCursorPos(1,18)
	center_printing ("Payout Information:")

	term.setCursorPos(1,19)
	center_printing ("Match any of the first 2 images and get 1 to 5 payout")

	term.setCursorPos(1,20)
	center_printing ("Match all 3 images and get 1 to 15 payout")

	term.setCursorPos(1,24)
	center_printing ("Bet is "..min_bet.." "..accepted_currency..".")

	
	--Have a constant spinning of the reel to draw players in
	image = math.random(1,#options)
	slot_image = paintutils.loadImage((options[image]))
	paintutils.drawImage(slot_image, 2,1)
	
	image = math.random(1,#options)
	slot_image = paintutils.loadImage((options[image]))
	paintutils.drawImage(slot_image, 22,1)
	
	image = math.random(1,#options)
	slot_image = paintutils.loadImage((options[image]))
	paintutils.drawImage(slot_image, 42,1)
	
	sleep(2)
	mon.setBackgroundColour((colours.black))
	
	--Check for deposit
	deposit_chest.condenseItems()
	currency = deposit_chest.getStackInSlot(1)
	if currency ~= nil then
		--They paid something!
		bet_type = currency.id
		bet_amount = currency.qty
		--The currency is correct, now make sure they are betting within the min / max
		--Check if the bet amount is high / low enough
        if bet_amount < min_bet then
			bet_status = "low"
		end

		--Make sure the currency is something that we accept and they have bet within the min and max settings
		if (bet_type == real_currency_name) and (bet_status == nil) then
			--Push the item to the collections chest
            redstone.setOutput(collections_chest_redstone_direction, true)
			deposit_chest.pushItem(collections_chest_push_direction,1,64)
			paid()
            redstone.setOutput(collections_chest_redstone_direction, false)
		else
			term.setCursorPos(1,22)

			--Set the background of the error message to red
			term.setBackgroundColor(colors.red)

			--Determine what error to display to the user

			--Cheater! Someone tried renaming an item in an anvil to match the currency used on this slot
			if (currency.display_name == accepted_currency) and (currency.id ~= real_currency_name) then
				center_printing("CHEATER DETECTED")
				sleep(3)
			--Wrong currency error
			elseif bet_type ~= real_currency_name then
				center_printing("Sorry. We do not accept "..currency.display_name.." here.")
			--Bet too low error
			elseif bet_status == "low" then
				center_printing("You did not bet enough "..accepted_currency..".".." The minimum bet is ".. min_bet..".")
			end
			term.setBackgroundColor(colors.black)		
			currency = nil
			bet_status = nil
			sleep(5)
			bet_type = nil
			bet_amount = nil
			term.clear()
		end
	end
end