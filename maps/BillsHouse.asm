	object_const_def
	const BILLSHOUSE_GRAMPS
	const BILLSHOUSE_BILL

BillsHouse_MapScripts:
	def_scene_scripts

	def_callbacks

BillTransferNetworkScript:
	faceplayer
	opentext
	checkevent EVENT_FOUGHT_PORYGON
	iftrue .Cleared
	checkevent EVENT_TRANSFER_NETWORK_EXPLAINED
	iftrue .AlreadyExplained
	writetext BillIntroText
	promptbutton
	writetext BillExplainText
	promptbutton
	writetext BillAskText
	yesorno
	iffalse .Declined
	setevent EVENT_TRANSFER_NETWORK_EXPLAINED
	sjump .SendIn

.AlreadyExplained:
	writetext BillAskAgainText
	yesorno
	iffalse .Declined
	sjump .SendIn

.SendIn:
	writetext BillSendingText
	waitbutton
	closetext
	warp TRANSFER_NETWORK_ENTRY, 4, 5
	end

.Declined:
	writetext BillDeclinedText
	waitbutton
	closetext
	end

.Cleared:
	writetext BillClearedText
	waitbutton
	closetext
	end

BillIntroText:
	text "Oh -- hello."

	para "I'm using GRAMPS'S"
	line "PC to check some-"
	cont "thing."
	done

BillExplainText:
	text "#MON go into"
	line "storage."

	para "Some don't come"
	line "back out."

	para "Not released. Not"
	line "anywhere. Just"
	cont "gone."
	done

BillAskText:
	text "I can send you in"
	line "after them."

	para "It should be safe."
	line "Will you go?"
	done

BillAskAgainText:
	text "Still nothing on"
	line "my end."

	para "Want to go back"
	line "in?"
	done

BillSendingText:
	text "Hold on."

	para "Sending you"
	line "through now."
	done

BillDeclinedText:
	text "All right."

	para "Come back if you"
	line "change your mind."
	done

BillClearedText:
	text "Whatever was jam-"
	line "ming the line is"
	cont "gone."

	para "Thank you. I mean"
	line "that."
	done

BillsGrandpa:
	faceplayer
	opentext
	checkevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	iftrue .JustShowedSomething
	checkevent EVENT_GOT_THUNDERSTONE_FROM_BILLS_GRANDPA
	iftrue .GotThunderstone
	checkevent EVENT_MET_BILLS_GRANDPA
	iftrue .MetGrandpa
	writetext BillsGrandpaIntroText
	promptbutton
	setevent EVENT_MET_BILLS_GRANDPA
.MetGrandpa:
	checkevent EVENT_SHOWED_PICHU_TO_BILLS_GRANDPA
	iftrue .ShowedPichu
	checkevent EVENT_SHOWED_GROWLITHE_VULPIX_TO_BILLS_GRANDPA
	iftrue .ShowedGrowlitheVulpix
	checkevent EVENT_SHOWED_STARYU_TO_BILLS_GRANDPA
	iftrue .ShowedStaryu
	checkevent EVENT_SHOWED_ODDISH_TO_BILLS_GRANDPA
	iftrue .ShowedOddish
	checkevent EVENT_SHOWED_LICKITUNG_TO_BILLS_GRANDPA
	iftrue .ShowedLickitung
	writetext BillsGrandpaLickitungText
	promptbutton
	writetext BillsGrandpaAskToSeeMonText
	yesorno
	iffalse .SaidNo
	scall .ExcitedToSee
	special BillsGrandfather
	iffalse .SaidNo
	ifnotequal LICKITUNG, .WrongPokemon
	scall .CorrectPokemon
	setevent EVENT_SHOWED_LICKITUNG_TO_BILLS_GRANDPA
	sjump .ShowedLickitung

.GotEverstone:
	writetext BillsGrandpaOddishText
	promptbutton
	writetext BillsGrandpaAskToSeeMonText
	yesorno
	iffalse .SaidNo
	scall .ExcitedToSee
	special BillsGrandfather
	iffalse .SaidNo
	ifnotequal ODDISH, .WrongPokemon
	scall .CorrectPokemon
	setevent EVENT_SHOWED_ODDISH_TO_BILLS_GRANDPA
	sjump .ShowedOddish

.GotLeafStone:
	writetext BillsGrandpaStaryuText
	promptbutton
	writetext BillsGrandpaAskToSeeMonText
	yesorno
	iffalse .SaidNo
	scall .ExcitedToSee
	special BillsGrandfather
	iffalse .SaidNo
	ifnotequal STARYU, .WrongPokemon
	scall .CorrectPokemon
	setevent EVENT_SHOWED_STARYU_TO_BILLS_GRANDPA
	sjump .ShowedStaryu

.GotWaterStone:
	checkver
	iftrue .AskVulpix
	writetext BillsGrandpaGrowlitheText
	promptbutton
	writetext BillsGrandpaAskToSeeMonText
	yesorno
	iffalse .SaidNo
	scall .ExcitedToSee
	special BillsGrandfather
	iffalse .SaidNo
	ifnotequal GROWLITHE, .WrongPokemon
	scall .CorrectPokemon
	setevent EVENT_SHOWED_GROWLITHE_VULPIX_TO_BILLS_GRANDPA
	sjump .ShowedGrowlitheVulpix

.AskVulpix:
	writetext BillsGrandpaVulpixText
	promptbutton
	writetext BillsGrandpaAskToSeeMonText
	yesorno
	iffalse .SaidNo
	scall .ExcitedToSee
	special BillsGrandfather
	iffalse .SaidNo
	ifnotequal VULPIX, .WrongPokemon
	scall .CorrectPokemon
	setevent EVENT_SHOWED_GROWLITHE_VULPIX_TO_BILLS_GRANDPA
	sjump .ShowedGrowlitheVulpix

.GotFireStone:
	writetext BillsGrandpaPichuText
	promptbutton
	writetext BillsGrandpaAskToSeeMonText
	yesorno
	iffalse .SaidNo
	scall .ExcitedToSee
	special BillsGrandfather
	iffalse .SaidNo
	ifnotequal PICHU, .WrongPokemon
	scall .CorrectPokemon
	setevent EVENT_SHOWED_PICHU_TO_BILLS_GRANDPA
	sjump .ShowedPichu

.ShowedLickitung:
	checkevent EVENT_GOT_EVERSTONE_FROM_BILLS_GRANDPA
	iftrue .GotEverstone
	scall .ReceiveItem
	verbosegiveitem EVERSTONE
	iffalse .BagFull
	setevent EVENT_GOT_EVERSTONE_FROM_BILLS_GRANDPA
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	closetext
	end

.ShowedOddish:
	checkevent EVENT_GOT_LEAF_STONE_FROM_BILLS_GRANDPA
	iftrue .GotLeafStone
	scall .ReceiveItem
	verbosegiveitem LEAF_STONE
	iffalse .BagFull
	setevent EVENT_GOT_LEAF_STONE_FROM_BILLS_GRANDPA
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	closetext
	end

.ShowedStaryu:
	checkevent EVENT_GOT_WATER_STONE_FROM_BILLS_GRANDPA
	iftrue .GotWaterStone
	scall .ReceiveItem
	verbosegiveitem WATER_STONE
	iffalse .BagFull
	setevent EVENT_GOT_WATER_STONE_FROM_BILLS_GRANDPA
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	closetext
	end

.ShowedGrowlitheVulpix:
	checkevent EVENT_GOT_FIRE_STONE_FROM_BILLS_GRANDPA
	iftrue .GotFireStone
	scall .ReceiveItem
	verbosegiveitem FIRE_STONE
	iffalse .BagFull
	setevent EVENT_GOT_FIRE_STONE_FROM_BILLS_GRANDPA
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	closetext
	end

.ShowedPichu:
	scall .ReceiveItem
	verbosegiveitem THUNDERSTONE
	iffalse .BagFull
	setevent EVENT_GOT_THUNDERSTONE_FROM_BILLS_GRANDPA
	closetext
	end

.ExcitedToSee:
	writetext BillsGrandpaExcitedToSeeText
	promptbutton
	end

.SaidNo:
	writetext BillsGrandpaYouDontHaveItTextText
	waitbutton
	closetext
	end

.CorrectPokemon:
	writetext BillsGrandpaShownPokemonText
	promptbutton
	end

.ReceiveItem:
	writetext BillsGrandpaTokenOfAppreciationText
	promptbutton
	end

.JustShowedSomething:
	writetext BillsGrandpaComeAgainText
	waitbutton
	closetext
	end

.GotThunderstone:
	writetext BillsGrandpaShownAllThePokemonText
	waitbutton
	closetext
	end

.WrongPokemon:
	writetext BillsGrandpaWrongPokemonText
	waitbutton
	closetext
	end

.BagFull:
	closetext
	end

BillsGrandpaIntroText:
	text "Hm? You know BILL?"
	line "He's my grandson."

	para "He's in JOHTO. He"
	line "does something"

	para "with PCs, so I'm"
	line "house-sitting."
	done

BillsGrandpaAskToSeeMonText:
	text "If you have that"
	line "#MON, may I see"
	cont "it, please?"
	done

BillsGrandpaExcitedToSeeText:
	text "You will show me?"
	line "How good of you!"
	done

BillsGrandpaYouDontHaveItTextText:
	text "You don't have it?"
	line "That's too bad…"
	done

BillsGrandpaShownPokemonText:
	text "Ah, so that is"
	line "@"
	text_ram wStringBuffer3
	text "?"

	para "Isn't it cute!"
	line "That's so kind of"
	cont "you."
	done

BillsGrandpaTokenOfAppreciationText:
	text "Thanks!"

	para "This is a token of"
	line "my appreciation."
	done

BillsGrandpaComeAgainText:
	text "Come visit again"
	line "sometime."
	done

BillsGrandpaShownAllThePokemonText:
	text "Thanks for showing"
	line "me so many cute"
	cont "#MON."

	para "I really enjoyed"
	line "myself. I'm glad"

	para "I've lived such a"
	line "long life."
	done

BillsGrandpaWrongPokemonText:
	text "Hm?"

	para "That's not the"
	line "#MON that I was"
	cont "told about."
	done

BillsGrandpaLickitungText:
	text "My grandson BILL"
	line "told me about a"

	para "#MON that has a"
	line "long tongue."
	done

BillsGrandpaOddishText:
	text "Ah, my grandson"
	line "mentioned a round,"

	para "green #MON that"
	line "has leaves growing"
	cont "on its head."
	done

BillsGrandpaStaryuText:
	text "Do you know of a"
	line "sea #MON that"

	para "has a red sphere"
	line "in its body?"

	para "You know, the one"
	line "that's shaped like"
	cont "a star?"

	para "I heard that it"
	line "appears at night."

	para "I would surely"
	line "like to see it."
	done

BillsGrandpaGrowlitheText:
	text "BILL told me about"
	line "a #MON that is"

	para "very loyal to its"
	line "trainer."

	para "It's supposed to"
	line "ROAR well."
	done

BillsGrandpaVulpixText:
	text "I heard about a"
	line "cute #MON that"
	cont "has six tails."

	para "I would love to"
	line "hug a cute #MON"
	cont "like that."
	done

BillsGrandpaPichuText:
	text "Do you know that"
	line "hugely popular"
	cont "#MON?"

	para "The #MON that"
	line "has a yellow body"
	cont "and red cheeks."

	para "I would love to"
	line "see what it looks"

	para "like before it"
	line "evolves."
	done

BillsHouse_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, ROUTE_25, 1
	warp_event  3,  7, ROUTE_25, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  2,  3, SPRITE_GRAMPS, SPRITEMOVEDATA_STANDING_UP, 0, 2, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, BillsGrandpa, -1
	object_event  5,  3, SPRITE_BILL, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, BillTransferNetworkScript, -1
