/datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H
	proc/randomize_appearance_for(var/mob/living/carbon/human/H)
		if(H)
			if(H.gender == MALE)
				gender = MALE
			else
				gender = FEMALE
		s_tone = random_skin_tone()
		h_style = random_hair_style(gender, species)
		f_style = random_facial_hair_style(gender, species)
		randomize_hair_color("hair")
		randomize_hair_color("facial")
		randomize_eyes_color()
		underwear = rand(1,underwear_m.len)
		backbag = 2
		age = rand(AGE_MIN,AGE_MAX)
		if(H)
			copy_to(H,1)


	proc/randomize_hair_color(var/target = "hair")
		if(prob (75) && target == "facial") // Chance to inherit hair color
			r_facial = r_hair
			g_facial = g_hair
			b_facial = b_hair
			return

		var/red
		var/green
		var/blue

		var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", "punk")
		switch(col)
			if("blonde")
				red = 255
				green = 255
				blue = 0
			if("black")
				red = 0
				green = 0
				blue = 0
			if("chestnut")
				red = 153
				green = 102
				blue = 51
			if("copper")
				red = 255
				green = 153
				blue = 0
			if("brown")
				red = 102
				green = 51
				blue = 0
			if("wheat")
				red = 255
				green = 255
				blue = 153
			if("old")
				red = rand (100, 255)
				green = red
				blue = red
			if("punk")
				red = rand (0, 255)
				green = rand (0, 255)
				blue = rand (0, 255)

		red = max(min(red + rand (-25, 25), 255), 0)
		green = max(min(green + rand (-25, 25), 255), 0)
		blue = max(min(blue + rand (-25, 25), 255), 0)

		switch(target)
			if("hair")
				r_hair = red
				g_hair = green
				b_hair = blue
			if("facial")
				r_facial = red
				g_facial = green
				b_facial = blue

	proc/randomize_eyes_color()
		var/red
		var/green
		var/blue

		var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
		switch(col)
			if("black")
				red = 0
				green = 0
				blue = 0
			if("grey")
				red = rand (100, 200)
				green = red
				blue = red
			if("brown")
				red = 102
				green = 51
				blue = 0
			if("chestnut")
				red = 153
				green = 102
				blue = 0
			if("blue")
				red = 51
				green = 102
				blue = 204
			if("lightblue")
				red = 102
				green = 204
				blue = 255
			if("green")
				red = 0
				green = 102
				blue = 0
			if("albino")
				red = rand (200, 255)
				green = rand (0, 150)
				blue = rand (0, 150)

		red = max(min(red + rand (-25, 25), 255), 0)
		green = max(min(green + rand (-25, 25), 255), 0)
		blue = max(min(blue + rand (-25, 25), 255), 0)

		r_eyes = red
		g_eyes = green
		b_eyes = blue


	proc/update_preview_icon()		//seriously. This is horrendous.
		qdel(preview_icon_front)
		qdel(preview_icon_side)
		qdel(preview_icon)

		var/g = "m"
		if(gender == FEMALE)	g = "f"

		var/icon/icobase
		var/datum/species/current_species = all_species[species]
/*
		var/uniform_icon = 'icons/mob/uniform.dmi'
		var/shoes_icon = 'icons/mob/feet.dmi'
		var/back_icon = 'icons/mob/back.dmi'
		var/gloves_icon = 'icons/mob/hands.dmi'
		var/suit_icon = 'icons/mob/suit.dmi'

		if(fat)
			uniform_icon = 'icons/mob/uniform_fat.dmi'
		else if(g == "f")
			uniform_icon = 'icons/mob/uniform_f.dmi'

		if(g == "f" && !fat)
			shoes_icon = 'icons/mob/feet_f.dmi'
			back_icon = 'icons/mob/back_f.dmi'
			gloves_icon = 'icons/mob/hands_f.dmi'
			suit_icon = 'icons/mob/suit_f.dmi'
*/
		if(current_species)
			icobase = current_species.icobase
		else
			icobase = 'icons/mob/human_races/r_human.dmi'

		preview_icon = new /icon(icobase, "torso_[g][fat ? "_fat" : ""]")
		preview_icon.Blend(new /icon(icobase, "groin_[g]"), ICON_OVERLAY)
		preview_icon.Blend(new /icon(icobase, "head_[g]"), ICON_OVERLAY)
		preview_icon.Blend(new /icon(icobase, "l_arm_[g]"), ICON_OVERLAY)
		preview_icon.Blend(new /icon(icobase, "r_arm_[g]"), ICON_OVERLAY)
		preview_icon.Blend(new /icon(icobase, "l_leg_[g]"), ICON_OVERLAY)
		preview_icon.Blend(new /icon(icobase, "r_leg_[g]"), ICON_OVERLAY)
		preview_icon.Blend(new /icon(icobase, "l_foot_[g]"), ICON_OVERLAY)
		preview_icon.Blend(new /icon(icobase, "r_foot_[g]"), ICON_OVERLAY)
		preview_icon.Blend(new /icon(icobase, "l_hand_[g]"), ICON_OVERLAY)
		preview_icon.Blend(new /icon(icobase, "r_hand_[g]"), ICON_OVERLAY)

		for(var/name in list("l_arm","r_arm","l_leg","r_leg","l_foot","r_foot","l_hand","r_hand"))
			// make sure the organ is added to the list so it's drawn
			if(organ_data[name] == null)
				organ_data[name] = null

		for(var/name in organ_data)
			if(organ_data[name] == "amputated") continue

			var/icon/temp = new /icon(icobase, "[name]")
			if(organ_data[name] == "cyborg")
				temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))

			preview_icon.Blend(temp, ICON_OVERLAY)

		// Skin tone
		if(current_species && (current_species.flags & HAS_SKIN_TONE))
			if (s_tone >= 0)
				preview_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
			else
				preview_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = current_species ? current_species.eyes : "eyes_s")
		eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style)
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			eyes_s.Blend(hair_s, ICON_OVERLAY)

		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style)
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			eyes_s.Blend(facial_s, ICON_OVERLAY)

		var/datum/sprite_accessory/facial_detail = facial_details_list[d_style]
		if(facial_detail)
			var/icon/detail_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_detail.icon_state]_s")
			detail_s.Blend(rgb(r_detail, g_detail, b_detail), ICON_ADD)
			eyes_s.Blend(detail_s, ICON_OVERLAY)

/*
		var/icon/clothes_s = null
		if(job_civilian_low & ASSISTANT)//This gives the preview icon clothes depending on which job(if any) is set to 'high'
			clothes_s = new /icon(uniform_icon, "grey_s")
			clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
			if(backbag == 2)
				clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
			else if(backbag == 3 || backbag == 4)
				clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)

		else if(job_civilian_high)//I hate how this looks, but there's no reason to go through this switch if it's empty
			switch(job_civilian_high)
				if(HOP)
					clothes_s = new /icon(uniform_icon, "hop_s")
					clothes_s.Blend(new /icon(shoes_icon, "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(suit_icon, "armor"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(BARTENDER)
					clothes_s = new /icon(uniform_icon, "ba_suit_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(suit_icon, "armor"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(BOTANIST)
					clothes_s = new /icon(uniform_icon, "hydroponics_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(gloves_icon, "ggloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(suit_icon, "apron"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-hyd"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(CHEF)
					clothes_s = new /icon(uniform_icon, "chef_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "chef"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(JANITOR)
					clothes_s = new /icon(uniform_icon, "janitor_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(LIBRARIAN)
					clothes_s = new /icon(uniform_icon, "red_suit_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(QUARTERMASTER)
					clothes_s = new /icon(uniform_icon, "qm_s")
					clothes_s.Blend(new /icon(shoes_icon, "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(gloves_icon, "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "clipboard"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(CARGOTECH)
					clothes_s = new /icon(uniform_icon, "cargotech_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(gloves_icon, "bgloves"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(MINER)
					clothes_s = new /icon(uniform_icon, "miner_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(gloves_icon, "bgloves"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-eng"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(LAWYER)
					clothes_s = new /icon(uniform_icon, "internalaffairs_s")
					clothes_s.Blend(new /icon(shoes_icon, "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "briefcase"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(CHAPLAIN)
					clothes_s = new /icon(uniform_icon, "chapblack_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(CLOWN)
					clothes_s = new /icon(uniform_icon, "clown_s")
					clothes_s.Blend(new /icon(shoes_icon, "clown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "clown"), ICON_OVERLAY)
					clothes_s.Blend(new /icon(back_icon, "clownpack"), ICON_OVERLAY)
				if(MIME)
					clothes_s = new /icon(uniform_icon, "mime_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(gloves_icon, "lgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "mime"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "beret"), ICON_OVERLAY)
					clothes_s.Blend(new /icon(suit_icon, "suspenders"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)

		else if(job_medsci_high)
			switch(job_medsci_high)
				if(RD)
					clothes_s = new /icon(uniform_icon, "director_s")
					clothes_s.Blend(new /icon(shoes_icon, "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "clipboard"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(suit_icon, "labcoat_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-tox"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(SCIENTIST)
					clothes_s = new /icon(uniform_icon, "toxinswhite_s")
					clothes_s.Blend(new /icon(shoes_icon, "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(suit_icon, "labcoat_tox_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-tox"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(CHEMIST)
					clothes_s = new /icon(uniform_icon, "chemistrywhite_s")
					clothes_s.Blend(new /icon(shoes_icon, "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(suit_icon, "labcoat_chem_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-chem"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(CMO)
					clothes_s = new /icon(uniform_icon, "cmo_s")
					clothes_s.Blend(new /icon(shoes_icon, "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_lefthand.dmi', "firstaid"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(suit_icon, "labcoat_cmo_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "medicalpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-med"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(DOCTOR)
					clothes_s = new /icon(uniform_icon, "medical_s")
					clothes_s.Blend(new /icon(shoes_icon, "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_lefthand.dmi', "firstaid"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(suit_icon, "labcoat_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "medicalpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-med"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(GENETICIST)
					clothes_s = new /icon(uniform_icon, "geneticswhite_s")
					clothes_s.Blend(new /icon(shoes_icon, "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(suit_icon, "labcoat_gen_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-gen"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(VIROLOGIST)
					clothes_s = new /icon(uniform_icon, "virologywhite_s")
					clothes_s.Blend(new /icon(shoes_icon, "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "sterile"), ICON_OVERLAY)
					clothes_s.Blend(new /icon(suit_icon, "labcoat_vir_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "medicalpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-vir"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(ROBOTICIST)
					clothes_s = new /icon(uniform_icon, "robotics_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(gloves_icon, "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "toolbox_blue"), ICON_OVERLAY)
					clothes_s.Blend(new /icon(suit_icon, "labcoat_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)

		else if(job_engsec_high)
			switch(job_engsec_high)
				if(CAPTAIN)
					clothes_s = new /icon(uniform_icon, "captain_s")
					clothes_s.Blend(new /icon(shoes_icon, "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "captain"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_OVERLAY)
					clothes_s.Blend(new /icon(suit_icon, "caparmor"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-cap"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(HOS)
					clothes_s = new /icon(uniform_icon, "hosred_s")
					clothes_s.Blend(new /icon(shoes_icon, "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(gloves_icon, "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
					clothes_s.Blend(new /icon(suit_icon, "armor"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "securitypack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-sec"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(WARDEN)
					clothes_s = new /icon(uniform_icon, "warden_s")
					clothes_s.Blend(new /icon(shoes_icon, "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(gloves_icon, "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
					clothes_s.Blend(new /icon(suit_icon, "armor"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "securitypack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-sec"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(DETECTIVE)
					clothes_s = new /icon(uniform_icon, "detective_s")
					clothes_s.Blend(new /icon(shoes_icon, "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(gloves_icon, "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "detective"), ICON_OVERLAY)
					clothes_s.Blend(new /icon(suit_icon, "detective"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(OFFICER)
					clothes_s = new /icon(uniform_icon, "secred_s")
					clothes_s.Blend(new /icon(shoes_icon, "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
					clothes_s.Blend(new /icon(suit_icon, "armor"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "securitypack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-sec"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(CHIEF)
					clothes_s = new /icon(uniform_icon, "chief_s")
					clothes_s.Blend(new /icon(shoes_icon, "brown"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(gloves_icon, "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_white"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "engiepack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-eng"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(ENGINEER)
					clothes_s = new /icon(uniform_icon, "engine_s")
					clothes_s.Blend(new /icon(shoes_icon, "orange"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_yellow"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "engiepack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-eng"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(ATMOSTECH)
					clothes_s = new /icon(uniform_icon, "atmos_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon(gloves_icon, "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon(back_icon, "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)

				if(AI)//Gives AI and borgs assistant-wear, so they can still customize their character
					clothes_s = new /icon(uniform_icon, "grey_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					if(backbag == 2)
						clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
					else if(backbag == 3 || backbag == 4)
						clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
				if(CYBORG)
					clothes_s = new /icon(uniform_icon, "grey_s")
					clothes_s.Blend(new /icon(shoes_icon, "black"), ICON_UNDERLAY)
					if(backbag == 2)
						clothes_s.Blend(new /icon(back_icon, "backpack"), ICON_OVERLAY)
					else if(backbag == 3 || backbag == 4)
						clothes_s.Blend(new /icon(back_icon, "satchel"), ICON_OVERLAY)
*/
		if(disabilities & NEARSIGHTED)
			if(g == "f")
				preview_icon.Blend(new /icon('icons/mob/eyes_f.dmi', "glasses"), ICON_OVERLAY)
			else
				preview_icon.Blend(new /icon('icons/mob/eyes.dmi', "glasses"), ICON_OVERLAY)

		preview_icon.Blend(eyes_s, ICON_OVERLAY)
		preview_icon_front = new(preview_icon, dir = SOUTH)
		preview_icon_side = new(preview_icon, dir = WEST)

		qdel(eyes_s)