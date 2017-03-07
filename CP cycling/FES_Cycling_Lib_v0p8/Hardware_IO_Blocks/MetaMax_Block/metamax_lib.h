#include "serial_w32.h"
#define MM_EA_SIZE 2*28  // size of data package for 0xEA protocol
#define MM_EA_NDAT  21   // number of values on 0xEA protocol
#define MM_EC_SIZE 2*8   // size of data package for 0xEC protocol
#define MM_EC_NDAT  6    // number of values on 0xEC protocol

/* function to open the port and set it up for communication with tunturi */
int metamax_open(char *port);

/* generate the checksum */
unsigned char metamax_checksum(unsigned char *buf, unsigned int len);

int metamax_recv(HANDLE *hCom, unsigned char *data, unsigned int len);


int tunturi_getcurrentdata(HANDLE *hCom, 
                           unsigned char *angle,
                           unsigned char *beat, 
                           unsigned short *velocity);

void *tunturi_mkshm(char *SharedMemName, unsigned int shm_size );

/* 
   decoding tools
*/
typedef union { 
  WORD w;
  byte b[2];
} u_w_b;

typedef union { 
  DWORD d;
  byte b[4];
} u_d_b;

struct METAMAX {
  WORD prot_id;
  WORD lfd_nr;
  DWORD t_meas;
  WORD vt;
  WORD feto2;
  WORD fetco2;
  WORD tu;
  WORD pu;
  WORD peak_exp;
  WORD af;
  WORD hf;
  WORD fio2;
  WORD fico2;
  WORD t_flow;
  WORD vi;
  WORD dummy1;
  WORD dummy2;
  WORD analog1;
  WORD t_insp;
  WORD t_exp;
  WORD peak_insp;
  WORD t_peakin;
  WORD t_peakex;
  WORD volo2;
  WORD volco2;
  WORD dummy3;
  WORD chksum;
} metamax_data;

union metamax_union 
{
  char array[MM_EA_SIZE];
  WORD warray[MM_EA_SIZE/2];
  struct METAMAX data;
};

struct METAMAX_EC {
  WORD prot_id;  // 0 1
  WORD lfd_nr;   // 2 3
  WORD O2;     // 4 5
  WORD CO2;     // 6 7
  WORD flow;     // 8 9
  WORD ecg1;     // 10 11
  WORD ecg2;     // 12 13
  WORD chksum;     // 14 15
} metamax_ec;

union metamax_ec_union 
{
  char array[MM_EC_SIZE];
  WORD warray[MM_EC_SIZE/2];
  struct METAMAX_EC data;
};


WORD decodeWord(WORD wValue);
int decodeInt(WORD wValue);
DWORD decodeDWord(DWORD dValue);

void decode_mmu(union metamax_union *mmu);
void decode_mmu_ec(union metamax_ec_union *mmu);
void print_mmu(union metamax_union *mmu);
void calib_mmu(union metamax_union *mmu, double *mm_array);
void calib_mmu_ec(union metamax_ec_union *mmu, double *mm_array);
