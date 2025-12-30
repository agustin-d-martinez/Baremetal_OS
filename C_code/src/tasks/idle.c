__attribute__((section(".idle"))) void idle(){
    while(1) asm volatile("WFI");
}