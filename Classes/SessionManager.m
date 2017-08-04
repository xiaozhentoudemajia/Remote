//
//  SessionManager.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 23/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "SessionManager.h"
#import "SynthesizeSingleton.h"
#import "DAAPRequestReply.h"
#import "DAAPResponsemlog.h"
#import "DAAPResponsemdcl.h"
#import "PreferencesManager.h"

@interface SessionManager()

- (void) _didSuccessfullyConnect:(NSNotification *)notification;

@property (nonatomic, retain, readwrite) NSMutableArray* servers;
@end

@implementation SessionManager

@synthesize servers = _servers;

SYNTHESIZE_SINGLETON_FOR_CLASS(SessionManager)

- (id) init {
	if ((self = [super init])) {
		self.servers = [NSMutableArray arrayWithArray:[[PreferencesManager sharedPreferencesManager] getAllStoredServers]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didSuccessfullyConnect:) name:kNotificationConnected object:nil];
	}
	return self;
}

- (BOOL) isSessionEstablished {
	if (self.currentServer != nil) {
		if (self.currentServer.connected) {
			return YES;
		}
	}
	return NO;
}

- (FDServer *) foundNewServer:(FDServer *)server{
	int foundIndex = -1;
	for (int i = 0; i<[self.servers count];i++) {
		NSString *serverServiceName = [[self.servers objectAtIndex:i] servicename];
		NSString *newserverServiceName = server.servicename;
		if ([newserverServiceName isEqualToString:serverServiceName]) {
			foundIndex = i;
			break;
		}
	}
	if (foundIndex >=0) {
		FDServer *oldServer = [self.servers objectAtIndex:foundIndex];
		oldServer.pairingGUID = server.pairingGUID;
		oldServer.host = server.host;
		oldServer.port = server.port;
		oldServer.TXT = server.TXT;
		oldServer.connected = server.connected;
		oldServer.sessionId = server.sessionId;
		oldServer.musicLibraryId = server.musicLibraryId;
		oldServer.databaseId = server.databaseId;
		[[PreferencesManager sharedPreferencesManager] addServer:server];
		return oldServer;
	} else {
		[self.servers addObject:server];
		[[PreferencesManager sharedPreferencesManager] addServer:server];
		return server;
	}
	
}

- (FDServer *) currentServer{
	for (FDServer *s in self.servers) {
		if (s.connected) {
			return s;
		}
	}
	return nil;
}

- (NSArray *) getServers{
	return [NSArray arrayWithArray:self.servers];
}

- (void) openLastUsedServer{
	FDServer *s = [[PreferencesManager sharedPreferencesManager] lastUsedServer];
	int foundIndex = -1;
	for (int i = 0; i<[self.servers count];i++) {
		NSString *serverServiceName = [[self.servers objectAtIndex:i] servicename];
		NSString *lastUsedServiceName = s.servicename;
		if ([lastUsedServiceName isEqualToString:serverServiceName]) {
			foundIndex = i;
			break;
		}
	}
	if (foundIndex >=0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTryReconnect object:self];
		FDServer *server = [self.servers objectAtIndex:foundIndex];
		[server open];
		
	}
}

- (void) deleteServerWithPairingGUID:(NSString *)pairingGUID{
	int foundIndex = -1;
	for (int i = 0; i<[self.servers count];i++) {
		if ([pairingGUID isEqualToString:[[self.servers objectAtIndex:i] pairingGUID]]) {
			foundIndex = i;
			break;
		}
	}
	if (foundIndex >=0) {
		FDServer *server = [self.servers objectAtIndex:foundIndex];
		[server logout];
		[[PreferencesManager sharedPreferencesManager] deleteServerAtIndex:foundIndex];
		[self.servers removeObjectAtIndex:foundIndex];
	}
}

- (void) _didSuccessfullyConnect:(NSNotification *)notification{
	[self foundNewServer:(FDServer *)[notification.userInfo objectForKey:@"server"]];
}

@end
