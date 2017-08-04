//
//  HexDumpUtility.m
//  yTrack
//
//  Created by Fabrice Dewasmes on 15/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "HexDumpUtility.h"
#import "DDLog.h"

#ifdef CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif



@implementation HexDumpUtility

+ (void) printHexDumpToConsole:(NSData *)data{
	
	int dataLength = [data length];
	
	// store a hex dump (ie: "00000000: 12 34 56 78 9a bd de f0  ........") in hexDump
	NSMutableString *hexDump = [[NSMutableString alloc] initWithCapacity:dataLength];
	// temporary storage for ASCII representation (ie: "........" from above)
	NSMutableString *tempAscii = [NSMutableString stringWithCapacity:8];
	// Is the file just a plain text file (ie: only containing ASCII values from 32 to 126)
	BOOL isPlainText = YES;
	// Keep track of position in file
	int i;
	
	for (i=0; i<dataLength; i++) {
		// Every 8 bytes, print text representation of hex and the current location in the file
		if (i % 8 == 0) {
			// Don't print the text representation before the first line since we haven't read any data yet
			if (i != 0) {
				// Print out the ASCII representation and empty out the string for the next line
				[hexDump appendFormat:@"% @\n", tempAscii];
				[tempAscii setString:@""];
			}
			// Print the first field in the Output (ie: current location in the file)
			[hexDump appendFormat:@"%08X: ", i];
		}
		unsigned char uChar;
		[data getBytes:&uChar range:NSMakeRange(i, 1)];
		// Check if the character is a normal printable character
		if (uChar >= 32 && uChar <= 126) {
			[tempAscii appendFormat:@"%c", uChar];
		} else {
			// If it isn't, pur a period (.) in the ASCII representation
			[tempAscii appendString:@"."];
			// and flag this as a non-text file unless this is for a tab, CR, or LF character
			if (uChar != 9 && uChar != 10 && uChar != 13) {
				isPlainText = NO;
			}
		}
		[hexDump appendFormat:@"%02X ", uChar];
	}
	
	// print text for last line here...
	// If the last line wasn't a multiple of 8 bytes, pad the line with enough spaces to get the ASCII representation to properly allign
	if (i % 8 != 0) {
		for (; i % 8 != 0; i++) {
			[hexDump appendString:@"   "];
		}
	}
	[hexDump appendFormat:@"% @\n", tempAscii];
	
	
//	NSLog(@"%@",hexDump);
	DDLogVerbose(@"%@",hexDump);
	[hexDump release];
}

@end
