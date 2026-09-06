	object_const_def
	const TRANSFERNETWORKDEEPNODE_SOURCE

TransferNetworkDeepNode_MapScripts:
	def_scene_scripts

	def_callbacks

TransferNetworkDeepNodeSighting:
	jumptext TransferNetworkDeepNodeSightingText

TransferNetworkDeepNodeExitSign:
	jumptext TransferNetworkDeepNodeExitSignText

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

TransferNetworkDeepNodeExitSignText:
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
	warp_event  4,  3, TRANSFER_NETWORK_BLOCKADE, 3
	warp_event  6, 15, TRANSFER_NETWORK_BLOCKADE, 2
	warp_event  7, 15, TRANSFER_NETWORK_BLOCKADE, 2

	def_coord_events

	def_bg_events
	bg_event  3,  4, BGEVENT_READ, TransferNetworkDeepNodeSighting
	bg_event  7, 14, BGEVENT_READ, TransferNetworkDeepNodeExitSign

	def_object_events
	object_event  4, 10, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, TransferNetworkDeepNodeSource, -1
