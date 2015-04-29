//CONTENTS:
//Base scanner stuff
//Health scanner
//Forensic scanner
//Reagent scanner

/datum/computer/file/pda_program/scan
	return_text()
		return src.return_text_header()

	proc/scan_atom(atom/A as mob|obj|turf|area)

		if( !A || (!src.holder) || (!src.master))
			return 1

		if((!istype(holder)) || (!istype(master)))
			return 1

		if(!(holder in src.master.contents))
			if(master.scan_program == src)
				master.scan_program = null
			return 1

		return 0

	//Health analyzer program
	health_scan
		name = "Health Scan"
		size = 8.0

		scan_atom(atom/A as mob|obj|turf|area)
			if(..())
				return

			var/mob/living/carbon/C = A
			if(!istype(C))
				return

			var/dat = "<span class='info'>Analyzing Results for [C]:\n</span>"
			dat += "<span class='info'>\t Overall Status: [C.stat > 1 ? "dead" : "[C.health]% healthy</span>"]\n"
			dat += "<span class='info'>\t Damage Specifics: [C.getOxyLoss() > 50 ? "\red" : "\blue"][C.getOxyLoss()]-[C.getToxLoss() > 50 ? "\red" : "\blue"][C.getToxLoss()]-[C.getFireLoss() > 50 ? "\red" : "\blue"][C.getFireLoss()]-[C.getBruteLoss() > 50 ? "\red" : "\blue"][C.getBruteLoss()]\n</span>"
			dat += "<span class='info'>\t Key: Suffocation/Toxin/Burns/Brute\n</span>"
			dat += "<span class='info'>\t Body Temperature: [C.bodytemperature-T0C]&deg;C ([C.bodytemperature*1.8-459.67]&deg;F)</span>"
			if(C.virus)
				dat += "<span class='warning'>\n<b>Warning Virus Detected.</b>\nName: [C.virus.name].\nType: [C.virus.spread].\nStage: [C.virus.stage]/[C.virus.max_stages].\nPossible Cure: [C.virus.cure]</span>"

			return dat

	//Forensic scanner
	forensic_scan
		name = "Forensic Scan"
		size = 8.0

		scan_atom(atom/A as mob|obj|turf|area)
			if(..())
				return
			var/dat = null

			if(istype(A,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = A
				if (!istype(H.dna, /datum/dna) || !isnull(H.gloves))
					dat += "<span class='info'>Unable to scan [A]'s fingerprints.\n</span>"
				else
					dat += "<span class='info'>[H]'s Fingerprints: [md5(H.dna.uni_identity)]\n</span>"
				if ( !(H.blood_DNA) )
					dat += "<span class='info'>No blood found on [H]\n</span>"
				else
					dat += "<span class='info'>Blood type: [H.blood_type]\nDNA: [H.blood_DNA]\n</span>"

			if (!A.fingerprints)
				dat += "<span class='info'>Unable to locate any fingerprints on [A]!\n</span>"
			else
				var/list/L = params2list(A:fingerprints)
				dat += "<span class='info'>Isolated [L.len] fingerprints.\n</span>"
				for(var/i in L)
					dat += "<span class='info'>\t [i]\n</span>"

			return dat


	//Reagent scanning program
	reagent_scan
		name = "Reagent Scan"
		size = 6.0

		scan_atom(atom/A as mob|obj|turf|area)
			if(..())
				return
			var/dat = null
			if(!isnull(A.reagents))
				if(A.reagents.reagent_list.len > 0)
					var/reagents_length = A.reagents.reagent_list.len
					dat += "<span class='info'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.\n</span>"
					for (var/datum/reagent/re in A.reagents.reagent_list)
						dat += "<span class='info'>\t [re] - [re.volume]\n</span>"
				else
					dat = "<span class='info'>No active chemical agents found in [A].</span>"
			else
				dat = "<span class='info'>No significant chemical agents found in [A].</span>"

			return dat
