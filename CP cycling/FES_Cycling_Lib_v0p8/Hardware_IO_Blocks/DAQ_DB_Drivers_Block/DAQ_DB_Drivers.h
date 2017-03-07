/* --------------------------------------------------------------------- */
/*   File: DAQ_DB_Drivers.h
/* Author: Benjamin Saunders
/*   Date: 09 Feb 2004
/* --------------------------------------------------------------------- */
/* Discription:
/* This file is the header file for the DAQ_DB_Drivers.c file that
/* containes the function calls for the DAQ-6024E AD card (only) for
/* reading analogue input channels using double buffering.
/* When compiling this s-function the National Instruments (NI)
/* libraries nidaq32.lib and nidex32.lib need to be linked in.  Also
/* include the National Instruments header file nidaqex.h
/* For a better description of the NI functions used see the
/* DAQ_DB_Drivers.c file or use the NI documentation for a full
/* explanation.
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* Defines */

#define DB_BUFFER_SIZE   200000

#define ID_YES                6
#define ID_NO                 7

/* #define DEBUG_MODE /**/


/* --------------------------------------------------------------------- */
/* Function Prototypes */

int DAQ_CardCheck(void);
int DAQ_DB_Init(i16 numChans, i16 *channels, i16 *gains, f64 scanRatePerSec, i16 scanCount);
int DAQ_DB_Step(i16 **hb, u32 *ptsTfr);
int DAQ_DB_Term(void);


/* --------------------------------------------------------------------- */
/* End of File DAQ_DB_Drivers.h */