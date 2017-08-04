//
//  DAAPResponseerror.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 20/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"

@interface DAAPResponseerror : DAAPResponse {
	NSError *error;
}

@property (nonatomic, readonly) NSError *error;

- (id) initWithData:(NSData *)theData error:(NSError *)err;

@end
