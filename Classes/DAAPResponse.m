//
//  DAAPResponse.m
//  yTrack
//
//  Created by Fabrice Dewasmes on 18/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponse.h"


@implementation DAAPResponse

@synthesize commandName;
@synthesize data;

- (id) initWithData:(NSData *)theData{
	if ((self = [super init])) {
        self.data = theData;
    }
    return self;
}

- (BOOL) isString:(NSString *)command{
	if ([command isEqualToString:@"minm"]) {
		return YES;
	} else if ([command isEqualToString:@"cann"]) {
		return YES;
	} else if ([command isEqualToString:@"cana"]) {
		return YES;
	} else if ([command isEqualToString:@"cang"]) {
		return YES;
	} else if ([command isEqualToString:@"canl"]) {
		return YES;
	} else if ([command isEqualToString:@"asaa"]) {
		return YES;
	} else if ([command isEqualToString:@"asal"]) {
		return YES;
	} else if ([command isEqualToString:@"asar"]) {
		return YES;
	} else if ([command isEqualToString:@"ceWM"]) {
		return YES;
	} else if ([command isEqualToString:@"asdt"]) {
		return YES;
	} else if ([command isEqualToString:@"msts"]) {
		return YES;
	} else if ([command isEqualToString:@"mcna"]) {
		return YES;
	} else if ([command isEqualToString:@"ascm"]) {
		return YES;
	} else if ([command isEqualToString:@"asfm"]) {
		return YES;
	} else if ([command isEqualToString:@"mcnm"]) {
		return YES;
	} else if ([command isEqualToString:@"mshc"]) {
		return YES;
	} 
	return NO;
}

- (BOOL) isNumber:(int)length{
	return (length == 1 || length == 2 || length == 4 || length == 8);
}

- (BOOL) isBranch:(NSString *)command{
	if ([command isEqualToString:@"cmst"]) {
		return YES;
	} else if ([command isEqualToString:@"mlog"]) {
		return YES;
	} else if ([command isEqualToString:@"agal"]) {
		return YES;
	} else if ([command isEqualToString:@"mlcl"]) {
		return YES;
	} else if ([command isEqualToString:@"mshl"]) {
		return YES;
	} else if ([command isEqualToString:@"abro"]) {
		return YES;
	} else if ([command isEqualToString:@"abar"]) {
		return YES;
	} else if ([command isEqualToString:@"apso"]) {
		return YES;
	} else if ([command isEqualToString:@"caci"]) {
		return YES;
	} else if ([command isEqualToString:@"avdb"]) {
		return YES;
	} else if ([command isEqualToString:@"cmgt"]) {
		return YES;
	} else if ([command isEqualToString:@"aply"]) {
		return YES;
	} else if ([command isEqualToString:@"adbs"]) {
		return YES;
	} else if ([command isEqualToString:@"msrv"]) {
		return YES;
	} else if ([command isEqualToString:@"casp"]) {
		return YES;
	} else if ([command isEqualToString:@"mdcl"]) {
		return YES;
	} else if ([command isEqualToString:@"mlit"]) {
		return YES;
	} else if ([command isEqualToString:@"mccr"]) {
		return YES;
	} else if ([command isEqualToString:@"glmc"]) {
		return YES;
	} 
				return NO;
	//return [branches evaluateWithObject:command];
}

- (NSString *) parseCommandName:(NSData *) theData atPosition:(int)position{
	UInt8 *command;
	[theData getBytes:&command range:NSMakeRange(position,4)];
	NSString * str = [[[NSString alloc] initWithBytes:&command length:4 encoding:NSISOLatin1StringEncoding] autorelease];
	return str;
}

- (NSString *) getSelectorNameFromCommandName:(NSString *)command{
//	NSString *firstLetter = [[command substringToIndex:1] uppercaseString];
//	NSString *rest = [command substringFromIndex:1];
	NSString *test = [command capitalizedString];
	return [[@"set" stringByAppendingString:test] stringByAppendingString:@":"];
//	return [NSString stringWithFormat:@"set%@:",test];
}

- (NSString *) parseString:(NSData *) theData{
	NSString * str = [[[NSString alloc] initWithBytes:[theData bytes] length:[theData length] encoding:NSUTF8StringEncoding] autorelease];
	//[HexDumpUtility printHexDumpToConsole:data];
	return str;
}

- (void) getBytes:(Byte *)buffer fromData:(NSData *)theData length:(int)length{
	//[HexDumpUtility printHexDumpToConsole:data];
	Byte value[length];
	[theData getBytes:&value range:NSMakeRange(0, length)];
	
	for (int i = 0; i < length ; i ++) {
		buffer[i] = value[length - i - 1];
	}
	
}

- (BOOL) parseBoolean:(NSData *) theData{
	Byte res[1];
	[self getBytes:res fromData:theData length:1];
	NSValue *hop = [NSValue value:res withObjCType:@encode(short)];
	short test;
	[hop getValue:&test];
	/*	if (test) NSLog(@"TRUE");
	 else NSLog(@"FALSE");*/
	return test;
}


- (short) parseShort:(NSData *) theData{
	int16_t *temp = malloc(1);
	[theData getBytes:temp length:2];
	int16_t swapped = NSSwapShort(*temp);
	free(temp);
	return swapped;
}

- (long) parseLong:(NSData *) theData {
	int32_t *temp = malloc(1);
	[theData getBytes:temp length:4];
	int32_t swapped = NSSwapInt(*temp);
	free(temp);
	return swapped;
}

- (long long) parseLongLong:(NSData *)theData{
	
	int64_t *temp = malloc(1);
	[theData getBytes:temp length:8];
	int64_t swapped = NSSwapLongLong(*temp);
	free(temp);
	return swapped;
}

- (int) parseLength:(NSData *) theData atPosition:(int)pos{	
	int32_t *temp = malloc(1);
	[theData getBytes:temp range:NSMakeRange(pos, 4)];
	int32_t swapped = NSSwapInt(*temp);
	free(temp);
	return swapped;
}


- (NSNumber *) parseNumber:(NSData *)theData length:(int)length{
	NSNumber *retValue;
	switch (length) {
		case 1:
			retValue = [NSNumber numberWithShort:[self parseBoolean:theData]];	
			break;
		case 2:
			retValue = [NSNumber numberWithShort:[self parseShort:theData]];
			break;
		case 4:
			retValue = [NSNumber numberWithLong:[self parseLong:theData]];
			break;
		case 8:
			retValue = [NSNumber numberWithLongLong:[self parseLongLong:theData]];
			break;
		default:
			return nil;
	}
	return retValue;
}

- (void) parse:(NSData *)theData{
	int progress = 0;
	int handle = theData.length;
	while (handle > 0) {
		NSString *command = [self parseCommandName:theData atPosition:progress];
		NSString *commandSetter = [self getSelectorNameFromCommandName:command];
		
		int length = [self parseLength:theData atPosition:progress+4];
		//NSLog(@"command (%d) : %@ - %@",length,command, commandSetter);
		
		
		// is current object interested in that command
		if (![self respondsToSelector:NSSelectorFromString(commandSetter)]){
			progress += 8 + length;
			handle -= 8 + length;
			  continue;
		}
			  
		handle -= 8 + length;
		NSData *block = [theData subdataWithRange:NSMakeRange(progress+8, length)];
		
		if ([self isBranch:command]) {
			NSString *clazz = [NSString stringWithFormat:@"DAAPResponse%@",command];
			DAAPResponse *subCommand = (DAAPResponse *)[[NSClassFromString(clazz) alloc] initWithData:block];
			[subCommand parse];
			[self performSelector:NSSelectorFromString(commandSetter) withObject:subCommand];
			[subCommand release];
		} else if([self isString:command]){			
			NSString *str = [self parseString:block];
			//NSLog(@"string : %@",str);
			[self performSelector:NSSelectorFromString(commandSetter) withObject:str];
		} else if ([self isNumber:length]) {
			[self performSelector:NSSelectorFromString(commandSetter) withObject:[self parseNumber:block length:length]];
		} 
		//[block release];
		progress += 8 + length;
	}
}


- (void) parse{
	// delegate method to heriting classes
	int length = [self parseLength:self.data atPosition:4];
	self.data = [self.data subdataWithRange:NSMakeRange(8, length)];
	[self parse:self.data];
}

- (void)dealloc {
	[self.data release];
	[self.commandName release];
    [super dealloc];
}

@end
