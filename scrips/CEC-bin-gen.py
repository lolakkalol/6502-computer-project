fill  = bytes((int('0xff', 16),))
eeprom = bytes((int('0xff', 16)-int(1),))
sram = bytes((int('0xff', 16)-int(1<<1),))
via = bytes((int('0xff', 16)-int(1<<2),))

with open("enableBin.bin", "wb") as f:
    # AT28C64B-15PU has 0x2000 addressable bytes from 0-0x1FFF!
    # LSb is for the clock
    for i in range(0,int('0x2000', 16)):

        # SRAM
        if (i < int('0x800', 16) and i % 2):
            f.write(sram)
            continue
        
        # VIA; 0xc00 maps to address space 0x600X, where x is all 4 bits hence each addres is mapped to 1/2 byte of memory space
        if (i == int('0xc00 ', 16)):
            f.write(via)
            continue
        
        # EEPROM
        if (i >= int('0x1000', 16)):
            f.write(eeprom)
            continue
    
        f.write(fill)