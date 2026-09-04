	object_const_def
	const TRANSFERNETWORKDEEPNODE_BACK_DOORWAY
	const TRANSFERNETWORKDEEPNODE_SOURCE

TransferNetworkDeepNode_MapScripts:
	def_scene_scripts

	def_callbacks

TransferNetworkDeepNodeSighting:
	jumptext TransferNetworkDeepNodeSightingText

TransferNetworkDeepNodeBackDoorwayScript:
	opentext
	writetext TransferNetworkDeepNodeBackDoorwayText
	waitbutton
	closetext
	warp TRANSFER_NETWORK_BLOCKADE, 3, 9
	end

TransferNetworkDeepNodeSource:
	checkevent EVENT_FOUGHT_PORYGON
	iftrue .Empty
	opentext
	writetext TransferNetworkDeepNodeApproachText
	waitbutton
	closetext
	sjump TransferNetworkDeepNodePorygonBattleScript

.Empty:
	opentext
	writetext TransferNetworkDeepNodeEmptyText
	waitbutton
	closetext
	end

TransferNetworkDeepNodePorygonBattleScript:
	loadwildmon PORYGON, 20
	startbattle
	ifequal DRAW, TransferNetworkDeepNodePorygonFledScript
	setevent EVENT_FOUGHT_PORYGON
	reloadmapafterbattle
	end

TransferNetworkDeepNodePorygonFledScript:
	reloadmapafterbattle
	end

TransferNetworkDeepNodeSightingText:
	text "Something sweeps"
	line "the far wall,"
	cont "corner to corner."

	para "Searching."

	para "Not for you. Not"
	line "yet."
	done

TransferNetworkDeepNodeBackDoorwayText:
	text "The way back up is"
	line "still open."
	done

TransferNetworkDeepNodeApproachText:
	text "Something is coiled"
	line "up ahead. Not"
	cont "moving."

	para "Watching, maybe."

	para "It doesn't look"
	line "like it wants to"
	cont "be found."
	done

TransferNetworkDeepNodeEmptyText:
	text "It's gone quiet."

	para "That won't last."

	para "You should go."
	done

TransferNetworkDeepNode_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_coord_events

	def_bg_events
	bg_event  2,  4, BGEVENT_READ, TransferNetworkDeepNodeSighting

	def_object_events
	object_event  4,  8, SPRITE_FAMICOM, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, TransferNetworkDeepNodeBackDoorwayScript, -1
	object_event  5,  1, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, TransferNetworkDeepNodeSource, -1
