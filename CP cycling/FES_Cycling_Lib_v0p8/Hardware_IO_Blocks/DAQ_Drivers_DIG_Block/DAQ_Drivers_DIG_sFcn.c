/* --------------------------------------------------------------------- */
/*   File: DAQ_Drivers_DIG_sFcn.c
/* Author: Benjamin Saunders
/*   Date: 28 January 2004
/* --------------------------------------------------------------------- */
/* Discription:
/* This is the s-function code that contains the drivers for the DAQ1200
/* and the DAQ-6024E AD cards for reading and writting to a digital port.
/* When compiling this s-function the National Instruments (NI)
/* libraries nidaq32.lib and nidex32.lib need to be linked in.  Also
/* include the National Instruments header file nidaqex.h
/*
/* This s-function uses 5 NI functions:
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
/* status = DIG_Prt_Config (deviceNbr, port_nbr, mode, dir);
/*   DIG_Prt_Config is used to configure the digital port with desired
/*   mode and direction.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   port_nbr   : Is the digital I/O port number. 0 for the E Series
/*                devices or 0 through 2 for 1200 Series devices.
/*   mode       : Indicates the handshake mode the port uses..
/*                0: Port is configured for no-handshaking (nonlatched)
/*                   mode. You must use mode = 0 for all other ports and
/*                   devices.
/*                1: Port is configured for handshaking (latched) mode.
/*                   mode = 1 is valid only for ports 0 and 1 of 1200
/*                   Series devices.
/*   dir        : Indicates the direction, input or output, or the output
/*                type to which the port is to be configured.
/*                0: Port is configured as an input port (default).
/*                1: Port is configured as a standard output port.
/*                2: Port is configured as a bidirectional port.
/*                3: Port is configured as an output port, with wired-OR
/*                   (open collector) output drivers.
/*
/* status = DIG_In_Prt (deviceNbr, port_nbr, pattern);
/*   Used to reads the whole of a digital port.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   port_nbr   : The digital I/O port number; 0 for E Series devices; 0
/*                through 2 for 1200 Series devices.
/*   pattern    : Returns the digital data read from the specified port.
/*                NI-DAQ maps pattern to the digital input lines making
/*                up the port such that bit 0, the least significant bit,
/*                corresponds to digital input line 0. If the port is less
/*                than 32 bits wide, NI-DAQ also sets the bits of pattern
/*                that do not correspond to lines in the port to 0. For
/*                example, because port 0 and 1 on E Series is four bits wide,
/*                only bits 0 through 7 of pattern reflect the digital state
/*                of these ports, while NI-DAQ sets all other bits of pattern
/*                to 0.
/*
/* status = DIG_Out_Prt (deviceNbr, port_nbr, pattern);
/*   Used to reads an analog input channel and returns the result scaled
/*   in units of volts.
/*
/*   status     : Is the output status of the function (used to catch
/*                errors).
/*   deviceNbr  : Is the device number as assigned by the NI Measurement &
/*                Automation.
/*   port_nbr   : The digital I/O port number; 0 for E Series devices; 0
/*                through 2 for 1200 Series devices.
/*   pattern    : The digital pattern for the data written to the
/*                specified port. NI-DAQ ignores the high 32 bits of
/*                pattern. NI-DAQ maps the low 32 bits of pattern to the
/*                digital output lines making up the port so bit 0, the
/*                least significant bit, corresponds to digital output
/*                line 0. If the port is less than eight bits wide, only
/*                the low-order bits in pattern affect the port. For
/*                example, because port 0 and 1 on the E Series device is
/*                8 bits wide, only bits 0 through 7 of pattern affect the
/*                digital output state of these ports.
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
/* 28 January 2004: Ben Saunders
/*   Copied this function from the original that was programmed to read
/*   analogue inputs.
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* S-function preamble */

#define S_FUNCTION_NAME  DAQ_Drivers_DIG_sFcn
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "nidaqex.h" /* Include the NI drivers */


/* --------------------------------------------------------------------- */
/* User defines - using macros for s-function parameters */

#define SSPARAM_IDX_STIME    0     /* sample time */
#define SSPARAM_IDX_HMODE    1     /* handshake mode of the port */
#define SSPARAM_IDX_DIRCT    2     /* direction of port */
#define SSPARAM_IDX_PORTN    3     /* port number */

#define NBR_SSPARAMS         4     /* number of used parameters */

#define SSPARAM_STIME        ssGetSFcnParam(S, SSPARAM_IDX_STIME)     /* sample time */
#define SSPARAM_HMODE        ssGetSFcnParam(S, SSPARAM_IDX_HMODE)     /* handshake mode */
#define SSPARAM_DIRCT        ssGetSFcnParam(S, SSPARAM_IDX_DIRCT)     /* direction of port */
#define SSPARAM_PORTN        ssGetSFcnParam(S, SSPARAM_IDX_PORTN)     /* port number */

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
  int_T  hMode;       /* value of the handshake mode */
  int_T  direction;   /* value of the direction of port */
  int_T  port_nbr;    /* value of the port number */

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
  /* Parameter: SSPARAM_PORTN = port number */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_PORTN, NONTUNABLE); 
  
  if (mxIsComplex(SSPARAM_PORTN)) {
    ssSetErrorStatus(S,"Parameter 'port number' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_PORTN) != 2) {
    ssSetErrorStatus(S,"Parameter 'port number' must have only 2 dimensions.");
    return;
  }
  if (mxGetNumberOfElements(SSPARAM_PORTN) != 1) {
    ssSetErrorStatus(S,"Parameter 'port number' must have only 1 elements.");
    return;
  }
  
  port_nbr = (int_T) ((real_T *) mxGetData(SSPARAM_PORTN))[0];
  if ((cardType == 1200) && ((port_nbr < 0) || (port_nbr > 2))) {
    ssSetErrorStatus(S,"Value of parameter 'port number' for DAQ 1200 must be 0, 1 or 2.");
    return;
  }
  if ((cardType == 6024) && (port_nbr != 0)) {
    ssSetErrorStatus(S,"Value of parameter 'port number' for DAQ-6024E must be 0 (only one port).");
    return;
  }
  
  /* ------------------------------------- */
  /* Parameter: SSPARAM_HMODE = handshake mode */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_HMODE, NONTUNABLE); 
  
  if (mxIsComplex(SSPARAM_HMODE)) {
    ssSetErrorStatus(S,"Parameter 'handshake mode' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_HMODE) != 2) {
    ssSetErrorStatus(S,"Parameter 'handshake mode' must have only 2 dimensions.");
    return;
  }
  if (mxGetNumberOfElements(SSPARAM_HMODE) != 1) {
    ssSetErrorStatus(S,"Parameter 'handshake mode' must have only 1 elements.");
    return;
  }
  
  hMode = (int_T) ((real_T *) mxGetData(SSPARAM_HMODE))[0];
  if ((hMode != 0) && (hMode != 1)) {
    ssSetErrorStatus(S,"Value of parameter 'handshake mode' must be either 0 or 1.");
    return;
  }
  if ((cardType == 6024) && (hMode != 0)) {
    ssSetErrorStatus(S,"Value of parameter 'handshake mode' for DAQ-6024E must be no-handshake (0).");
    return;
  }
  if ((hMode == 1) && (port_nbr == 2)) {
    ssSetErrorStatus(S,"Parameter 'handshake mode' can only be 1 for ports 0 or 1 with the DAQ 1200.");
    return;
  }
  
  /* ------------------------------------- */
  /* Parameter: SSPARAM_DIRCT = direction of port */
  
  ssSetSFcnParamTunable(S, SSPARAM_IDX_DIRCT, NONTUNABLE); 
  
  if (mxIsComplex(SSPARAM_DIRCT)) {
    ssSetErrorStatus(S,"Parameter 'direction' has to be a non complex type.");
    return;
  }
  if (mxGetNumberOfDimensions(SSPARAM_DIRCT) != 2) {
    ssSetErrorStatus(S,"Parameter 'direction' must have only 2 dimensions.");
    return;
  }
  if (mxGetNumberOfElements(SSPARAM_DIRCT) != 1) {
    ssSetErrorStatus(S,"Parameter 'direction' must have only 1 elements.");
    return;
  }
  
  direction = (int_T) ((real_T *) mxGetData(SSPARAM_DIRCT))[0];
  if ( (direction < 0) || (direction > 3) ) {
    ssSetErrorStatus(S,"Value of parameter 'direction' must be between 0 and 3.");
    return;
  }
  if ((cardType == 6024) && (direction != 0) && (direction != 1)) {
    ssSetErrorStatus(S,"Value of parameter 'direction' for DAQ-6024E must be either input or output (standard 0 or 1).");
    return;
  }
  
} /* End of Function: mdlInitializeSizes */
/* --------------------------------------------------------------------- */
#endif


/* ===================================================================== */
static void mdlInitializeSizes(SimStruct *S) {
  
  int_T direction = (int_T) ((real_T *) mxGetData(SSPARAM_DIRCT))[0];
  
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
  switch (direction) {
    case 0: /* Input port (read from the DIG port) */
      if (!ssSetNumInputPorts(S, 0)) return;
      if (!ssSetNumOutputPorts(S, 1)) return;
      ssSetOutputPortWidth(S, 0, 1);
      break;
    case 1: /* Standard output port (write to the DIG port) */
    case 3: /* Output port, with wired-OR output drivers */
      if (!ssSetNumInputPorts(S, 1)) return;
      if (!ssSetNumOutputPorts(S, 0)) return;
      ssSetInputPortDirectFeedThrough(S, 0, 1);
      ssSetInputPortWidth(S, 0, 1);
      break;
    case 2: /* Bidirectional port */
      if (!ssSetNumInputPorts(S, 1)) return;
      if (!ssSetNumOutputPorts(S, 1)) return;
      ssSetInputPortDirectFeedThrough(S, 0, 1);
      ssSetInputPortWidth(S, 0, 1);
      ssSetOutputPortWidth(S, 0, 1);
      break;
    default: /* unkown value of direction */
      ssSetErrorStatus(S,"Unkown value of parameter 'direction' when evaluating block ports.");
      return;
      break;
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
  
  i16 deviceNbr  = 1;   /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
  /* u32 infoType;       /* information type requested */
  /* u32 infoValue;      /* information requested output */
  
  i16 direction = (i16) ((real_T *) mxGetData(SSPARAM_DIRCT))[0];
  i16 port_nbr = (i16) ((real_T *) mxGetData(SSPARAM_PORTN))[0];
  i16 hMode = (i16) ((real_T *) mxGetData(SSPARAM_HMODE))[0];
  
  i16 status, retVal;   /* The returned status of the functions and NIDAQErrorHandler */
  i16 ignoreWrng = 0;   /* Don't ignore the warnings (0) */
  
  int_T  *IWork = ssGetIWork(S); /* Shows existence of device */
  
  /* ssPrintf("Debugging (%s, %d): deviceNbr = %d, port_nbr = %d, hMode = %d, direction = %d\n", __FILE__, __LINE__, deviceNbr, port_nbr, hMode, direction); /**/
  
  /* ------------------------------------- */
  /* Configure the DIG port */
  
  status = DIG_Prt_Config (deviceNbr, port_nbr, hMode, direction);
  
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
  
  InputRealPtrsType uPtrs; /* s-function inputs */
  real_T *y; /* s-function outputs */
  int_T  i; /* loop counter */  
  
  /* ------------------------------------- */
  /* Variables needed for the AD card */
  
  i16 deviceNbr  = 1;   /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
  i16 status, retVal;   /* The returned status of the functions and NIDAQErrorHandler */
  i16 ignoreWrng = 0;   /* Don't ignore the warnings (0) */
  i32 pattern_in;       /* The digital data read from the specified port */
  i32 pattern_out;      /* The digital data written to the specified port */
  
  int_T direction = (int_T) ((real_T *) mxGetData(SSPARAM_DIRCT))[0];
  i16 port_nbr = (i16) ((real_T *) mxGetData(SSPARAM_PORTN))[0];
  
  int_T  read_first = 0; /* Option for bidirectional read before or after writting */
  int_T  *IWork = ssGetIWork(S); /* Shows existence of device */
  
  /* ssPrintf("Debugging (%s, %d): IWork = %d\n", __FILE__, __LINE__, IWork[0]); /**/
  /* ssPrintf("Debugging (%s, %d): Got to here!\n", __FILE__, __LINE__); /**/
  
  /* ------------------------------------- */
  /* Check if initialisation was successful */
  
  if (IWork[0] == -1) { /* Don't use the card drivers */
    switch (direction) {
      case 0: /* Input port (Read port) */
      case 2: /* Bidirectional port */
        y = ssGetOutputPortSignal(S,0); /* set the output pointer */
        y[0] = 0;
      break;
    }
    return;
  }
  
  /* ------------------------------------- */
  /* Read/Write pattern from/to the specified port */
  
  switch (direction) {
    /* -------------------- */
    case 0: /* Input port (Read port) */
      
      y = ssGetOutputPortSignal(S,0); /* set the output pointer */
      
      status = DIG_In_Prt (deviceNbr, port_nbr, &pattern_in);
      retVal = NIDAQErrorHandler(status, "DIG_In_Prt", ignoreWrng);
      y[0] = (real_T)pattern_in;
      
      break;
      
    /* -------------------- */
    case 1: /* Standard output port */
    case 3: /* Output port, with wired-OR output drivers */
      
      uPtrs = ssGetInputPortRealSignal(S,0);  /* set the input pointer */
      
      pattern_out = (i32)(*uPtrs[0]);
      status = DIG_Out_Prt (deviceNbr, port_nbr, pattern_out);
      retVal = NIDAQErrorHandler(status, "DIG_In_Prt", ignoreWrng);
      break;
      
    /* -------------------- */
    case 2: /* Bidirectional port */
      
      uPtrs = ssGetInputPortRealSignal(S,0);  /* set the input pointer */
      y = ssGetOutputPortSignal(S,0); /* set the output pointer */
      
      read_first = 1; /* Read before writting but option is here to swap (or add into the mask) */
      if (read_first) { 
        status = DIG_In_Prt (deviceNbr, port_nbr, pattern_in);
        retVal = NIDAQErrorHandler(status, "DIG_In_Prt", ignoreWrng);
        /* y[0] = (real_T)(*pattern_in); */
      }
      
      pattern_out = (i32)(*uPtrs[0]);
      status = DIG_Out_Prt (deviceNbr, port_nbr, pattern_out);
      retVal = NIDAQErrorHandler(status, "DIG_In_Prt", ignoreWrng);
      
      if (!read_first) {
        status = DIG_In_Prt (deviceNbr, port_nbr, pattern_in);
        retVal = NIDAQErrorHandler(status, "DIG_In_Prt", ignoreWrng);
        /* y[0] = (real_T)(*pattern_in); */
      }
      
      break;
      
    /* -------------------- */
    default: /* Unkown value of direction */
      ssSetErrorStatus(S,"Unkown value of parameter 'direction' when evaluating block ports.");
      return;
      break;
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
