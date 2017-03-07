/* --------------------------------------------------------------------- */
/*   File: DAQ_Drivers_DB_Read_sFcn.c
/* Author: Benjamin Saunders
/*   Date: 06 Feb 2004
/* --------------------------------------------------------------------- */
/* Discription:
/* This is the s-function containes the function calls for the DAQ-6024E
/* AD card (only) for reading analogue input channels using double
/* buffering.
/* When compiling this s-function the National Instruments (NI)
/* libraries nidaq32.lib and nidex32.lib need to be linked in.  Also
/* include the National Instruments header file nidaqex.h
/*
/* This s-function uses the following NI functions:
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
/* status = status = DAQ_DB_Config (deviceNbr, DBmode);
/*   DAQ_DB_Config is used to configure the AD card so that it runs in
/*   double buffered mode.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   DBmode     : Indicates whether to enable or disable the double
/*                buffered mode of acquisition.
/*                0: Disable double buffering (default).
/*                1: Enable double buffering.
/*
/* status = DAQ_Start (deviceNbr, chan, gain, buffer, count, timebase, sInt);
/*   Initiates an asynchronous, single-channel DAQ operation and stores
/*   its input in an array.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   chan       : Is the analog input channel number.
/*   gain       : gain setting to be used for the specified channel. Valid
/*                gain seetings are:
/*                DAQ 6024E card: -1 (for a gain of 0.5) 1, 10 or 100.
/*   buffer     : Used to hold acquired readings.
/*   count      : Number of samples buffer can hold at any given time.
/*                For double buffered mode must be an even number.
/*                For E series devices: count can be 2 through to 2^24.
/*   timebase   : Timebase value or resolution, to be used for the sample
/*                interval counter. timebase has the following possible
/*                values:
/*                -3:  20 MHz clock used as a timebase (50 ns) (E Series only).
/*                -1:   5 MHz clock used as timebase (200 ns resolution).
/*                 0: External clock used as timebase.
/*                 1:   1 MHz clock used as timebase (1 탎 resolution).
/*                 2: 100 kHz clock used as timebase (10 탎 resolution).
/*                 3:  10 kHz clock used as timebase (100 탎 resolution).
/*                 4:   1 kHz clock used as timebase (1 ms resolution).
/*                 5: 100 Hz clock used as timebase (10 ms resolution).
/*   sInt       : Sample interval, the length of the sample interval (the
/*                amount of time to elapse between each A/D conversion).
/*                Can take the value 2 through 65,535.  Thus the actual
/*                sample time is sInt*(timebase time) e.g. sInt = 25 and
/*                timebase = 2 then the sample interval is 25*10탎 = 250탎.
/*
/* status = SCAN_Setup (deviceNbr, numChans, chanVector, gainVector);
/*   Initializes circuitry for a scanned data acquisition operation.
/*   Initialization includes storing a table of the channel sequence
/*   and gain setting for each channel to be digitized.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   numChans   : Number of channels. Takes 1 through 512 for the E
/*                Series devices
/*   chanVector : Channel scan sequence. Can contain any analog input
/*                channel number and in most cases can be put in any
/*                order.
/*   gainVector : Gain setting to use for each channel in chanVector.
/*                Valid gain setings are for the DAQ 6024E card: -1 (for
/*                a gain of 0.5) 1, 10 or 100.
/*
/* status = SCAN_Start (deviceNbr, buffer, count, sampTB, sampInt, scanTB, scanInt);
/*   This function initiates a multiple-channel scanned data acquisition
/*   operation, with or without interval scanning, and stores its input
/*   in an array.  This function must be paired with SCAN_Setup for every
/*   call.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   buffer     : Used to hold acquired readings.
/*   count      : Number of samples buffer can hold at any given time.
/*                For double buffered mode must be an even number.
/*                For E series devices: count can be 2 through
/*                2*(total number of channels scanned) or (2^32)-1,
/*                whichever is less.
/*   sampTB     : Resolution used for the sample-interval counter. It
/*                selects the clock frequency that indicates the timebase
/*                to be used for the sample-interval counter. The
/*                sample-interval counter controls the time that elapses
/*                between acquisition of samples within a scan sequence.
/*                sampTB has the following possible values:
/*                -3:  20 MHz clock used as a timebase (50 ns) (E Series only).
/*                -1:   5 MHz clock used as timebase (200 ns resolution).
/*                 0: External clock used as timebase.
/*                 1:   1 MHz clock used as timebase (1 탎 resolution).
/*                 2: 100 kHz clock used as timebase (10 탎 resolution).
/*                 3:  10 kHz clock used as timebase (100 탎 resolution).
/*                 4:   1 kHz clock used as timebase (1 ms resolution).
/*                 5: 100 Hz clock used as timebase (10 ms resolution).
/*   sampInt    : Length of the sample interval. Can take the value 2
/*                through 65,535.  Thus the actual sample time is
/*                sampInt*(sampTB time) e.g. sampInt = 25 and sampTB = 2
/*                then the sample interval is 25*10탎 = 250탎.
/*   scanTB     : Resolution for the scan-interval counter. The
/*                scan-interval counter controls the time that elapses
/*                between scan sequences. It has the same possible
/*                values as sampTB with the same meanings.
/*   scanInt    : Length of the scan interval. Can take the value 0 or 2
/*                through 65,535. If scanInterval equals 0, the time
/*                that elapses between A/D conversions and the time that
/*                elapses between scan sequences are both equal to the
/*                sample interval. As soon as the scan sequence has
/*                completed, NI-DAQ restarts one sample interval later.
/*                Other values of scanInt operate as with sampInt but
/*                for the scan interval.
/*
/* status = DAQ_DB_Transfer (deviceNbr, halfBuffer, ptsTfr, daqStopped);
/*   Transfers half the data from the buffer being used for
/*   double-buffered data acquisition to another buffer, which is passed
/*   to the function, and waits until the data to be transferred is
/*   available before returning. You can execute DAQ_DB_Transfer
/*   repeatedly to return sequential half buffers of the data.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   halfBuffer : Integer array to which the data is to be transferred.
/*                The size of the array must be at least half the size
/*                of the circular buffer being used for double-buffered
/*                data acquisition.
/*   ptsTfr     : Outputs the number of points transferred.
/*   daqStopped : Indicates the completion of a pretrigger mode
/*                acquisition. (pretrigger mode only).
/*
/* status = DAQ_Clear (deviceNbr);
/*   Cancels the current DAQ operation (both single-channel and
/*   multiple-channel scanned) and reinitializes the DAQ circuitry. If
/*   your application calls DAQ_Start, SCAN_Start, or Lab_ISCAN_Start,
/*   always make sure you call DAQ_Clear before your application
/*   terminates and returns control to the operating system.
/*   Unpredictable behavior can result unless you call DAQ_Clear (either
/*   directly, or indirectly through DAQ_Check, Lab_ISCAN_Check, or
/*   DAQ_DB_Transfer).
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
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
/* 06 Feb. 2004: Ben Saunders
/*   Set up this s-function.
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
#define SSPARAM_IDX_CHNLS    1     /* channels */
#define SSPARAM_IDX_GAINS    2     /* gains for each channel */
#define SSPARAM_IDX_SCANB    3     /* scan timebase */
#define SSPARAM_IDX_SCANI    4     /* scan interval */

#define NBR_SSPARAMS         5     /* number of used parameters */

#define SSPARAM_STIME        ssGetSFcnParam(S, SSPARAM_IDX_STIME)     /* sample time */
#define SSPARAM_CHNLS        ssGetSFcnParam(S, SSPARAM_IDX_CHNLS)     /* channels */
#define SSPARAM_GAINS        ssGetSFcnParam(S, SSPARAM_IDX_GAINS)     /* gains for each channel */
#define SSPARAM_SCANB        ssGetSFcnParam(S, SSPARAM_IDX_SCANB)     /* scan timebase */
#define SSPARAM_SCANI        ssGetSFcnParam(S, SSPARAM_IDX_SCANI)     /* scan interval */

#define NONTUNABLE           0     /* Parameters are non-tunable */

#define DB_BUFFER_SIZE       10000


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
  
  real_T sampleTime; /* value of the sample time */
  i16 *channels;     /* array of the channels */
  i16 numChans;      /* size of the channels array */
  i16 *gains;        /* array of the channel gains */
  i16 scanTB;        /* scan timebase */
  u16 scanInt;       /* scan interval */
  int_T i;           /* loop counter */

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
/*    case 48: /* DAQCard-1200 */
/*      cardType = 1200; */
/*      break; */
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
  numChans = (i16)mxGetNumberOfElements(SSPARAM_CHNLS);
  if (numChans > 16) {
    ssSetErrorStatus(S,"Parameter 'channels' must have 16 or less elements.");
    return;
  }
  
  channels = (i16 *)mxGetPr(SSPARAM_CHNLS);
  for (i=0 ; i<numChans ; i++) {
    if ((channels[i] < 0) || (channels[i] > 16)) {
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
  
  gains = (i16 *)mxGetPr(SSPARAM_GAINS);
  for (i=0 ; i<numChans ; i++) {
    if ((gains[i] < 0) || (gains[i] > 16)) {
      ssSetErrorStatus(S,"Values of the parameter 'gains' must be between 0 and 15.");
      return;
    }
  }
  
  /* ------------------------------------- */
  /* Parameter: SSPARAM_SCANB = scan timebase */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_SCANB, NONTUNABLE); 
  
  if (mxIsComplex(SSPARAM_SCANB)) {
    ssSetErrorStatus(S,"Parameter 'scan timebase' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_SCANB) != 2) {
    ssSetErrorStatus(S,"Parameter 'scan timebase' must have only 2 dimensions.");
    return;
  }
  if (mxGetNumberOfElements(SSPARAM_SCANB) != 1) {
    ssSetErrorStatus(S,"Parameter 'scan timebase' must have only 1 elements.");
    return;
  }
  
  scanTB  = (i16)mxGetScalar(SSPARAM_SCANB);
  if ( (scanTB != -2) && (scanTB != -1) && (scanTB < 0) ) {
    ssSetErrorStatus(S,"Value of parameter 'scan timebase' must be between -1 or higher than 0.");
    return;
  }
  
  /* ------------------------------------- */
  /* Parameter: SSPARAM_SCANI = scan interval */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_SCANI, NONTUNABLE); 
  
  if (mxIsComplex(SSPARAM_SCANI)) {
    ssSetErrorStatus(S,"Parameter 'scan interval' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_SCANI) != 2) {
    ssSetErrorStatus(S,"Parameter 'scan interval' must have only 2 dimensions.");
    return;
  }
  if (mxGetNumberOfElements(SSPARAM_SCANI) != 1) {
    ssSetErrorStatus(S,"Parameter 'scan interval' must have only 1 elements.");
    return;
  }
  
  scanInt = (u16)mxGetScalar(SSPARAM_SCANI);
  if ( (scanInt != -2) && (scanInt != -1) && (scanInt < 0) ) {
    ssSetErrorStatus(S,"Value of parameter 'scan interval' must be between -1 or higher than 0.");
    return;
  }
  
} /* End of Function: mdlInitializeSizes */
/* --------------------------------------------------------------------- */
#endif


/* ===================================================================== */
static void mdlInitializeSizes(SimStruct *S) {
  
  /* get nbrChannels */
  i16 numChans = (i16)mxGetNumberOfElements(SSPARAM_CHNLS);
  
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
  ssSetOutputPortWidth(S, 0, (int_T)numChans);
  
  /* Number of block sample times */
  ssSetNumSampleTimes(S, 1);
  
  /* Set the number of work vectors */
  ssSetNumRWork(S, 0);
  ssSetNumIWork(S, DB_BUFFER_SIZE+1);
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
  
  i16 deviceNbr = 1; /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
  i16 *channels = (i16 *)mxGetPr(SSPARAM_CHNLS);
  i16 numChans  = (i16)mxGetNumberOfElements(SSPARAM_CHNLS);
  i16 *gains    = (i16 *)mxGetPr(SSPARAM_GAINS);
  i16 *buffer;
  i16 sampTB = -3; /* sample timebase within each scan (= -3 so it is as fast as possible) */
  u16 sampInt = 2; /* sample interval within each scan (= 2 so it is as fast as possible) */
  i16 scanTB  = (i16)mxGetScalar(SSPARAM_SCANB);
  u16 scanInt = (u16)mxGetScalar(SSPARAM_SCANI);
  
  i16 status, retVal;   /* The returned status of the functions and NIDAQErrorHandler */
  i16 ignoreWrng = 0;   /* Don't ignore the warnings (0) */
  
  int_T  *IWork = ssGetIWork(S); /* Shows existence of device */
  
  /* ------------------------------------- */
  /* Set the position of buffer */
  
  buffer = &((i16)IWork[1]); /* IWork[0] is used for something else */
  
  /* ------------------------------------- */
  /* Configure the AD Card */
  
  status = DAQ_DB_Config (deviceNumber, DBmode)
  
  status = SCAN_Setup (deviceNbr, numChans, channels, gains);
  
  /* Check existence of device */
  if ((status == -10401) || (status == -10402) || (status == -10403)) {
    /* No device or unrecognised device */
    IWork[0] = -1;
  } else {
    retVal = NIDAQErrorHandler(status, "SCAN_Setup", ignoreWrng);
    IWork[0] = 1;
  }
  
  if (IWork[0] == 1) {
    status = SCAN_Start (deviceNbr, buffer, (u32)DB_BUFFER_SIZE, sampTB, sampInt, scanTB, scanInt);
    retVal = NIDAQErrorHandler(status, "SCAN_Start", ignoreWrng);
  }
  
  /* ssPrintf("Debugging (%s, %d): Got to here.\n", __FILE__, __LINE__, status); */
  
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
  
  i16 numChans  = (i16)mxGetNumberOfElements(SSPARAM_CHNLS);
  i16 halfBuffer[DB_BUFFER_SIZE/2];
  u32 ptsTfr;
  i16 daqStopped;
  
  int_T  *IWork = ssGetIWork(S); /* Shows existence of device */
  
  /* ssPrintf("Debugging (%s, %d): IWork = %d\n", __FILE__, __LINE__, IWork[0]); */
  
  /* ------------------------------------- */
  /* Transfer half the DB circular buffer from the AD Card */
  
  if (IWork[0] != -1) {
    status = DAQ_DB_Transfer(deviceNbr, halfBuffer, &ptsTfr, &daqStopped);
    retVal = NIDAQErrorHandler(status, "DAQ_DB_Transfer", ignoreWrng);
  }
  
  for (i=0; i<numChans; i++) {
    y[i] = 0;
  }
  
} /* End of Function: mdlOutputs */
/* --------------------------------------------------------------------- */


/* ===================================================================== */
static void mdlTerminate(SimStruct *S) {
  
  /* ------------------------------------- */
  /* Variables used by the s-function */
  
  /* ------------------------------------- */
  /* Variables needed for the AD card */
  
  i16 deviceNbr  = 1;   /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
  i16 status, retVal;   /* The returned status of the functions and NIDAQErrorHandler */
  i16 ignoreWrng = 0;   /* Don't ignore the warnings (0) */
  
  int_T  *IWork = ssGetIWork(S); /* Shows existence of device */
  
  /* ssPrintf("Debugging (%s, %d): IWork = %d\n", __FILE__, __LINE__, IWork[0]); */
  
  /* ------------------------------------- */
  /* Reset the AD Card */
  
  if (IWork[0] != -1) {
    status = DAQ_Clear (deviceNbr);
    retVal = NIDAQErrorHandler(status, "DAQ_Clear", ignoreWrng);
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
