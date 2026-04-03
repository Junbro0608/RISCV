#define APB_GPO_BASE  (0x20000000U) // GPO 베이스 주소 추가
#define APB_FND_BASE  (0x20003000U)
#define APB_UART_BASE (0x20004000U)
#define APB_GPIO_BASE (0x20002000U)

#define GPO_CTL       (*(volatile unsigned int *)(APB_GPO_BASE + 0x00U))
#define GPO_ODATA     (*(volatile unsigned int *)(APB_GPO_BASE + 0x04U))
#define FND_CTL       (*(volatile unsigned int *)(APB_FND_BASE + 0x00U))
#define FND_ODATA     (*(volatile unsigned int *)(APB_FND_BASE + 0x04U))
#define GPIO_CTL      (*(volatile unsigned int *)(APB_GPIO_BASE + 0x00U))
#define GPIO_IDATA    (*(volatile unsigned int *)(APB_GPIO_BASE + 0x08U))
#define UART_STATUS   (*(volatile int *)         (APB_UART_BASE + 0x08U)) 
#define UART_RX_DATA  (*(volatile unsigned int *)(APB_UART_BASE + 0x0CU))
#define UART_BAUD     (*(volatile unsigned int *)(APB_UART_BASE + 0x10U))

char uart_rx(void);

int main(void) {
    char cmd;
    unsigned int secret = 0;
    unsigned int sw_val = 0;
    unsigned int d1, d2, d3, d4;

    // 1. 하드웨어 초기화
    GPO_CTL = 0xFFFF;  // 16개의 LED 핀을 모두 출력용으로 활성화
    FND_CTL = 1; 
    GPIO_CTL = 0x0000; 
    UART_BAUD = 0; 

    // [핵심] 4자리 스위치 구분을 위한 가이드라인 LED 점등 (0x8888)
    // LED 15, 11, 7, 3번이 켜져서 4개의 스위치 묶음이 한눈에 들어옵니다.
    GPO_ODATA = 0x1111; 

    FND_ODATA = 8282; 

    while(1) {
        cmd = uart_rx();

        if (cmd == 's') {
            FND_ODATA = 9999; 
            
            d1 = uart_rx() - '0';
            d2 = uart_rx() - '0';
            d3 = uart_rx() - '0';
            d4 = uart_rx() - '0';
            
            secret = (d1 << 12) | (d2 << 8) | (d3 << 4) | d4;
            
            FND_ODATA = 8888; 
        }
        else if (cmd == 'i') {
            sw_val = GPIO_IDATA & 0xFFFF;

            if (sw_val < secret) {
                FND_ODATA = 1111; 
            } 
            else if (sw_val > secret) {
                FND_ODATA = 0;    
            } 
            else {
                FND_ODATA = 7777; 
            }
        }
    }
    return 0;
}

char uart_rx(void) {
    while (UART_STATUS >= 0); 
    return (char)UART_RX_DATA;
}