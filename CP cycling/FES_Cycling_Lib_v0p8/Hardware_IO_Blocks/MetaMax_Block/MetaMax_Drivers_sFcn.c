/* --------------------------------------------------------------------- */
/*   File: MetaMax_Drivers_sFcn.c
/* Author: Henrik Gollee
/*   Date: 3 Feb. 2003
/* --------------------------------------------------------------------- */
/* Discription:
/* This is the s-function code that contains the drivers for connecting
/* to the MetaMax 3B with Win32.  For use with RTW the additional libs
/* must be set using:
/*   set_param('name_of_S-Function', 'S-Function_modules', ...
/*   'metamax_lib serial_w32');
/*
/* To compile this with mex use:
/*   mex MetaMax_Drivers_sFcn metamax_lib.c serial_w32.c
/*
/* --------------------------------------------------------------------- */
/* Updates:
/* 8 Sep. 2003: Ben Saunders
/*   Added this documentation format and other comments through out the
/*   S-function.
/*
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* S-function preamble */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  MetaMax_Drivers_sFcn

#include "simstruc.h"

#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <process.h>
#include "serial_w32.h" /* Include serial port drivers */
#include "metamax_lib.h" /* Include the MetaMax library software */


/* --------------------------------------------------------------------- */
/* User defines - using macros for s-function parameters */

#define VERBOSE

#define SAMPLETIME(S)  ssGetSFcnParam(S,0)
#define COMPORT(S)     ssGetSFcnParam(S,1)


/* --------------------------------------------------------------------- */
/* Global variables */

static char mm_termflag;               // termination flag for the sub-thread.
static double mm_array[MM_EA_NDAT];    // return array
static double mm_ec_array[MM_EC_NDAT]; // return array
static char mm_comport;                // number of the serial port
static int mm_threadrunning;           // flag indicating running sub-thread
static HANDLE mm_fd;                   // handle to the serial port

static void datacollection_thread() /* Thread for communication with serial line interface. */
{
  BOOL fSuccess = 0;
  char port[4];
  unsigned char recv_buf[2];               // 2 chars
  unsigned char recv_buf_ea[MM_EA_SIZE-2]; // 27 words
  unsigned char recv_buf_ec[MM_EC_SIZE-2]; // 7 words
  union metamax_union mmu;
  union metamax_ec_union mmu_ec;
  int s_pos, k, l;
  mm_termflag = 0;
  mm_threadrunning = 1;

  switch (mm_comport) { 
  case 1: case 2: case 3: case 4: /* COM1 - COM4*/
    sprintf(port,"COM%i",mm_comport);
    break;
  default:
    mm_threadrunning = 0;
    _endthread();
    break;
  }

  mm_threadrunning = 2;
  mm_fd = (HANDLE) metamax_open(port);
  if (!mm_fd) {
    mm_threadrunning = -1;
    _endthread();
  }
    
  mm_threadrunning = 10;
  while(!mm_termflag) {
    //while simulation is running... (mm_termflag is set in mdlTerminate)
    mm_threadrunning++;

    memset(recv_buf, 0, sizeof(recv_buf));
    memset(recv_buf_ea, 0, sizeof(recv_buf_ea));
    memset(recv_buf_ec, 0, sizeof(recv_buf_ec));
    memset(mmu.array, 0, sizeof(mmu.array));
    memset(mmu_ec.array, 0, sizeof(mmu_ec.array));

    metamax_recv(&mm_fd, recv_buf, 2);
    if (recv_buf[0]==0xEA & recv_buf[1]==0x00) {
      //start of breathing package detected
      mmu.array[0]=recv_buf[0];
      mmu.array[1]=recv_buf[1];

      // receive the remaining bytes
      metamax_recv(&mm_fd, recv_buf_ea, MM_EA_SIZE-2);
      for (l=0;l<(MM_EA_SIZE-2);l++)
	mmu.array[l+2]=recv_buf_ea[l];
      
      // now data_buf should contain a complete breathing package.
      // Analyse and calibrate it!
      decode_mmu(&mmu);
      calib_mmu(&mmu,&mm_array);
    } else if (recv_buf[0]==0xEC & recv_buf[1]==0x00) {
      //start of cont package detected
      mmu_ec.array[0]=recv_buf[0];
      mmu_ec.array[1]=recv_buf[1];

      // receive the remaining bytes
      metamax_recv(&mm_fd, recv_buf_ec, MM_EC_SIZE-2);
      for (l=0;l<(MM_EC_SIZE-2);l++)
	mmu_ec.array[l+2]=recv_buf_ec[l];

      // now data_buf should contain a complete breathing package.
      // Analyse and calibrate it!
      decode_mmu_ec(&mmu_ec);
      calib_mmu_ec(&mmu_ec,&mm_ec_array);
    } 
  }

  fSuccess=serial_closeport(mm_fd);
  mm_threadrunning = 0;
  _endthread();
}
/*-----------------------------------------------------------------------*/
 
 
 /*====================*
 * S-function methods *
 *====================*/
 
static void mdlInitializeSizes(SimStruct *S)
{
  /* See sfuntmpl.doc for more details on the macros below */
  
  ssSetNumSFcnParams(S, 2);  /* Number of expected parameters */
  if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
    /* Return if number of expected != number of actual parameters */
    return;
  }
  
  ssSetNumContStates(S, 0);
  ssSetNumDiscStates(S, 0);
  
  if (!ssSetNumInputPorts(S, 0)) return;
  
  if (!ssSetNumOutputPorts(S, 3)) return;
  ssSetOutputPortWidth(S, 0, MM_EA_NDAT);
  ssSetOutputPortWidth(S, 1, MM_EC_NDAT);
  ssSetOutputPortWidth(S, 2, 1);
  
  ssSetNumSampleTimes(S, 1); 
  ssSetNumRWork(S, 0); 
  ssSetNumIWork(S, 0); 
  ssSetNumPWork(S, 0); 
  ssSetNumModes(S, 0); 
  ssSetNumNonsampledZCs(S, 0); 
  ssSetOptions(S, 0); 
} 

 
static void mdlInitializeSampleTimes(SimStruct *S) 
{ 
  if (!mxIsDouble(SAMPLETIME(S))) {
    ssSetErrorStatus(S,"The 1st argument needs to be the sample time, e.g. 0.05.\n");
    return;
  } else {
    if (mxGetNumberOfElements(SAMPLETIME(S))!=1) {
      ssSetErrorStatus(S,"The 1st argument needs to be scalar, e.g. 0.05.\n");
      return;
    } else {
      ssSetSampleTime(S, 0, mxGetScalar(SAMPLETIME(S)));
      ssSetOffsetTime(S, 0, 0.0);
    }
  }
} 
 
 
#undef MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */ 
#if defined(MDL_INITIALIZE_CONDITIONS) 
static void mdlInitializeConditions(SimStruct *S) 
{ 
} 
#endif /* MDL_INITIALIZE_CONDITIONS */
 
#define MDL_START  /* Change to #undef to remove function */ 
#if defined(MDL_START) 
static void mdlStart(SimStruct *S)
{
  char num;

  /* read the second argument (comport) */
  if (!mxIsDouble(COMPORT(S))) {
    ssSetErrorStatus(S,"The 2nd argument needs to be the number of the serial port, e.g. 1 for COM1, 2 for COM2 etc.\n");
    return;
  } else {
    if (mxGetNumberOfElements(COMPORT(S))!=1) {
      ssSetErrorStatus(S,"The 2nd argument needs to be scalar, e.g. 1 or 2.\n");
      return;
    } else {
      mm_comport = mxGetScalar(COMPORT(S));
    }
  }

  /* initialise the return vector and create the data collection thread */ 
  memset(mm_array,0,sizeof(mm_array));
  memset(mm_ec_array,0,sizeof(mm_ec_array));
#ifdef VERBOSE
  printf("Creating data acquisition thread...");
#endif
  mm_threadrunning = 0;
  _beginthread(datacollection_thread, 0, NULL);
#ifdef VERBOSE
  printf("done.\n"); fflush(stdout);
#endif
  Sleep(100);
  if (mm_threadrunning < 0) { // something wrong
    ssSetErrorStatus(S,"Error opening serial port");
  }
}
#endif /*  MDL_START */
 
 
static void mdlOutputs(SimStruct *S, int_T tid)
{
  real_T            *y0    = ssGetOutputPortRealSignal(S,0);
  real_T            *y1    = ssGetOutputPortRealSignal(S,1);
  real_T            *y2    = ssGetOutputPortRealSignal(S,2);
  int k;
 
  for (k=0;k<MM_EA_NDAT;k++)
    y0[k]= (real_T) mm_array[k];

  for (k=0;k<MM_EC_NDAT;k++)
    y1[k]= (real_T) mm_ec_array[k];

  y2[0]=mm_threadrunning;

}
 
 
static void mdlTerminate(SimStruct *S) 
{ 
  mm_termflag = 1;
  Sleep(100);
  if (mm_threadrunning){
    printf("Waiting for thread to terminate..."); fflush(stdout);
    Sleep(1000);
    if (mm_threadrunning){
      printf("Warning: Thread still running.\n");
      printf("Closing port: ");
      if (serial_closeport(mm_fd))
	printf("successful\n");
      else
	printf("failed\n");
    }
    else {
      printf("done.\n"); fflush(stdout);
      //printf("mm_termflag = %i , mm_threadrunning = %i\n",mm_termflag, mm_threadrunning);
    }
  }
} 
 
 
/*======================================================* 
 * See sfuntmpl.doc for the optional S-function methods * 
 *======================================================*/ 
 
/*=============================* 
 * Required S-function trailer * 
 *=============================*/ 
 
#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */ 
#include "simulink.c"      /* MEX-file interface mechanism */ 
#else 
#include "cg_sfun.h"       /* Code generation registration function */ 
#endif 
