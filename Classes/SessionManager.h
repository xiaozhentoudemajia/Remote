//
//  SessionManager.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 23/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDServer.h"
#import "RemoteHDViewController.h"

#define CurrentServer [[SessionManager sharedSessionManager] currentServer]

@interface SessionManager : NSObject {
@private
	BOOL sessionEstablished;
	NSMutableArray *_servers;
}


+ (id) sharedSessionManager;

- (BOOL) isSessionEstablished;
- (FDServer *) foundNewServer:(FDServer *)server;
- (NSArray *) getServers;
- (FDServer *) currentServer;
- (void) openLastUsedServer;
- (void) deleteServerWithPairingGUID:(NSString *)pairingGUID;

@end
