FleeMons:
; referenced by TryEnemyFlee and FastBallMultiplier

; Porygon was deliberately removed from SometimesFleeMons: vanilla Crystal
; has no wild Porygon encounter for this to ever matter, but the Transfer
; Network vignette adds the first one, and a quest reward that can just run
; away is a bad myth. See maps/TransferNetworkDeepNode.asm.

SometimesFleeMons:
	db MAGNEMITE
	db GRIMER
	db TANGELA
	db MR__MIME
	db EEVEE
	db DRATINI
	db DRAGONAIR
	db TOGETIC
	db UMBREON
	db UNOWN
	db SNUBBULL
	db HERACROSS
	db -1

OftenFleeMons:
	db CUBONE
	db ARTICUNO
	db ZAPDOS
	db MOLTRES
	db QUAGSIRE
	db DELIBIRD
	db PHANPY
	db TEDDIURSA
	db -1

AlwaysFleeMons:
	db RAIKOU
	db ENTEI
	db -1
