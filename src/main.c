#include <stdint.h>
// Necesitamos definir los siguientes registros:
// RCC_APB2ENR: APB2 peripheral clock enable register
#define         RCC_APB2ENR     (*((int*)0x40021018U))
// GPIOC_BASE: Direccion base de GPIOC
#define         GPIOC_BASE      (0x40011000U)
// GPIOC_CRH  
#define         GPIOC_CRH       (*((int*)(GPIOC_BASE + 0x4U)))
// GPIOC_ODR  
#define         GPIOC_ODR       (*((int*)(GPIOC_BASE + 0xCU)))

int main()
{ 
  // habilitamos clock a GPIOC mediante "APB2 peripheral clock enable register" (pagina 112)
  // tenemos que poner un 1 en el bit 4
  RCC_APB2ENR |= 1U << 4; // 0000 0000 0011 0000
                          // 0000 0000 0000 0000
                          // -------------------
                          // 0000 0000 0001 0000
  
  // Ponemos a GPIOC 13 como salida push-pull (frec. max. de 50 MHz o menos) 
  // con MODE elejimos "Output mode, max speed 50 MHz." (pagina 171), lo ponemos en 10
  GPIOC_CRH |=  (0x2 << 20);     
  // con CNF seleccionamos  "General purpose output push-pull" (pagina 171), lo ponemos en 00
  GPIOC_CRH &= ~(0x3 << 22);  // 0000 0000 1100 0000 0000 0000 0000 0000
                              // 1111 1111 0011 1111 1111 1111 1111 1111 <- despues de ~ 

  while(1){
    // apagamos LED mediante "Port output data register" (pagina 173)
    GPIOC_ODR |= 1U << 13;
        
    // delay por software
    for(int i = 0; i < 500000; i++);
    
    // encendemos LED mediante "Port output data register" (pagina 173)
    GPIOC_ODR &= ~(1U << 13);
    
    // delay por software
    for(int i = 0; i < 500000; i++);    
  }  
  return 0;
}
