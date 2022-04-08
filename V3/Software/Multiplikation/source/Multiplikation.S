# ------------------------------------------------------------------------------
# Praktikum Recherorganisation
# Versuch 3
# Unterprogramme zur Bitmanipulation
# Hochschule Osnabrueck / Bernhard Lang, Rainer Höckmann
# ------------------------------------------------------------------------------
.set SP_INIT, 0x00008000

# ------------------------------------------------------------------------------
# Peripherie-Definitionen
# ------------------------------------------------------------------------------
.set In_Port,  0x8100
.set Out_Port, 0x8200

# ------------------------------------------------------------------------------
# Globale Variablen
# ------------------------------------------------------------------------------
.section .data
Ergebnis: .word 0xDECAFBAD             # unsigned int Ergebnis;

# ------------------------------------------------------------------------------
# Einsprungpunkte
# ------------------------------------------------------------------------------
.section .text

Reset_Vector:
    beq $zero, $zero, main

# ------------------------------------------------------------------------------
# int bit_von(int Wert, int Bitnummer)
# ------------------------------------------------------------------------------
#   $a0: Wert
#   $a1: Bitnummer
#   $v0: Rueckgabewert
# ------------------------------------------------------------------------------
# return (Wert >> Bitnummer) & 1;
# ------------------------------------------------------------------------------
bit_von:
    srlv $t0, $a0, $a1
    andi $v0, $t0, 1
    jr   $ra                           # Ruecksprung

# ------------------------------------------------------------------------------
# int lese_bit(int Adresswert, int Bitnummer)
# ------------------------------------------------------------------------------
#   $a0: Adresswert
#   $a1: Bitnummer
#   $v0: Rueckgabewert
# ------------------------------------------------------------------------------
# int * Adresse = (int*) Adresswert;
# return bit_von(*Adresse, Bitnummer);
# ------------------------------------------------------------------------------
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
# int * Adresse = (int*) Adresswert;
# *Adresse = *Adresse | (1 << Bitnummer);
# ------------------------------------------------------------------------------
setze_bit:
    ori  $t0, $zero, 1
    sllv $t1, $t0, $a1
    lw   $t2, 0($a0)
    or   $t3, $t1, $t2
    sw   $t3, 0($a0)

    jr   $ra                           # Ruecksprung

# ------------------------------------------------------------------------------
# int lese_bitfeld(int Adresswert, int Maske, int Shift)
# ------------------------------------------------------------------------------
#   $a0: Adresswert
#   $a1: Maske
#   $a2: Shift
#   $v0: Rueckgabewert
# ------------------------------------------------------------------------------
# int * Adresse = (int*) Adresswert;
# return (*Adresse >> Shift) & Maske;
# ------------------------------------------------------------------------------
lese_bitfeld:
# TODO: Unterprogramm ergaenzen
    lw   $t0, 0($a0)
    srlv  $t1, $t0, $a2
    and  $t2, $t1, $a1
    addiu $v0, $t2, 0
    jr   $ra                           # Ruecksprung

# ------------------------------------------------------------------------------
# void loesche_bit(int Adresswert, int Bitnummer)
# ------------------------------------------------------------------------------
#   $a0: Adresswert
#   $a1: Bitnummer
# ------------------------------------------------------------------------------
# int * Adresse = (int*) Adresswert;
# *Adresse = *Adresse & ~(1 << Bitnummer);
# ------------------------------------------------------------------------------
loesche_bit:
# TODO: Unterprogramm ergaenzen
    ori $t5, $zero, 0xffff
    ori $t6, $zero, 16
    sllv $t7, $t5, $t6
    or $t8, $t7, $t5

    ori $t0, $zero, 1
    sllv $t1, $t0, $a1
    xor $t4, $t1, $t8
    lw   $t2, 0($a0)
    and   $t3, $t4, $t2
    sw   $t3, 0($a0)
    addiu $k1, $t3, 0
    jr   $ra                           # Ruecksprung

# ------------------------------------------------------------------------------
# void schreibe_bitfeld(int Adresswert, int Wert, int Maske, int Shift)
# ------------------------------------------------------------------------------
#   $a0: Adresswert
#   $a1: Wert
#   $a2: Maske
#   $a3: Shift
# ------------------------------------------------------------------------------
# int * Adresse = (int*) Adresswert;
# *Adresse = *Adresse & ~(Maske << Shift) | ((Wert & Maske) << Shift);
# ------------------------------------------------------------------------------
schreibe_bitfeld:
# TODO: Unterprogramm ergaenzen
    ori $t7, $zero, 0xffff
    ori $t8, $zero, 16
    sllv $t9, $t7, $t8
    or $t8, $t9, $t7


    lw   $t0, 0($a0)
    sllv  $t1, $a2, $a3
    xor  $t2, $t1, $t8
    and  $t3, $t0, $t2

    and  $t4, $a1, $a2
    sllv $t5, $t4, $a3

    or  $t6, $t3, $t5
    sw  $t6, 0($a0)
    jr   $ra                           # // Ruecksprung

# ------------------------------------------------------------------------------
# unsigned int multipliziere(unsigned int a, unsigned int b)
# ------------------------------------------------------------------------------
#   $a0: a
#   $a1: b
#   $v0: Rueckgabewert (Produkt aus a und b)
# ------------------------------------------------------------------------------
# unsigned int Produkt = 0;
# for(int bit = 0; bit < 32; bit++) {
#     if(bit_von(b, bit) != 0) {
#         Produkt = Produkt + a;
#     }
#     a = a << 1;
# }
# return Produkt;
# ------------------------------------------------------------------------------
multipliziere:
	.set Produkt, $s0                  # unsigned int Produkt;
	.set bit, $s1                      # int bit;
	.set a, $a0
	.set b, $a1

	addiu $sp, $sp, -8                 # Callee-Saved Register auf Stack sichern
	sw    $s0, 0($sp)
	sw    $s1, 4($sp)

# TODO: Unterprogramm ergaenzen


    ori  bit, $zero, 0
    ori  Produkt, $zero, 0
    naechsteStelle:
    	addiu $t6, bit, -32
    	bgez $t6, end

    	addiu $sp, $sp, -12
    	sw a, 0($sp)
    	sw b, 4($sp)
    	sw $ra, 8($sp)
    	or $a0, $zero, b
    	or $a1, $zero, bit
    	la $t5,bit_von
    	jalr $ra, $t5
    	lw a, 0($sp)
    	lw b, 4($sp)

    	lw $ra, 8($sp)
    	addiu $sp, $sp, 12
    	beq $v0, $zero, addierer
    	addu Produkt, Produkt, a
    addierer:
    	ori  $t4, $zero, 1
    	sllv a, a, $t4
    	addiu bit, bit, 1
    	blez $zero, naechsteStelle
    end:
    ori   $v0, Produkt, 0


	lw    $s0, 0($sp)
	lw    $s1, 4($sp)
	addiu $sp, $sp, +8                 # Callee-Saved Register vom Stack wiederherstellen

    jr    $ra

# ------------------------------------------------------------------------------
# Hauptprogramm
# ------------------------------------------------------------------------------
main:
	.set Multiplikator, $s0            # unsigned int Multiplikator;
	.set Multiplikand,  $s1            # unsigned int Multiplikand;
	.set Produkt,       $s2            # unsigned int Produkt
	.set Highbyte,      $s3            # int Highbyte;
	.set Lowbyte,       $s4            # int Lowbyte;
	.set i,             $s5            # int i;

    li    $sp, SP_INIT                 # Stackpointer initialisieren

Hauptschleife:                         # while(1) {
	# -----------------------------------------------------
	# Multiplikator von den Schaltern einlesen (Bits 15..8)
	# -----------------------------------------------------
	la    $a0, In_Port                 #     Multiplikator = lese_bitfeld(In_Port, 0xff, 8);
	li    $a1, 0xff
	li    $a2, 8
	la    $t0, lese_bitfeld
	jalr  $ra, $t0
	ori   Multiplikator, $v0, 0

	# ---------------------------------------------------
	# Multiplikand von den Schaltern einlesen (Bits 7..0)
	# ---------------------------------------------------
	la    $a0, In_Port                 #     Multiplikand = lese_bitfeld(In_Port, 0xff, 0);
	li    $a1, 0xff
	li    $a2, 0
	la    $t0, lese_bitfeld
	jalr  $ra, $t0
	ori   Multiplikand, $v0, 0

	# -------------------------
	# Multiplikation ausfuehren
	# -------------------------
    ori   $a0, Multiplikator, 0        #     Produkt = multipliziere(Multiplikator, Multiplikand);
    ori   $a1, Multiplikand, 0
	la    $t0, multipliziere
	jalr  $ra, $t0
	ori   Produkt, $v0, 0

	# ------------------------------------
	# Produkt bitweise im Speicher ablegen
	# ------------------------------------
	                                   #     for(i = 31; i >= 0; i--)
Copy_init:
	li    i, 31                        #         // i = 31

Copy_test:
	bltz  i, Copy_end                  #         // i >= 0
	                                   #     {
	ori   $a0, Produkt, 0              #         if(bit_von(Produkt, i))
	ori   $a1, i, 0
	la    $t0, bit_von
	jalr  $ra, $t0
	beq   $v0, $zero, nicht_gesetzt
	                                   #         {
	la    $a0, Ergebnis                #             setze_bit(Ergebnis, i);
	ori   $a1, i, 0
	la    $t0, setze_bit
	jalr  $ra, $t0
	beq   $zero, $zero, Copy_iter
	                                   #         } else {
nicht_gesetzt:
	la    $a0, Ergebnis                #             loesche_bit(Ergebnis, i);
	ori   $a1, i, 0
	la    $t0, loesche_bit
	jalr  $ra, $t0
	                                   #         }
Copy_iter:
	addiu i, i, -1                     #         // i--
	beq   $zero, $zero, Copy_test      #     } // for

Copy_end:
	# -------------------------------------------------
	# Ergebnis-Highbyte bitweise aus dem Speicher lesen
	# -------------------------------------------------
	li    Highbyte, 0                  #     Highbyte = 0

Highbyte_init:                         #     for(i = 7; i >= 0; i--)
	li    i, 7                         #         // i = 7

Highbyte_test:
	bltz  i, Highbyte_end              #         // i >= 0
	                                   #     {
	li    $t0, 1					   #         Highbyte = Highbyte << 1;
	sllv  Highbyte, Highbyte, $t0

	la    $a0, Ergebnis				   #         if(lese_bit(Ergebnis, i + 8))
	addiu $a1, i, 8
	la    $t0, lese_bit
	jalr  $ra, $t0
	blez  $v0, Highbyte_iter
	                                   #         {
	ori   Highbyte, Highbyte, 1		   #             Highbyte = Highbyte | 1;
									   #         } // if
Highbyte_iter:
	addiu i, i, -1                     #         // i--
	beq   $zero, $zero, Highbyte_test  #     } // for

Highbyte_end:
	# ------------------------------------------------
	# Ergebnis-Lowbyte bitweise aus dem Speicher lesen
	# ------------------------------------------------
	li    Lowbyte, 0                   #     Lowbyte = 0

Lowbyte_init:                          #     for(i = 7; i >= 0; i--)
	li    i, 7        				   #         // i = 7

Lowbyte_test:
	bltz  i, Lowbyte_end               #         // i >= 0
	                                   #     {
	li    $t0, 1					   #         Lowbyte = Lowbyte << 1;
	sllv  Lowbyte, Lowbyte, $t0

	la    $a0, Ergebnis				   #         if(lese_bit(Ergebnis, i))
	ori   $a1, i, 0
	la    $t0, lese_bit
	jalr  $ra, $t0
	blez  $v0, Lowbyte_iter
	                                   #         {
	ori   Lowbyte, Lowbyte, 1		   #             Lowbyte = Lowbyte | 1;
									   #         } // if
Lowbyte_iter:
	addiu i, i, -1                     #         // i--
	beq   $zero, $zero, Lowbyte_test   #     } // for

Lowbyte_end:
	# ------------------------------------------------
	# Ergebnis-Highbyte auf LEDs (Bits 15..8) ausgeben
	# ------------------------------------------------
	la   $a0, Out_Port                 #     schreibe_bitfeld(Out_Port, Highbyte, 0xff, 8);
	ori  $a1, Highbyte, 0
	ori  $a2, $zero, 0xff
	ori  $a3, $zero, 8
	la   $t0, schreibe_bitfeld
	jalr $ra, $t0

	# ------------------------------------------------
	# Ergebnis-Lowbyte auf LEDs (Bits 7..0) ausgeben
	# ------------------------------------------------
	la   $a0, Out_Port                 #     schreibe_bitfeld(Out_Port, Lowbyte, 0xff, 0);
	ori  $a1, Lowbyte, 0
	ori  $a2, $zero, 0xff
	ori  $a3, $zero, 0
	la   $t0, schreibe_bitfeld
	jalr $ra, $t0

	beq $zero, $zero, Hauptschleife    # } // while


