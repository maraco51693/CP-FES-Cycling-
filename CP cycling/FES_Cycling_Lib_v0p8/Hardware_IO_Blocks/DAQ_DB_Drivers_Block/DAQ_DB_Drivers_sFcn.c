/* --------------------------------------------------------------------- */
/*   File: DAQ_DB_Drivers_sFcn.c
/* Author: Benjamin Saunders
/*   Date: 09 Feb 2004
/* --------------------------------------------------------------------- */
/* Discription:
/* This s-function uses a seperatly written file (DAQ_DB_Drivers.c) that
/* containes the function calls for the doubled buffered functions of
/* the DAQ-6024E AD card. When compiling this s-function this file needs
/* to be linked in together with the National Instruments (NI) libraries
/* nidaq32.lib and nidex32.lib. Also include the header files
/* DAQ_DB_Drivers.h and the National Instruments header file nidaqex.h.
/*
/* --------------------------------------------------------------------- */
/* Updates:
/* 09 Feb. 2004: Ben Saunders
/*   Set up this s-function from the DAQ_Drivers_DB_Read_sFcn.c file.
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* S-function preamble */

#define S_FUNCTION_NAME  DAQ_DB_Drivers_sFcn
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "nidaqex.h" /* Include the NI drivers */
#include "DAQ_DB_Drivers.h" /* Add user functions*/


/* --------------------------------------------------------------------- */
/* User defines - using macros for s-function parameters */

#define SSPARAM_IDX_STIME    0     /* sample time */
#define SSPARAM_IDX_CHNLS    1     /* channels */
#define SSPARAM_IDX_GAINS    2     /* gains for each channel */
#define SSPARAM_IDX_SCANR    3     /* scan rate */

#define NBR_SSPARAMS         4     /* number of used parameters */

#define SSPARAM_STIME        ssGetSFcnParam(S, SSPARAM_IDX_STIME)     /* sample time */
#define SSPARAM_CHNLS        ssGetSFcnParam(S, SSPARAM_IDX_CHNLS)     /* channels */
#define SSPARAM_GAINS        ssGetSFcnParam(S, SSPARAM_IDX_GAINS)     /* gains for each channel */
#define SSPARAM_SCANR        ssGetSFcnParam(S, SSPARAM_IDX_SCANR)     /* scan rate */

#define NONTUNABLE           0     /* Parameters are non-tunable */


#define MDL_CHECK_PARAMETERS       /* use a seperate function to check parameters */
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* ===================================================================== */
static void mdlCheckParameters(SimStruct *S) {
  
  /* ------------------------------------- */
  /* Variables */
  
  real_T sampleTime; /* value of the sample time */
  real_T *chans_rpt; /* array of the channels */
  /* i16 *chans;        /* array of the channels */
  i16 numChans;      /* size of the channels array */
  real_T *gains_rpt; /* array of the channel gains */
  /* i16 *gains;        /* array of the channel gains */
  i16 scanRate;      /* scan rate */
  int_T i;           /* loop counter */
  
  /* ------------------------------------- */
  /* Parameter: SSPARAM_STIME = sample time */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_STIME, NONTUNABLE); 
  
  if (mxIsComplex(SSPARAM_STIME)) {
    ssSetErrorStatus(S,"Parameter 'sample time' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_STIME) != 2) {
    ssSetErrorStatus(S,"Parameter 'sample time' must have only 2 dimensions.");
    return;
  }
  if (mxGetNumberOfElements(SSPARAM_STIME) != 1) {
    ssSetErrorStatus(S,"Parameter 'sample time' must have only 1 elements.");
    return;
  }
  
  sampleTime = (real_T) ((real_T *) mxGetData(SSPARAM_STIME))[0];
  if ( (sampleTime != -2) && (sampleTime != -1) && (sampleTime < 0) ) {
    ssSetErrorStatus(S,"Value of parameter 'sample time' must be between -1 or higher than 0.");
    return;
  }
  
  /* ------------------------------------- */
  /* Parameter: SSPARAM_CHNLS = channels */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_CHNLS, NONTUNABLE); 
  
  if (!mxIsNumeric(SSPARAM_CHNLS)) {
    ssSetErrorStatus(S, "The argument indicating the input channels needs to be a numerical vector.");
    return;
  }
  if (mxIsComplex(SSPARAM_CHNLS)) {
    ssSetErrorStatus(S,"Parameter 'channels' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_CHNLS) != 2) {
    ssSetErrorStatus(S,"Parameter 'channels' must have only 2 dimensions.");
    return;
  }
  numChans = (i16)mxGetNumberOfElements(SSPARAM_CHNLS);
  if (numChans > 16) {
    ssSetErrorStatus(S,"Parameter 'channels' must have 16 or less elements.");
    return;
  }
  
  chans_rpt = mxGetPr(SSPARAM_CHNLS);
  for (i=0 ; i<numChans ; i++) {
    if ((chans_rpt[i] < 0) || (chans_rpt[i] > 16)) {
      ssSetErrorStatus(S,"Channel elements must be between 0 and 15.");
      return;
    }
  }
  
  /* ------------------------------------- */
  /* Parameter: SSPARAM_GAINS = gains for each channel */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_GAINS, NONTUNABLE); 
  
  if (mxIsComplex(SSPARAM_GAINS)) {
    ssSetErrorStatus(S,"Parameter 'channel gains' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_GAINS) != 2) {
    ssSetErrorStatus(S,"Parameter 'channel gains' must have only 2 dimensions.");
    return;
  }
  if (mxGetNumberOfElements(SSPARAM_GAINS) != numChans) {
    ssSetErrorStatus(S,"Parameter 'channel gains' must have the same number of elements as the 'channels' parameter.");
    return;
  }
  
  gains_rpt = mxGetPr(SSPARAM_GAINS);
  for (i=0 ; i<numChans ; i++) {
    if ((gains_rpt[i] != -1) && (gains_rpt[i] != 1) && (gains_rpt[i] != 10) && (gains_rpt[i] != 100)) {
      ssPrintf("gains_rpt[%d] = %f\n", i, gains_rpt[i]);
      ssSetErrorStatus(S,"Values of the parameter 'gains' must a vector of only -1, 1, 10 or 100.");
      return;
    }
  }
  
  /* ------------------------------------- */
  /* Parameter: SSPARAM_SCANR = scan rate */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_SCANR, NONTUNABLE); 
  
  if (mxIsComplex(SSPARAM_SCANR)) {
    ssSetErrorStatus(S,"Parameter 'scan rate' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_SCANR) != 2) {
    ssSetErrorStatus(S,"Parameter 'scan rate' must have only 2 dimensions.");
    return;
  }
  if (mxGetNumberOfElements(SSPARAM_SCANR) != 1) {
    ssSetErrorStatus(S,"Parameter 'scan rate' must have only 1 elements.");
    return;
  }
  
  scanRate  = (int_T)mxGetScalar(SSPARAM_SCANR);
  if ( (scanRate/sampleTime < 1) || ((scanRate/sampleTime)*numChans > 200000) ) {
    ssSetErrorStatus(S,"Value of parameter 'scan rate' is out of range (1/sec up to 200k/sec/chan).");
    return;
  }
  
} /* End of Function: mdlInitializeSizes */
/* --------------------------------------------------------------------- */
#endif


/* ===================================================================== */
static void mdlInitializeSizes(SimStruct *S) {
  
  /* get nbrChannels */
  i16 numChans   = (i16)mxGetNumberOfElements(SSPARAM_CHNLS);
  int_T scanRate = (int_T)mxGetScalar(SSPARAM_SCANR);
  int_T i;
  
  /* Check the number of expected parameters against the actual number */
  ssSetNumSFcnParams(S, NBR_SSPARAMS); /* Number of expected parameters */
  if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
    mdlCheckParameters(S);
    /* if (ssGetErrorStates(S) != NULL) return; */
  } else {
    return; /* Error message automaticlly generated by simulaink */
  }
  
  /* Set the number of states used */
  ssSetNumContStates(S, 0);
  ssSetNumDiscStates(S, 0);
  
  /* Set up the input and output ports */
  if (!ssSetNumInputPorts(S, 0)) return;
  if (!ssSetNumOutputPorts(S, (int_T)numChans)) return;
  for (i=0; i<(int_T)numChans; i++) {
    ssSetOutputPortWidth(S, i, scanRate);
  }
  
  /* Number of block sample times */
  ssSetNumSampleTimes(S, 1);
  
  /* Set the number of work vectors */
  ssSetNumRWork(S, 0);
  ssSetNumIWork(S, 1);
  ssSetNumPWork(S, 0);
  ssSetNumModes(S, 0);
  ssSetNumNonsampledZCs(S, 0);
  
} /* End of Function: mdlInitializeSizes */
/* --------------------------------------------------------------------- */


/* ===================================================================== */
static void mdlInitializeSampleTimes(SimStruct *S) {
  
  real_T sampleTime = (real_T) ((real_T *) mxGetData(SSPARAM_STIME))[0];
  
  if (sampleTime == -2) {
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
  } else if (sampleTime == -1) {
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
  } else {
    ssSetSampleTime(S, 0, sampleTime);
    ssSetOffsetTime(S, 0, 0.0);
  }
  
} /* End of Function: mdlInitializeSampleTimes */
/* --------------------------------------------------------------------- */


#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)
/* ===================================================================== */
static void mdlStart(SimStruct *S) {
  
  /* ------------------------------------- */
  /* Variables needed for the AD card */
  
  i16 numChans      = (i16)mxGetNumberOfElements(SSPARAM_CHNLS);
  real_T *chans_rpt = mxGetPr(SSPARAM_CHNLS);
  i16 channels[]    = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; /* can't contain more that 18 values */
  real_T *gains_rpt = mxGetPr(SSPARAM_GAINS);
  i16 gains[]       = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}; /* can't contain more that 18 values */
  int_T scanRate    = (int_T)mxGetScalar(SSPARAM_SCANR);
  real_T sampleTime = (real_T) ((real_T *) mxGetData(SSPARAM_STIME))[0];
  f64 scanRatePerSec;
  int_T retDB;
  int_T i;
  
  int_T *IWork = ssGetIWork(S); /* Shows existence of device */
  
  IWork[0] = 1;
  
  /* ssPrintf("Debugging (%s, %d): Got to here.\n", __FILE__, __LINE__); /**/
  
  /* ------------------------------------- */
  /* Convert the channel numbers and gains to i16s */
  
  for (i=0; i<numChans; i++) {
    channels[i] = (i16)chans_rpt[i];
    gains[i]    = (i16)gains_rpt[i];
  }
  
  /* ------------------------------------- */
  /* Configure the AD Card */
  
  scanRatePerSec = (f64)(scanRate / sampleTime);
  
  /* ssPrintf("Debugging (%s, %d): scanRatePerSec = %f, scanCount = %d \n", __FILE__, __LINE__, scanRatePerSec, (int_T)(scanRate*2)); /**/
  
  retDB = DAQ_DB_Init(numChans, channels, gains, scanRatePerSec, (i16)(scanRate*2));
  if (retDB != 0) {IWork[0] = 0; ssSetStopRequested(S, 1);}
  
} /* End of Function: mdlStart */
/* --------------------------------------------------------------------- */
#endif /*  MDL_START */


/* ===================================================================== */
static void mdlOutputs(SimStruct *S, int_T tid) {
  
  /* ------------------------------------- */
  /* Variables used by the s-function */
  
  real_T *y;   /* s-function port outputs */
  int_T retDB; /* Return status of DAQ_DB functions */
  int_T i, j;  /* loop counters */
  int_T *IWork = ssGetIWork(S); /* Shows existence of device */
  
  /* ------------------------------------- */
  /* Variables needed for the AD card */
  
  i16 numChans   = (i16)mxGetNumberOfElements(SSPARAM_CHNLS);
  int_T scanRate = (int_T)mxGetScalar(SSPARAM_SCANR);
  i16 *hb;     /* Pointer to the half buffer that was read in so far. */
  u32 ptsTfr;  /* Points scaned in so far */
  i16 temp = 13;
  
  /* ssPrintf("Debugging (%s, %d): Got to here.\n", __FILE__, __LINE__); */
  hb = &temp;
  
  /* ------------------------------------- */
  /* Transfer half the DB circular buffer from the AD Card */
  
  if (IWork[0] == 1) {
  	retDB = DAQ_DB_Step(&hb, &ptsTfr);
  	if (retDB < 0) {
  		ssSetStopRequested(S, 1);
  		return;
  	}
  	
  	if (ptsTfr > scanRate*numChans) {
  		ssPrintf("Warning (%s): Too many values sampled for this block.\n", __FILE__);
  	}
  }
  
  /* ssPrintf("Debugging (%s, %d): Points transfered = %d.\n", __FILE__, __LINE__, ptsTfr); /**/
  
  /* ------------------------------------- */
  /* Write Output of the S-Function */
  
  if (ptsTfr > 0) {
    for (i=0; i<numChans; i++) {
      y = ssGetOutputPortSignal(S,i);
      for (j=0; j<scanRate; j++) {
        y[j] = (real_T)(*(hb+(j*numChans)+i));
      }
    }
    
    /* ssPrintf("Debugging (%s, %d): Points transfered ok.\n", __FILE__, __LINE__); /**/
    /* ssPrintf("Debugging (%s, %d): Points transfered [%d %d %d].\n", __FILE__, __LINE__, (int_T)(*(hb+0)), (int_T)(*(hb+1)), (int_T)(*(hb+2))); /**/
  } else {
    ssPrintf("Warning (%s): No Points transfered.\n", __FILE__); /**/
  }
  
} /* End of Function: mdlOutputs */
/* --------------------------------------------------------------------- */


/* ===================================================================== */
static void mdlTerminate(SimStruct *S) {
  
  /* ------------------------------------- */
  /* Variables used by the s-function */
  
  int_T retDB; /* Return status of DAQ_DB functions */
  int_T *IWork = ssGetIWork(S); /* Shows existence of device */
  
  /* ssPrintf("Debugging (%s, %d): Running mdlTerminate.\n", __FILE__, __LINE__); /**/
  
  /* ------------------------------------- */
  /* Reset the AD Card */
  
  if (IWork[0] == 1) {
  	retDB = DAQ_DB_Term();
  	/* if (retDB != 0) {ssSetStopRequested(S, 1);} /* stopping anyway so no need for this */
  }
  
} /* End of Function: mdlTerminate */
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* Required S-function trailer */

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
