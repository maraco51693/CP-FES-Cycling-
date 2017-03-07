/* ********************************************************************* */
/*   File: DAQ_DB_Drivers.c
/* Author: Benjamin Saunders
/*   Date: 09 Feb 2004
/* --------------------------------------------------------------------- */
/* Discription:
/* This file containes the function calls for the DAQ-6024E AD card
/* (only) for reading analogue input channels using double buffering.
/* When compiling this s-function the National Instruments (NI)
/* libraries nidaq32.lib and nidex32.lib need to be linked in.  Also
/* include the National Instruments header file nidaqex.h
/* --------------------------------------------------------------------- */
/* Updates:
/* 09 Feb. 2004: Ben Saunders
/*   Set up this file from an s-function. It is easier to deal with
/*   seperatly especially because it uses global variables.
/* 12 Feb. 2004: Ben Saunders
/*   Created the DAQ_CardCheck function and added the NI function
/*   DAQ_Rate and made the variable count an input to the function
/*   DAQ_DB_Init.
/* ********************************************************************* */

/* --------------------------------------------------------------------- */
/* Includes */

#include "nidaqex.h" /* Include the NI drivers */
#include "DAQ_DB_Drivers.h"
#include "simstruc.h" /* only needed when using in an s-Function */


/* --------------------------------------------------------------------- */
/* Global Variables */

i16 buffer[DB_BUFFER_SIZE];
/* This buffer has to be big enough that external computation can be
/* done before half of it is filled up
*/

i16 halfBuffer[(DB_BUFFER_SIZE/2) + 1];
int cardType = 0;
int isCardInit = 0; /* used to indicate if the card has been initialised (1) or not (0). */


/* ********************************************************************* */
/* Functions */

/* --------------------------------------------------------------------- */
int DAQ_CardCheck(void)
/* This function is used to check which AD card is plugged in
*/
{
	/* -------------------------------------------- */
	/* Local Variables */
	
	i16 deviceNbr  = 1; /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
	i16 status, retVal; /* The returned status of the functions and NIDAQErrorHandler */
	i16 ignoreWrng = 0; /* Don't ignore the warnings (0) */
	
	u32 infoType;       /* information type requested */
	u32 infoValue;      /* information requested output */
	
	
	/* -------------------------------------------- */
	/* Check for NI DAQ Card */
	
	infoType = ND_DEVICE_TYPE_CODE;
	
	status = Get_DAQ_Device_Info (deviceNbr, infoType, &infoValue);
	
	/* Check existence of device */
	if (status == -10401) {
		printf("Warning (%s): Unknown device error (-10401).\n", __FILE__);
		isCardInit = 0; return -1;
	} else if (status == -10402) {
		printf("Warning (%s): Device not found error (-10402).\n", __FILE__);
		isCardInit = 0; return -1;
	} else if (status == -10403) {
		printf("Warning (%s): Device recognised but action not supported (-10403).\n", __FILE__);
		isCardInit = 0; return -1;
	} else {
		retVal = NIDAQErrorHandler(status, "Get_DAQ_Device_Info", ignoreWrng);
		if (retVal == ID_NO) {isCardInit = 0; return -1;} /* prematurely end */
	}
	
	switch (infoValue) {
	case 1: /* Not a National Instruments DAQ device */
		cardType = 0;
		isCardInit = 0;
		break;
	case 48: /* DAQCard-1200 */
		cardType = 1200;
	break;
		case 91: /* DAQCard-6024E */
		cardType = 6024;
		break;
	default: /* Unknown */
		/* printf("Error (%s): This function is not set up to deal with this AD device.\n", __FILE__); */
		/* return; */
		cardType = 0;
		isCardInit = 0;
		break;
	}
	
#ifdef DEBUG_MODE
	printf("Debuging (%s, %d): Completed DAQ_CardCheck.\n", __FILE__, __LINE__);
#endif
	
	return 0;
	
	
} /* End of DAQ_CardCheck */
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
int DAQ_DB_Init(i16 numChans, i16 *channels, i16 *gains, f64 scanRatePerSec, i16 scanCount)
/* This function is used to initiate the AD card for DB operations
*/
{
	/* -------------------------------------------- */
	/* Local Variables */
	
	i16 deviceNbr  = 1;   /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
	i16 status, retVal;   /* The returned status of the functions and NIDAQErrorHandler */
	i16 ignoreWrng = 0;   /* Don't ignore the warnings (0) */
	
	int retDB = 0;        /* Returned values from local functions */
		
	i16 sampTB  = 1; /* sample timebase within each scan (as fast as possible for this card) */
	u16 sampInt = 5; /* sample interval within each scan (as fast as possible for this card) */
	/* within each scan each channel is sampled at 5 * 1µs = 5µs */
	i16 scanTB;      /* sample timebase between each scan */
	u16 scanInt;     /* sample interval between each scan */
	
	i16 daqStopped; /* indication of whether the data acquisition has completed */
	u32 retrieved;  /* progress of an acquisition */
	
	
	/* -------------------------------------------- */
	/* Pre-set isCardInit to 0 */
	
	isCardInit = 0;
	
	
	/* -------------------------------------------- */
	/* Check scanCount */
	
	if ((scanCount*numChans) > DB_BUFFER_SIZE) {
		printf("Error (%s): Buffer size is too small.\n", __FILE__);
		return -1;
	}
	
	
	/* -------------------------------------------- */
	/* Check for NI DAQ Card */
	
	retDB = DAQ_CardCheck(); /* set the cardType variable */
	if (retDB != 0) {return -1;}
	
	
	/* -------------------------------------------- */
	/* Set DB Mode */
	
	if (cardType != 0) {
		status = DAQ_DB_Config (deviceNbr, 1); /* 0=disable; 1=enable */
		retVal = NIDAQErrorHandler(status, "DAQ_DB_Config", ignoreWrng);
		if (retVal == ID_NO) {return -1;} /* prematurely end */
	}
	
	
	/* -------------------------------------------- */
	/* Get Scan Timebase and Interval Values */
	
		
	if (cardType != 0) {
		status = DAQ_Rate (scanRatePerSec, 0, &scanTB, &scanInt); /* defined in points/sec (0) */
		retVal = NIDAQErrorHandler(status, "DAQ_Rate", ignoreWrng);
		if (retVal == ID_NO) {return -1;} /* prematurely end */
		/* printf("Debugging (%s, %d): scanRatePerSec = %f; scanTB = %d; scanInt = %d\n", __FILE__, __LINE__, scanRatePerSec, scanTB, scanInt); /**/
	}
	
	if ((scanTB < 1) ||((scanTB == 1) && (scanInt < 6))) {
		printf("Error (%s): Scan rate is too fast for the hardware.\n", __FILE__);
		return -1;
	}
	
	if ((scanTB == 1) && (scanInt < 6)) {
		scanInt = 0;
	}
	
	
	/* -------------------------------------------- */
	/* Set Up the AD channels to be scanned */
	
	if (cardType != 0) {
		status = SCAN_Setup (deviceNbr, numChans, channels, gains);
		retVal = NIDAQErrorHandler(status, "SCAN_Setup", ignoreWrng);
		if (retVal == ID_NO) {return -1;} /* prematurely end */
		/* printf("Debugging (%s, %d): numChans = %d, channels[1 2 3 4] = [%d %d], gains[1 2 3 4] = [%d %d]\n", __FILE__, __LINE__, numChans, channels[0], channels[1], gains[0], gains[1]); /**/
	}
	
	
	/* -------------------------------------------- */
	/* Start the Device Scanning */
	
	if (cardType != 0) {
		/* status = SCAN_Start (deviceNbr, buffer, scanCount*numChans, 1, 5, 1, 3846); /**/
		status = SCAN_Start (deviceNbr, buffer, scanCount*numChans, sampTB, sampInt, scanTB, scanInt); /**/
		retVal = NIDAQErrorHandler(status, "SCAN_Start", ignoreWrng);
		if (retVal == ID_NO) {return -1;} /* prematurely end */
		
		/* printf("Debugging (%s, %d): scanCount*numChans = %d, samp[TB, int] = [%d, %d], scan[TB, int] = [%d, %d]\n", __FILE__, __LINE__, scanCount*numChans, sampTB, sampInt, scanTB, scanInt); /**/
		printf("Debugging (%s, %d): scanCount = %d numChans = %d, scan[TB, int] = [%d, %d]\n", __FILE__, __LINE__, scanCount, numChans, scanTB, scanInt); /**/
		
		/* status = DAQ_Check (deviceNbr, &daqStopped, retrieved);
		/* retVal = NIDAQErrorHandler(status, "DAQ_Check", ignoreWrng);
		/* if (retVal == ID_NO) {return -1;} /* prematurely end */
		/* if (daqStopped != 1) {
		/* 	printf("Warning (%s): DAQ_Check indicated that card had not been stopped (%d).\n", __FILE__, daqStopped); /**/
		/* 	return -1;
		/* } /* prematurely end */
	}
	
#ifdef DEBUG_MODE
	printf("Debuging (%s, %d): Completed DAQ_DB_Init.\n", __FILE__, __LINE__);
#endif
	
	isCardInit = 1;
	return 0;
	
	
} /* End of DAQ_DB_Init */
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
int DAQ_DB_Step(i16 **hb, u32 *ptsTfr)
/* This function is used to grab data from the buffer during data
/* acquisition.  Note that the NI function will perform blocking while
/*this is being done.
*/
{
	/* -------------------------------------------- */
	/* Local Variables */
	
	i16 deviceNbr  = 1;   /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
	i16 status, retVal;   /* The returned status of the functions and NIDAQErrorHandler */
	i16 ignoreWrng = 0;   /* Don't ignore the warnings (0) */
	
	/* i16 halfReady; /**/
	i16 daqStopped;
	
	
	/* -------------------------------------------- */
	/* Transfer half the DB circular buffer from the AD Card */
	
	if (isCardInit == 1) {
		
		/* status = DAQ_DB_HalfReady (deviceNbr, &halfReady, &daqStopped);
		/* retVal = NIDAQErrorHandler(status, "DAQ_DB_HalfReady", ignoreWrng);
		/* if (retVal == ID_NO) {return -1;} /* prematurely end */
		/* if (daqStopped == 1) {
		/* 	printf("Warning (%s): DAQ_DB_HalfReady indicated that process has been stopped (%d).\n", __FILE__, daqStopped); /**/
		/* }
		/**/
		
		status = DAQ_DB_Transfer (deviceNbr, halfBuffer, ptsTfr, &daqStopped);
		/* printf("Debugging (%s, %d): deviceNbr = %d, ptsTfr = %d, halfBuffer = [%d %d ...], daqStopped = %d\n", __FILE__, __LINE__, deviceNbr, *ptsTfr, halfBuffer[0], halfBuffer[1], daqStopped); /**/
		switch (status) {
			case 10846:
				printf("Warning (%s): Data lost. Could not capture data quick enough.\n", __FILE__);
				return 1;
				break;
			case -10846:
				printf("Error (%s): Data lost. Could not capture data quick enough.\n", __FILE__);
				return 1;
				break;
			default:
				retVal = NIDAQErrorHandler(status, "DAQ_DB_Transfer", ignoreWrng);
				if (retVal == ID_NO) {return -1;} /* prematurely end */
				break;
		}
		*hb = halfBuffer;
	} else {
		printf("Warning (%s): No card initialised.\n", __FILE__);
	}
	
	
#ifdef DEBUG_MODE
	printf("Debuging (%s, %d): Completed DAQ_DB_Transfer.\n", __FILE__, __LINE__);
#endif
	
	return 0;
	
	
} /* End of DAQ_DB_Transfer */
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
int DAQ_DB_Term(void)
/* This function terminates the double buffering process.  It must be
/* called before another DAQ_DB_Init call is made.
*/
{
	/* -------------------------------------------- */
	/* Local Variables */
	
	i16 deviceNbr  = 1;   /* Is the device number as assigned by the NI Measurement & Automation.  Assume this is 1 */
	i16 status, retVal;   /* The returned status of the functions and NIDAQErrorHandler */
	i16 ignoreWrng = 0;   /* Don't ignore the warnings (0) */
	
	
	/* ------------------------------------- */
	/* Reset the AD Card */
	
	if (isCardInit == 1) {
		status = DAQ_Clear (deviceNbr);
		retVal = NIDAQErrorHandler(status, "DAQ_Clear", ignoreWrng);
		if (retVal == ID_NO) {return -1;} /* prematurely end */
	}
	
#ifdef DEBUG_MODE
	printf("Debuging (%s, %d): Completed DAQ_DB_Terminate.\n", __FILE__, __LINE__);
#endif
	
	return 0;
	
	
} /* End of DAQ_DB_Terminate */
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* End of File DAQ_DB_Drivers.c */