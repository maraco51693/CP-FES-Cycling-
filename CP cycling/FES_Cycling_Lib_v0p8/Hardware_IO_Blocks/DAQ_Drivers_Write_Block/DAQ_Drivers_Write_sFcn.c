/* --------------------------------------------------------------------- */
/*   File: DAQ_Drivers_Write_sFcn.c
/* Author: Benjamin Saunders
/*   Date: 7 Sep 2003
/* --------------------------------------------------------------------- */
/* Discription:
/* This is the s-function code that contains the drivers for the DAQ1200
/* AD card.  When compiling this s-function the National Instruments (NI)
/* libraries nidaq32.lib and nidex32.lib need to be linked in.  Also
/* include the National Instruments header file nidaqex.h
/*
/* This s-function uses 3 NI functions:
/*
/* status = Get_DAQ_Device_Info (deviceNbr, infoType, infoValue);
/*   Get_DAQ_Device_Info returns information pertaining to the device
/*   operation.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   infoType   : type of information you want to retrieve.
/*   infoValue  : retrieved information.
/*
/* status = AO_VWrite(deviceNbr, chan, voltage);
/*   Used to write to an analog output channel and returns the result scaled
/*   in units of volts.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   chan       : Is the analog input channel to be read.
/*   voltage    : The desired voltage on the output.
/*
/* retVal = NIDAQErrorHandler(status, sStrFnName, ignoreWrng);
/*   Used to catch and handle errors that occur from NI functions.
/*   retVal     : Is the returned value of this function.
/*   status     : Is the status output from a previouse NI function.
/*   sStrFnName : Is a static string of the function's name. e.g. use
/*                "AI_Configure" or "AI_VRead".
/*   ignoreWrng : Can be set to ignore warnings or not.
/*
/* --------------------------------------------------------------------- */
/* Updates:
/* 7 Sep. 2003: Ben Saunders
/*   Copied this function from the corresponding function for reading
/*   written by Henrik Gollee.
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* S-function preamble */

#define S_FUNCTION_NAME  DAQ_Drivers_Write_sFcn
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "nidaqex.h" /* Include the NI drivers */


/* --------------------------------------------------------------------- */
/* User defines - using macros for s-function parameters */

#define SSPARAM_IDX_STIME    0     /* sample time */
#define SSPARAM_IDX_CHNLS    1     /* channel */

#define NBR_SSPARAMS         2     /* number of used parameters */

#define SSPARAM_STIME        ssGetSFcnParam(S, SSPARAM_IDX_STIME)     /* sample time */
#define SSPARAM_CHNLS        ssGetSFcnParam(S, SSPARAM_IDX_CHNLS)     /* channel */

#define NONTUNABLE           0     /* Parameters are non-tunable */


#define MDL_CHECK_PARAMETERS       /* use a seperate function to check parameters */
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* ===================================================================== */
static void mdlCheckParameters(SimStruct *S) {
  
  /* ------------------------------------- */
  /* Variables */
  
  i16 deviceNbr  = 1; /* The device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
  u32 infoType;       /* Information type requested */
  u32 infoValue;      /* Information requested output */
  int_T cardType = 0; /* Representation of the type of device being used */
  i16 status, retVal; /* The returned status of the functions and NIDAQErrorHandler */
  i16 ignoreWrng = 0; /* Don't ignore the warnings (0) */
  
  real_T sampleTime;  /* Value of the sample time */
  real_T channel;     /* Channel number */
  
  /* ------------------------------------- */
  /* Check if devide is there (and what type it is) */
  
  infoType = ND_DEVICE_TYPE_CODE;
  
  status = Get_DAQ_Device_Info (deviceNbr, infoType, &infoValue);
  
  /* Check existence of device */
  if (status == -10401) {
    ssPrintf("Warning (%s): Unknown device error (-10401).\n", __FILE__);
  } else if (status == -10402) {
    ssPrintf("Warning (%s): Device not found error (-10402).\n", __FILE__);
  } else if (status == -10403) {
    ssPrintf("Warning (%s): Device recognised but action not supported (-10403).\n", __FILE__);
  } else {
    retVal = NIDAQErrorHandler(status, "Get_DAQ_Device_Info", ignoreWrng);
  }
  
  switch (infoValue) {
    case 1: /* Not a National Instruments DAQ device */
      cardType = 0;
      break;
    case 48: /* DAQCard-1200 */
      cardType = 1200;
      break;
    case 91: /* DAQCard-6024E */
      cardType = 6024;
      break;
    default: /* Unknown */
      /* ssSetErrorStatus(S,"This s-function is not set up to deal with this AD device."); */
      /* return; */
      cardType = 0;
      break;
  }
  
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
  if (mxGetNumberOfElements(SSPARAM_CHNLS) > 1) {
    ssSetErrorStatus(S,"Parameter 'channel' must have only one element.");
    return;
  }
  
  channel = (real_T) ((real_T *) mxGetData(SSPARAM_CHNLS))[0];
  if ((channel < 0) || (channel > 1)) {
    ssSetErrorStatus(S,"Channel number must be either 0 or 1.");
    return;
  }
  
} /* End of Function: mdlInitializeSizes */
/* --------------------------------------------------------------------- */
#endif


/* ===================================================================== */
static void mdlInitializeSizes(SimStruct *S) {
  
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
  if (!ssSetNumInputPorts(S, 1)) return;
  ssSetInputPortDirectFeedThrough(S, 0, 1);
  ssSetInputPortWidth(S, 0, 1);
  if (!ssSetNumOutputPorts(S, 0)) return;
  
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
  
  i16 deviceNbr  = 1; /* The device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
  u32 infoType;       /* Information type requested */
  u32 infoValue;      /* Information requested output */
  i16 status, retVal; /* The returned status of the functions and NIDAQErrorHandler */
  i16 ignoreWrng = 0; /* Don't ignore the warnings (0) */
  
  real_T sampleTime;  /* Value of the sample time */
  real_T channel;     /* Channel number */
  
  int_T  *IWork = ssGetIWork(S); /* Shows existence of device */
  
  /* ------------------------------------- */
  /* Check if devide is there (and what type it is) */
  
  infoType = ND_DEVICE_TYPE_CODE;
  
  status = Get_DAQ_Device_Info (deviceNbr, infoType, &infoValue);
  
  /* Check existence of device */
  if ((status == -10401) || (status == -10402) || (status == -10403)) {
    /* No device or unrecognised device */
    IWork[0] = -1;
  } else {
    retVal = NIDAQErrorHandler(status, "Get_DAQ_Device_Info", ignoreWrng);
    IWork[0] = 1;
  }
  
} /* End of Function: mdlStart */
/* --------------------------------------------------------------------- */
#endif /*  MDL_START */


/* ===================================================================== */
static void mdlOutputs(SimStruct *S, int_T tid) {
  
  /* ------------------------------------- */
  /* Variables used by the s-function */
  
  /* const real_T u = *(ssGetInputPortRealSignal(S,0)); /* s-function block inputs */
  InputRealPtrsType uPtrs = ssGetInputPortRealSignal(S,0);
  
  
  /* ------------------------------------- */
  /* Variables needed for the AD card */
  
  i16 deviceNbr  = 1;   /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
  i16 status, retVal;   /* The returned status of the functions and NIDAQErrorHandler */
  i16 ignoreWrng = 0;   /* Don't ignore the warnings (0) */
  f64 voltage;          /* Input into the DAQ card */
  
  real_T chan       = (real_T) ((real_T *) mxGetData(SSPARAM_CHNLS))[0];
  
  int_T  *IWork = ssGetIWork(S); /* Shows existence of device */
  
  /* ssPrintf("Debugging (%s, %d): IWork = %d\n", __FILE__, __LINE__, IWork[0]); */
  
  /* ------------------------------------- */
  /* Write the voltage to the AD Card channel */
  
  if (IWork[0] != -1) {
    /* ssPrintf("Debugging (%s): Writting %f volts to channel %d\n", __FILE__, *uPtrs[0], (i16)(chan)); */
    status = AO_VWrite(deviceNbr, (i16)(chan), *uPtrs[0]);
    retVal = NIDAQErrorHandler(status, "AO_VWrite", ignoreWrng);
  }
  
} /* End of Function: mdlOutputs */
/* --------------------------------------------------------------------- */


/* ===================================================================== */
static void mdlTerminate(SimStruct *S) {
} /* End of Function: mdlTerminate */
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* Required S-function trailer */

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
