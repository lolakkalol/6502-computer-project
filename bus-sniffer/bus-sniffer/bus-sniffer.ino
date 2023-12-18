//uint8_t adress_lines = {};
//uint8_t data_lines   = {};

uint8_t rw_pin    = 37;
uint8_t clk_pin   = 31;
uint8_t pause_pin = 33; // Not an actual pin in the computer but used to temporarily halt the clock

void nextCycle() {
  digitalWrite(clk_pin, LOW);
  digitalWrite(clk_pin, HIGH);
  digitalWrite(clk_pin, LOW);
}

void getBinaryRep(char* buf, uint16_t data) {
  for(uint8_t i = 0; i < 16; i++)
    buf[i] = (data >> i) & 0x0001 ? '1' : '0';

  buf[16] = '\0';
}

void getBinaryRep(char* buf, uint8_t data) {
  for(uint8_t i = 0; i < 8; i++)
    buf[i] = (data >> i) & 0x01 ? '1' : '0';

  buf[8] = '\0';
}

void decodeOP(char* buf, uint8_t op) {
  switch (op) {
    case 0x0:
      sprintf(buf, "BRK");
      break;
    case 0x1:
      sprintf(buf, "ORA(zp,x)");
      break;
    case 0x4:
      sprintf(buf, "TSB(zp)");
      break;
    case 0x5:
      sprintf(buf, "ORA(zp)");
      break;
    case 0x6:
      sprintf(buf, "ASL(zp)");
      break;
    case 0x7:
      sprintf(buf, "RMB0(zp)");
      break;
    case 0x8:
      sprintf(buf, "PHP(s)");
      break;
    case 0x9:
      sprintf(buf, "ORA(#)");
      break;
    case 0xA:
      sprintf(buf, "ASL(A)");
      break;
    case 0xC:
      sprintf(buf, "TSB(a)");
      break;
    case 0xD:
      sprintf(buf, "ORA(a)");
      break;
    case 0xE:
      sprintf(buf, "ASL(a)");
      break;
    case 0xF:
      sprintf(buf, "BBR0(r)");
      break;
    case 0x10:
      sprintf(buf, "BPL(r)");
      break;
    case 0x11:
      sprintf(buf, "ORA(zp),y");
      break;
    case 0x12:
      sprintf(buf, "ORA(zp)");
      break;
    case 0x14:
      sprintf(buf, "TRB(zp)");
      break;
    default:
      sprintf(buf, "UNKNOWN");
      break;
     
  }
}

void setup() {
  Serial.begin(115200);

  // Setup; address pins
  for (uint8_t i = 24; i <= 52; i+=2) {
    pinMode(i, INPUT);
  }
    
  // Setup; data pins
  for (uint8_t i = 39; i <= 53; i+=2)
    pinMode(i, INPUT);

  // Setup; rest of pins
  pinMode(rw_pin, INPUT);
  pinMode(clk_pin, OUTPUT);
  pinMode(pause_pin, INPUT);
}

uint16_t address = 0x0000;
uint8_t  data    = 0x00;

char buf[50];

void loop() {
  // Read address bus
  for (uint8_t i = 22; i <= 52; i+=2) {
    address = address >> 1;
    address |= digitalRead(i) << 15;
  }
  
  // Read data bus
  for (uint8_t i = 39; i <= 53; i+=2) {
    data = data >> 1;
    data |= digitalRead(i) << 7;
  }

  Serial.println("-------------------------------");
  Serial.println("               0123456789ABCDEF");

  // Print and format address
  sprintf(buf, "Addr: 0x%04X : \0", address);
  Serial.print(buf);
  
  getBinaryRep(buf, address);
  Serial.println(buf);

  // Print and format data
  sprintf(buf, "Data: 0x%02X   : \0", data);
  Serial.print(buf);

  getBinaryRep(buf, data);
  Serial.println(buf);

  sprintf(buf, "R/W: %c", digitalRead(rw_pin) ? 'R' : 'W');
  Serial.println(buf);

  // Check for pause button press
  // If pressed: (Check with interrupt?)
    // Pause unit next time it is pressed
  // Else:
    // Perform cycle
    // Clock low
    // Clock high
    // Clock low

    nextCycle();
    delay(1000);
  
}
