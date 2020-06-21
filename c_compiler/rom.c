// long* rom_size=(long*)0x1000;
// long* ram_size=(long*)0x1000000;
// long* pci_base=(long*)0xFFFFFFFFFF000000;

int main() {
  extern long* rom_size;
  extern long* ram_size;
  extern long* pci_base;
  long rom_sz_val=*rom_size;
  long ram_sz_val=*ram_size;
  long* hdd_start=(long*)(rom_sz_val+ram_sz_val);
  long len_mask=pci_base[0x12];
  hdd_start=(long*)((long)hdd_start|~len_mask)+1;
  pci_base[0x12]=(long)hdd_start; //set BAR0 of hdd to first free address
  pci_base[0x11]=1; //enable hdd BAR0
  for (short idx=512;idx>0;) {
    idx=idx-1;
    char byte_tmp=hdd_start[idx]; //set r3 to byte from HDD
    ((char*)rom_sz_val)[idx]=byte_tmp; //store HDD byte to RAM
  }
  *rom_sz_val();
}
