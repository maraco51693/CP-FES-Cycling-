/* collection of functions to deal with the serial port in windows32 
	environment
*/

#include "serial_w32.h"



/*-------------------------------------------------------------------------
  printerrorvalue()
  print an error message and value
  ------------------------------------------------------------------------- */
void printerrorvalue(DWORD value)
{
  LPVOID lpMsgBuf;
  //obtain the error message associated with the error-value
  FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
					  NULL,
					  value,
					  MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
					  (LPTSTR) &lpMsgBuf,
					  0,
					  NULL 
					  );
	 
  printf("%s\n",lpMsgBuf); fflush(stdout);
}

/*-------------------------------------------------------------------------
  openserial()
  Opens port and returns a handle 
  ------------------------------------------------------------------------- */
HANDLE serial_openport (char *port)

{
  HANDLE hCom;
  DWORD dwError;

  hCom = CreateFile(port,
                    GENERIC_READ | GENERIC_WRITE,
                    0,    /* comm devices must be opened w/exclusive-access */
                    NULL, /* no security attrs */
                    OPEN_EXISTING, /* comm devices must use OPEN_EXISTING */
                    0,    /* if 1 overlapped I/O, ie asynchronous */
                    NULL  /* hTemplate must be NULL for comm devices */
                    );

  if (hCom == INVALID_HANDLE_VALUE) {
    /* handle error */
    dwError = GetLastError();
	 printf("Error: Invalid Handle while opening port %s: ", port);
    printerrorvalue(dwError);
  }
  return hCom;
}

/*-------------------------------------------------------------------------
  setupserialport()
  Set the input and output buffer size.
  Set the COM port for use with the stimulator.
  Fill in a DCB structure with the current configuration. 
  The DCB structure is then modified and used to reconfigure the device.
  Set the time-out parameters.
  ------------------------------------------------------------------------- */
BOOL serial_setupport (
		       HANDLE hCom,    // handle to serial port
		       DWORD InQueue,  // size of the input buffer (in bytes)
		       DWORD OutQueue, // size of the output buffer (in bytes)
		       DWORD BaudRate, // current baud rate 
		       DWORD fParity,  // enable parity checking, FALSE=0, TRUE=1
		       BYTE ByteSize,  // number of bits/byte, 4-8 
		       BYTE Parity,    // 0-4=no,odd,even,mark,space 
		       BYTE StopBits,  // 0,1,2 = 1, 1.5, 2
		       DWORD ReadIntervalTimeout,
		       DWORD ReadTotalTimeoutMultiplier,
		       DWORD ReadTotalTimeoutConstant,
		       DWORD WriteTotalTimeoutMultiplier,
		       DWORD WriteTotalTimeoutConstant
		       )
     /*
       BOOL   A Boolean value.
       BYTE.  An 8-bit integer that is not signed (unsgned char)
       DWORD  A 32-bit unsigned integer or the address of a segment and its associated offset.
       LONG   A 32-bit signed integer.
       LPARAM A 32-bit value passed as a parameter to a window procedure or callback function.
       LPSTR  A 32-bit pointer to a character string.
     */
{
  DCB dcb;
  DWORD dwError;
  BOOL fSuccess;
  COMMTIMEOUTS ct;

  /* set up the input / output buffers */
  fSuccess = SetupComm(hCom, InQueue, OutQueue);
  if (!fSuccess) {
    /* Handle error */
    dwError = GetLastError();
    printf("Error setup COM: "); 
    printerrorvalue(dwError);
    return fSuccess;
  }

  /* Get the current configuration. */
  fSuccess = GetCommState(hCom, &dcb);
  if (!fSuccess) {
    /* Handle error */
    dwError = GetLastError();
    printf("Error getting COM state: "); 
    printerrorvalue(dwError);
    return fSuccess;
  }

  /* Fill in the DCB: default values */
  dcb.fBinary = FALSE;           // binary mode, no EOF check   
  dcb.fOutxCtsFlow = FALSE;      // CTS output flow control     
  dcb.fOutxDsrFlow = FALSE;      // DSR output flow control     
  dcb.fDtrControl = DTR_CONTROL_DISABLE; // DTR flow control type       
  dcb.fDsrSensitivity = FALSE;   // DSR sensitivity             
  dcb.fTXContinueOnXoff = FALSE; // XOFF continues Tx           
  dcb.fOutX = FALSE;             // XON/XOFF out flow control       
  dcb.fInX = FALSE;              // XON/XOFF in flow control        
  dcb.fRtsControl = RTS_CONTROL_DISABLE; // RTS flow control 

  /* Fill in the DCB: from function inputs */
  dcb.BaudRate = BaudRate;     
  dcb.fParity = fParity;      
  dcb.ByteSize = ByteSize;   
  dcb.Parity = Parity;      
  dcb.StopBits = StopBits;  
  
  /* Set the new DCB configuration */
  fSuccess = SetCommState(hCom, &dcb);
  if (!fSuccess) {
    /* Handle error */
    dwError = GetLastError();
    printf("Error setting COM state: ");
    printerrorvalue(dwError);
    return fSuccess;
  }

  /* Get the current time-outs. */
  fSuccess = GetCommTimeouts(hCom, &ct);
  if (!fSuccess) {
    /* Handle error */
    dwError = GetLastError();
    printf("Error getting COM time-outs: ");
    printerrorvalue(dwError);
    return fSuccess;
  }
  /* Fill in the COMMTIMEOUTS: Disable all of them by setting them to 0 */
  /*
    ReadIntervalTimeout 
    Specifies the maximum time, in milliseconds, allowed to elapse
    between the arrival of two characters on the communications
    line. During a ReadFile operation, the time period begins when the
    first character is received. If the interval between the arrival
    of any two characters exceeds this amount, the ReadFile operation
    is completed and any buffered data is returned. A value of zero
    indicates that interval time-outs are not used.
    A value of MAXDWORD, combined with zero values for both the
    ReadTotalTimeoutConstant and ReadTotalTimeoutMultiplier members,
    specifies that the read operation is to return immediately with
    the characters that have already been received, even if no
    characters have been received.

    ReadTotalTimeoutMultiplier 
    Specifies the multiplier, in milliseconds, used to calculate the
    total time-out period for read operations. For each read
    operation, this value is multiplied by the requested number of
    bytes to be read.

    ReadTotalTimeoutConstant 
    Specifies the constant, in milliseconds, used to calculate the
    total time-out period for read operations. For each read
    operation, this value is added to the product of the
    ReadTotalTimeoutMultiplier member and the requested number of
    bytes.  
    A value of zero for both the ReadTotalTimeoutMultiplier and
    ReadTotalTimeoutConstant members indicates that total time-outs
    are not used for read operations.

    WriteTotalTimeoutMultiplier 
    Specifies the multiplier, in milliseconds, used to calculate the
    total time-out period for write operations. For each write
    operation, this value is multiplied by the number of bytes to be
    written.

    WriteTotalTimeoutConstant 
    Specifies the constant, in milliseconds, used to calculate the
    total time-out period for write operations. For each write
    operation, this value is added to the product of the
    WriteTotalTimeoutMultiplier member and the number of bytes to be
    written.
    A value of zero for both the WriteTotalTimeoutMultiplier and
    WriteTotalTimeoutConstant members indicates that total time-outs
    are not used for write operations.

    Remarks
	 
    If an application sets ReadIntervalTimeout and
    ReadTotalTimeoutMultiplier to MAXDWORD and sets
    ReadTotalTimeoutConstant to a value greater than zero and less
    than MAXDWORD, one of the following occurs when the ReadFile
    function is called:
    - If there are any characters in the input buffer, ReadFile
    returns immediately with the characters in the buffer.
    - If there are no characters in the input buffer, ReadFile waits
    until a character arrives and then returns immediately.  
    - If no character arrives within the time specified by
    ReadTotalTimeoutConstant, ReadFile times out.  
  */
  ct.ReadIntervalTimeout=ReadIntervalTimeout;
  ct.ReadTotalTimeoutMultiplier=ReadTotalTimeoutMultiplier;
  ct.ReadTotalTimeoutConstant=ReadTotalTimeoutConstant;
  ct.WriteTotalTimeoutMultiplier=WriteTotalTimeoutMultiplier;
  ct.WriteTotalTimeoutConstant=WriteTotalTimeoutConstant;

  fSuccess = SetCommTimeouts(hCom, &ct);
  if (!fSuccess) {
    /* Handle error */
    dwError = GetLastError();
    printf("Error setting COM time-outs: ");
    printerrorvalue(dwError);
    return fSuccess;
  }

  return fSuccess;
}

/*-------------------------------------------------------------------------
  closeserial()
  close the serial port
  ------------------------------------------------------------------------- */
BOOL serial_closeport(HANDLE hCom)
{
  DWORD dwError;
  BOOL fSuccess;

  fSuccess=CloseHandle(hCom);
  if (!fSuccess) {
    /* handle error */
    dwError = GetLastError();
	 printf("Error closing COM: " );
    printerrorvalue(dwError);
  }
  return fSuccess;
}

/*-------------------------------------------------------------------------
  sendstring()
  send a string to the serial port 
  ------------------------------------------------------------------------- */
BOOL serial_sendstring(
                HANDLE hCom,    //handle to the serial port 
                unsigned char *buffer,   //pointer to the string
                DWORD nb        //number of bytes in the string
                )
{
  DWORD  dwBytesWritten, dwError;
  BOOL fSuccess;

#ifdef VERBOSE
  unsigned int k;
  printf("sending: ");
  for (k=0;k<nb;k++)
    printf("0x%X ",buffer[k]);
  printf("\n");
  fflush(stdout);
#endif


  fSuccess = WriteFile(hCom, (LPSTR) buffer, nb, &dwBytesWritten, NULL);

  if (!fSuccess) {
    /* Handle error */
    dwError = GetLastError();
	 printf("Error writing to COM [sendstring]: ");
    printerrorvalue( dwError);
  }
  return fSuccess;
}

/*-------------------------------------------------------------------------
  readstring()
  reads a string from the serial port
  ------------------------------------------------------------------------- */
BOOL serial_readstring(
                HANDLE hCom,    //handle to the serial port 
                char *buffer,   //pointer to the string
                DWORD nb        //number of bytes in the string
                )
{
  DWORD  dwBytesRead, dwError;
  BOOL fSuccess;

  fSuccess = ReadFile(hCom, (LPVOID ) buffer, nb, &dwBytesRead, NULL);

  if (!fSuccess) {
    /* Handle error */
    dwError = GetLastError();
	 printf("Error reading from COM: "); 
    printerrorvalue(dwError);
  }

  return fSuccess;
}

