#include "doomkeys.h"
#include "m_argv.h"
#include "doomgeneric.h"

#include <stdio.h>
#include <unistd.h>

#include <stdbool.h>

#include "xparameters.h"
#include "xil_printf.h"
#include "xaxivdma.h"
#include "xil_cache.h"
#include "xiltimer.h"

#define KEYQUEUE_SIZE 16

static unsigned short s_KeyQueue[KEYQUEUE_SIZE];
static unsigned int s_KeyQueueWriteIndex = 0;
static unsigned int s_KeyQueueReadIndex = 0;

/* Hardware addresses and frame buffer layout */
#define DDR_BASE_ADDR XPAR_DDR_MEM_BASEADDR
#define READ_ADDRESS_BASE (DDR_BASE_ADDR + 0x01000000)
#define GP_VERSION_ADDR (XPAR_SEGAGAMEPAD2_0_BASEADDR + 0x00)
#define GP_CONTROL_ADDR (XPAR_SEGAGAMEPAD2_0_BASEADDR + 0x04)
#define GP_STATUS_ADDR (XPAR_SEGAGAMEPAD2_0_BASEADDR + 0x08)
#define GP_INTERRUPT_ADDR (XPAR_SEGAGAMEPAD2_0_BASEADDR + 0x0C)

static XAxiVdma AxiVdma;
static XAxiVdma_Config *AxiVdma_Config;

/* Frame geometry derived from doomgeneric settings */
static const unsigned int BYTES_PER_PIXEL = 3;
static const unsigned int FRAME_HORIZONTAL_LEN = DOOMGENERIC_RESX * BYTES_PER_PIXEL;
static const unsigned int FRAME_VERTICAL_LEN = DOOMGENERIC_RESY;
static const unsigned int FRAME_SIZE_BYTES = FRAME_HORIZONTAL_LEN * FRAME_VERTICAL_LEN;

extern pixel_t* DG_ScreenBuffer;

static void addKeyToQueue(int pressed, unsigned int keyCode){
  unsigned char key = keyCode;

  unsigned short keyData = (pressed << 8) | key;

  s_KeyQueue[s_KeyQueueWriteIndex] = keyData;
  s_KeyQueueWriteIndex++;
  s_KeyQueueWriteIndex %= KEYQUEUE_SIZE;
}

static void handleKeyInput(){
  static unsigned int prev_state = 0;
  unsigned int cur = (*(volatile unsigned int*)GP_STATUS_ADDR);

  struct { unsigned int bit; unsigned char doomkey; } map[] = {
    { (1<<0), KEY_UPARROW },
    { (1<<1), KEY_DOWNARROW },
    { (1<<2), KEY_LEFTARROW },
    { (1<<3), KEY_RIGHTARROW },
    { (1<<4), KEY_FIRE },   // A
    { (1<<5), KEY_USE },    // B
    { (1<<6), KEY_RSHIFT }, // C
    { (1<<7), KEY_ENTER },  // START
    { (1<<8), 'x' },        // X -> raw char
    { (1<<9), 'y' },        // Y -> raw char
    { (1<<10), 'z' },       // Z -> raw char
    { (1<<11), KEY_TAB }    // Mode -> map to TAB
  };

  int map_count = sizeof(map)/sizeof(map[0]);
  for (int i = 0; i < map_count; ++i) {
    unsigned int bit = map[i].bit;
    unsigned int was = (prev_state & bit) != 0;
    unsigned int is = (cur & bit) != 0;
    if (was != is) {
      addKeyToQueue(is ? 1 : 0, map[i].doomkey);
    }
  }

  prev_state = cur;
}

void DG_Init(){
    int Status;

    /* enable gamepad hardware */
    (*(volatile unsigned int*)GP_CONTROL_ADDR) = 3;

    /* Initialize VDMA */
    AxiVdma_Config = XAxiVdma_LookupConfig(XPAR_XAXIVDMA_0_BASEADDR);
    if (!AxiVdma_Config) {
      xil_printf("VDMA config lookup failed\r\n");
      return;
    }

    Status = XAxiVdma_CfgInitialize(&AxiVdma, AxiVdma_Config, AxiVdma_Config->BaseAddress);
    if (Status != XST_SUCCESS) {
      xil_printf("VDMA cfg initialize failed\r\n");
      return;
    }

    Status = XAxiVdma_Selftest(&AxiVdma);
    if (Status != XST_SUCCESS) {
      xil_printf("VDMA selftest failed\r\n");
    }

    /* configure frame counter */
    XAxiVdma_FrameCounter FrameCfg;
    FrameCfg.ReadFrameCount = AxiVdma_Config->MaxFrameStoreNum;
    FrameCfg.WriteFrameCount = AxiVdma_Config->MaxFrameStoreNum;
    Status = XAxiVdma_SetFrameCounter(&AxiVdma, &FrameCfg);
    if (Status != XST_SUCCESS) {
      xil_printf("VDMA set frame counter failed\r\n");
    }

    /* configure read channel */
    XAxiVdma_DmaSetup ReadCfg;
    ReadCfg.VertSizeInput = FRAME_VERTICAL_LEN;
    ReadCfg.HoriSizeInput = FRAME_HORIZONTAL_LEN;
    ReadCfg.Stride = FRAME_HORIZONTAL_LEN;
    ReadCfg.FrameDelay = 0;
    ReadCfg.EnableCircularBuf = 1;
    ReadCfg.EnableSync = 0;
    ReadCfg.PointNum = 0;
    ReadCfg.EnableFrameCounter = 0;
    ReadCfg.FixedFrameStoreAddr = 0;

    Status = XAxiVdma_DmaConfig(&AxiVdma, XAXIVDMA_READ, &ReadCfg);
    if (Status != XST_SUCCESS) {
      xil_printf("VDMA dma config failed\r\n");
    }

    /* populate frame store addresses */
    UINTPTR frameAddr = READ_ADDRESS_BASE;
    for (int i = 0; i < FrameCfg.ReadFrameCount; ++i) {
      ReadCfg.FrameStoreStartAddr[i] = frameAddr;
      frameAddr += FRAME_SIZE_BYTES;
    }

    Status = XAxiVdma_DmaSetBufferAddr(&AxiVdma, XAXIVDMA_READ, ReadCfg.FrameStoreStartAddr);
    if (Status != XST_SUCCESS) {
      xil_printf("VDMA set buffer addr failed\r\n");
    }

    Status = XAxiVdma_DmaStart(&AxiVdma, XAXIVDMA_READ);
    if (Status != XST_SUCCESS) {
      xil_printf("VDMA dma start failed\r\n");
    }
}

int BufferDraw(int frameNum) {
    UINTPTR frameAddr = (READ_ADDRESS_BASE) + (frameNum * FRAME_SIZE_BYTES);
    u16 x, y;
    u8 *addr = (u8 *)frameAddr;
    u32 i = 0;
    for (y = 0; y < DOOMGENERIC_RESY; y++) {
        for (x = 0; x < DOOMGENERIC_RESX; x++) {
            pixel_t p = DG_ScreenBuffer[i];
            i++;
            *addr++ = p & 0xFF;
            *addr++ = (p >> 8) & 0xFF;
            *addr++ = (p >> 16) & 0xFF;
        }
    }
    Xil_DCacheFlushRange(frameAddr, FRAME_SIZE_BYTES);
    return XST_SUCCESS;
}

void DG_DrawFrame()
{
    u32 cur = XAxiVdma_CurrFrameStore(&AxiVdma, XAXIVDMA_READ);
    u32 max = AxiVdma_Config->MaxFrameStoreNum;
    u32 frame_number = (cur + 1) % max;

    BufferDraw(frame_number);

    int Status = XAxiVdma_StartParking(&AxiVdma, frame_number, XAXIVDMA_READ);
    if (Status != XST_SUCCESS) {
      xil_printf("VDMA start parking failed\r\n");
    }

    handleKeyInput();
}

void DG_SleepMs(uint32_t ms)
{
    usleep(ms * 1000);
}

uint32_t DG_GetTicksMs()
{
    XTime t;
    XTime_GetTime(&t);
    return (uint32_t)(t / (COUNTS_PER_SECOND / 1000));
}

int DG_GetKey(int* pressed, unsigned char* doomKey)
{
  if (s_KeyQueueReadIndex == s_KeyQueueWriteIndex){
    //key queue is empty
    return 0;
  }else{
    unsigned short keyData = s_KeyQueue[s_KeyQueueReadIndex];
    s_KeyQueueReadIndex++;
    s_KeyQueueReadIndex %= KEYQUEUE_SIZE;

    *pressed = keyData >> 8;
    *doomKey = keyData & 0xFF;

    return 1;
  }

  return 0;
}

void DG_SetWindowTitle(const char * title) { (void)title; }

int main(int argc, char **argv)
{
    doomgeneric_Create(argc, argv);

    for (int i = 0; ; i++)
    {
        doomgeneric_Tick();
    }
    
    return 0;
}

