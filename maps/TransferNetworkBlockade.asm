	object_const_def
	const TRANSFERNETWORKBLOCKADE_BACK_DOORWAY
	const TRANSFERNETWORKBLOCKADE_REVIVE
	const TRANSFERNETWORKBLOCKADE_ETHER
	const TRANSFERNETWORKBLOCKADE_TM_SWIFT

TransferNetworkBlockade_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_TILES, TransferNetworkBlockadeBreachCallback

TransferNetworkBlockadeBreachCallback:
	checkevent EVENT_TRANSFER_NETWORK_BREACH_OPENED
	iftrue .Open
	endcallback

.Open:
	changeblock 8, 6, $07 ; floor -- the breach stays clear
	endcallback

TransferNetworkBlockadeSign1:
	jumptext TransferNetworkBlockadeSign1Text

TransferNetworkBlockadeSign2:
	jumptext TransferNetworkBlockadeSign2Text

TransferNetworkBlockadeBreach:
	checkevent EVENT_TRANSFER_NETWORK_BREACH_OPENED
	iftrue .Open
	opentext
	writetext TransferNetworkBlockadeBreachText
	waitbutton
	closetext
	setevent EVENT_TRANSFER_NETWORK_BREACH_OPENED
	changeblock 8, 6, $07 ; floor -- clears a way through
	reloadmap

.Open:
	jumptext TransferNetworkBlockadeBreachOpenText

TransferNetworkBlockadeBackDoorwayScript:
	opentext
	writetext TransferNetworkBlockadeBackDoorwayText
	waitbutton
	closetext
	warp TRANSFER_NETWORK_ENTRY, 4, 9
	end

TransferNetworkBlockadeRevive:
	itemball REVIVE

TransferNetworkBlockadeEther:
	itemball ETHER

TransferNetworkBlockadeTMSwift:
	itemball TM_SWIFT

TransferNetworkBlockadeSign1Text:
	text "Someone's #MON"
	line "was mid-transfer"
	cont "when this froze."

	para "Their supplies"
	line "went nowhere too."
	done

TransferNetworkBlockadeSign2Text:
	text "Dozens of records,"
	line "stuck the same way."

	para "None of them are"
	line "going anywhere on"
	cont "their own."
	done

TransferNetworkBlockadeBreachText:
	text "A single line is"
	line "still live here."

	para "Something pushes"
	line "back, then gives"
	cont "way all at once."
	done

TransferNetworkBlockadeBreachOpenText:
	text "The line stayed"
	line "open behind you."
	done

TransferNetworkBlockadeBackDoorwayText:
	text "The way back up is"
	line "still open."
	done

TransferNetworkBlockade_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  8,  3, TRANSFER_NETWORK_ENTRY, 1
	warp_event  6,  9, TRANSFER_NETWORK_DEEP_NODE, 1
	warp_event  6, 11, TRANSFER_NETWORK_DEEP_NODE, 1
	warp_event  7, 11, TRANSFER_NETWORK_DEEP_NODE, 1

	def_coord_events

	def_bg_events
	bg_event  3,  4, BGEVENT_READ, TransferNetworkBlockadeSign1
	bg_event 13,  4, BGEVENT_READ, TransferNetworkBlockadeSign2
	bg_event  9,  6, BGEVENT_READ, TransferNetworkBlockadeBreach

	def_object_events
	object_event  7,  2, SPRITE_FAMICOM, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, TransferNetworkBlockadeBackDoorwayScript, -1
	object_event  4,  5, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, TransferNetworkBlockadeRevive, EVENT_TRANSFER_NETWORK_ITEM_REVIVE
	object_event  8,  5, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, TransferNetworkBlockadeEther, EVENT_TRANSFER_NETWORK_ITEM_ETHER
	object_event 12,  5, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, TransferNetworkBlockadeTMSwift, EVENT_TRANSFER_NETWORK_TM_SWIFT
