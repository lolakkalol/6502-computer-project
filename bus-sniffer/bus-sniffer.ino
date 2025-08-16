//uint8_t adress_lines = {};
//uint8_t data_lines   = {};

uint8_t rw_pin    = 37;
uint8_t clk_pin   = 31;
uint8_t pause_pin = 33; // Not an actual pin in the computer but used to temporarily halt the clock

// Trigger
uint8_t triggered = 0;
uint8_t t_event = 1;
uint8_t event_count = 0;

bool clk = false;

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
    case 0x69:
        sprintf(buf, "ADC #Oper");
        break;
    case 0x72:
        sprintf(buf, "ADC (ZP)");
        break;
    case 0x71:
        sprintf(buf, "ADC (ZP),Y");
        break;
    case 0x61:
        sprintf(buf, "ADC (ZP,X)");
        break;
    case 0x6D:
        sprintf(buf, "ADC Abs");
        break;
    case 0x7D:
        sprintf(buf, "ADC Abs,X");
        break;
    case 0x79:
        sprintf(buf, "ADC Abs,Y");
        break;
    case 0x65:
        sprintf(buf, "ADC ZP");
        break;
    case 0x75:
        sprintf(buf, "ADC ZP,X");
        break;
    case 0x29:
        sprintf(buf, "AND #Oper");
        break;
    case 0x32:
        sprintf(buf, "AND (ZP)");
        break;
    case 0x31:
        sprintf(buf, "AND (ZP),Y");
        break;
    case 0x21:
        sprintf(buf, "AND (ZP,X)");
        break;
    case 0x2D:
        sprintf(buf, "AND Abs");
        break;
    case 0x3D:
        sprintf(buf, "AND Abs,X");
        break;
    case 0x39:
        sprintf(buf, "AND Abs,Y");
        break;
    case 0x25:
        sprintf(buf, "AND ZP");
        break;
    case 0x35:
        sprintf(buf, "AND ZP,X");
        break;
    case 0x0A:
        sprintf(buf, "ASL A");
        break;
    case 0x0E:
        sprintf(buf, "ASL Abs");
        break;
    case 0x1E:
        sprintf(buf, "ASL Abs,X");
        break;
    case 0x6:
        sprintf(buf, "ASL ZP");
        break;
    case 0x16:
        sprintf(buf, "ASL ZP,X");
        break;
    case 0x0F:
        sprintf(buf, "BBR0 Oper");
        break;
    case 0x1F:
        sprintf(buf, "BBR1 Oper");
        break;
    case 0x2F:
        sprintf(buf, "BBR2 Oper");
        break;
    case 0x3F:
        sprintf(buf, "BBR3 Oper");
        break;
    case 0x4F:
        sprintf(buf, "BBR4 Oper");
        break;
    case 0x5F:
        sprintf(buf, "BBR5 Oper");
        break;
    case 0x6F:
        sprintf(buf, "BBR6 Oper");
        break;
    case 0x7F:
        sprintf(buf, "BBR7 Oper");
        break;
    case 0x8F:
        sprintf(buf, "BBS0 Oper");
        break;
    case 0x9F:
        sprintf(buf, "BBS1 Oper");
        break;
    case 0xAF:
        sprintf(buf, "BBS2 Oper");
        break;
    case 0xBF:
        sprintf(buf, "BBS3 Oper");
        break;
    case 0xCF:
        sprintf(buf, "BBS4 Oper");
        break;
    case 0xDF:
        sprintf(buf, "BBS5 Oper");
        break;
    case 0xEF:
        sprintf(buf, "BBS6 Oper");
        break;
    case 0xFF:
        sprintf(buf, "BBS7 Oper");
        break;
    case 0x90:
        sprintf(buf, "BCC Oper");
        break;
    case 0xB0:
        sprintf(buf, "BCS Oper");
        break;
    case 0xF0:
        sprintf(buf, "BEQ Oper");
        break;
    case 0x89:
        sprintf(buf, "BIT #Oper");
        break;
    case 0x2C:
        sprintf(buf, "BIT Abs");
        break;
    case 0x3C:
        sprintf(buf, "BIT Abs,X");
        break;
    case 0x24:
        sprintf(buf, "BIT ZP");
        break;
    case 0x34:
        sprintf(buf, "BIT ZP,X");
        break;
    case 0x30:
        sprintf(buf, "BMI Oper");
        break;
    case 0xD0:
        sprintf(buf, "BNE Oper");
        break;
    case 0x10:
        sprintf(buf, "BPL Oper");
        break;
    case 0x80:
        sprintf(buf, "BRA Oper");
        break;
    case 0x0:
        sprintf(buf, "BRK");
        break;
    case 0x50:
        sprintf(buf, "BVC Oper");
        break;
    case 0x70:
        sprintf(buf, "BVS Oper");
        break;
    case 0x18:
        sprintf(buf, "CLC");
        break;
    case 0xD8:
        sprintf(buf, "CLD");
        break;
    case 0x58:
        sprintf(buf, "CLI");
        break;
    case 0xB8:
        sprintf(buf, "CLV");
        break;
    case 0xC9:
        sprintf(buf, "CMP #Oper");
        break;
    case 0xD2:
        sprintf(buf, "CMP (ZP)");
        break;
    case 0xD1:
        sprintf(buf, "CMP (ZP),Y");
        break;
    case 0xC1:
        sprintf(buf, "CMP (ZP,X)");
        break;
    case 0xCD:
        sprintf(buf, "CMP Abs");
        break;
    case 0xDD:
        sprintf(buf, "CMP Abs,X");
        break;
    case 0xD9:
        sprintf(buf, "CMP Abs,Y");
        break;
    case 0xC5:
        sprintf(buf, "CMP ZP");
        break;
    case 0xD5:
        sprintf(buf, "CMP ZP");
        break;
    case 0xE0:
        sprintf(buf, "CPX #Oper");
        break;
    case 0xEC:
        sprintf(buf, "CPX Abs");
        break;
    case 0xE4:
        sprintf(buf, "CPX ZP");
        break;
    case 0xC0:
        sprintf(buf, "CPY #Oper");
        break;
    case 0xCC:
        sprintf(buf, "CPY Abs");
        break;
    case 0xC4:
        sprintf(buf, "CPY ZP");
        break;
    case 0x3A:
        sprintf(buf, "DEA");
        break;
    case 0xCE:
        sprintf(buf, "DEC Abs");
        break;
    case 0xDE:
        sprintf(buf, "DEC Abs,X");
        break;
    case 0xC6:
        sprintf(buf, "DEC ZP");
        break;
    case 0xD6:
        sprintf(buf, "DEC ZP,X");
        break;
    case 0xCA:
        sprintf(buf, "DEX");
        break;
    case 0x88:
        sprintf(buf, "DEY");
        break;
    case 0x49:
        sprintf(buf, "EOR #Oper");
        break;
    case 0x52:
        sprintf(buf, "EOR (ZP)");
        break;
    case 0x51:
        sprintf(buf, "EOR (ZP),Y");
        break;
    case 0x41:
        sprintf(buf, "EOR (ZP,X)");
        break;
    case 0x4D:
        sprintf(buf, "EOR Abs");
        break;
    case 0x5D:
        sprintf(buf, "EOR Abs,X");
        break;
    case 0x59:
        sprintf(buf, "EOR Abs,Y");
        break;
    case 0x45:
        sprintf(buf, "EOR ZP");
        break;
    case 0x55:
        sprintf(buf, "EOR ZP,X");
        break;
    case 0x1A:
        sprintf(buf, "INA");
        break;
    case 0xEE:
        sprintf(buf, "INC Abs");
        break;
    case 0xFE:
        sprintf(buf, "INC Abs,X");
        break;
    case 0xE6:
        sprintf(buf, "INC ZP");
        break;
    case 0xF6:
        sprintf(buf, "INC ZP,X");
        break;
    case 0xE8:
        sprintf(buf, "INX");
        break;
    case 0xC8:
        sprintf(buf, "INY");
        break;
    case 0x6C:
        sprintf(buf, "JMP (Abs)");
        break;
    case 0x7C:
        sprintf(buf, "JMP (Abs,X)");
        break;
    case 0x4C:
        sprintf(buf, "JMP Abs");
        break;
    case 0x20:
        sprintf(buf, "JSR Abs");
        break;
    case 0xA9:
        sprintf(buf, "LDA #Oper");
        break;
    case 0xB2:
        sprintf(buf, "LDA (ZP)");
        break;
    case 0xB1:
        sprintf(buf, "LDA (ZP),Y");
        break;
    case 0xA1:
        sprintf(buf, "LDA (ZP,X)");
        break;
    case 0xAD:
        sprintf(buf, "LDA Abs");
        break;
    case 0xBD:
        sprintf(buf, "LDA Abs,X");
        break;
    case 0xB9:
        sprintf(buf, "LDA Abs,Y");
        break;
    case 0xA5:
        sprintf(buf, "LDA ZP");
        break;
    case 0xB5:
        sprintf(buf, "LDA ZP,X");
        break;
    case 0xA2:
        sprintf(buf, "LDX #Oper");
        break;
    case 0xAE:
        sprintf(buf, "LDX Abs");
        break;
    case 0xBE:
        sprintf(buf, "LDX Abs,Y");
        break;
    case 0xA6:
        sprintf(buf, "LDX ZP");
        break;
    case 0xB6:
        sprintf(buf, "LDX ZP,Y");
        break;
    case 0xA0:
        sprintf(buf, "LDY #Oper");
        break;
    case 0xAC:
        sprintf(buf, "LDY Abs");
        break;
    case 0xBC:
        sprintf(buf, "LDY Abs,X");
        break;
    case 0xA4:
        sprintf(buf, "LDY ZP");
        break;
    case 0xB4:
        sprintf(buf, "LDY ZP,X");
        break;
    case 0x4A:
        sprintf(buf, "LSR A");
        break;
    case 0x4E:
        sprintf(buf, "LSR Abs");
        break;
    case 0x5E:
        sprintf(buf, "LSR Abs,X");
        break;
    case 0x46:
        sprintf(buf, "LSR ZP");
        break;
    case 0x56:
        sprintf(buf, "LSR ZP,X");
        break;
    case 0xEA:
        sprintf(buf, "NOP");
        break;
    case 0x9:
        sprintf(buf, "ORA #Oper");
        break;
    case 0x12:
        sprintf(buf, "ORA (ZP)");
        break;
    case 0x11:
        sprintf(buf, "ORA (ZP),Y");
        break;
    case 0x1:
        sprintf(buf, "ORA (ZP,X)");
        break;
    case 0x0D:
        sprintf(buf, "ORA Abs");
        break;
    case 0x1D:
        sprintf(buf, "ORA Abs,X");
        break;
    case 0x19:
        sprintf(buf, "ORA Abs,Y");
        break;
    case 0x5:
        sprintf(buf, "ORA ZP");
        break;
    case 0x15:
        sprintf(buf, "ORA ZP,X");
        break;
    case 0x48:
        sprintf(buf, "PHA");
        break;
    case 0xDA:
        sprintf(buf, "PHX");
        break;
    case 0x5A:
        sprintf(buf, "PHY");
        break;
    case 0x68:
        sprintf(buf, "PLA");
        break;
    case 0xFA:
        sprintf(buf, "PLX");
        break;
    case 0x7A:
        sprintf(buf, "PLY");
        break;
    case 0x2A:
        sprintf(buf, "ROL A");
        break;
    case 0x2E:
        sprintf(buf, "ROL Abs");
        break;
    case 0x3E:
        sprintf(buf, "ROL Abs,X");
        break;
    case 0x26:
        sprintf(buf, "ROL ZP");
        break;
    case 0x36:
        sprintf(buf, "ROL ZP,X");
        break;
    case 0x6A:
        sprintf(buf, "ROR A");
        break;
    case 0x6E:
        sprintf(buf, "ROR Abs");
        break;
    case 0x7E:
        sprintf(buf, "ROR Abs,X");
        break;
    case 0x66:
        sprintf(buf, "ROR ZP");
        break;
    case 0x76:
        sprintf(buf, "ROR ZP,X");
        break;
    case 0x40:
        sprintf(buf, "RTI");
        break;
    case 0x60:
        sprintf(buf, "RTS");
        break;
    case 0xE9:
        sprintf(buf, "SBC #Oper");
        break;
    case 0xF2:
        sprintf(buf, "SBC (ZP)");
        break;
    case 0xF1:
        sprintf(buf, "SBC (ZP),Y");
        break;
    case 0xE1:
        sprintf(buf, "SBC (ZP,X)");
        break;
    case 0xED:
        sprintf(buf, "SBC Abs");
        break;
    case 0xFD:
        sprintf(buf, "SBC Abs,X");
        break;
    case 0xF9:
        sprintf(buf, "SBC Abs,Y");
        break;
    case 0xE5:
        sprintf(buf, "SBC ZP");
        break;
    case 0xF5:
        sprintf(buf, "SBC ZP,X");
        break;
    case 0x38:
        sprintf(buf, "SEC");
        break;
    case 0xF8:
        sprintf(buf, "SED");
        break;
    case 0x78:
        sprintf(buf, "SEI");
        break;
    case 0x92:
        sprintf(buf, "STA (ZP)");
        break;
    case 0x91:
        sprintf(buf, "STA (ZP),Y");
        break;
    case 0x81:
        sprintf(buf, "STA (ZP,X)");
        break;
    case 0x8D:
        sprintf(buf, "STA Abs");
        break;
    case 0x9D:
        sprintf(buf, "STA Abs,X");
        break;
    case 0x99:
        sprintf(buf, "STA Abs,Y");
        break;
    case 0x85:
        sprintf(buf, "STA ZP");
        break;
    case 0x95:
        sprintf(buf, "STA ZP,X");
        break;
    case 0x8E:
        sprintf(buf, "STX Abs");
        break;
    case 0x86:
        sprintf(buf, "STX ZP");
        break;
    case 0x96:
        sprintf(buf, "STX ZP,Y");
        break;
    case 0x8C:
        sprintf(buf, "STY Abs");
        break;
    case 0x84:
        sprintf(buf, "STY ZP");
        break;
    case 0x94:
        sprintf(buf, "STY ZP,X");
        break;
    case 0x9C:
        sprintf(buf, "STZ Abs");
        break;
    case 0x9E:
        sprintf(buf, "STZ Abs,X");
        break;
    case 0x64:
        sprintf(buf, "STZ ZP");
        break;
    case 0x74:
        sprintf(buf, "STZ ZP,X");
        break;
    case 0xAA:
        sprintf(buf, "TAX");
        break;
    case 0xA8:
        sprintf(buf, "TAY");
        break;
    case 0x1C:
        sprintf(buf, "TRB Abs");
        break;
    case 0x14:
        sprintf(buf, "TRB ZP");
        break;
    case 0x0C:
        sprintf(buf, "TSB Abs");
        break;
    case 0x4:
        sprintf(buf, "TSB ZP");
        break;
    case 0xBA:
        sprintf(buf, "TSX");
        break;
    case 0x8A:
        sprintf(buf, "TXA");
        break;
    case 0x9A:
        sprintf(buf, "TXS");
        break;
    case 0x98:
        sprintf(buf, "TYA");
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

  sprintf(buf, "OP: ");
  Serial.print(buf);
  decodeOP(buf, data);
  Serial.println(buf);

  sprintf(buf, "R/W: %c\0", digitalRead(rw_pin) ? 'R' : 'W');
  Serial.println(buf);

  sprintf(buf, "Clk: %c", clk ? 'H' : 'L');
  Serial.println(buf);

  while (digitalRead(pause_pin) == 0)
    delay(100);
  
  clk = !clk;
  digitalWrite(clk_pin, clk ? HIGH : LOW);
  //nextCycle();
  delay(200);
  
}
