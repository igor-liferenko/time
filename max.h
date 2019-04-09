void display_write(unsigned int dc) /* FIXME: will it work without `|unsigned|'? */
{
  for (int i = 16; i > 0; i--) { // shift 16 bits out, msb first
    if (dc & 1 << 15) PORTB |= 1 << PB4;
    else PORTB &= ~(1 << PB4);
    PORTE &= ~(1 << PE6); PORTE |= 1 << PE6;
    dc <<= 1;
  }
  PORTD |= 1 << PD7; PORTD &= ~(1 << PD7);
}

/* Initialization of all registers must be done, because they may contain garbage. */
void MAX_init(void)
{
  DDRB |= 1 << PB4;
  DDRE |= 1 << PE6;
  DDRD |= 1 << PD7;
  display_write(0x0F << 8 | 0x00);
  display_write(0x0C << 8 | 0x00);
  display_write(0x01 << 8 | 0x0F);
  display_write(0x02 << 8 | 0x0F);
  display_write(0x03 << 8 | 0x0F);
  display_write(0x04 << 8 | 0x0F);
  display_write(0x05 << 8 | 0x0F);
  display_write(0x06 << 8 | 0x0F);
  display_write(0x07 << 8 | 0x0F);
  display_write(0x08 << 8 | 0x0F);
  display_write(0x09 << 8 | 0xFF);
  display_write(0x0A << 8 | 0x0F);
  display_write(0x0B << 8 | 0x07);
  display_write(0x0C << 8 | 0x01);
}
