//
//  DAAPResponse.h
//  yTrack
//
//  Created by Fabrice Dewasmes on 18/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAAPResponse : NSObject {
	NSString * commandName;
	NSData *data;
}

@property (copy, nonatomic) NSString *commandName;
@property (retain, nonatomic) NSData *data;

- (id) initWithData:(NSData *)theData;

- (BOOL) isString:(NSString *)command;
- (BOOL) isNumber:(int)length;
- (BOOL) isBranch:(NSString *)command;
- (NSNumber *) parseNumber:(NSData *)data length:(int)length;
- (NSString *) parseString:(NSData *)data;
- (int) parseLength:(NSData *) data atPosition:(int)pos;
- (long long) parseLongLong:(NSData *)data;
- (long) parseLong:(NSData *) data;
- (short) parseShort:(NSData *) data;
- (BOOL) parseBoolean:(NSData *) data;
- (void) getBytes:(Byte *)buffer fromData:(NSData *)data length:(int)length;
- (NSString *) parseCommandName:(NSData *) data atPosition:(int)position;
- (void) parse;
- (void) parse:(NSData *)theData;
- (NSString *) getSelectorNameFromCommandName:(NSString *)command;

@end
