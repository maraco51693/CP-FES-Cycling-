/* 
  sf_rtsync_cont.c
  S-Function for real-time execution in win32
  
  To compile as a mex function use 
  mex sf_rtsync_cont.c winmm.lib

  Uses windows multimedia timer. Time basis is milliseconds. 
  To compile use MS Visual C/C++.

  Put this block somewhere in your simulink diagram to make the
  execution somewhat follow real time. 

  Set the simulink sample time parameter to 1 and use a fixed step solver.
  Set the sample time parameter of this block to 1.
 
  Now the value of the input to this block defines how long each 
  sample step takes (in seconds).

  Input is the sample time.

  Output 1 is the actual delay for each sample step.
  Output 2 is the simulation time (time passed since start of simulation)

  Note: The first output measures the time between system initialisation and
        start which is often larger than the required sample time. 

  mex -v sf_rtsync_cont.c  winmm.lib
 */ 
 
#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  sf_rtsync_cont

#undef VERBOSE
 
/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"
 
/* other header files */
#include <stdio.h>
#include <string.h>
# include <windows.h>
#include <mmsystem.h>
 
#define VERBOSE

/* Global variables */

 
/*
 define the parameters
 */
#define SAMPLETIME(S)  ssGetSFcnParam(S,0)

#define TPREV  RWork[0]
//#define TS  RWork[1]
#define TSTART  RWork[1]
 
 
 /*====================*
 * S-function methods *
 *====================*/
 
static void mdlInitializeSizes(SimStruct *S)
{
  /* See sfuntmpl.doc for more details on the macros below */
  
  ssSetNumSFcnParams(S, 1);  /* Number of expected parameters */
  if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
	 /* Return if number of expected != number of actual parameters */
	 return;
  }
  
  ssSetNumContStates(S, 0);
  ssSetNumDiscStates(S, 0);
  
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortRequiredContiguous(S, 0, true); /*direct input signal access*/
    /*
     * Set direct feedthrough flag (1=yes, 0=no).
     * A port has direct feedthrough if the input is used in either
     * the mdlOutputs or mdlGetTimeOfNextVarHit functions.
     * See matlabroot/simulink/src/sfuntmpl_directfeed.txt.
     */
    ssSetInputPortDirectFeedThrough(S, 0, 1);
  
  if (!ssSetNumOutputPorts(S, 2)) return;
  ssSetOutputPortWidth(S, 0, 1);
  ssSetOutputPortWidth(S, 1, 1);
  
  ssSetNumSampleTimes(S, 1); 
  ssSetNumRWork(S, 2); 
  ssSetNumIWork(S, 0); 
  ssSetNumPWork(S, 0); 
  ssSetNumModes(S, 0); 
  ssSetNumNonsampledZCs(S, 0); 
  ssSetOptions(S, 0); 
} 

 
static void mdlInitializeSampleTimes(SimStruct *S) 
{ 
  if (!mxIsDouble(SAMPLETIME(S))) {
    ssSetErrorStatus(S,"The second argument needs to be the sample time, e.g. 0.05.\n");
    return;
  } else {
    if (mxGetNumberOfElements(SAMPLETIME(S))!=1) {
      ssSetErrorStatus(S,"The second argument needs to be scalar, e.g. 0.05.\n");
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
  real_T *RWork = ssGetRWork(S);
  timeBeginPeriod(1);
  TPREV = (real_T) timeGetTime();
  TSTART = (real_T)timeGetTime();
}
#endif /*  MDL_START */
 
 
static void mdlOutputs(SimStruct *S, int_T tid)
{
  real_T            *y0    = ssGetOutputPortRealSignal(S,0);
  real_T            *y1    = ssGetOutputPortRealSignal(S,1);
  real_T tdiff,ts;
  real_T *RWork = ssGetRWork(S);
  const real_T *u = (const real_T*) ssGetInputPortSignal(S,0);

  ts = 1e3*u[0];

  tdiff = (real_T) timeGetTime()-TPREV;
  
  if (tdiff<0) { // time counter wrap-round
    printf("WARNING: counter wrap-around!\n tnow = %g, tprev = %g\n",1e3*(TPREV+tdiff), 1e3*TPREV); fflush(stdout);
    //Sleep((DWORD) TS);
    Sleep((DWORD) ts);
  } else {
    //while ((tdiff>=0) & (tdiff<TS)) {
    while ((tdiff>=0) & (tdiff<ts)) {
      tdiff = (real_T) timeGetTime()-TPREV;
    }
  }
  
  tdiff = (real_T) timeGetTime() - TPREV;
  TPREV += tdiff; // equivalent to TPREV=mu_time(), but one fcn-call less
  
  y0[0]= 1e-3* (real_T) tdiff;
  y1[0]= 1e-3* (tdiff+TPREV-TSTART); //simulation time [in sec]

}
 
#undef MDL_UPDATE  /* Change to #undef to remove function */ 
#if defined(MDL_UPDATE) 
static void mdlUpdate(SimStruct *S, int_T tid)
{
}
#endif /* MDL_UPDATE */
 
 
#undef MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
static void mdlDerivatives(SimStruct *S)
{
}
#endif /* MDL_DERIVATIVES */
 
 
static void mdlTerminate(SimStruct *S) 
{ 
  timeEndPeriod(1);
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
