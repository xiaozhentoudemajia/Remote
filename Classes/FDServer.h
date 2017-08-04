//
//  FDServer.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 25/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPRequestReply.h"
#import "DAAPRequest.h"
#import "DAAPResponseapso.h"
#import "DAAPResponsecmst.h"
#import "DAAPResponseagal.h"
#import "AsyncImageLoader.h"
#import "Reachability.h"

#define kLibraryServicenameKey @"servicename"
#define kLibraryPairingGUIDKey @"pairingGUID"
#define kLibraryHostKey @"host"
#define kLibraryPortKey @"port"
#define kLibraryDomainKey @"domain"
#define kLibraryTypeKey @"type"
#define kLibraryTXTKey @"TXT"

#define kServerPodcastsLibraryAEPS 1
#define kServerITunesDJLibraryAEPS 2
#define kServerMoviesLibraryAEPS 4
#define kServerTVShowsLibraryAEPS 5
#define kServerMusicLibraryAEPS 6
#define kServerBooksLibraryAEPS 7
#define kServerPurchasedLibraryAEPS 8
#define kServerPurchasedOnDeviceLibraryAEPS 9
#define kServerGeniusLibraryAEPS 12
#define kServerITunesULibraryAEPS 13
#define kServerGeniusMixesLibraryAEPS 15
#define kServerGeniusMixLibraryAEPS 16

@protocol FDServerDelegate

@optional
- (void) didFinishResolvingServerWithSuccess:(BOOL)success;
- (void) didOpenServer:(id)server;
- (void) didFindSpeakers:(NSArray *)speakers;

@end

typedef enum {
	kRepeatStateNoRepeat = 0,
	kRepeatStateTrack = 1,
	kRepeatStateWhole = 2
} kRepeatState;


@interface FDServer : NSObject <DAAPRequestDelegate> {
	@private
	NSString *host;
	NSString *port;
	NSString *pairingGUID;
	NSString *servicename;
	NSDictionary *TXT;
	int sessionId;
	NSInteger databaseId;
	long long databasePersistentId;
	NSInteger musicLibraryId;
	NSInteger podcastsLibraryId;
	long long podcastsPersistentId;
	NSInteger booksLibraryId;
	long long booksPersistentId;
	int musr;
	long revNum;
	BOOL connected;
	NSString *currentTrack;
	NSString *currentAlbum;
	NSString *currentArtist;
	NSNumber *currentAlbumId;
	BOOL playing;
	kRepeatState repeatState;
	BOOL shuffle;
	BOOL trackChanged;
	
	DAAPRequestReply *daapReqRep;
	NSMutableArray *userPlaylists;
	Reachability *r;
	
	id<FDServerDelegate> delegate;
	
	NSNetService *_currentResolve;
	NSString *_domain;
	NSString *_type;
	
	int numericDoneTime;
	int numericTotalTime;
	NSString *doneTime;
	NSString *remainingTime;
	NSTimer *timer;
}

@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *port;
@property (nonatomic, copy) NSString *pairingGUID;
@property (nonatomic, copy) NSString *servicename;
@property (nonatomic, retain) NSDictionary *TXT;
@property (nonatomic) int sessionId;
@property (nonatomic) NSInteger databaseId;
@property (nonatomic) NSInteger musicLibraryId;
@property (nonatomic) NSInteger podcastsLibraryId;
@property (nonatomic) NSInteger booksLibraryId;
@property (nonatomic, readonly) long long booksPersistentId;
@property (nonatomic, readonly) long long podcastsPersistentId;

@property (nonatomic, retain) Reachability *r;

@property (nonatomic) BOOL connected;
@property (nonatomic, copy, readonly) NSString *currentTrack;
@property (nonatomic, copy, readonly) NSString *currentAlbum;
@property (nonatomic, copy, readonly) NSString *currentArtist;
@property (nonatomic, retain) NSNumber *currentAlbumId;
@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, readonly) kRepeatState repeatState;
@property (nonatomic, readonly) BOOL shuffle;
@property (nonatomic, readonly) BOOL trackChanged;
@property (nonatomic, readonly) int numericDoneTime;
@property (nonatomic, readonly) int numericTotalTime;
@property (nonatomic, copy, readonly) NSString *doneTime;
@property (nonatomic, copy, readonly) NSString *remainingTime;
@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, assign) id<FDServerDelegate> delegate;

- (id) initWithNetService:(NSNetService *)service pairingGUID:(NSString *)thePairingGUID;
- (id) initWithDictionary:(NSDictionary *)dict;
- (void) open;
- (void) logout;

- (NSArray *) getPlayLists;
- (void) getArtists:(id<DAAPRequestDelegate>)aDelegate;
- (DAAPResponseagal *) getAlbumsForArtist:(NSString *)artist;
- (DAAPResponseapso *) getTracksForAlbum:(NSNumber *)albumId;
- (void) getTracksForAlbum:(NSNumber *)albumId delegate:(id<DAAPRequestDelegate>)aDelegate;
- (DAAPResponseapso *) getTracksForPodcast:(NSString *)podcastId;
- (DAAPResponseapso *) getTracksForBook:(NSString *)podcastId;
- (DAAPResponseapso *) getAllTracksForArtist:(NSString *)artist;
- (void) getAllTracksForPlaylist:(int)playlistId delegate:(id<DAAPRequestDelegate>)aDelegate;
- (AsyncImageLoader *) getArtwork:(NSNumber *)albumId delegate:(id<AsyncImageLoaderDelegate>)aDelegate forAlbum:(BOOL)forAlbum;
- (AsyncImageLoader *) getArtwork:(NSNumber *)albumId size:(int)aSize delegate:(id<AsyncImageLoaderDelegate>)aDelegate forAlbum:(BOOL)forAlbum;
- (void) getAllAlbums:(id<DAAPRequestDelegate>)aDelegate;
- (void) getAllTracks:(id<DAAPRequestDelegate>)aDelegate;
- (void) getAllBooks:(id<DAAPRequestDelegate>)aDelegate;
- (void) getAllPodcasts:(id<DAAPRequestDelegate>)aDelegate;
- (void) playSongInLibrary:(int)songId;
- (void) playSongInPlaylist:(long long)containermper song:(long)songId;
- (void) playPodcast:(long long)containermper song:(long)songId; 
- (void) playPodcast2:(int)songIndex inAlbum:(NSNumber *)albumId;
- (void) playBook2:(int)songIndex inAlbum:(NSNumber *)albumId;
- (void) playBookInLibrary:(int)bookId;
- (void) playSongIndex:(int)songIndex inAlbum:(NSNumber *)albumId;
- (void) playAllTracksForArtist:(NSString *)artist index:(int)songIndex;
- (void) playPreviousItem;
- (void) playNextItem;
- (void) playPause;
- (void) monitorPlayStatus;
- (void) updateStatus;
- (void) getVolume:(id<DAAPRequestDelegate>)aDelegate action:(SEL)action;
- (void) setVolume:(long) volume;
- (void) toggleShuffle;
- (void) toggleRepeatState;
- (void) changePlayingTime:(int)position;
- (NSArray *) getSpeakers;
- (void) getSpeakers:(id<DAAPRequestDelegate>)aDelegate;
- (void) setSpeakers:(NSArray *)speakers;
- (NSDictionary *) getAsDictionary;
//FIXME : remove that method ! Noone should tell the server to stop tick time !
- (void) shouldInvalidateTimerUpdates;


- (void) getServerInfo;
- (void) connectionTimedOut;


@end
