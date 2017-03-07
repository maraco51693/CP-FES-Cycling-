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
/*
/* The functions below uses the following NI functions:
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
/*   To display a message dialog box with the NI-DAQ error/warning code
/*   and a description, and an option for the user to continue.
/*
/*   retVal     : Is the returned value from the message dialog box.
/*   status     : Is the status output from a previouse NI function.
/*   sStrFnName : Is a static string of the previouse NI function's name.
/*   ignoreWrng : Can be set to ignore warnings (1) or not (0).
/*
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
#include "simstruc.h"


/* --------------------------------------------------------------------- */
/* Global Variables */

i16 buffer[DB_BUFFER_SIZE];
/* This buffer has to be big enough that external computation can be
/* done before half of it is filled up
*/

i16 halfBuffer[(DB_BUFFER_SIZE/2) + 1];

int cardType = 0;


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
		return -1;
	} else if (status == -10402) {
		printf("Warning (%s): Device not found error (-10402).\n", __FILE__);
		return -1;
	} else if (status == -10403) {
		printf("Warning (%s): Device recognised but action not supported (-10403).\n", __FILE__);
		return -1;
	} else {
		retVal = NIDAQErrorHandler(status, "Get_DAQ_Device_Info", ignoreWrng);
		if (retVal == ID_NO) {return -1;} /* prematurely end */
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
		/* printf("Error (%s): This function is not set up to deal with this AD device.\n", __FILE__); */
		/* return; */
		cardType = 0;
		break;
	}
	
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
	/* within each scan each channel is sampled at 5 * 1탎 = 5탎 */
	i16 scanTB;      /* sample timebase between each scan */
	u16 scanInt;     /* sample interval between each scan */
	
	
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
	}
	
	
	/* -------------------------------------------- */
	/* Start the Device Scanning */
	
	if (cardType != 0) {
		status = SCAN_Start (deviceNbr, buffer, scanCount*numChans, sampTB, sampInt, scanTB, scanInt);
		retVal = NIDAQErrorHandler(status, "SCAN_Start", ignoreWrng);
		if (retVal == ID_NO) {return -1;} /* prematurely end */
	}
	
	return 0;
	
	
} /* End of DAQ_DB_Init */
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
int DAQ_DB_Step(i16 *hb, u32 *ptsTfr)
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
	
	i16 daqStopped;
	
	
	/* -------------------------------------------- */
	/* Transfer half the DB circular buffer from the AD Card */
	
	if (cardType != 0) {
		status = DAQ_DB_Transfer (deviceNbr, halfBuffer, ptsTfr, &daqStopped);
		retVal = NIDAQErrorHandler(status, "DAQ_DB_Transfer", ignoreWrng);
		if (retVal == ID_NO) {return -1;} /* prematurely end */
	}
	
	hb = halfBuffer;
	
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
	
	if (cardType != 0) {
		status = DAQ_Clear (deviceNbr);
		retVal = NIDAQErrorHandler(status, "DAQ_Clear", ignoreWrng);
		if (retVal == ID_NO) {return -1;} /* prematurely end */
	}
	
	return 0;
	
	
} /* End of DAQ_DB_Terminate */
/* --------------------------------------------------------------------- */


/* --------------------------------------------------------------------- */
/* End of File DAQ_DB_Drivers.c */