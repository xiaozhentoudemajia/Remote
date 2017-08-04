//
//  DAAPResponsemshl.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 09/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"

@interface DAAPResponsemshl : DAAPResponse {
	NSMutableArray *indexList;
}

@property (nonatomic, retain) NSMutableArray *indexList;

@end
