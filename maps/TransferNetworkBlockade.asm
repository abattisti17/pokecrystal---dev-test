	object_const_def
	const TRANSFERNETWORKBLOCKADE_BACK_DOORWAY
	const TRANSFERNETWORKBLOCKADE_DEEPER_DOORWAY
	const TRANSFERNETWORKBLOCKADE_ULTRA_BALL
	const TRANSFERNETWORKBLOCKADE_REVIVE
	const TRANSFERNETWORKBLOCKADE_ETHER
	const TRANSFERNETWORKBLOCKADE_TM_SWIFT

TransferNetworkBlockade_MapScripts:
	def_scene_scripts

	def_callbacks

TransferNetworkBlockadeSign1:
	jumptext TransferNetworkBlockadeSign1Text

TransferNetworkBlockadeSign2:
	jumptext TransferNetworkBlockadeSign2Text

TransferNetworkBlockadeSign3:
	jumptext TransferNetworkBlockadeSign3Text

TransferNetworkBlockadeBackDoorwayScript:
	opentext
	writetext TransferNetworkBlockadeBackDoorwayText
	waitbutton
	closetext
	warp TRANSFER_NETWORK_ENTRY, 4, 5
	end

TransferNetworkBlockadeDeeperDoorwayScript:
	opentext
	writetext TransferNetworkBlockadeDeeperDoorwayText
	waitbutton
	closetext
	warp TRANSFER_NETWORK_DEEP_NODE, 4, 9
	end

TransferNetworkBlockadeUltraBall:
	itemball ULTRA_BALL

TransferNetworkBlockadeRevive:
	itemball REVIVE

TransferNetworkBlockadeEther:
	itemball ETHER

TransferNetworkBlockadeTMSwift:
	itemball TM_SWIFT

TransferNetworkBlockadeSign1Text:
	text "A #BALL, held"
	line "in place mid-"
	cont "transfer."

	para "Whatever was in-"
	line "side is still in"
	cont "there. Waiting."
	done

TransferNetworkBlockadeSign2Text:
	text "Another #BALL."

	para "A name is stamped"
	line "on this one. Some-"
	cont "one is missing a"
	cont "#MON right now."
	done

TransferNetworkBlockadeSign3Text:
	text "Dozens more, stuck"
	line "the same way."

	para "None of them are"
	line "going anywhere on"
	cont "their own."
	done

TransferNetworkBlockadeBackDoorwayText:
	text "The way back up is"
	line "still open."
	done

TransferNetworkBlockadeDeeperDoorwayText:
	text "The corridor drops"
	line "away here."

	para "Whatever is jam-"
	line "ming the line is"
	cont "further down."
	done

TransferNetworkBlockade_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_coord_events

	def_bg_events
	bg_event  2,  4, BGEVENT_READ, TransferNetworkBlockadeSign1
	bg_event  7,  1, BGEVENT_READ, TransferNetworkBlockadeSign2
	bg_event  6,  5, BGEVENT_READ, TransferNetworkBlockadeSign3

	def_object_events
	object_event  4,  5, SPRITE_FAMICOM, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, TransferNetworkBlockadeBackDoorwayScript, -1
	object_event  6,  1, SPRITE_FAMICOM, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, TransferNetworkBlockadeDeeperDoorwayScript, -1
	object_event  1,  6, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, TransferNetworkBlockadeUltraBall, EVENT_TRANSFER_NETWORK_ITEM_ULTRA_BALL
	object_event  2,  6, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, TransferNetworkBlockadeRevive, EVENT_TRANSFER_NETWORK_ITEM_REVIVE
	object_event  5,  6, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, TransferNetworkBlockadeEther, EVENT_TRANSFER_NETWORK_ITEM_ETHER
	object_event  6,  7, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, TransferNetworkBlockadeTMSwift, EVENT_TRANSFER_NETWORK_TM_SWIFT
