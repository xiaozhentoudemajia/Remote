//
//  DAAPDatasource.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 24/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPDatasource.h"
#import "DAAPResponsecmst.h"
#import "DDLog.h"

#ifdef CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation DAAPDatasource
@synthesize delegate;
@synthesize list;
@synthesize indexList;
@synthesize needsRefresh;

- (id) init{
	if ((self = [super init])) {
		needsRefresh = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusUpdate:) name:kNotificationStatusUpdate object:nil];
    }
    return self;
}


// Used to update nowPlaying in the table
- (void) statusUpdate:(NSNotification *)notification{
	DDLogVerbose(@"DAAPDatasource received update from server");
	[self.delegate refreshTableView];
	DDLogVerbose(@"DAAPDatasource doneRefreshing");
}

- (void) clearDatas{
	self.list = nil;
	self.indexList = nil;
	needsRefresh = YES;
}

- (void) didFinishLoading:(DAAPResponse *)response{
	needsRefresh = NO;
}

- (void) dealloc{
	[self.list release];
	[self.indexList release];
	[super dealloc];
}

@end
