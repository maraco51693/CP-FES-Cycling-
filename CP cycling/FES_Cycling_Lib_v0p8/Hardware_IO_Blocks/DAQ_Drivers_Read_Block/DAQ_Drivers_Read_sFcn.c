/* --------------------------------------------------------------------- */
/*   File: DAQ_Drivers_Read_sFcn.c
/* Author: Henrik Gollee + Benjamin Saunders
/*   Date: 29 May 2003
/* --------------------------------------------------------------------- */
/* Discription:
/* This is the s-function code that contains the drivers for the DAQ1200
/* and the DAQ-6024E AD cards for reading a channel from the AD card.
/* When compiling this s-function the National Instruments (NI)
/* libraries nidaq32.lib and nidex32.lib need to be linked in.  Also
/* include the National Instruments header file nidaqex.h
/*
/* This s-function uses 4 NI functions:
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
/* status = AI_Configure(deviceNbr, chan, inputMode, inputRange, polarity, driveAIS);
/*   AI_Configure is used to configure the AD card with desired
/*   characteristics.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   chan       : Is the channel to be configured. (Except for E Series
/*                devices, you must set iChan to -1 because the same
/*                analog input configuration applies to all channels. For
/*                E Series devices, chan specifies the channel to
/*                configure).
/*   inputMode  : Indicates whether channels are configured for
/*                single-ended or differential operation.
/*                0: Differential (DIFF) configuration (default).
/*                1: Referenced Single-Ended (RSE) configuration. This is
/*                   used when the input signal does not have its own
/*                   ground reference. The negative (-) input of the
/*                   instrumentation amplifier is tied to the
/*                   instrumentation amplifier signal ground to provide
/*                   one.
/*                2: Nonreferenced Single-Ended (NRSE) configuration. This
/*                   is used when the input signal has its own ground
/*                   reference. The ground reference for the input signal
/*                   is connected to AISENSE, which is tied to the negative
/*                   (-) input of the instrumentation amplifier.
/*   inputRange : Voltage range of the analog input channels.
/*   polarity   : Indicates whether the AD card is configured for
/*                unipolar or bipolar operation.
/*                0: Bipolar operation (default value).
/*                1: Unipolar operation.
/*   driveAIS   : Indicates whether to drive AISENSE to onboard ground.
/*                (driveAIS is ignored for all currently supported
/*                devices, but may be an option on older devices).
/*
/* status = AI_VRead(deviceNbr, chan, gain, *voltage);
/*   Used to reads an analogue input channel and returns the result scaled
/*   in units of volts.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   chan       : Is the analog input channel to be read.
/*   gain       : gain setting to be used for the specified channel. Valid
/*                gain seetings are:
/*                DAQ 1200 card: 1, 2, 5, 10, 20, 50 or 100.
/*                DAQ 6024E card: -1 (for a gain of 0.5) 1, 10 or 100.
/*   voltage    : The measured voltage returned, scaled to units of volts.
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
/* 27 June 2003: Ben Saunders
/*   Added functionality for the DAQ-6024E Card.  Also reformated
/*   this documentation.
/* 1 July 2003: Ben Saunders
/*   Added the mdlCheckParameters function so that all parameter
/*   checking is done in one place only.
/* 3 Sep. 2003: Ben Saunders
/*   Increased the amount of channels that can be read from 9 to 16.
/* 19 Nov. 2003: Ben Saunders
/*   Changed the error to a warning when no AD card is plugged in to the
/*   AD card.  The resulting output during simulation will be 0 for each
/*   channel.
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* S-function preamble */

#define S_FUNCTION_NAME  DAQ_Drivers_Read_sFcn
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "nidaqex.h" /* Include the NI drivers */


/* --------------------------------------------------------------------- */
/* User defines - using macros for s-function parameters */

#define SSPARAM_IDX_STIME    0     /* sample time */
#define SSPARAM_IDX_IMODE    1     /* input mode */
#define SSPARAM_IDX_POLAR    2     /* polarity */
#define SSPARAM_IDX_IGAIN    3     /* input gain */
#define SSPARAM_IDX_CHNLS    4     /* channels */

#define NBR_SSPARAMS         5     /* number of used parameters */

#define SSPARAM_STIME        ssGetSFcnParam(S, SSPARAM_IDX_STIME)     /* sample time */
#define SSPARAM_IMODE        ssGetSFcnParam(S, SSPARAM_IDX_IMODE)     /* input mode */
#define SSPARAM_POLAR        ssGetSFcnParam(S, SSPARAM_IDX_POLAR)     /* polarity */
#define SSPARAM_IGAIN        ssGetSFcnParam(S, SSPARAM_IDX_IGAIN)     /* input gain */
#define SSPARAM_CHNLS        ssGetSFcnParam(S, SSPARAM_IDX_CHNLS)     /* channels */

#define NONTUNABLE           0     /* Parameters are non-tunable */


#define MDL_CHECK_PARAMETERS       /* use a seperate function to check parameters */
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* ===================================================================== */
static void mdlCheckParameters(SimStruct *S) {
  
  /* ------------------------------------- */
  /* Variables */
  
  i16 deviceNbr  = 1; /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
  u32 infoType;       /* information type requested */
  u32 infoValue;      /* information requested output */
  int_T cardType = 0; /* Representation of the type of device being used */
  i16 status, retVal; /* The returned status of the functions and NIDAQErrorHandler */
  i16 ignoreWrng = 0; /* Don't ignore the warnings (0) */
  
  real_T sampleTime;  /* value of the sample time */
  real_T iMode;       /* value of the input mode */
  real_T polarity;    /* value of the polarity */
  real_T iGain;       /* value of the input gain */
  real_T *channels;   /* array of the channels */
  int_T nbrChannels;  /* size of the channels array */
  int_T i;            /* loop counter */

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
  /* Parameter: SSPARAM_IMODE = input mode */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_IMODE, NONTUNABLE); 
  
  if (mxIsComplex(SSPARAM_IMODE)) {
    ssSetErrorStatus(S,"Parameter 'input mode' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_IMODE) != 2) {
    ssSetErrorStatus(S,"Parameter 'input mode' must have only 2 dimensions.");
    return;
  }
  if (mxGetNumberOfElements(SSPARAM_IMODE) != 1) {
    ssSetErrorStatus(S,"Parameter 'input mode' must have only 1 elements.");
    return;
  }
  
  iMode = (real_T) ((real_T *) mxGetData(SSPARAM_IMODE))[0];
  if ( (iMode != 0) && (iMode != 1) && (iMode != 2) ) {
    ssSetErrorStatus(S,"Value of parameter 'input mode' must be either 0, 1 or 2.");
    return;
  }
  
  /* ------------------------------------- */
  /* Parameter: SSPARAM_POLAR = polarity */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_POLAR, NONTUNABLE); 
  
  if (mxIsComplex(SSPARAM_POLAR)) {
    ssSetErrorStatus(S,"Parameter 'polarity' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_POLAR) != 2) {
    ssSetErrorStatus(S,"Parameter 'polarity' must have only 2 dimensions.");
    return;
  }
  if (mxGetNumberOfElements(SSPARAM_POLAR) != 1) {
    ssSetErrorStatus(S,"Parameter 'polarity' must have only 1 elements.");
    return;
  }
  
  polarity = (real_T) ((real_T *) mxGetData(SSPARAM_POLAR))[0];
  if ( (polarity != 0) && (polarity != 1) ) {
    ssSetErrorStatus(S,"Value of parameter 'polarity' must be either 0 or 1.");
    return;
  }
  if ((cardType == 6024) && (polarity == 1)) {
    ssSetErrorStatus(S,"Value of parameter 'polarity' for DAQ-6024E must be 0 (bipolar).");
    return;
  }
  
  /* ------------------------------------- */
  /* Parameter: SSPARAM_IGAIN = input gain */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_IGAIN, NONTUNABLE); 
  
  if (mxIsComplex(SSPARAM_IGAIN)) {
    ssSetErrorStatus(S,"Parameter 'input gain' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_IGAIN) != 2) {
    ssSetErrorStatus(S,"Parameter 'input gain' must have only 2 dimensions.");
    return;
  }
  if (mxGetNumberOfElements(SSPARAM_IGAIN) != 1) {
    ssSetErrorStatus(S,"Parameter 'input gain' must have only 1 elements.");
    return;
  }
  
  /* Check card type for valid values of the input gain */
  /* Valid gain seetings for the DAQ 1200 card: 1, 2, 5, 10, 20, 50, 100 */
  /* Valid gain seetings for the DAQ 6024E card: -1 (for a gain of 0.5) 1, 10 or 100. */
  iGain = (real_T) ((real_T *) mxGetData(SSPARAM_IGAIN))[0];
  switch (cardType) {
    case 1200:
      if ((iGain != 1) && (iGain != 2) && (iGain != 5) && (iGain != 10) &&
          (iGain != 20) && (iGain != 50) && (iGain != 100)) {
        ssSetErrorStatus(S,"Valid values of 'input gain' for the DAQ1200 are: 1, 2, 5, 10, 20, 50 and 100");
        return;
      }
      break;
    case 6024:
      if ((iGain != -1) && (iGain != 1) && (iGain != 10) && (iGain != 100)) {
        ssSetErrorStatus(S,"Valid values of 'input gain' for the DAQ6024E are: -1 (for 0.5), 1, 10 and 100");
        return;
      }
      break;
    default:
      /* ssSetErrorStatus(S,"This s-function is not set up to deal with this AD device."); */
      /* ssPrintf("Warning (%s): This s-function is not set up to deal with this AD device.\n", __FILE__); */
      /* return; */
      break;
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
  nbrChannels = mxGetNumberOfElements(SSPARAM_CHNLS);
  if (nbrChannels > 16) {
    ssSetErrorStatus(S,"Parameter 'channels' must have 16 or less elements.");
    return;
  }
  
  channels = mxGetPr(SSPARAM_CHNLS);
  for (i=0 ; i<nbrChannels ; i++) {
    if ((channels[i] < 0) || (channels[i] > 16)) {
      ssSetErrorStatus(S,"Channel elements must be between 0 and 15.");
      return;
    }
  }
  
} /* End of Function: mdlInitializeSizes */
/* --------------------------------------------------------------------- */
#endif


/* ===================================================================== */
static void mdlInitializeSizes(SimStruct *S) {
  
  /* get nbrChannels */
  int_T nbrChannels = mxGetNumberOfElements(SSPARAM_CHNLS);
  
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
  ssSetOutputPortWidth(S, 0, nbrChannels);
  
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
  
  i16 deviceNbr  = 1;   /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
  i16 chan       = -1;  /* Except for E Series devices, chan must be set to -1 */
  i16 inputRange = 0;   /* Voltage range of the analog input channels - ignore */
  i16 driveAIS   = 0;   /* driveAIS is ignored for all currently supported devices */
  
  i16 inputMode  = (i16) (mxGetScalar(SSPARAM_IMODE)); /* Indicates whether channels are configured for single-ended or differential operation. */
  i16 polarity   = (i16) (mxGetScalar(SSPARAM_POLAR)); /* Indicates whether the AD card is configured for unipolar or bipolar operation. */
  
  i16 status, retVal;   /* The returned status of the functions and NIDAQErrorHandler */
  i16 ignoreWrng = 0;   /* Don't ignore the warnings (0) */
  
  int_T  *IWork = ssGetIWork(S); /* Shows existence of device */
  
  /* ------------------------------------- */
  /* Configure the AD Card */
  
  status = AI_Configure(deviceNbr, chan, inputMode, inputRange, polarity, driveAIS);
  /* ssPrintf("Debugging (%s): status = %d\n", __FILE__, status); */
  
  /* Check existence of device */
  if ((status == -10401) || (status == -10402) || (status == -10403)) {
    /* No device or unrecognised device */
    IWork[0] = -1;
  } else {
    retVal = NIDAQErrorHandler(status, "AI_Configure", ignoreWrng);
    IWork[0] = 1;
  }
  
} /* End of Function: mdlStart */
/* --------------------------------------------------------------------- */
#endif /*  MDL_START */


/* ===================================================================== */
static void mdlOutputs(SimStruct *S, int_T tid) {
  
  /* ------------------------------------- */
  /* Variables used by the s-function */
  
  real_T *y = ssGetOutputPortSignal(S,0); /* s-function outputs */
  int_T i;            /* loop counter */
  
  /* ------------------------------------- */
  /* Variables needed for the AD card */
  
  i16 deviceNbr  = 1;   /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
  i16 status, retVal;   /* The returned status of the functions and NIDAQErrorHandler */
  i16 ignoreWrng = 0;   /* Don't ignore the warnings (0) */
  f64 voltage;          /* Output from the DAQ card */
  
  real_T *chan      = mxGetPr(SSPARAM_CHNLS);
  int_T nbrChannels = mxGetNumberOfElements(SSPARAM_CHNLS);
  i16 gain = (i16) ((real_T *) mxGetData(SSPARAM_IGAIN))[0];
  
  int_T  *IWork = ssGetIWork(S); /* Shows existence of device */
  
  /* ssPrintf("Debugging (%s, %d): IWork = %d\n", __FILE__, __LINE__, IWork[0]); */
  
  /* ------------------------------------- */
  /* Read the voltages from the AD Card */
  
  for (i=0 ; i<nbrChannels ; i++) {
    voltage = 0.0;
    
    if (IWork[0] != -1) {
      status = AI_VRead(deviceNbr, (i16)(chan[i]), gain, &voltage);
      retVal = NIDAQErrorHandler(status, "AI_VRead", ignoreWrng);
    }
    
    y[i] = voltage;
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
