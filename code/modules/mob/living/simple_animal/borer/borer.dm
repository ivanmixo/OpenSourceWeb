
/mob/living/simple_animal/borer
	name = "cortical borer"
	real_name = "cortical borer"
	desc = "A small, quivering sluglike creature."
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	response_help  = "pokes"
	response_disarm = "prods the"
	response_harm   = "stomps on the"
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 5
	a_intent = "harm"
	stop_automated_movement = 1
//	status_flags = CANPUSH
	attacktext = "nips"
	friendly = "prods"
	wander = 0
	pass_flags = PASSTABLE
	universal_understand = 1

	var/used_dominate
	var/chemicals = 10                      // Chemicals used for reproduction and spitting neurotoxin.
	var/mob/living/carbon/human/host        // Human host for the brain worm.
	var/truename                            // Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
	var/controlling                         // Used in human death check.
	var/docile = 0                          // Sugar can stop borers from acting.
	var/has_reproduced
	var/roundstart
	var/last_host = null

/mob/living/simple_animal/borer/roundstart
	roundstart = 1

/mob/living/simple_animal/borer/New()
	..()

	add_language("Cortical Link")
	src.verbs += /mob/living/proc/ventcrawl
	src.verbs += /mob/living/proc/hide

	truename = "[pick("Primary","Secondary","Tertiary","Quaternary")] [rand(1000,9999)]"
	if(!roundstart) request_player()

/mob/living/simple_animal/borer/Life()

	..()

	if(host)

		if(!stat && !host.stat)

			if(host.reagents && host.reagents.has_reagent("sugar"))
				if(!docile)
					if(controlling)
						host << "\blue You feel the soporific flow of sugar in your host's blood, lulling you into docility."
					else
						src << "\blue You feel the soporific flow of sugar in your host's blood, lulling you into docility."
					docile = 1
			else
				if(docile)
					if(controlling)
						host << "\blue You shake off your lethargy as the sugar leaves your host's blood."
					else
						src << "\blue You shake off your lethargy as the sugar leaves your host's blood."
					docile = 0

			if(chemicals < 250 && !controlling)
				chemicals++
			if(controlling)
				if(chemicals < 10)
					var/mob/living/simple_animal/borer/B = src.host.has_brain_worms()

					src << "\red <B>You no longer have the strength to control the host</B>"
					B.host_brain << "\red <B>Your vision swims as the alien parasite releases control of your body.</B>"
					src.ckey = src.host.ckey
					B.controlling = 0
					if(B.host_brain.ckey)
						src.host.ckey = B.host_brain.ckey
						B.host_brain.ckey = null
						B.host_brain.name = "host brain"
						B.host_brain.real_name = "host brain"

						src.host.verbs -= /mob/living/carbon/proc/release_control
						src.host.verbs -= /mob/living/carbon/proc/punish_host
						src.host.verbs -= /mob/living/carbon/proc/spawn_larvae
				chemicals--

				if(docile)
					host << "\blue You are feeling far too docile to continue controlling your host..."
					host.release_control()
					return

				if(prob(5))
					host.adjustBrainLoss(rand(1,2))

				if(prob(host.brainloss/20))
					host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")

/mob/living/simple_animal/borer/proc/detatch()

	if(!host || !controlling) return

	if(istype(host,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = host
		var/datum/organ/external/head = H.get_organ("head")
		head.implants -= src

	controlling = 0

	host.remove_language("Cortical Link")
	host.verbs -= /mob/living/carbon/proc/release_control
	host.verbs -= /mob/living/carbon/proc/punish_host
	host.verbs -= /mob/living/carbon/proc/spawn_larvae

	if(host_brain)

		// these are here so bans and multikey warnings are not triggered on the wrong people when ckey is changed.
		// computer_id and IP are not updated magically on their own in offline mobs -walter0o

		// host -> self
		var/h2s_id = host.computer_id
		var/h2s_ip= host.lastKnownIP
		host.computer_id = null
		host.lastKnownIP = null

		src.ckey = host.ckey

		if(!src.computer_id)
			src.computer_id = h2s_id

		if(!host_brain.lastKnownIP)
			src.lastKnownIP = h2s_ip

		// brain -> host
		var/b2h_id = host_brain.computer_id
		var/b2h_ip= host_brain.lastKnownIP
		host_brain.computer_id = null
		host_brain.lastKnownIP = null

		host.ckey = host_brain.ckey

		if(!host.computer_id)
			host.computer_id = b2h_id

		if(!host.lastKnownIP)
			host.lastKnownIP = b2h_ip

	qdel(host_brain)

/mob/living/simple_animal/borer/proc/leave_host()

	if(!host) return

	if(host.mind)
		//If they're not a proper traitor, reset their antag status.
		if(host.mind.special_role == "Borer Thrall")
			host << "<span class ='danger'>You are no longer an antagonist.</span>"
			ticker.mode.borers -= host.mind
			host.mind.special_role = null

	src.loc = get_turf(host)

	reset_view(null)
	machine = null

	host.reset_view(null)
	host.machine = null

	var/mob/living/H = host
	H.status_flags &= ~PASSEMOTES
	host = null
	return

//Procs for grabbing players.
/mob/living/simple_animal/borer/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(jobban_isbanned(O, "Syndicate"))
			continue
		if(O.client)
			if(O.client.prefs.be_special & BE_ALIEN)
				question(O.client)

/mob/living/simple_animal/borer/proc/question(var/client/C)
	spawn(0)
		if(!C)	return
		var/response = alert(C, "A cortical borer needs a player. Are you interested?", "Cortical borer request", "Yes", "No", "Never for this round")
		if(!C || ckey)
			return
		if(response == "Yes")
			transfer_personality(C)
		else if (response == "Never for this round")
			C.prefs.be_special ^= BE_ALIEN

/mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)

	if(!candidate)
		return

	src.ckey = candidate.ckey
	if(src.mind)
		src.mind.make_Borer()
		log_admin("New borer: ", src.ckey)
	/*	src.mind.assigned_role = "Cortical Borer"
		src.mind.special_role = "Cortical Borer"
		ticker.mode.borers |= src.mind
		*/

/mob/living/simple_animal/borer/can_use_vents()
	return

/mob/living/simple_animal/borer/proc/enter_host(mob/living/carbon/host)
	if(host.has_brain_worms())
		return 0

	src.last_host = host.name
	src.host = host
	src.host.status_flags |= PASSEMOTES
	src.loc = host

	if(client) client.eye = host

	return 1

/mob/living/simple_animal/borer/emote(var/message)
	return

/mob/living/simple_animal/mouse/can_use_vents()
	return 1

/mob/proc/clearHUD()
	if(client)
		client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask, global_hud.g_dither, global_hud.r_dither, global_hud.gray_dither, global_hud.lp_dither)
		update_action_buttons()
