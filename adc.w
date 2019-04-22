@ To test, continuously write samples to UART.

From ttps://piandmore.wordpress.com/2016/10/14/photo-resistors-in-depth/: please do not forget to connect 3.3V to ARef which gives a better ready is my experience. = ???

see on youtube avr measure analog voltage

@c
#include <avr/io.h>

int main (void)
{
  uint8_t sample;

  ADMUX = 1 << REFS0 | 1 << ADLAR | 4;
  ADCSRA = 1 << ADEN; /* enable ADC */
  ADCSRA |= (1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0); /* prescaler of 128
                                                       (16000000/128 = 125000) */
  ADCSRA |= 1<<ADSC; /* start conversion */

  while(1) {
    while (ADCSRA & (1<<ADSC)) ;
    sample = ADCH;
    ADCSRA |= (1<<ADSC); /* start conversion */
  }
}
