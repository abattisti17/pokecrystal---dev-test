; Pokémon: Lost Legends -- dev fast-start configuration
; Only used when building with `make devwarp`. Has no effect on release builds.
; Change these to test a different scene without replaying the intro.

DEF DEVWARP_SPECIES    EQU CYNDAQUIL  ; the Pokemon you start with
DEF DEVWARP_LEVEL      EQU 25         ; its level
DEF DEVWARP_FIELD_MOVE EQU STRENGTH   ; written into its 4th move slot
DEF DEVWARP_SPECIES_2  EQU GOROCHU    ; second party slot -- whatever is in progress
DEF DEVWARP_LEVEL_2    EQU 50         ; its level
DEF DEVWARP_GENDER     EQU 0          ; 0 = male, 1 = female
DEF DEVWARP_HOUR       EQU 12         ; clock hour (0-23); 12 = daytime
DEF DEVWARP_MINUTE     EQU 0          ; clock minute (0-59)
