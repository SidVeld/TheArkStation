// Hotel room presets

/hotel_room_preset
	var/room_number
	var/bed_count
	var/guest_count // Do not set if corresponds to the number of beds
	var/hourly_price
	var/special_room = 0 // It indicates if the room can be reserved only through an employee

/hotel_room_preset/one_zero_one
	room_number = "101"
	bed_count = 1
	hourly_price = 123

/hotel_room_preset/one_zero_two
	room_number = "102"
	bed_count = 1
	hourly_price = 123

/hotel_room_preset/one_zero_three
	room_number = "103"
	bed_count = 1
	hourly_price = 123

/hotel_room_preset/one_zero_four
	room_number = "104"
	bed_count = 1
	hourly_price = 123

/hotel_room_preset/two_zero_one
	room_number = "201"
	bed_count = 2
	hourly_price = 223

/hotel_room_preset/two_zero_two
	room_number = "202"
	bed_count = 2
	hourly_price = 223

/hotel_room_preset/three_zero_one
	room_number = "301"
	bed_count = 1
	guest_count = 2
	hourly_price = 323

/hotel_room_preset/three_zero_two
	room_number = "302"
	bed_count = 1
	guest_count = 2
	hourly_price = 323

/hotel_room_preset/three_zero_three
	room_number = "303"
	bed_count = 1
	guest_count = 2
	hourly_price = 323

/hotel_room_preset/penthouse
	room_number = "Penthouse"
	bed_count = 1
	guest_count = 2
	hourly_price = 423
	special_room = 1

GLOBAL_LIST_INIT(hotel_room_presets, list(			// Make sure any rooms you've created above are added to this list and vice versa,
	"101" = /hotel_room_preset/one_zero_one,
	"102" = /hotel_room_preset/one_zero_two,
	"103" = /hotel_room_preset/one_zero_three,
	"104" = /hotel_room_preset/one_zero_four,
	"201" = /hotel_room_preset/two_zero_one,
	"202" = /hotel_room_preset/two_zero_two,
	"301" = /hotel_room_preset/three_zero_one,
	"302" = /hotel_room_preset/three_zero_two,
	"303" = /hotel_room_preset/three_zero_three,
	"Penthouse" = /hotel_room_preset/penthouse
))

GLOBAL_LIST_EMPTY(hotel_rooms)

/proc/setup_hotel_rooms()
	if (!LAZYLEN(GLOB.hotel_rooms))
		var/rooms_list = GLOB.hotel_room_presets
		for(var/room_number in rooms_list)
			var/hotel_room_preset_path = rooms_list[room_number]
			GLOB.hotel_rooms += new/datum/hotel_room(room_number, hotel_room_preset_path)

// Defining room datums

/datum/hotel_room
	var/room_number
	var/bed_count
	var/guest_count
	var/hourly_price
	var/special_room

	var/room_status = 0 // 0 - broken, 1 - available, 2 - occupied (or reservation in progress), 3 - blocked
	var/room_requests = 0 // 0 - nothing, 1 - do not disturb, 2 - make up the room, 3 - room turnover (set automatically at the end of the reservation)
	var/list/room_keys = list()
	var/list/room_guests = list()
	var/room_reservation_start_time
	var/room_reservation_end_time

	var/list/room_log = list()

	var/obj/machinery/hotel_room_sign/room_sign
	var/obj/machinery/computer/hotel_room_controller/room_controller
	var/obj/machinery/door/airlock/room_airlock

/datum/hotel_room/New(var/room_number, var/hotel_room_preset_path)
	src.room_number = room_number
	if(ispath(hotel_room_preset_path, /hotel_room_preset))
		var/hotel_room_preset/hotel_room_preset = decls_repository.get_decl(hotel_room_preset_path)
		src.bed_count = hotel_room_preset.bed_count
		if(hotel_room_preset.guest_count)
			src.guest_count = hotel_room_preset.guest_count
		else
			src.guest_count = hotel_room_preset.bed_count
		src.hourly_price = hotel_room_preset.hourly_price
		src.special_room = hotel_room_preset.special_room

		for(var/obj/machinery/hotel_room_sign/S in world)
			if (S.id_tag == "room_[room_number]_sign")
				room_sign = S
				break
		if(!room_sign)
			crash_with("A hotel room ([room_number]) is unable to find its sign!")

		for(var/obj/machinery/computer/hotel_room_controller/C in world)
			if (C.id_tag == "room_[room_number]_controller")
				room_controller = C
				break
		if(!room_controller)
			crash_with("A hotel room ([room_number]) is unable to find its controller!")

		for(var/obj/machinery/door/airlock/A in world)
			if (A.id_tag == "room_[room_number]_airlock")
				room_airlock = A
				break
		if(!room_airlock)
			crash_with("A hotel room ([room_number]) is unable to find its door!")

	else
		crash_with("A hotel room preset ([room_number]) is incorrect!")

	room_airlock.autoset_access = 0
	room_airlock.req_access = list(list("ACCESS_LIBERTY_HOTEL", "ACCESS_LIBERTY_ROOM_[room_number]"))
	room_controller.hotel_room = src
	room_sign.hotel_room = src

	room_status = 1

	room_test_n_update()

/datum/hotel_room/proc/room_test_n_update()
	var/room_is_broken = 0

	if (!istype(room_sign))
		room_sign = null
		room_is_broken = 1
	else
		room_sign.update_icon()

	if (!istype(room_controller))
		room_controller = null
		room_is_broken = 1
	else
		room_controller.update_icon()

	if (!istype(room_airlock))
		room_airlock = null
		room_is_broken = 1

	if (room_is_broken && room_status)
		clear_reservation()
		room_status = 0
		room_requests = 0

	if (room_status == 0)
		return 0
	else
		return 1

/datum/hotel_room/proc/room_guests2text()
	var/room_guest_list = ""
	if(room_status == 2)
		var/N = 0
		if(room_guests.len)
			for(var/guest_name in room_guests)
				room_guest_list += "[guest_name]"
				N += 1
				if (N < room_guests.len)
					room_guest_list += ", "
		else
			room_guest_list = "none"
	return room_guest_list

/datum/hotel_room/proc/get_user_id_name()				// Used for logging
	if(istype(usr, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = usr
		return H.get_id_name("unknown")
	else
		return "unknown"

/datum/hotel_room/proc/room_block()
	room_status = 3
	var/log_entry = "\[[stationtime2text()]\] The room was blocked by [get_user_id_name()]."

	room_log.Add(log_entry)
	room_test_n_update()

/datum/hotel_room/proc/room_unblock()
	if(room_requests != 3)
		room_status = 1
		var/log_entry = "\[[stationtime2text()]\] The room was unblocked by [get_user_id_name()]."

		room_log.Add(log_entry)
	room_test_n_update()

/datum/hotel_room/proc/room_reset()
	var/log_entry
	if(room_requests > 1)
		log_entry = "\[[stationtime2text()]\] The room was reset by [get_user_id_name()]. "
		room_requests = 0
		if(room_status == 3)
			log_entry += "Room turnover was marked as complete. Reservation available."
			room_status = 1
		else
			log_entry += "Make up request was marked as fulfilled."

	room_log.Add(log_entry)
	room_test_n_update()

/datum/hotel_room/proc/clear_reservation(var/auto_clear = 0)

	if(room_status != 2 && room_status != 0)
		return

	var/log_entry
	if(room_reservation_end_time && room_status == 2) // Reservation end time serves as an indicator if the reservation has been completed
		if(auto_clear)
			log_entry = "\[[stationtime2text()]\] An active room reservation ended. Keycards of the following guests were rendered expired automatically: [room_guests2text()]. Room turnover required."
		else
			log_entry = "\[[stationtime2text()]\] An active room reservation was canceled by [get_user_id_name()]. Keycards of the following guests were rendered invalid: [room_guests2text()]. Room turnover required."
		room_status = 3
		room_requests = 3
	else
		if (room_reservation_end_time && room_status == 0)
			log_entry = "\[[stationtime2text()]\] An active room reservation was automatically cancelled due to a fatal error! Keycards of the following guests were rendered invalid: [room_guests2text()]. Room unusable."
		else
			if(auto_clear)
				log_entry = "\[[stationtime2text()]\] Room reservation process was automatically terminated due to a"
				if(room_status)
					log_entry += " timeout. Room reset."
					room_status = 1
				else
					log_entry += " fatal room error."
			else
				log_entry = "\[[stationtime2text()]\] Room reservation process was terminated by [get_user_id_name()]. Room reset."
				room_status = 1
	room_log.Add(log_entry)


	room_reservation_start_time = null
	room_reservation_end_time = null
	for(var/obj/item/weapon/card/id/hotel_key/K in room_keys)
		K.expire()
	room_keys = list()
	room_guests = list()

	room_test_n_update()
