//
//  HexDumpUtility.h
//  yTrack
//
//  Created by Fabrice Dewasmes on 15/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HexDumpUtility : NSObject {

}

+ (void) printHexDumpToConsole:(NSData *)data;

@end
