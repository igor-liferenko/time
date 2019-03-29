/* Displaying for each display is done by writing to its row address (not column) due
to configuration of this pacrticular hardware that I have. */

#define NUM_DEVICES 4

#define SS_PIN PB5 /* can be any digital pin (on micro pin labelled with `SS' will not work
  because it has led on it) */
#define SS_DDR DDRB
#define SS_PORT PORTB

#define SLAVE_SELECT    SS_PORT &= ~(1 << SS_PIN)
#define SLAVE_DESELECT  SS_PORT |= (1 << SS_PIN)

#include <avr/io.h>
#include <util/delay.h>
#include <avr/pgmspace.h>
#include <string.h>

const uint8_t d0[8][5] PROGMEM = { 
  { 0, 1, 1, 1, 0 },
  { 1, 0, 0, 0, 1 },
  { 1, 0, 0, 1, 1 },
  { 1, 0, 1, 0, 1 },
  { 1, 1, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d1[8][5] PROGMEM = {
  { 0, 0, 1, 0, 0 },
  { 0, 1, 1, 0, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 0, 1, 0 ,0 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d2[8][5] PROGMEM = {
  { 0, 1, 1, 1, 0 },
  { 1, 0, 0, 0, 1 },
  { 0, 0, 0, 0, 1 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 1, 0, 0, 0 },
  { 1, 1, 1, 1, 1 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d3[8][5] PROGMEM = {
  { 1, 1, 1, 1, 1 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d4[8][5] PROGMEM = {
  { 0, 0, 0, 1, 0 },
  { 0, 0, 1, 1, 0 },
  { 0, 1, 0, 1, 0 },
  { 1, 0, 0, 1, 0 },
  { 1, 1, 1, 1, 1 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d5[8][5] PROGMEM = {
  { 1, 1, 1, 1, 1 },
  { 1, 0, 0, 0, 0 },
  { 1, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 1 },
  { 0, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d6[8][5] PROGMEM = {
  { 0, 0, 1, 1, 0 },
  { 0, 1, 0, 0, 0 },
  { 1, 0, 0, 0, 0 },
  { 1, 1, 1, 1, 0 },
  { 1, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d7[8][5] PROGMEM = {
{1,1,1,1,1},
{1,0,0,0,1},
{0,0,0,1,0},
{0,0,1,0,0},
{0,1,0,0,0},
{0,1,0,0,0},
{0,1,0,0,0},
{0,0,0,0,0}
};

const uint8_t d8[8][5] PROGMEM = {
{0,1,1,1,0},
{1,0,0,0,1},
{1,0,0,0,1},
{0,1,1,1,0},
{1,0,0,0,1},
{1,0,0,0,1},
{0,1,1,1,0},
{0,0,0,0,0}
};

const uint8_t d9[8][5] PROGMEM = {
{0,1,1,1,0},
{1,0,0,0,1},
{1,0,0,0,1},
{0,1,1,1,1},
{0,0,0,0,1},
{0,0,0,1,0},
{0,1,1,0,0},
{0,0,0,0,0}
};

const uint8_t colon[8][5] PROGMEM = {
  { 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0 },
  { 0, 0, 1, 1, 0 },
  { 0, 0, 1, 1, 0 },
  { 0, 0, 0, 0, 0 },
  { 0, 0, 1, 1, 0 },
  { 0, 0, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

uint8_t buffer[8][NUM_DEVICES*8];

void init_SPI(void) 
{
  SS_PORT |= (1 << SS_PIN);      // begin high (unselected)
  SS_DDR |= (1 << SS_PIN);

  DDRB |= (1 << PB2);       // Output on MOSI 
  DDRB |= (1 << PB1);       // Output on SCK 

  SPCR |= (1 << MSTR);      // Clockmaster 
  SPCR |= (1 << SPE);       // Enable SPI
}

void writeByte(uint8_t byte)
{
  SPDR = byte;                      // SPI starts sending immediately  
  while(!(SPSR & (1 << SPIF)));     // Loop until complete bit set
}

void writeWord(uint8_t address, uint8_t data) 
{
  writeByte(address);
  writeByte(data);
}

void init_displays(void)
{
  SLAVE_SELECT;
  for (int i = 0; i < NUM_DEVICES; i++)
    writeWord(0x0A, 0x07); // set brightness (FIXME: try |0x0F|)
  SLAVE_DESELECT;
	
  SLAVE_SELECT;
  for (int i = 0; i < NUM_DEVICES; i++)
    writeWord(0x0B, 0x07); // select columns 0-7
  SLAVE_DESELECT;
	 
  // FIXME: try without it:
  SLAVE_SELECT;
  for (int i = 0; i < NUM_DEVICES; i++)  
    writeWord(0x0F, 0x00);
  SLAVE_DESELECT;

  SLAVE_SELECT;
  for (int i = 0; i < NUM_DEVICES; i++)
    writeWord(0x0C, 0x01);
  SLAVE_DESELECT;
}

void display_buffer(void)
{
  for (int i = 0; i < 8; i++) {
    uint8_t data;
    SLAVE_SELECT;
    for (int j = NUM_DEVICES-1; j>=0; j--) {
      data = 0x00;
      for (int k = 0; k < 8; k++) {
        if (buffer[i][j*8+k]) data |= 1 << 7-k;
      }
      writeWord(i+1, data);
    }
    SLAVE_DESELECT;
  }
}

#define CYC(b) for (int j = 0; j < 5; j++) buffer[i][k--] = pgm_read_byte(&b[i][j]);
void fill_buffer(char *s)
{
for (int i = 0; i < 8; i++) {
  int k = NUM_DEVICES*8-1-2;
  for (int c = 0; c < strlen(s); c++) {
    switch (*(s+c))
    {
    case '0':
      CYC(d0);
      break;
    case '1':
      CYC(d1);
      break;
    case '2':
      CYC(d2);
      break;
    case '3':
      CYC(d3);
      break;
    case '4':
      CYC(d4);
      break;
    case '5':
      CYC(d5);
      break;
    case '6':
      CYC(d6);
      break;
    case '7':
      CYC(d7);
      break;
    case '8':
      CYC(d8);
      break;
    case '9':
      CYC(d9);
      break;
    case ':':
      CYC(colon);
      break;
    }
    buffer[i][k--] = 0x00; // empty space
  }
}
}
