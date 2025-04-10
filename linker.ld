MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 128K
    RAM (rwx)   : ORIGIN = 0x20000000, LENGTH = 20K
}
__reset_stack_pointer = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
    .vectors : {
        * (.isr_vector);
    } > FLASH /* Put this in the flash memory region */

    .text : {
        /* And here comes the rest of the code */
        *(.text*)
    } > FLASH /* Put this in the flash memory region */

    _sdata = .;
    .data : {
        /* This is the data section */
        *(.data*)
    } > RAM AT > FLASH /* Put this in the RAM region, but load it from the FLASH region */
    _edata = .;

    _sbss = .;  
    .bss : {
        /* This is the bss section */
        *(.bss*)
    } > RAM /* Put this in the RAM region */
    _ebss = .;

    _load_address = LOADADDR(.data);

}