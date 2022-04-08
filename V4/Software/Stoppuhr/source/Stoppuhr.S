# ------------------------------------------------------------------------------
# Praktikum Recherorganisation
# Versuch 4
# Stoppuhr
# Hochschule Osnabrueck / Bernhard Lang, Rainer H�ckmann
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Prozessor-Konstanten
# ------------------------------------------------------------------------------
.set SP_INIT, 0x00008000

.set Status, $12
.set Cause,  $13
.set EPC,    $14

.set IE,  (1<<0)
.set EXL, (1<<1)
.set IM0, (1<<8)
.set IM2, (1<<10)
.set IM3, (1<<11)
.set IM4, (1<<12)
.set IP0, (1<<8)
.set IP2, (1<<10)
.set IP3, (1<<11)
.set IP4, (1<<12)

# ------------------------------------------------------------------------------
# Peripherie-Definitionen
# ------------------------------------------------------------------------------
.set Timer_Basis,         0x8000
.set Timer_Periode,       0x0
.set Timer_Schwelle,      0x4
.set Timer_Zaehlerstand,  0x8
.set Timer_Kontroll,      0xC
.set Timer_Status,        0x10

.set Timer_IrEn,          0

.set GPIO_Basis,          0x8100
.set GPIO_Eingabe,        0x0
.set GPIO_Ausgabe,        0x4
.set GPIO_Richtung,       0x8

.set SSP_Basis,           0x8200
.set SSP_Wert0,           0x0
.set SSP_Wert1,           0x4
.set SSP_Wert2,           0x8
.set SSP_Wert3,           0xC

# ------------------------------------------------------------------------------
# Anwendungsspezifische Definitionen
# ------------------------------------------------------------------------------

# Spezifikation der GPIO-Pins
.set START,  0
.set STOP,   1
.set RESET,  2

# Konstanten fuer die Ausfuehrung in Hardware (Echtzeit)
.set ZAEHLER_PERIODE, 59999 # Echtzeit (Ein Interrupt pro ms)
.set MS_PRO_INTERRUPT, 1    # Echtzeit (1 ms pro Interrupt)

# Konstanten fuer die Ausfuehrung im VHDL-Simulator (Beschleunigung x100)
#.set ZAEHLER_PERIODE, 29999 # Beschleunigt (2 Interrupts pro ms)
#.set MS_PRO_INTERRUPT, 50  # Beschleunigt  (50 ms pro Interrupt)

# ------------------------------------------------------------------------------
#  Globale Variablen
# ------------------------------------------------------------------------------
.section .data
ms:                 .word 0                 # volatile int ms;

# ------------------------------------------------------------------------------
# Einsprungpunkte
# ------------------------------------------------------------------------------
.section .text

Reset_Vector:
    beq $zero, $zero, main

IP0_Vector:
	beq $zero, $zero, IP0_Vector

IP2_Vector:
    beq $zero, $zero, Timer_Handler

IP3_Vector:
	beq $zero, $zero, IP3_Vector

IP4_Vector:
	beq $zero, $zero, IP4_Vector

# ------------------------------------------------------------------------------
# int bit_von(int Wert, int Bitnummer)
# ------------------------------------------------------------------------------
#   $a0: Wert
#   $a1: Bitnummer
#   $v0: Rueckgabewert
# ------------------------------------------------------------------------------
# TODO: Unterprogramm aus Versuch 3 �bernehmen
bit_von:
    srlv $t0, $a0, $a1
    andi $v0, $t0, 1
    jr   $ra                           # // Ruecksprung

# ------------------------------------------------------------------------------
# int lese_bit(int Adresswert, int Bitnummer)
# ------------------------------------------------------------------------------
#   $a0: Adresswert
#   $a1: Bitnummer
#   $v0: Rueckgabewert
# ------------------------------------------------------------------------------
# TODO: Unterprogramm aus Versuch 3 �bernehmen
lese_bit:
    addiu $sp, $sp, -4                 # Ruecksprungadresse auf dem Stack sichern
    sw    $ra, 0($sp)

    lw    $a0, 0($a0)
    la    $t0, bit_von
    jalr  $ra, $t0

    lw    $ra, 0($sp)                  # Ruecksprungadresse vom Stack wiederherstellen
    addiu $sp, $sp, 4
    jr    $ra                          # Ruecksprung

# ------------------------------------------------------------------------------
# void setze_bit(int Adresswert, int Bitnummer)
# ------------------------------------------------------------------------------
#   $a0: Adresswert
#   $a1: Bitnummer
# ------------------------------------------------------------------------------
# TODO: Unterprogramm aus Versuch 3 �bernehmen
setze_bit:
    ori  $t0, $zero, 1
    sllv $t1, $t0, $a1
    lw   $t2, 0($a0)
    or   $t3, $t1, $t2
    sw   $t3, 0($a0)
    jr   $ra

# ------------------------------------------------------------------------------
# void loesche_bit(int Adresswert, int Bitnummer)
# ------------------------------------------------------------------------------
#   $a0: Adresswert
#   $a1: Bitnummer
# ------------------------------------------------------------------------------
# TODO: Unterprogramm aus Versuch 3 �bernehmen
loesche_bit:
    ori   $t5, $zero, 0xffff
    ori   $t6, $zero, 16
    sllv  $t7, $t5, $t6
    or    $t8, $t7, $t5

    ori   $t0, $zero, 1
    sllv  $t1, $t0, $a1
    xor   $t4, $t1, $t8
    lw    $t2, 0($a0)
    and   $t3, $t4, $t2
    sw    $t3, 0($a0)
    addiu $k1, $t3, 0
    jr    $ra                             # Ruecksprung

# ------------------------------------------------------------------------------
# void schreibe_bitfeld(int Adresswert, int Wert, int Maske, int Shift)
# ------------------------------------------------------------------------------
#   $a0: Adresswert
#   $a1: Wert
#   $a2: Maske
#   $a3: Shift
# ------------------------------------------------------------------------------
# TODO: Unterprogramm aus Versuch 3 �bernehmen
schreibe_bitfeld:
    ori   $t7, $zero, 0xffff
    ori   $t8, $zero, 16
    sllv  $t9, $t7, $t8
    or    $t8, $t9, $t7


    lw    $t0, 0($a0)
    sllv  $t1, $a2, $a3
    xor   $t2, $t1, $t8
    and   $t3, $t0, $t2

    and   $t4, $a1, $a2
    sllv  $t5, $t4, $a3

    or    $t6, $t3, $t5
    sw    $t6, 0($a0)
    jr    $ra                           # // Ruecksprung

# ------------------------------------------------------------------------------
# void Timer_Handler()
# ------------------------------------------------------------------------------
Timer_Handler:
    addiu $sp, $sp, -8                  # Register retten
    sw    $t0, 0($sp)
    sw    $t1, 4($sp)

    la    $t1, ms                       # Seit letztem Interrupt vergangene ms
    lw    $t0, 0($t1)                   # ms = ms + MS_PRO_INTERRUPT
    addiu $t0, $t0, MS_PRO_INTERRUPT
    sw    $t0, 0($t1)

    li    $t1, Timer_Basis              # Timer-Status abfragen, um Interrupt zu l�schen
    lw    $zero, Timer_Status($t1)

    lw    $t0, 0($sp)                   # Register wiederherstellen
    lw    $t1, 4($sp)
    addiu $sp, $sp, 8
    eret                                # Unterbrechung beendet

# ------------------------------------------------------------------------------
# void Zeit_anzeigen(int Minuten, int Zehner, int Einer, int Zehntel)
# ------------------------------------------------------------------------------
#   $a0: Minuten
#   $a1: Zehner
#   $a2: Einer
#   $a3: Zehntel
# ------------------------------------------------------------------------------
Zeit_anzeigen:
# TODO: Unterprogramm ergaenzen

    li    $t0, SSP_Basis
    ori   $a0, $a0, 0x10
    sw    $a0, SSP_Wert3($t0)
    sw    $a1, SSP_Wert2($t0)
    ori   $a2, $a2, 0x10
    sw    $a2, SSP_Wert1($t0)
    sw    $a3, SSP_Wert0($t0)

    jr    $ra


# ------------------------------------------------------------------------------
# void main()
# ------------------------------------------------------------------------------
.set Minuten,     $s0
.set Zehner,      $s1
.set Einer,       $s2
.set Zehntel,     $s3

main:
    li    $sp, SP_INIT                    # Stackpointer initialisieren

    ori   Minuten, $zero, 0               # int Minuten = 0;
    ori   Zehner, $zero, 0                # int Zehner = 0;
    ori   Einer, $zero, 0                 # int Einer = 0;
    ori   Zehntel, $zero, 0               # int Zehntel = 0;

    ori   $t0, $zero, 0                   # ms = 0;
    la    $t1, ms
    sw    $t0, 0($t1)

    li    $a0, Timer_Basis                # schreibe_bitfeld(Timer_Basis + Timer_Periode, TAKTZYKLEN_PRO_MS, 0xffffffff, 0);
    addiu $a0, $a0, Timer_Periode
    li    $a1, ZAEHLER_PERIODE
    li    $a2, 0xffffffff
    ori   $a3, $zero, 0
    la    $t1, schreibe_bitfeld
    jalr  $ra, $t1

    ori   $t0, $zero, IM2                 # Interrupt IP2 freigeben
    mfc0  $t1, Status
    or    $t0, $t0, $t1
    mtc0  $t0, Status

    ei    $zero                           # Globalen Interrupt freigeben

    ori   $a0, Minuten, 0                 # Zeit_anzeigen(Minuten, Zehner, Einer, Zehntel);
    ori   $a1, Zehner, 0
    ori   $a2, Einer, 0
    ori   $a3, Zehntel, 0
    la    $t1, Zeit_anzeigen
    jalr  $ra, $t1

WARTEN:                                   #     while(1) {
    li    $a0, GPIO_Basis                 #         if(lese_bit(GPIO_Basis + GPIO_Eingabe, START) != 0) {
    addiu $a0, $a0, GPIO_Eingabe
    ori   $a1, $zero, START
    la    $t1, lese_bit
    jalr  $ra, $t1
    bne   $v0, $zero, Uhr_starten         #             break;
                                          #         }

    li    $a0, GPIO_Basis                 #         if(lese_bit(GPIO_Basis + GPIO_Eingabe, RESET) != 0) {
    addiu $a0, $a0, GPIO_Eingabe
    ori   $a1, $zero, RESET
    la    $t1, lese_bit
    jalr  $ra, $t1
    beq   $v0, $zero, WARTEN

Uhr_zuruecksetzen:
    ori   Minuten, $zero, 0               #             Minuten = 0;
    ori   Zehner, $zero, 0                #             Zehner  = 0;
    ori   Einer, $zero, 0                 #             Einer   = 0;
    ori   Zehntel, $zero, 0               #             Zehntel = 0;

    ori   $a0, Minuten, 0                 #             Zeit_anzeigen(Minuten, Zehner, Einer, Zehntel);
    ori   $a1, Zehner, 0
    ori   $a2, Einer, 0
    ori   $a3, Zehntel, 0
    la    $t1, Zeit_anzeigen
    jalr  $ra, $t1
                                          #         }
    beq   $zero, $zero, WARTEN            #     }

Uhr_starten:
    ori   $t0, $zero, 0                   #     ms = 0
    la    $t1, ms
    sw    $t0, 0($t1)

    li    $a0, Timer_Basis                #     // Timer-Interrupt aktivieren
    addiu $a0, $a0, Timer_Kontroll        #     setze_bit(Timer_Basis + Timer_Kontroll, Timer_IrEn)
    ori   $a1, $zero, Timer_IrEn
    la    $t1, setze_bit
    jalr  $ra, $t1

ZAEHLEN:                                  # while(1) {
    la    $t1, ms                         #     if(ms >= 100) {
    lw    $t0, 0($t1)
    addiu $t0, $t0, -100
    bltz  $t0, Stop_pruefen

    li    $a0, Timer_Basis                #         // Timer-Interrupt sperren
    addiu $a0, $a0, Timer_Kontroll        #         loesche_bit(Timer_Basis + Timer_Kontroll, Timer_IrEn)
    ori   $a1, $zero, Timer_IrEn
    la    $t1, loesche_bit
    jalr  $ra, $t1

    la    $t1, ms                         #         ms = ms - 100
    lw    $t0, 0($t1)
    addiu $t0, $t0, -100
    sw    $t0, 0($t1)

    li    $a0, Timer_Basis                #         // Timer-Interrupt freigeben
    addiu $a0, $a0, Timer_Kontroll        #         setze_bit(Timer_Basis + Timer_Kontroll, Timer_IrEn)
    ori   $a1, $zero, Timer_IrEn
    la    $t1, setze_bit
    jalr  $ra, $t1

    addiu Zehntel, Zehntel, 1             #         Zehntel++;

    addiu $t0, Zehntel, -10               #         if(Zehntel == 10) {
    bne   $t0, $zero, Einer_pruefen
    addiu Einer, Einer, 1                 #             Einer++;
    ori   Zehntel, $zero, 0               #             Zehntel = 0;
                                          #         }
Einer_pruefen:
    addiu $t0, Einer, -10                 #         if(Einer == 10) {
    bne   $t0, $zero, Zehner_pruefen
    addiu Zehner, Zehner, 1               #             Zehner++;
    ori   Einer, $zero, 0                 #             Einer = 0;
                                          #         }
Zehner_pruefen:
    addiu $t0, Zehner, -6                 #         if(Zehner == 6) {
    bne   $t0, $zero, Minuten_pruefen
    addiu Minuten, Minuten, 1             #             Minuten++;
    ori   Zehner, $zero, 0                #            Zehner = 0;
                                          #         }
Minuten_pruefen:
    addiu $t0, Minuten, -10               #         if(Minuten == 10) {
    bne   $t0, $zero, Zeit_aktualisieren
    ori   Minuten, $zero, 0               #            Minuten = 0;
                                          #         }
Zeit_aktualisieren:
    ori   $a0, Minuten, 0                 #         Zeit_anzeigen(Minuten, Zehner, Einer, Zehntel);
    ori   $a1, Zehner, 0
    ori   $a2, Einer, 0
    ori   $a3, Zehntel, 0
    la    $t1, Zeit_anzeigen
    jalr  $ra, $t1                        #         }

Stop_pruefen:
    li    $a0, GPIO_Basis                 #         if(lese_bit(GPIO_Basis + GPIO_Eingabe, STOP)) {
    addiu $a0, $a0, GPIO_Eingabe
    ori   $a1, $zero, STOP
    la    $t1, lese_bit
    jalr  $ra, $t1
    bne   $v0, $zero, Uhr_stoppen         #             break;
                                          #         }
    beq   $zero, $zero, ZAEHLEN           #     }

Uhr_stoppen:
    li    $a0, Timer_Basis                #     loesche_bit(Timer_Basis + Timer_Kontroll, Timer_IrEn)
    addiu $a0, $a0, Timer_Kontroll
    ori   $a1, $zero, Timer_IrEn
    la    $t1, loesche_bit
    jalr  $ra, $t1

    beq   $zero, $zero, WARTEN            # }
