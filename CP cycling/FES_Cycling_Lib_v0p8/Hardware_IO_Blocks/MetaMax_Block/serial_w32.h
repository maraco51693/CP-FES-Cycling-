#ifndef VERBOSE
#undef VERBOSE
#endif

#include <windows.h>
#include <stdio.h>


void printerrorvalue(DWORD value);
HANDLE serial_openport (char *port);
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
							 );
BOOL serial_closeport(HANDLE hCom);
BOOL serial_sendstring(
                HANDLE hCom,    //handle to the serial port 
                unsigned char *buffer,   //pointer to the string
                DWORD nb        //number of bytes in the string
                );
BOOL serial_readstring(
                HANDLE hCom,    //handle to the serial port 
                char *buffer,   //pointer to the string
                DWORD nb        //number of bytes in the string
                );
