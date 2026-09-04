	object_const_def
	const TRANSFERNETWORKENTRY_DOORWAY

TransferNetworkEntry_MapScripts:
	def_scene_scripts

	def_callbacks

TransferNetworkEntryHum:
	jumptext TransferNetworkEntryHumText

TransferNetworkEntryGlimpse:
	jumptext TransferNetworkEntryGlimpseText

TransferNetworkEntryCorridor:
	jumptext TransferNetworkEntryCorridorText

TransferNetworkEntryDoorwayScript:
	opentext
	writetext TransferNetworkEntryDoorwayText
	waitbutton
	closetext
	warp TRANSFER_NETWORK_BLOCKADE, 2, 5
	end

TransferNetworkEntryHumText:
	text "The walls are"
	line "humming. Low and"
	cont "steady."
	done

TransferNetworkEntryGlimpseText:
	text "Something moved,"
	line "just past the"
	cont "edge of sight."

	para "It didn't stop to"
	line "look at you."
	done

TransferNetworkEntryCorridorText:
	text "The corridor bends"
	line "and rejoins itself"
	cont "up ahead."

	para "None of the angles"
	line "are quite right."
	done

TransferNetworkEntryDoorwayText:
	text "The corridor keeps"
	line "going from here."
	done

TransferNetworkEntry_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, ROUTE_25, 1
	warp_event  3,  7, ROUTE_25, 1

	def_coord_events

	def_bg_events
	bg_event  6,  5, BGEVENT_READ, TransferNetworkEntryHum
	bg_event  7,  4, BGEVENT_READ, TransferNetworkEntryGlimpse
	bg_event  7,  1, BGEVENT_READ, TransferNetworkEntryCorridor

	def_object_events
	object_event  6,  1, SPRITE_FAMICOM, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, TransferNetworkEntryDoorwayScript, -1
