//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
/mob/verb/testslurring(var/text as text)
	usr << text
	usr << sanitize(text)
	usr << slurring(sanitize(text))
	usr << stutter(sanitize(text))
*/

proc/intoxicated(phrase) // using cp1251!
	var/output = ""

	for(var/i = 1; i <= lentext(phrase); i++)
		var/letter = copytext(phrase, i, i + 1)
		if(letter == " ") //skip whitespaces
			output += " "
			continue
		if(letter == "&")
			letter = "&#255;"
			i += 6
		if(rand(1,3)==3)
			if(lowerrustext(letter)=="з")	letter="с"
			if(lowerrustext(letter)=="в")	letter="ф"
			if(lowerrustext(letter)=="б")	letter="п"
			if(lowerrustext(letter)=="г")	letter="х"
			if(lowerrustext(letter)=="д")	letter="т"
			if(lowerrustext(letter)=="л")	letter="ль"
		switch(rand(1,15))
			if(1,3,5,8)		letter = "[lowerrustext(letter)]"
			if(2,4,6,15)	letter = "[upperrustext(letter)]"
			if(7)			letter += "'"
			if(9,10)		letter = "<b>[letter]</b>"
			if(11,12)		letter = "<big>[letter]</big>"
			if(13)			letter = "<small>[letter]</small>"
		output += letter

	return output

// For drunken speak, etc
proc/slurring(phrase) // using cp1251!
	var/output = ""

	for(var/i = 1; i <= lentext(phrase); i++)
		var/letter = copytext(phrase, i, i + 1)
		if(letter == " ") //skip whitespaces
			output += " "
			continue
		if(letter == "&")
			letter = "&#255;"
			i += 6
		if(prob(33))
			if(lowerrustext(letter)=="о")	letter="у"
			if(lowerrustext(letter)=="ы")	letter="i"
			if(lowerrustext(letter)=="р")	letter="r"
			if(lowerrustext(letter)=="л")	letter="ль"
			if(lowerrustext(letter)=="з")	letter="с"
			if(lowerrustext(letter)=="в")	letter="ф"
			if(lowerrustext(letter)=="б")	letter="п"
			if(lowerrustext(letter)=="г")	letter="х"
			if(lowerrustext(letter)=="д")	letter="т"
			if(lowerrustext(letter)=="л")	letter="ль"
		if(lowertext(letter) == "ы")		letter="i"
		if(lowertext(letter) == "р")		letter="r"
		switch(rand(1,15))
			if(1,3,5,8)		letter = "[lowerrustext(letter)]"
			if(2,4,6,15)	letter = "[upperrustext(letter)]"
			if(7)			letter += "'"
			if(9,10)		letter = "<b>[letter]</b>"
			if(11,12)		letter = "<big>[letter]</big>"
			if(13)			letter = "<small>[letter]</small>"
		output += letter

	return output

proc/stutter(phrase)
	var/list/unstuttered_words = dd_text2list(phrase," ") //Split it up into words.
	var/output = ""

	for(var/word in unstuttered_words)
		var/first_letter = copytext(word, 1, 2)
		if(first_letter == "&")
			first_letter = "&#255;"
		switch(rand(1,3))
			if(1)
				word = "[first_letter]-[word] "
			if(2)
				word = "[first_letter]-[first_letter]-[word] "
			if(3)
				word = "[first_letter]-[first_letter]-[first_letter]-[word] "
		output += word
	return output

proc/Stagger(mob/M,d) //Technically not a filter, but it relates to drunkenness.
	step(M, pick(d,turn(d,90),turn(d,-90)))

proc/Ellipsis(original_msg, chance = 50, keep_words)
	if(chance <= 0) return "..."
	if(chance >= 100) return original_msg

	var/list
		words = text2list(original_msg," ")
		new_words = list()

	var/new_msg = ""

	for(var/w in words)
		if(prob(chance))
			new_words += "..."
			if(!keep_words)
				continue
		new_words += w

	new_msg = list2text(new_words," ")

	return new_msg
