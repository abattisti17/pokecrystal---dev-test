; Pokémon: Lost Legends -- dev fast-start configuration
; Only used when building with `make devwarp`. Has no effect on release builds.
; Change these to test a different scene without replaying the intro.

; Which SPAWN_* the fast-start lands you at (see data/maps/spawn_points.asm).
; Vermilion Port is the trunk default (Mew under the crate). Vignette
; branches typically point this at their own entry point while in progress
; -- e.g. SPAWN_TRANSFER_NETWORK_ENTRY for the Transfer Network vignette --
; and are expected to restore SPAWN_VERMILION before merging to master,
; unless a coordinated merge decides otherwise (see BRANCHES.md).
DEF DEVWARP_SPAWN      EQU SPAWN_TRANSFER_NETWORK_ENTRY

DEF DEVWARP_SPECIES    EQU CYNDAQUIL  ; the Pokemon you start with
DEF DEVWARP_LEVEL      EQU 25         ; its level
DEF DEVWARP_FIELD_MOVE EQU STRENGTH   ; written into its 4th move slot
DEF DEVWARP_SPECIES_2  EQU GOROCHU    ; second party slot -- whatever is in progress
DEF DEVWARP_LEVEL_2    EQU 50         ; its level
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
