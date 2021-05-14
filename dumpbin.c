#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

enum {
    BIN_SIZE = 32768,
};

uint8_t binary[BIN_SIZE] = {0xea};

void createBinary(){
    for(int i = 0; i < BIN_SIZE; i++){
        binary[i] = 0xea;
    }
    //boot address
    binary[0x7ffc] = 0x00;
    binary[0x7ffd] = 0x80;
}

int main(int argc, char **argv){
    FILE *f, *input;
    int i = 0;
    input = fopen(argv[1], "rb");
    createBinary();

    if (input == NULL){
        fprintf(stderr, "Could not open input file\n");
    }
     
    int reading = 1;
    while(reading){
        uint8_t byte;
        if(reading = fread(&byte, sizeof(uint8_t), 1, input)){
            binary[i++] = byte;
        }
    }

    fclose(input);
    
    f = fopen("bootrom.bin", "wb");
    if(f == NULL){
        fprintf(stderr, "Could not open bootrom.bin\n");
        return -1;
    }
    fwrite(binary, sizeof(uint8_t), BIN_SIZE, f);
    fclose(f);
}
