/* --------------------------------------------------------------------- */
/*   File: miniLAB_AIn_sFcn.c
/* Author: Benjamin Saunders
/*   Date: 12 Jan 2005
/* --------------------------------------------------------------------- */
/* Discription:
/* This s-function containes the function calls for the miniLAB USB AD card
/* "Universal Library" functions.  When compiling this s-function this
/* file needs to be linked in together with the Universal Library
/* libraries.
/*
/* --------------------------------------------------------------------- */
/* Updates:
/* dd mmm yyyy: Author
/*   Description of what has been done.
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* S-function preamble */

#define S_FUNCTION_NAME  miniLAB_AIn_sFcn
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "cbw.h"       /* include the AD drivers */


/* --------------------------------------------------------------------- */
/* User defines - using macros for s-function parameters */

#define SSPARAM_IDX_STIME    0     /* sample time */
#define SSPARAM_IDX_CHNLS    1     /* channels */

#define NBR_SSPARAMS         2     /* number of used parameters */

#define SSPARAM_STIME        ssGetSFcnParam(S, SSPARAM_IDX_STIME)     /* sample time */
#define SSPARAM_CHNLS        ssGetSFcnParam(S, SSPARAM_IDX_CHNLS)     /* channels */

#define NONTUNABLE           0     /* Parameters are non-tunable */


#define MDL_CHECK_PARAMETERS       /* use a seperate function to check parameters */
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* ===================================================================== */
static void mdlCheckParameters(SimStruct *S) {
  
  /* ------------------------------------- */
  /* Variables */
  
  real_T sampleTime; /* value of the sample time */
  real_T *chans_rpt; /* array of the channels */
  int_T numChans;    /* size of the channels array */
  int_T i;           /* loop counter */
  
  /* ssPrintf("Debugging (%s, %d): Got to Here!\n", __FILE__, __LINE__); /**/
  
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
  numChans = (int_T)mxGetNumberOfElements(SSPARAM_CHNLS);
  if (numChans > 8) {
    ssSetErrorStatus(S,"Parameter 'channels' must have 8 or less elements.");
    return;
  }
  
  chans_rpt = mxGetPr(SSPARAM_CHNLS);
  for (i=0 ; i<numChans ; i++) {
    if ((chans_rpt[i] < 0) || (chans_rpt[i] > 7)) {
      ssSetErrorStatus(S,"Channel elements must be between 0 and 7.");
      return;
    }
  }
  
} /* End of Function: mdlInitializeSizes */
/* --------------------------------------------------------------------- */
#endif


/* ===================================================================== */
static void mdlInitializeSizes(SimStruct *S) {
  
  /* get nbrChannels */
  int_T numChans = (int_T)mxGetNumberOfElements(SSPARAM_CHNLS);
  
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
  if (!ssSetNumOutputPorts(S, 1)) return;
  ssSetOutputPortWidth(S, 0, numChans);
  
  /* Number of block sample times */
  ssSetNumSampleTimes(S, 1);
  
  /* Set the number of work vectors */
  ssSetNumRWork(S, 0);
  ssSetNumIWork(S, 0);
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
  
/* Do Nothing */

} /* End of Function: mdlStart */
/* --------------------------------------------------------------------- */
#endif /*  MDL_START */


/* ===================================================================== */
static void mdlOutputs(SimStruct *S, int_T tid) {
  
  /* ------------------------------------- */
  /* Variables used by the s-function */
  
  real_T *y = ssGetOutputPortSignal(S,0);    /* s-function port outputs */
  int_T ULStat; /* Return status of DAQ_DB functions */
  int_T numChans = (int_T)mxGetNumberOfElements(SSPARAM_CHNLS);
  real_T *chans_rpt = mxGetPr(SSPARAM_CHNLS); /* array of the channels */
  int_T i;   /* loop counter */
  
  /* ------------------------------------- */
  /* Variables needed for the AD card */
  
  long rate = 1000;        /* Inter-Channel sampling (between channels) */
  WORD ADData[8];         /* Buffer for data from the AD card */
  int Options;            /* Options for the scan of the AD card */
  char ErrMsg[ERRSTRLEN]; /* Used to display the error message */
  
  /* ------------------------------------- */
  /* Access the AD card and scan all channels */
  
  Options = BURSTIO;
  
  ULStat = cbAInScan(1, 0, 7, 8, &rate, BIP10VOLTS, ADData, Options);
  
  if (ULStat != 0) {
    for (i=0; i<8; i++) {
      ADData[i] = 2048; /* This is half the 12 bit range and corresponds to 0 volts (-10v to +10v) */
    }
    cbGetErrMsg(ULStat,  ErrMsg);
    ssPrintf("Warning (%s): miniLAB driver error: %s\n", __FILE__, ErrMsg); /**/
  }
  
  /* ssPrintf("Debugging (%s, %d): Status = %d, Output = [%d %d %d %d]\n", __FILE__, __LINE__, ULStat, (uint_T)ADData[0], (uint_T)ADData[1], (uint_T)ADData[2], (uint_T)ADData[3]); /**/
  /* ssPrintf("Debugging (%s, %d): Status = %d, Sample Rate = %d \n", __FILE__, __LINE__, ULStat, (uint_T)rate); /**/
  
  /* ------------------------------------- */
  /* Write Output of the S-Function */
  
  for (i=0; i<numChans; i++) {
    /* Convert the 12 bit integer (2^12) to a real voltage between -10V and +10V */
    y[i] = 10*((((real_T)((uint_T)ADData[(int_T)chans_rpt[i]]))-2048)/2048); /**/
  }
  
} /* End of Function: mdlOutputs */
/* --------------------------------------------------------------------- */


/* ===================================================================== */
static void mdlTerminate(SimStruct *S) {
  
/* Do Nothing */

} /* End of Function: mdlTerminate */
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* Required S-function trailer */

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
