ROM_BASE = 0x00000000;
RAM_BASE = 0x00004000;
ROM_SIZE = 16K;
RAM_SIZE = 16K;

MEMORY {
	ROM (rx) : ORIGIN = ROM_BASE, LENGTH  = ROM_SIZE,
	RAM (rw) : ORIGIN = RAM_BASE, LENGTH  = RAM_SIZE
}

SECTIONS
{
	/* Read Only (Instructions + Data) */
	.text : {
		*(.text)
		*(.text.*)
		*(.rodata.*)
	} >ROM
  
	/* Initialized Data */
	.data : {
		*(.sdata)
		*(.sdata.*)
		*(.data)
		*(.data.*)
	} >RAM
	
	/* Uninitialized Data */
	.bss : {
		*(.bss)
		*(.bss.*)
		*(.sbss)
		*(.sbss.*)
	} >RAM	
}
