; Pokémon: Lost Legends -- dev fast-start configuration
; Only used when building with `make devwarp`. Has no effect on release builds.
; Change these to test a different scene without replaying the intro.

; Which SPAWN_* the fast-start lands you at (see data/maps/spawn_points.asm).
; Vermilion Port is the trunk default (Mew under the crate). Vignette
; branches typically point this at their own entry point while in progress
; -- e.g. SPAWN_TRANSFER_NETWORK_ENTRY for the Transfer Network vignette --
; and are expected to restore SPAWN_VERMILION before merging to master,
; unless a coordinated merge decides otherwise (see BRANCHES.md).
DEF DEVWARP_SPAWN      EQU SPAWN_VERMILION

DEF DEVWARP_SPECIES    EQU CYNDAQUIL  ; the Pokemon you start with
DEF DEVWARP_LEVEL      EQU 25         ; its level
; Starter moveset, written directly into all four slots.
DEF DEVWARP_MOVE_1 EQU FLAMETHROWER
DEF DEVWARP_MOVE_2 EQU SMOKESCREEN
DEF DEVWARP_MOVE_3 EQU SURF     ; HM, gated by ENGINE_FOGBADGE
DEF DEVWARP_MOVE_4 EQU STRENGTH ; HM, gated by ENGINE_PLAINBADGE
DEF DEVWARP_SPECIES_2  EQU GOROCHU    ; second party slot -- whatever is in progress
DEF DEVWARP_LEVEL_2    EQU 50         ; its level

; Slot 3: the catcher. False Swipe leaves targets on 1 HP, Spore is a
; guaranteed sleep. Scyther can learn neither naturally -- that's the point.
DEF DEVWARP_SPECIES_3  EQU SCYTHER
DEF DEVWARP_LEVEL_3    EQU 69
DEF DEVWARP_S3_MOVE_1  EQU FALSE_SWIPE
DEF DEVWARP_S3_MOVE_2  EQU SPORE
DEF DEVWARP_S3_MOVE_3  EQU SLASH
DEF DEVWARP_S3_MOVE_4  EQU HYPER_BEAM

; Slot 4: the taxi.
DEF DEVWARP_SPECIES_4  EQU PIDGEOT
DEF DEVWARP_LEVEL_4    EQU 50
DEF DEVWARP_S4_MOVE_1  EQU FLY

; Slot 5: the HM slave. Covers the HMs nothing else in the party has --
; Cyndaquil already carries Surf/Strength, Pidgeot carries Fly. Shuckle
; can learn none of Cut/Whirlpool/Waterfall/Flash naturally; written
; directly into its move slots anyway, same as Scyther's moveset above.
DEF DEVWARP_SPECIES_5  EQU SHUCKLE
DEF DEVWARP_LEVEL_5    EQU 50
DEF DEVWARP_S5_MOVE_1  EQU CUT        ; HM, gated by ENGINE_HIVEBADGE
DEF DEVWARP_S5_MOVE_2  EQU WHIRLPOOL  ; HM, gated by ENGINE_GLACIERBADGE
DEF DEVWARP_S5_MOVE_3  EQU WATERFALL  ; HM, gated by ENGINE_RISINGBADGE
DEF DEVWARP_S5_MOVE_4  EQU FLASH      ; HM, no badge gate

DEF DEVWARP_GENDER     EQU 0          ; 0 = male, 1 = female
DEF DEVWARP_HOUR       EQU 12         ; clock hour (0-23); 12 = daytime
DEF DEVWARP_MINUTE     EQU 0          ; clock minute (0-59)

; Testing loadout -- granted on every devwarp new game.
DEF DEVWARP_MONEY        EQU 999999   ; max wallet
DEF DEVWARP_ITEM_1       EQU ULTRA_BALL
DEF DEVWARP_ITEM_1_QTY   EQU 99
DEF DEVWARP_ITEM_2       EQU POTION
DEF DEVWARP_ITEM_2_QTY   EQU 99
DEF DEVWARP_KEY_ITEM     EQU BICYCLE  ; goes in the key items pocket
DEF DEVWARP_KEY_ITEM_2   EQU S_S_TICKET
