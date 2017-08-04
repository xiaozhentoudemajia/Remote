//
//  FDServer.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 25/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "FDServer.h"
#import "DAAPResponsemsrv.h"
#import "DAAPResponsemccr.h"
#import "DAAPResponseavdb.h"
#import "DAAPResponseaply.h"
#import "DAAPResponsemlit.h"
#import "DAAPResponsecmst.h"
#import "DAAPResponsemupd.h"
#import "DAAPResponsecmgt.h"
#import "DAAPResponsecasp.h"
#import "DAAPResponsemlog.h"
#import "DAAPResponseabro.h"
#import "DAAPResponseagal.h"
#import "DAAPResponseerror.h"
#import "SessionManager.h"
#import "DDLog.h"
#import <netinet/in.h>
#import <sys/socket.h>
#include <arpa/inet.h>


#ifdef CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif


@interface FDServer() 
- (BOOL) _login;
- (NSString *) _encodeString:(NSString *)string;
- (void) _renewConnection:(NSTimer *)timer;
- (void) _stopCurrentResolve;
- (void) _updateWithNetService:(NSNetService *)service;
- (void) _resolve;
- (BOOL) _connect;
- (NSString *) _computePrintableTime:(int)milliseconds;
- (void) _updateTime:(NSTimer *)timer;

@property (nonatomic, copy, readwrite) NSString *currentTrack;
@property (nonatomic, copy, readwrite) NSString *currentAlbum;
@property (nonatomic, copy, readwrite) NSString *currentArtist;
@property (nonatomic, readwrite) BOOL playing;
@property (nonatomic, readwrite) BOOL trackChanged;
@property (nonatomic, retain, readwrite) NSNetService* currentResolve;
@property (nonatomic, copy, readwrite) NSString *domain;
@property (nonatomic, copy, readwrite) NSString *type;
@property (nonatomic, copy, readwrite) NSString *doneTime;
@property (nonatomic, copy, readwrite) NSString *remainingTime;

@property (nonatomic, retain) DAAPRequestReply *daapReqRep;

@end

@implementation FDServer

@synthesize host;
@synthesize port;
@synthesize pairingGUID;
@synthesize sessionId;
@synthesize servicename;
@synthesize TXT;
@synthesize databaseId;
@synthesize musicLibraryId;
@synthesize booksLibraryId;
@synthesize podcastsLibraryId;
@synthesize connected;
@synthesize currentTrack;
@synthesize currentAlbum;
@synthesize currentArtist;
@synthesize currentAlbumId;
@synthesize playing;
@synthesize repeatState;
@synthesize shuffle;
@synthesize trackChanged;
@synthesize daapReqRep;
@synthesize booksPersistentId;
@synthesize podcastsPersistentId;
@synthesize r;
@synthesize currentResolve = _currentResolve;
@synthesize domain = _domain;
@synthesize type = _type;
@synthesize delegate;
@synthesize doneTime;
@synthesize remainingTime;
@synthesize numericDoneTime;
@synthesize numericTotalTime;
@synthesize timer;


- (id) init {
	if ((self = [super init])) {
        //[self getServerInfo];
    }
    return self;
}

- (BOOL) _connect{
	DDLogInfo(@"FDServer-connect, pairingGUID:%@",pairingGUID);
	
	if (![self _login]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationConnectionLost object:nil userInfo:nil]; 
		[timer invalidate];
		self.connected = NO;
		return NO;
	}
	
	// we have to know the databaseId for further requests
	NSString *databaseRequest = [NSString stringWithFormat:kRequestDatabases,self.host,self.port,sessionId];
	DAAPResponseavdb * db = (DAAPResponseavdb *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:databaseRequest]];
	if ([db isKindOfClass:[DAAPResponseerror class]]) {
		DAAPResponseerror *err = (DAAPResponseerror *)db;
		DDLogError(@"Failed to get database id : %@, %d",[err.error localizedDescription], err.error.code);
		self.connected = NO;
		return NO;
	}
	self.databaseId = [(NSNumber *)[(DAAPResponsemlit *)[db.listing.list  objectAtIndex:0] miid] intValue];
	
	// query playslists to get the Id of those we're interested in
	NSString *requestUrl = [NSString stringWithFormat:kRequestPlayLists,self.host,self.port,databaseId,sessionId];
	DDLogVerbose(@"Playlists list Syncronous call : %@",requestUrl);
	DAAPResponseaply * response = (DAAPResponseaply *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:requestUrl] ];
	if (userPlaylists == nil) {
		userPlaylists = [[[NSMutableArray alloc] init] retain];
	} else {
		[userPlaylists removeAllObjects];
	}
	
	for (DAAPResponsemlit *pl in response.listing.list) {
		DDLogVerbose(@"Playlist : name=%@,miid=%d,mper=%qX,aePS=%hi,aeSP=%hi,mimc=%i",pl.name, [pl.miid longValue],[pl.mper longLongValue],[pl.aePS shortValue], [pl.aeSP shortValue],[pl.mimc longValue]);
		if (([pl.aePS shortValue] == 0 || [pl.aePS shortValue] == kServerGeniusLibraryAEPS) && [pl.mimc longValue] > 0) {			
			[userPlaylists addObject:pl];
		}
		if ([pl.abpl shortValue] == 1){
			self.musicLibraryId = [pl.miid intValue];
			databasePersistentId = [pl.persistentId longLongValue];
		} else if ([pl.aePS shortValue] == kServerPodcastsLibraryAEPS){
			podcastsPersistentId = [pl.persistentId longLongValue];
			self.podcastsLibraryId = [pl.miid intValue];
		} else if ([pl.aePS shortValue] == kServerBooksLibraryAEPS){
			booksPersistentId = [pl.persistentId longLongValue];
			self.booksLibraryId = [pl.miid intValue];
		}
	}
	
	[userPlaylists removeObjectAtIndex:0];
	
	//[self getServerInfo];
	
	// initiate server monitoring to receive action events
	[self monitorPlayStatus];
	
	// tell the world we're connected
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationConnected object:nil userInfo:[NSDictionary dictionaryWithObject:self forKey:@"server"]]; 
	
	self.r = [Reachability reachabilityWithHostName:self.host];
	[r startNotifier];
	DDLogVerbose(@"----------------------------------");
	DDLogVerbose(@"isConnectionRequired : %@",[r isConnectionRequired]?@"YES":@"NO");
	switch ([r currentReachabilityStatus]) {
		case kNotReachable:
			DDLogVerbose(@"not reachable");
			break;
		case kReachableViaWiFi:
			DDLogVerbose(@"reachable via WiFi");
			break;
		case kReachableViaWWAN:
			DDLogVerbose(@"reachable via WWAN");
			break;
			
		default:
			break;
	}
	[delegate didOpenServer:self];
	return YES;
}

- (void) open{
	DDLogVerbose(@"FDServer-open");
	[self _resolve];
}

- (void) _stopCurrentResolve {
	[self.currentResolve stop];
	self.currentResolve = nil;
}

// This should never be called, since we resolve with a timeout of 0.0, which means indefinite
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	DDLogVerbose(@"FDServer - netServiceDidNOTResolveAddress");
	[delegate didFinishResolvingServerWithSuccess:NO];
	[self _stopCurrentResolve];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
	DDLogVerbose(@"FDServer - netServiceDidResolveAddress");
	[self _updateWithNetService:service];
	[self _stopCurrentResolve];
	[delegate didFinishResolvingServerWithSuccess:YES];
	[self _connect];
}

- (void) _resolve{
	DDLogVerbose(@"FDServer - starting resolving");
	NSNetService *service = [[NSNetService alloc] initWithDomain:self.domain type:self.type name:self.servicename];
	[service setTXTRecordData: [NSNetService dataFromTXTRecordDictionary:self.TXT]];
	self.currentResolve = service;
	[service release];
	[self.currentResolve setDelegate:self];
	[self.currentResolve resolveWithTimeout:20.0];
}

- (void) _updateWithNetService:(NSNetService *)service{
	[service retain];
	self.domain = service.domain;
	self.type = service.type;
	self.servicename = service.name;
	
	NSData *address = address = [[service addresses] objectAtIndex:0];
	struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
	self.host = [NSString stringWithFormat: @"%s", inet_ntoa(socketAddress->sin_addr)];
	
	// Note that [NSNetService port:] returns an NSInteger in host byte order
	NSInteger portNumber = [service port];
	if (portNumber != 0 && portNumber != 80) {
		self.port = [NSString  stringWithFormat:@"%d",portNumber];
	} else {
		self.port = @"";
	}
	DDLogVerbose(@"FDServer - resolved service : %@, %@, %@",service.name, self.host, self.port);
	self.TXT = [NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]];
	[service release];
}

- (BOOL) _login{
	NSString *loginURL = [NSString stringWithFormat:kRequestLogin,self.host,self.port,self.pairingGUID];
	DDLogVerbose(@"Login url : %@",loginURL);
	DAAPResponse * resp = (DAAPResponse *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:loginURL]];
	if ([resp isKindOfClass:[DAAPResponseerror class]]) {
		DAAPResponseerror *err = (DAAPResponseerror *)resp;
		if (err.error != nil) {
			DDLogError(@"Error : %@, %d",[err.error localizedDescription], err.error.code);
			return NO;
		}
		// in case of error, reply is not formatted as other messages, reply is only 3 bytes long
		// here I assume there is only one kind of error namely the rejected remote case
		if (resp.data.length == 3) {
			DDLogVerbose(@"Remote rejected");
			NSString *rejectedAlertTitle = [[NSBundle mainBundle] localizedStringForKey:@"rejectedAlertTitle" 
																				  value:@"Telecommande rejetée" 
																				  table:@"Localizable"];
			NSString *rejectedAlertContent = [[NSBundle mainBundle] localizedStringForKey:@"rejectedAlertContent" 
																					value:@"Votre télécommande n'est plus acceptée par le serveur" 
																					table:@"Localizable"];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:rejectedAlertTitle message:rejectedAlertContent delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			[[SessionManager sharedSessionManager] performSelector:@selector(deleteServerWithPairingGUID:) withObject:self.pairingGUID afterDelay:0.1];
			return NO;
		}
	} else {
		sessionId = [[(DAAPResponsemlog *)resp mlid] longValue];
	}
	
	// in case we've got no sessionId, something went wrongly
	if (sessionId == 0) {
		DDLogError(@"SessionId is 0");
		return NO;
	}
	
	// we've got a sessionId, we're connected !
	self.connected = YES;
	return YES;
}

- (void) logout{
	DDLogInfo(@"FDServer-logout");
	if (self.daapReqRep != nil) {
		[self.daapReqRep cancelConnection];
		self.daapReqRep = nil;
	}
	NSString *string = [NSString stringWithFormat:kRequestLogout,self.host,self.port,sessionId];
	[DAAPRequestReply request:[NSURL URLWithString:string]];

	// here we do not check the status of the command
	// TODO the request method should at least send back status just in case
	self.connected = NO;
}

// initializer for newly paired servers
- (id) initWithNetService:(NSNetService *)service pairingGUID:(NSString *)thePairingGUID{
	if ((self = [super init])) {
		self.pairingGUID = thePairingGUID;
		
		[self _updateWithNetService:service];
		
		musr = 1;
		revNum = 1;
	}
	return self;
}

// initializer used to rehydrate persisted servers from preference file
- (id) initWithDictionary:(NSDictionary *)dict{
	if ((self = [super init])) {
		self.servicename = [dict objectForKey:kLibraryServicenameKey];
		self.pairingGUID = [dict objectForKey:kLibraryPairingGUIDKey];
		//self.host = [dict objectForKey:kLibraryHostKey];
		//self.port = [dict objectForKey:kLibraryPortKey];
		self.domain = [dict objectForKey:kLibraryDomainKey];
		self.type = [dict objectForKey:kLibraryTypeKey];
		self.TXT = [dict objectForKey:kLibraryTXTKey];
		
		musr = 1;
		revNum = 1;
	}
	return self;
}

// return a form of the object that is persistable
// I think I should use NSCoder
- (NSDictionary *) getAsDictionary{
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.servicename, self.pairingGUID, self.TXT, self.domain, self.type, nil] 
													 forKeys:[NSArray arrayWithObjects:kLibraryServicenameKey, kLibraryPairingGUIDKey, kLibraryTXTKey, kLibraryDomainKey, kLibraryTypeKey, nil]];
	return dict;
}

#pragma mark -
#pragma mark content queries

- (NSArray *) getPlayLists{
	DDLogInfo(@"FDServer-getPlayLists");
	/*NSString *requestUrl = [NSString stringWithFormat:kRequestPlayLists,self.host,self.port,databaseId,sessionId];
	NSLog(@"%@",requestUrl);
	DAAPResponseaply * response = (DAAPResponseaply *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:requestUrl] ];
	NSArray *list = [NSArray arrayWithArray:response.listing.list];
	
	return list;*/
	return [NSArray arrayWithArray:userPlaylists];
}

- (void) getArtists:(id<DAAPRequestDelegate>)aDelegate{
	DDLogInfo(@"FDServer-getArtists");
	NSString *requestUrl = [NSString stringWithFormat:kRequestArtists,self.host,self.port,databaseId,sessionId];
	DAAPRequestReply *daapreq = [[DAAPRequestReply alloc] init];
	[daapreq setDelegate:aDelegate];
	[daapreq asyncRequestAndParse:[NSURL URLWithString:requestUrl]];
	[daapreq release];
}

- (DAAPResponseagal *) getAlbumsForArtist:(NSString *)artist{
	DDLogInfo(@"FDServer-getAlbumsForArtist");
	NSString *a = [self _encodeString:artist];
	NSString *requestUrl = [NSString stringWithFormat:kRequestAlbumsForArtist,self.host,self.port,databaseId,sessionId,a];
	DDLogVerbose(@"%@",requestUrl);
	[a release];
	DAAPResponseagal * response = (DAAPResponseagal *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:requestUrl] ];
	return response;
}

- (DAAPResponseapso *) getAllTracksForArtist:(NSString *)artist{
	DDLogInfo(@"FDServer-getAllTracksForArtist");
	NSString *a = [self _encodeString:artist];
	NSString *requestUrl = [NSString stringWithFormat:kRequestAllTracksForArtist,self.host,self.port,databaseId,musicLibraryId, sessionId,a];
	DDLogVerbose(@"%@",requestUrl);
	[a release];
	DAAPResponseapso * response = (DAAPResponseapso *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:requestUrl] ];
	return response;
}

- (void) getAllTracksForPlaylist:(int)playlistId delegate:(id<DAAPRequestDelegate>)aDelegate{
	DDLogInfo(@"FDServer-getAllTracksForPlaylist");
	NSString *requestUrl = [NSString stringWithFormat:kRequestTracksForPlaylist,self.host,self.port,databaseId,playlistId, sessionId];
	DDLogVerbose(@"%@",requestUrl);
	DAAPRequestReply *daapreq = [[DAAPRequestReply alloc] init];
	[daapreq setDelegate:aDelegate];
	[daapreq asyncRequestAndParse:[NSURL URLWithString:requestUrl]];
	[daapreq release];
}

- (DAAPResponseapso *) getTracksForAlbum:(NSNumber *)albumId{
	DDLogInfo(@"FDServer-getTracksForAlbum");
	NSString *requestUrl = [NSString stringWithFormat:kRequestTracksForAlbum,self.host,self.port,databaseId,musicLibraryId, sessionId,[albumId longLongValue]];
	DAAPResponseapso * response = (DAAPResponseapso *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:requestUrl] ];
	return response;
}

- (void) getTracksForAlbum:(NSNumber *)albumId delegate:(id<DAAPRequestDelegate>)aDelegate{
	DDLogInfo(@"FDServer-getTracksForAlbum - Async");
	NSString *requestUrl = [NSString stringWithFormat:kRequestTracksForAlbum,self.host,self.port,databaseId,musicLibraryId, sessionId,[albumId longLongValue]];
	DAAPRequestReply *daapreq = [[DAAPRequestReply alloc] init];
	[daapreq setDelegate:aDelegate];
	[daapreq asyncRequestAndParse:[NSURL URLWithString:requestUrl]];
	[daapreq release];
	
	//DAAPResponseapso * response = (DAAPResponseapso *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:requestUrl] ];
	//return response;
}

- (DAAPResponseapso *) getTracksForPodcast:(NSString *)podcastId{
	DDLogInfo(@"FDServer-getTracksForPodcast");
	NSString *requestUrl = [NSString stringWithFormat:kRequestPodcastTracks,self.host,self.port,databaseId,musicLibraryId, sessionId,podcastId];
	DDLogVerbose(@"%@",requestUrl);
	DAAPResponseapso * response = (DAAPResponseapso *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:requestUrl] ];
	return response;
}

- (DAAPResponseapso *) getTracksForBook:(NSString *)podcastId{
	DDLogInfo(@"FDServer-getTracksForPodcast");
	NSString *requestUrl = [NSString stringWithFormat:kRequestBookTracks,self.host,self.port,databaseId,musicLibraryId, sessionId,podcastId];
	DDLogVerbose(@"%@",requestUrl);
	DAAPResponseapso * response = (DAAPResponseapso *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:requestUrl] ];
	return response;
}

- (AsyncImageLoader *) getArtwork:(NSNumber *)albumId delegate:(id<AsyncImageLoaderDelegate>)aDelegate forAlbum:(BOOL)forAlbum{
	DDLogInfo(@"FDServer-getArtworkForAlbum");
	return [self getArtwork:albumId size:55 delegate:aDelegate forAlbum:forAlbum];
}

- (AsyncImageLoader *) getArtwork:(NSNumber *)albumId size:(int)aSize delegate:(id<AsyncImageLoaderDelegate>)aDelegate forAlbum:(BOOL)forAlbum{
	DDLogInfo(@"FDServer-getArtworkForAlbum with size");
	NSString *requestUrl;
	if (forAlbum) {
		requestUrl = [NSString stringWithFormat:kRequestAlbumArtwork,self.host,self.port,databaseId,[albumId intValue], sessionId, aSize, aSize];
	} else {
		requestUrl = [NSString stringWithFormat:kRequestTrackArtwork,self.host,self.port,databaseId,[albumId intValue], sessionId, aSize, aSize];
	}

		
	DDLogVerbose(@"%@",requestUrl);
	AsyncImageLoader *loader = [[[AsyncImageLoader alloc] init] autorelease];
	loader.delegate = aDelegate;
	[loader loadImageFromURL:[NSURL URLWithString:requestUrl] withId:albumId];
	return loader;
}

- (void) getAllAlbums:(id<DAAPRequestDelegate>)aDelegate{
	DDLogInfo(@"FDServer-getAllAlbums");
	NSString *requestUrl = [NSString stringWithFormat:kRequestAllAlbums,self.host,self.port,databaseId,sessionId];
	DAAPRequestReply *daapreq = [[DAAPRequestReply alloc] init];
	[daapreq setDelegate:aDelegate];
	[daapreq asyncRequestAndParse:[NSURL URLWithString:requestUrl]];
	[daapreq release];
}

- (void) getAllTracks:(id<DAAPRequestDelegate>)aDelegate{
	DDLogInfo(@"FDServer-getAllTracks with delegate");
	NSString *requestUrl = [NSString stringWithFormat:kRequestAllTracks,self.host,self.port,databaseId,musicLibraryId, sessionId];
	DAAPRequestReply *daapreq = [[DAAPRequestReply alloc] init];
	[daapreq setDelegate:aDelegate];
	[daapreq asyncRequestAndParse:[NSURL URLWithString:requestUrl]];
	[daapreq release];
	DDLogVerbose(@"FDServer-end getAllTracks with delegate");
}

- (void) getAllBooks:(id<DAAPRequestDelegate>)aDelegate{
	DDLogInfo(@"FDServer-getAllBooks with delegate");
	NSString *requestUrl = [NSString stringWithFormat:kRequestAllBooks,self.host,self.port,databaseId,sessionId];
	DAAPRequestReply *daapreq = [[DAAPRequestReply alloc] init];
	[daapreq setDelegate:aDelegate];
	[daapreq asyncRequestAndParse:[NSURL URLWithString:requestUrl]];
	[daapreq release];
}

- (void) getAllPodcasts:(id<DAAPRequestDelegate>)aDelegate{
	DDLogInfo(@"FDServer-getAllPodcasts with delegate");
	NSString *requestUrl = [NSString stringWithFormat:kRequestAllPodcasts,self.host,self.port,databaseId,sessionId];
	DAAPRequestReply *daapreq = [[DAAPRequestReply alloc] init];
	[daapreq setDelegate:aDelegate];
	[daapreq asyncRequestAndParse:[NSURL URLWithString:requestUrl]];
	[daapreq release];
}

#pragma mark -
#pragma mark server monitoring

- (void) monitorPlayStatus{
	DDLogInfo(@"FDServer-monitorPlayStatus");
	
	NSString *requestUrl = [NSString stringWithFormat:kRequestPlayStatusUpdate,self.host,self.port,1,sessionId];
	if (revNum > 1) {
		requestUrl = [NSString stringWithFormat:kRequestPlayStatusUpdate,self.host,self.port,revNum,sessionId];
	}

	DAAPRequestReply *daapReq = [[DAAPRequestReply alloc] init];
	
	[daapReq setDelegate:self];
	[daapReq asyncRequestAndParse:[NSURL URLWithString:requestUrl] withTimeout:20];
	self.daapReqRep = daapReq;
	[daapReq release];
	//[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(_renewConnection:) userInfo:nil repeats:NO];
}

- (void) _renewConnection:(NSTimer *)timer{
	[self.daapReqRep cancelConnection];
	[self monitorPlayStatus];
}

- (void) connectionTimedOut{
	DDLogInfo(@"FDServer-connectionTimedOut");
	[self monitorPlayStatus];
}

// if user can't connect to host, simply give up and don't try to reconnect automatically
- (void) cantConnect{
	DDLogInfo(@"FDServer-cantConnect");
	//self.connected = NO;
	[self logout];
	[[NSNotificationCenter defaultCenter ]postNotificationName:kNotificationConnectionLost object:nil];
	[timer invalidate];
}

// server finally sent a reply, see what's happened and notify observers
- (void) didFinishLoading:(DAAPResponse *)response{
	DDLogInfo(@"**************FDServer-didFinishLoading");
	if (response == nil){
		DDLogError(@"---PLAYSTATUSUPDATE RESPONSE IS NIL");
		[self _login];
	}else {
		DAAPResponsecmst * cmst = (DAAPResponsecmst *)response;
		
		if ([cmst.cant intValue] == 0) {
			numericDoneTime = 0;
		} else {
			numericDoneTime = [cmst.cast intValue]-[cmst.cant intValue];
		}
		numericTotalTime = [cmst.cast intValue];
		DDLogVerbose(@"remainingTime : %d, totalTime : %d",[cmst.cant intValue], numericTotalTime);
		
		self.doneTime = [self _computePrintableTime:numericDoneTime];
		int remTime = numericTotalTime - numericDoneTime;
		self.remainingTime = [NSString stringWithFormat:@"-%@",[self _computePrintableTime:remTime]];
		
		shuffle = [cmst.cash boolValue];
		repeatState = [cmst.carp intValue];
		//trackChanged = (![self.currentTrack isEqualToString:cmst.cann] || ![self.currentArtist isEqualToString:cmst.cana] || [self.currentAlbumId longLongValue] != [cmst.asai longLongValue]);
		trackChanged = ([self.currentAlbumId longLongValue] != [cmst.asai longLongValue]);
		self.currentTrack = cmst.cann;
		self.currentAlbum = cmst.canl;
		self.currentArtist = cmst.cana;
		self.currentAlbumId = cmst.asai;
		
		if ([cmst.caps shortValue] == 4) {
			playing = YES;
		} else if ([cmst.caps shortValue] == 3 || [cmst.caps shortValue] == 2) {
			playing = NO;
		} 
		[self.timer invalidate];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_updateTime:) userInfo:nil repeats:YES];
		[[NSNotificationCenter defaultCenter ]postNotificationName:kNotificationStatusUpdate object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:cmst,@"cmst",nil]];
		
		DDLogVerbose(@"received infos : %@, %@, %@",self.currentTrack, self.currentAlbum, self.currentArtist);
		if ([[cmst cmsr] longValue] > 1) {
			revNum = [[cmst cmsr] longValue];
		}
		//revNum = [[cmst cmsr] longValue];
	}
	if (revNum < 1) {
		revNum = 1;
	}
	NSString *requestUrl = [NSString stringWithFormat:kRequestPlayStatusUpdate,self.host,self.port,revNum,sessionId];
	DDLogVerbose(@"FDServer %@",requestUrl);
	DAAPRequestReply *daapReq = [[DAAPRequestReply alloc] init];
	
	[daapReq setDelegate:self];
	[daapReq asyncRequestAndParse:[NSURL URLWithString:requestUrl] withTimeout:20];
	self.daapReqRep = daapReq;
	[daapReq release];
	DDLogVerbose(@"FDServer leaving didFinishLoading");
}

#pragma mark -
#pragma mark query and set server state

- (NSArray *) getSpeakers{
	DDLogInfo(@"FDServer-getSpeakers");
	NSString *requestUrl = [NSString stringWithFormat:kRequestGetSpeakers,self.host,self.port, sessionId];
	DAAPResponsecasp *casp = (DAAPResponsecasp *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:requestUrl]];
	
	return casp.speakers;
}

- (void) getSpeakers:(id<DAAPRequestDelegate>)aDelegate{
	DDLogInfo(@"FDServer-getSpeakers async");
	
	NSString *requestUrl = [NSString stringWithFormat:kRequestGetSpeakers,self.host,self.port, sessionId];
	DAAPRequestReply *daapreq = [[DAAPRequestReply alloc] init];
	[daapreq setDelegate:aDelegate];
	[daapreq asyncRequestAndParse:[NSURL URLWithString:requestUrl]];
	[daapreq release];
}

- (void) setSpeakers:(NSArray *)speakers{
	DDLogInfo(@"FDServer-setSpeakers");
	if ([speakers count] < 1) return;
	NSString *speakerList = @"";
	for (int i = 0 ;i < [speakers count] - 1 ;i++) {
		long long val = [[speakers objectAtIndex:i] longLongValue];
		if (val == 0) {
			speakerList = [speakerList stringByAppendingFormat:@"0,",val];
		} else {
			speakerList = [speakerList stringByAppendingFormat:@"0x%qX,",val];
		}
		
	}
	long long val = [[speakers lastObject] longLongValue];
	if (val == 0) {
		speakerList = [speakerList stringByAppendingFormat:@"0",val];
	} else {
		speakerList = [speakerList stringByAppendingFormat:@"0x%qX",val];
	}
	DDLogVerbose(@"%@",speakerList);
	
	NSString *string = [NSString stringWithFormat:kRequestSetSpeakers,self.host,self.port,speakerList,sessionId];
	DDLogVerbose(@"%@",string);
	
	[DAAPRequestReply request:[NSURL URLWithString:string]];
}

- (void) getVolume:(id<DAAPRequestDelegate>)aDelegate action:(SEL)action{
	DDLogInfo(@"FDServer-getVolume");
	NSString *requestUrl = [NSString stringWithFormat:kRequestPropertyVolume,self.host,self.port, sessionId];
	
	DAAPRequestReply *daapreq = [[DAAPRequestReply alloc] init];
	[daapreq setDelegate:aDelegate];
	[daapreq setAction:action];
	[daapreq asyncRequestAndParse:[NSURL URLWithString:requestUrl] withTimeout:10];
	[daapreq release];
}

// this call cannot be made asynchronously as we re-read state from server immediately after chnging the volume value
- (void) setVolume:(long) volume{
	DDLogInfo(@"FDServer-setVolume");
	NSString *string = [NSString stringWithFormat:kRequestChangePropertyVolume,self.host,self.port,volume,sessionId];
	[DAAPRequestReply request:[NSURL URLWithString:string]];
}

- (void) toggleShuffle{
	NSString *string = [NSString stringWithFormat:kRequestChangePropertyShuffle,self.host,self.port,!shuffle,sessionId];
	if ([DAAPRequestReply request:[NSURL URLWithString:string]]){
		shuffle = !shuffle;
	}
}

- (void) toggleRepeatState{
	kRepeatState newState;
	switch (repeatState) {
		case kRepeatStateNoRepeat:
			newState = kRepeatStateWhole;
			break;
		case kRepeatStateWhole:
			newState = kRepeatStateTrack;
			break;
		case kRepeatStateTrack:
			newState = kRepeatStateNoRepeat;
			break;
		default:
			newState = kRepeatStateNoRepeat;
			break;
	}

	NSString *string = [NSString stringWithFormat:kRequestChangePropertyRepeat,self.host,self.port,newState,sessionId];
	if ([DAAPRequestReply request:[NSURL URLWithString:string]]){
		repeatState = newState;
	}
}

- (void) changePlayingTime:(int)position{
	DDLogInfo(@"FDServer-changePlayingTime");
	NSString *string = [NSString stringWithFormat:kRequestSetPlayingTime,self.host,self.port,position,sessionId];
	DAAPRequest *daapReq = [[DAAPRequest alloc] init];
	[daapReq asyncRequest:[NSURL URLWithString:string]];
	[daapReq release];
	numericDoneTime = position;
}

#pragma mark -
#pragma mark commands

- (void) playSongInLibrary:(int)songId{
	DDLogInfo(@"FDServer-playSongInLibrary");
	NSString *string = [NSString stringWithFormat:kRequestStopPlaying,self.host,self.port,sessionId];
	[DAAPRequestReply request:[NSURL URLWithString:string]];
	
	NSString *string2 = [NSString stringWithFormat:kRequestPlaySongInLibrary,self.host,self.port,songId,sessionId];
	DDLogVerbose(@"%@",string2);
	[DAAPRequestReply request:[NSURL URLWithString:string2]];
}

- (void) playSongInPlaylist:(long long)containermper song:(long)songId{
	DDLogInfo(@"FDServer-playSongInPlaylist");
	NSString *string = [NSString stringWithFormat:kRequestStopPlaying,self.host,self.port,sessionId];
	[DAAPRequestReply request:[NSURL URLWithString:string]];
	
	NSString *string2 = [NSString stringWithFormat:kRequestPlaySongInPlaylist,self.host,self.port,databasePersistentId,containermper,songId,sessionId];
	DDLogVerbose(@"%@",string2);
	[DAAPRequestReply request:[NSURL URLWithString:string2]];
}

- (void) playPodcast:(long long)containermper song:(long)songId{
	DDLogInfo(@"FDServer-playPodcast");
	NSString *string = [NSString stringWithFormat:kRequestStopPlaying,self.host,self.port,sessionId];
	[DAAPRequestReply request:[NSURL URLWithString:string]];
	
	NSString *string2 = [NSString stringWithFormat:kRequestPlayPodcast,self.host,self.port,databasePersistentId,containermper,songId,sessionId];
	DDLogVerbose(@"%@",string2);
	[DAAPRequestReply request:[NSURL URLWithString:string2]];
}

- (void) playBookInLibrary:(int)bookId{
	DDLogInfo(@"FDServer-playBookInLibrary");
	NSString *string = [NSString stringWithFormat:kRequestStopPlaying,self.host,self.port,sessionId];
	[DAAPRequestReply request:[NSURL URLWithString:string]];
	
	NSString *string2 = [NSString stringWithFormat:kRequestPlayBookInLibrary,self.host,self.port,bookId,sessionId];
	DDLogVerbose(@"%@",string2);
	[DAAPRequestReply request:[NSURL URLWithString:string2]];
}

- (void) playSongIndex:(int)songIndex inAlbum:(NSNumber *)albumId{
	DDLogInfo(@"FDServer-playSongIndex:inAlbum:");
	NSString *string = [NSString stringWithFormat:kRequestStopPlaying,self.host,self.port,sessionId];
	[DAAPRequestReply request:[NSURL URLWithString:string]];
	
	NSString *string2 = [NSString stringWithFormat:kRequestPlayTracksInAlbum,self.host,self.port,[albumId longLongValue], songIndex, sessionId];
	DDLogVerbose(@"%@",string2);
	[DAAPRequestReply request:[NSURL URLWithString:string2]];
}

- (void) playPodcast2:(int)songIndex inAlbum:(NSNumber *)albumId{
	DDLogInfo(@"FDServer-playPodcast2:inAlbum:");
	NSString *string = [NSString stringWithFormat:kRequestStopPlaying,self.host,self.port,sessionId];
	[DAAPRequestReply request:[NSURL URLWithString:string]];
	
	NSString *string2 = [NSString stringWithFormat:kRequestPlayPodcast2,self.host,self.port,[albumId longLongValue], songIndex, sessionId];
	DDLogVerbose(@"%@",string2);
	[DAAPRequestReply request:[NSURL URLWithString:string2]];
}

- (void) playBook2:(int)songIndex inAlbum:(NSNumber *)albumId{
	DDLogInfo(@"FDServer-playBook2:inAlbum:");
	NSString *string = [NSString stringWithFormat:kRequestStopPlaying,self.host,self.port,sessionId];
	[DAAPRequestReply request:[NSURL URLWithString:string]];
	
	NSString *string2 = [NSString stringWithFormat:kRequestPlayBook2,self.host,self.port,[albumId longLongValue], songIndex, sessionId];
	DDLogVerbose(@"%@",string2);
	[DAAPRequestReply request:[NSURL URLWithString:string2]];
}

- (void) playAllTracksForArtist:(NSString *)artist index:(int)songIndex{
	DDLogInfo(@"FDServer-playAllTracksForArtist");
	NSString *a = [self _encodeString:artist];
	NSString *string = [NSString stringWithFormat:kRequestStopPlaying,self.host,self.port,sessionId];
	[DAAPRequestReply request:[NSURL URLWithString:string]];
	
	NSString *string2 = [NSString stringWithFormat:kRequestPlayAllTracksForArtist,self.host,self.port,a, songIndex, sessionId];
	DDLogVerbose(@"%@",string2);
	[a release];
	[DAAPRequestReply request:[NSURL URLWithString:string2]];
}

- (void) playPreviousItem{
	DDLogInfo(@"FDServer-playPreviousItem");
	NSString *string = [NSString stringWithFormat:kRequestPlayPreviousItem,self.host,self.port,sessionId];
	DAAPRequest *daapReq = [[DAAPRequest alloc] init];
	
	[daapReq asyncRequest:[NSURL URLWithString:string]];
	[daapReq release];
}

- (void) playPause{
	DDLogInfo(@"FDServer-playPause");
	NSString *string = [NSString stringWithFormat:kRequestPlayPause,self.host,self.port,sessionId];
	DAAPRequest *daapReq = [[DAAPRequest alloc] init];	
	[daapReq asyncRequest:[NSURL URLWithString:string]];
	[daapReq release];
}

- (void) playNextItem{
	DDLogInfo(@"FDServer-playNextItem");
	NSString *string = [NSString stringWithFormat:kRequestPlayNextItem,self.host,self.port,sessionId];
	DAAPRequest *daapReq = [[DAAPRequest alloc] init];
	
	[daapReq asyncRequest:[NSURL URLWithString:string]];
	[daapReq release];
}

- (NSString *) _computePrintableTime:(int)milliseconds{
	int timeSec = milliseconds / 1000;
	
	int totalDays = timeSec / 86400;
    int totalHours = (timeSec / 3600) - (totalDays * 24);
    int totalMinutes = (timeSec / 60) - (totalDays * 24 * 60) - (totalHours * 60);
    int totalSeconds = timeSec % 60;
	if (totalHours > 0) {
		return [NSString stringWithFormat:@"%d:%02d:%02d",totalHours,totalMinutes,totalSeconds];
	} else {
		return [NSString stringWithFormat:@"%d:%02d",totalMinutes,totalSeconds];
	}
}

- (void) _updateTime:(NSTimer *)timer{
	if (playing) {
		numericDoneTime += 1000;
	}
	int remTime = numericTotalTime - numericDoneTime;
	self.doneTime = [self _computePrintableTime:numericDoneTime];
	self.remainingTime = [NSString stringWithFormat:@"-%@",[self _computePrintableTime:remTime]];	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTimerTicks object:nil userInfo:nil]; 
	
}

- (void) shouldInvalidateTimerUpdates{
	[timer invalidate];
}

#pragma mark -
#pragma mark not used

- (void) updateStatus{
	DDLogInfo(@"FDServer-updateStatus");
	NSString* str = [NSString stringWithFormat:kRequestUpdate,host,port,sessionId,musr];
	DAAPResponsemupd *mupd = (DAAPResponsemupd *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:str]];
	musr = [mupd.musr intValue];
}

- (void) getServerInfo{
	DDLogInfo(@"FDServer-getServerInfo");
	/*NSString* str = [NSString stringWithFormat:kRequestServerInfo,self.host,self.port];
	DAAPResponsemsrv *msrv = (DAAPResponsemsrv *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:str]];
	NSString* str2 = [[NSString alloc] initWithFormat:kRequestContentCodes,host,port];
	DAAPResponsemccr * resp = (DAAPResponsemccr *)[DAAPRequestReply onTheFlyRequestAndParseResponse:[NSURL URLWithString:str2]];*/
}

- (NSString *) _encodeString:(NSString *)string{
	
	// escape the ' character which is used as string delimiter in DAAP queries
	NSString *escapedString = [string stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
	
	// url encode query
	NSString * a = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																	   NULL,
																	   (CFStringRef)escapedString,
																	   NULL,
																	   (CFStringRef)@"!*();:@&=+$,/?%#[]-\\",
																	   kCFStringEncodingUTF8 );
	return a;
}

#pragma mark -
#pragma mark memory management

- (void)dealloc {
	[userPlaylists release];
	[self.host release];
	[self.port release];
	[self.pairingGUID release];
	[self.servicename release];
	[self.TXT release];
	[self.daapReqRep release];
	[self.currentAlbum release];
	[self.currentTrack release];
	[self.currentArtist release];
	[self.currentAlbumId release];
	[self.doneTime release];
	[self.remainingTime release];
	[self.timer invalidate];
    [super dealloc];
}

@end
