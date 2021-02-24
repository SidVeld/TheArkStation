/datum/computer_file/program/hotel_reservations
	filename = "hotelreservations"
	filedesc = "Hotel Reservations Management"
	nanomodule_path = /datum/nano_module/hotel_reservations
	ui_header = "alarm_green.gif"
	program_icon_state = "crew"
	program_key_state = "generic_key"
	program_menu_icon = "calendar"
	extended_desc = "This program connects to the hotel reservations system and enables it to be managed."
	required_access = "ACCESS_LIBERTY_HOTEL"
	requires_ntnet = 1
	network_destination = "hotel reservations database"
	size = 11
	category = PROG_UTIL

/datum/nano_module/hotel_reservations

	var/program_mode = 1 // 0 - error, 1 - room list, 2 - specific room info, 3 - room logs, 4 - new reservation, 5 - reservation extension
	var/program_auto_mode = 0 // 0 - manual reservations, 1 - automatic reservations

	var/datum/hotel_room/selected_room

	var/obj/machinery/computer/hotel_terminal/connected_terminal

/datum/nano_module/hotel_reservations/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = GLOB.default_state)

	setup_hotel_rooms() // The proc does check if the rooms have already been set up

	var/list/hotel_single_room_list = new
	var/list/hotel_double_room_list = new
	var/list/hotel_special_room_list = new

	var/list/hotel_selected_room = new

	var/list/data = host.initial_data()

	for(var/datum/hotel_room/R in GLOB.hotel_rooms)

		if (R == selected_room)
			if (R.room_status == 0)
				give_error()
			hotel_selected_room = list(
				"number" = R.room_number,
				"status" = R.room_status,
				"special" = R.special_room,
				"requests" = R.room_requests,
				"beds" = R.bed_count,
				"capacity" = R.guest_count,
				"price" = R.hourly_price,
				"guests" = R.room_guests2text(),
				"guests_as_list" = R.room_guests,
				"start" = R.room_reservation_start_time,
				"end" = R.room_reservation_end_time,
				"room_logs" = R.room_log
			)
			continue

		if (R.special_room)
			hotel_special_room_list.Add(list(list("room" = list(
				"number" = R.room_number,
				"status" = R.room_status,
				"requests" = R.room_requests,
				"beds" = R.bed_count,
				"capacity" = R.guest_count,
				"price" = R.hourly_price,
				"end" = R.room_reservation_end_time
			))))
			continue

		if (R.guest_count == 2)
			hotel_double_room_list.Add(list(list("room" = list(
				"number" = R.room_number,
				"status" = R.room_status,
				"requests" = R.room_requests,
				"beds" = R.bed_count,
				"capacity" = R.guest_count,
				"price" = R.hourly_price,
				"end" = R.room_reservation_end_time
			))))
			continue

		if (R.guest_count == 1)
			hotel_single_room_list.Add(list(list("room" = list(
				"number" = R.room_number,
				"status" = R.room_status,
				"requests" = R.room_requests,
				"beds" = R.bed_count,
				"capacity" = R.guest_count,
				"price" = R.hourly_price,
				"end" = R.room_reservation_end_time
			))))
			continue

	data["mode"] = program_mode
	data["auto_mode"] = program_auto_mode
	data["single_rooms"] = hotel_single_room_list
	data["double_rooms"] = hotel_double_room_list
	data["special_rooms"] = hotel_special_room_list
	data["selected_room"] = hotel_selected_room
	data["station_time"] = stationtime2text()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "hotel.tmpl", "Hotel Reservations System", 390, 500, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/hotel_reservations/Topic(href, href_list)
	if (..())
		return 1

	if (href_list["room_select"])
		for (var/datum/hotel_room/R in GLOB.hotel_rooms)
			if (R.room_number == href_list["room_select"])
				program_mode = 2
				selected_room = R
				return 1

	if (href_list["return_to_main"])
		program_mode = 1
		selected_room = null
		return 1

	if (href_list["return_to_room"])
		if(program_mode == 4)
			if(alert("This will erase the reservation. Are you sure?",,"Yes","No")=="No")
				return 1
			else
				selected_room.clear_reservation()
		program_mode = 2
		return 1

	if (href_list["room_block"])
		selected_room.room_block()
		return 1

	if (href_list["room_unblock"])
		selected_room.room_unblock()
		return 1

	if (href_list["room_reset"])
		selected_room.room_reset()
		return 1

	if (href_list["room_logs"])
		program_mode = 3
		return 1

	if (href_list["print_logs"])
		var/text_to_print = "<b>Room [selected_room.room_number] logs:</b><br><br>"
		for (var/log_entry in selected_room.room_log)
			text_to_print += "[log_entry]<br>"
		text_to_print += "<hr><i>Printed at [stationtime2text()]</i>"
		print_text(text_to_print, usr)
		return 1

	if (href_list["room_reserve"])
		if(selected_room.room_status != 1 || !connected_terminal)
			return 1
		selected_room.room_status = 2
		program_mode = 4
		return 1

	if (href_list["room_cancel"])
		selected_room.clear_reservation()
		return 1

/datum/nano_module/hotel_reservations/proc/give_error()
	if(!selected_room)
		return
	selected_room.clear_reservation(auto_clear = 1)
	selected_room = null
	program_mode = 0