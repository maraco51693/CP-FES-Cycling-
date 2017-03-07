/* 
   collection of function to use with tuturi treadmill
   uses serial_w32.cpp
 */

#include "metamax_lib.h"
#include "serial_w32.h"

/* 
   metamax_open()
   open and setup serial port
 */

int metamax_open(char *port)
{
  HANDLE hCom;
  BOOL fSuccess;
  
  printf("Opening serial port %s...", port);
  hCom=serial_openport(port);
  if (hCom == INVALID_HANDLE_VALUE) {
    printf("failed.\n");
    return 0;
  }
  fSuccess=serial_setupport(hCom,
                            128,0,  //input & output buffer sizes
                            19200,  //BaudRate
                            FALSE,  //fParity
                            8,     //Bytesize
                            NOPARITY,     //Parity
                            TWOSTOPBITS,     //Stopbits
                            //MAXDWORD, //ReadIntervalTimeout
                            0, //ReadIntervalTimeout
                            //5,1000,   //ReadTotalTimeoutMultiplier, ReadTotalTimeoutConstant
                            0,1000,   //ReadTotalTimeoutMultiplier, ReadTotalTimeoutConstant
                            1,1    //WriteTotalTimeoutMultiplier, WriteTotalTimeoutConstant
                            );
  if (!fSuccess) {
    printf("failed.\n");
    printf("Could not setup serial port.\n");
    return 0;
  }

  // success, return the handle to the port
  return (int) hCom;
}

/*---------------------------------------------------------------*/
unsigned char metamax_checksum(unsigned char *buf, unsigned int len)
{
  char cs=0;
  unsigned int k;

  for (k=0;k<len; k++){
    cs ^= buf[k];   // equivalent to cs = cs ^ buf[k], ^ is the XOR operator
  }
  return cs;
}

/*---------------------------------------------------------------*/
/*---------------------------------------------------------------*/
int metamax_recv(HANDLE *hCom, unsigned char *data, unsigned int len)
{
  unsigned char recvbuf[100], cs;  //large enough buffer
  unsigned int ret, total_len,k;

  serial_readstring(*hCom, data,  len);
  
  /* len is the expected data length
     need to add Start, XOR and End (=3bytes) */
  /*
  total_len = len+3;
  serial_readstring(*hCom, recvbuf,  total_len);
#ifdef VERBOSE
  printf("received: ");
  for(k=0;k<total_len;k++)
    printf("0x%x ", (unsigned char) recvbuf[k]);
  printf("\n");
#endif
  ret = -1;
  if ((unsigned char)recvbuf[0]== 0xf1 && 
      (unsigned char) recvbuf[total_len-1]==0xf2) { 
#ifdef VERBOSE
    printf("message received...");
#endif
#ifdef VERBOSE
      printf("checksum valid\n");
#endif
    }
  */

  return 0;
}

/*---------------------------------------------------------------*/


WORD decodeWord(WORD wValue)
{
  u_w_b uw;
  uw.w=wValue;
  return( (uw.b[1]<<7)+uw.b[0] );
}

int decodeInt(WORD wValue)
{
  WORD w;
  
  w=decodeWord(wValue);
  if(w>8191) w=w-16384;
  return(w);
}

DWORD decodeDWord(DWORD dValue)
{
  u_d_b db;
  int i;
  DWORD d;

  d=0;
  db.d=dValue;
  for(i=0;i<3;i++)d=(d+db.b[3-i])<<7;
  d=d+db.b[0];
  return(d);
}

void decode_mmu(union metamax_union *mmu)
{
  WORD chksum=0;

  mmu->data.prot_id = decodeWord(mmu->data.prot_id); 
  mmu->data.lfd_nr = decodeWord(mmu->data.lfd_nr); 
  mmu->data.t_meas = decodeDWord(mmu->data.t_meas); 
  mmu->data.vt = decodeWord(mmu->data.vt); 
  mmu->data.feto2 = decodeWord(mmu->data.feto2); 
  mmu->data.fetco2 = decodeWord(mmu->data.fetco2); 
  mmu->data.tu = decodeInt((WORD) mmu->data.tu); 
  mmu->data.pu = decodeWord(mmu->data.pu); 
  mmu->data.peak_exp = decodeWord(mmu->data.peak_exp); 
  mmu->data.peak_insp = decodeWord(mmu->data.peak_insp); 
  mmu->data.af = decodeWord(mmu->data.af); 
  mmu->data.hf = decodeWord(mmu->data.hf); 
  mmu->data.fio2 = decodeWord(mmu->data.fio2); 
  mmu->data.fico2 = decodeWord(mmu->data.fico2); 
  mmu->data.t_flow = decodeInt((WORD) mmu->data.t_flow); 
  mmu->data.vi = decodeWord(mmu->data.vi); 
  mmu->data.t_insp = decodeWord(mmu->data.t_insp); 
  mmu->data.t_exp = decodeWord(mmu->data.t_exp); 
  mmu->data.t_peakin = decodeWord(mmu->data.t_peakin); 
  mmu->data.t_peakex = decodeWord(mmu->data.t_peakex); 
  mmu->data.volo2 = decodeWord(mmu->data.volo2); 
  mmu->data.volco2 = decodeWord(mmu->data.volco2); 

  /*
  for (k=1;k<26;k++){
    chksum=chksum+ (mmu.warray[k]);
  }
  mmu.data.chksum = decodeWord(mmu.data.chksum); 
  printf("Checksum: 0x%X [0x%X 0x%X]\n" , mmu.data.chksum, chksum, (chksum & 0x7F7F));

  */
}

void print_mmu(union metamax_union *mmu)
{
  printf("Prot_ID:\t%u\t(0x%X)\n",mmu->data.prot_id, mmu->data.prot_id);
  printf("lfd_nr:\t\t%u \n",mmu->data.lfd_nr);
  printf("t_meas:\t\t%u\t%g [s]\n",mmu->data.t_meas,mmu->data.t_meas/1000.);
  printf("VT [ml]:\t%u \n",mmu->data.vt);
  printf("FETO2 :\t\t%u\t(%g%%) \n",mmu->data.feto2,mmu->data.feto2/100.);
  printf("FETCO2 :\t%u\t(%g%%) \n",mmu->data.fetco2,mmu->data.fetco2/100.);
  printf("T umgebung :\t%u\t(%g C) \n",mmu->data.tu,mmu->data.tu/10.);
  printf("P umgebung :\t\t%u mbar \n",mmu->data.pu);
  printf("Exp peak flow :\t%u\t(%g ml/s) \n",mmu->data.peak_exp,mmu->data.peak_exp*2.5);
  printf("Insp peak flow :%u\t(%g ml/s) \n",mmu->data.peak_insp,mmu->data.peak_insp*2.5);
  printf("Atemfrequenz:\t\t%u/min \n",mmu->data.af);
  printf("Herzfrequenz:\t\t%u/min \n",mmu->data.hf);
  printf("FIO2 :\t\t%u\t(%g%%) \n",mmu->data.fio2,mmu->data.fio2/100.);
  printf("FICO2 : \t%u\t(%g%%) \n",mmu->data.fico2,mmu->data.fico2/100.);
  printf("Atemtemp :\t%u\t(%g C) \n",mmu->data.t_flow,mmu->data.t_flow/10.);
  printf("Atemvolumen:\t\t%uml \n",mmu->data.vi);
  printf("Insp Dauer:\t\t%ums \n",mmu->data.t_insp);
  printf("Exp Dauer:\t\t%ums \n",mmu->data.t_exp);
  printf("Rel. T in:\t\t%ums \n",mmu->data.t_peakin);
  printf("Rel. T ex:\t\t%ums \n",mmu->data.t_peakex);
  printf("Vol O2: \t\t%uml \n",mmu->data.volo2);
  printf("Vol CO2:\t\t%uml \n",mmu->data.volco2);
  fflush(stdout);
}

void calib_mmu(union metamax_union *mmu, double *ma)
{
  ma[0]=mmu->data.lfd_nr;
  ma[1]=mmu->data.t_meas/1000.;

  ma[2]=mmu->data.tu/10.;
  ma[3]=mmu->data.pu;

  ma[4]=mmu->data.feto2/100.;
  ma[5]=mmu->data.fetco2/100.;
  ma[6]=mmu->data.fio2/100.;
  ma[7]=mmu->data.fico2/100.;

  ma[8]=mmu->data.vt;
  ma[9]=mmu->data.vi;

  ma[10]=mmu->data.volo2;
  ma[11]=mmu->data.volco2;

  ma[12]=mmu->data.peak_insp*2.5;
  ma[13]=mmu->data.peak_exp*2.5;

  ma[14]=mmu->data.t_insp;
  ma[15]=mmu->data.t_exp;

  ma[16]=mmu->data.t_peakin;
  ma[17]=mmu->data.t_peakex;

  ma[18]=mmu->data.t_flow/10.;

  ma[19]=mmu->data.af;
  ma[20]=mmu->data.hf;
}

void decode_mmu_ec(union metamax_ec_union *mmu)
{
  mmu->data.prot_id = decodeWord(mmu->data.prot_id); 
  mmu->data.lfd_nr = decodeWord(mmu->data.lfd_nr); 
  mmu->data.O2 = decodeWord(mmu->data.O2); 
  mmu->data.CO2 = decodeWord(mmu->data.CO2); 
  mmu->data.flow = decodeInt((WORD) mmu->data.flow); 
  mmu->data.ecg1 = decodeWord(mmu->data.ecg1); 
  mmu->data.ecg2 = decodeWord(mmu->data.ecg2); 
  mmu->data.chksum = decodeWord(mmu->data.chksum); 
}

void calib_mmu_ec(union metamax_ec_union *mmu, double *ma)
{
  ma[0]=(double) mmu->data.lfd_nr;
  ma[1]=(double) mmu->data.O2 / 100.;
  ma[2]=(double) mmu->data.CO2 / 100.;
  ma[3]=(double) mmu->data.flow;
  /* this is very strange: 
     decodeInt should make sure that the returned value is between 
     -0xffff/2 and +0xffff
     It normally does (see mmu) but not for this value.
     Hence we need this extra bit of code 
  */
  if (ma[3]>0xffff/2)
    ma[3]=0xffff-ma[3];
  ma[3]=ma[3]*2.5;
  ma[4]=(double) mmu->data.ecg1;
  ma[5]=(double) mmu->data.ecg2;
}
