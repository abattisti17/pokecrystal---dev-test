	object_const_def
	const TRANSFERNETWORKENTRY_BACK_DOORWAY

TransferNetworkEntry_MapScripts:
	def_scene_scripts

	def_callbacks

TransferNetworkEntryHum:
	jumptext TransferNetworkEntryHumText

TransferNetworkEntryGlimpse:
	jumptext TransferNetworkEntryGlimpseText

TransferNetworkEntryBackDoorwayScript:
	opentext
	writetext TransferNetworkEntryBackDoorwayText
	waitbutton
	closetext
	warp BILLS_HOUSE, 5, 4
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

TransferNetworkEntryBackDoorwayText:
	text "The way back up is"
	line "still open."
	done

TransferNetworkEntry_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 11, TRANSFER_NETWORK_BLOCKADE, 1
	warp_event  5, 11, TRANSFER_NETWORK_BLOCKADE, 1

	def_coord_events

	def_bg_events
	bg_event  4,  4, BGEVENT_READ, TransferNetworkEntryHum
	bg_event  6,  4, BGEVENT_READ, TransferNetworkEntryGlimpse

	def_object_events
	object_event  2,  3, SPRITE_FAMICOM, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, TransferNetworkEntryBackDoorwayScript, -1
