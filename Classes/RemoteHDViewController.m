//
//  RemoteHDViewController.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  fabrice.dewasmes@gmail.com
//  Copyright Fabrice Dewasmes 2010. All rights reserved.
//

#import "RemoteHDViewController.h"
#import "DAAPResponsemlog.h"
#import "DAAPResponsemsrv.h"
#import "DAAPResponsemdcl.h"
#import "PreferencesManager.h"
#import "DAAPResponsemlit.h"
#import "SpeakersViewController.h"
#import "DAAPResponsecmgt.h"
#import "AlbumCoverViewController.h"
#import "RemoteHDAppDelegate.h"
#import "DDLog.h"
#import "Reachability.h"


@interface RemoteHDViewController(PrivateMethods)

- (void) _shoutCastTask;
- (void) _setShoutcast:(NSString *)url;
- (void) _updateVolume;
- (void) _displayNoLib;
- (void) _updateTime;
- (void) _statusUpdate:(NSNotification *)notification;
- (void) _libraryAvailable;
- (void) _showOrHideVolumeControl;
- (void) _reconnect;
- (void) _switchedToDifferentView;
-(void) networkReachabilityEvent: (NSNotification *) notification;
@end


@implementation RemoteHDViewController
@synthesize navigationController;
@synthesize popOver;
@synthesize nowPlayingDetail;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	nowPlaying.displayShadow = YES;
	
	nowPlayingDetailShown = NO;
	librariesShown = NO;
	
	// i18n
	loadingMessageLabel.text = NSLocalizedString(@"loading",@"Chargement en cours...");
	[segmentedControl setTitle:NSLocalizedString(@"Tracks",@"Morceaux") forSegmentAtIndex:0];
	[segmentedControl setTitle:NSLocalizedString(@"Artists",@"Albums") forSegmentAtIndex:1];
	[segmentedControl setTitle:NSLocalizedString(@"Albums",@"Artistes") forSegmentAtIndex:2];
	[settingsButton setTitle:NSLocalizedString(@"settings",@"Réglages")];
	nowPlayingLabel.text = NSLocalizedString(@"nowPlaying",@"A l'écoute");
	
	// init navigation controller
	navigationController.navigationBarHidden = YES;
	navigationController.view.frame = CGRectMake(244, 70, 524, 890);
	navigationController.delegate = self;
	[self.view addSubview:navigationController.view];
	
	// init 'hiding views'
	[self.view bringSubviewToFront:loadingView];
	[self.view bringSubviewToFront:nolibView];
	
	// register observers for notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_libraryAvailable) name:kNotificationConnected object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_displayNoLib) name:kNotificationConnectionLost object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_statusUpdate:) name:kNotificationStatusUpdate object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_displayNoLib) name:kNotificationTryReconnect object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_displayError) name:kNotificationBrokenConnection object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityEvent:) name:kReachabilityChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateTime) name:kNotificationTimerTicks object:nil];
	
	// load preferences file and try to connect to the last used server
	[[PreferencesManager sharedPreferencesManager] loadPreferencesFromFile];
	
	
	// customize sliders
	volumeSlider.backgroundColor = [UIColor clearColor];	
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"slider1.png"]
								stretchableImageWithLeftCapWidth:34.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"slider2.png"]
								 stretchableImageWithLeftCapWidth:34.0 topCapHeight:0.0];
	[volumeSlider setThumbImage: [UIImage imageNamed:@"sliderPin.png"] forState:UIControlStateNormal];
	[volumeSlider setThumbImage: [UIImage imageNamed:@"sliderPin.png"] forState:UIControlStateSelected];
	[volumeSlider setThumbImage: [UIImage imageNamed:@"sliderPin.png"] forState:UIControlStateHighlighted];
	[volumeSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
	[volumeSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
	
	progress.backgroundColor = [UIColor clearColor];	
	UIImage *stetchLeftTrack2 = [[UIImage imageNamed:@"timeslider1.png"]
								stretchableImageWithLeftCapWidth:6.0 topCapHeight:0.0];
	UIImage *stetchRightTrack2 = [[UIImage imageNamed:@"timeslider2.png"]
								 stretchableImageWithLeftCapWidth:6.0 topCapHeight:0.0];
	[progress setThumbImage: [UIImage imageNamed:@"timeSliderPin.png"] forState:UIControlStateNormal];
	[progress setThumbImage: [UIImage imageNamed:@"timeSliderPin.png"] forState:UIControlStateSelected];
	[progress setThumbImage: [UIImage imageNamed:@"timeSliderPin.png"] forState:UIControlStateHighlighted];
	[progress setMinimumTrackImage:stetchLeftTrack2 forState:UIControlStateNormal];
	[progress setMaximumTrackImage:stetchRightTrack2 forState:UIControlStateNormal];

	// hide most part of the UI if we cannot connect to last used server
	//if (CurrentServer == nil) {
		[self _displayNoLib];
	//}
	
	// init the editing playing time state
	_editingPlayingTime = NO;

    [self _shoutCastTask];
}

- (void) viewDidAppear:(BOOL)animated{
	[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(_reconnect) userInfo:nil repeats:NO];
}

- (void) _reconnect {
	if (!CurrentServer.connected) {
		[[SessionManager sharedSessionManager] openLastUsedServer];
	}
}

#pragma mark -
#pragma mark Actions

- (IBAction) buttonClicked:(id)sender{
	DDLogVerbose(@"RemoteHDViewController settings button clicked");
	if (librariesViewController == nil) {
		DDLogVerbose(@"RemoteHDViewController creating libraries view controller");
		librariesViewController = [[LibrariesViewController alloc ] initWithNibName:@"LibrariesViewController" bundle:nil];
		librariesViewController.modalPresentationStyle = UIModalPresentationFormSheet;
		[librariesViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[librariesViewController setDelegate:self];
	}
	DDLogVerbose(@"RemoteHDViewController presenting modal view");
	[self presentModalViewController:librariesViewController animated:YES]; 
	librariesShown = YES;
}

- (IBAction) playClicked:(id)sender{
	FDServer *server = CurrentServer;
	[server playPause];
}

- (IBAction) pauseClicked:(id)sender{
	FDServer *server = CurrentServer;
	[server playPause];
}

- (IBAction) nextClicked:(id)sender{
	FDServer *server = CurrentServer;
	[server playNextItem];
}

- (IBAction) previousClicked:(id)sender{
	FDServer *server = CurrentServer;
	[server playPreviousItem];
}

// user did change volume
- (IBAction) volumeChanged:(id)sender{
	FDServer *server = CurrentServer;
	[server setVolume:volumeSlider.value];
	[self _updateVolume];
}

// called when user start changing the playing time slider
// used to avoid the timer to try top update slide state while user is editing value
- (IBAction) startingPlaytimeEdit:(id)sender{
	_editingPlayingTime = YES;
}

- (IBAction) playingTimeChanged:(id)sender{
	FDServer *server = CurrentServer;
	[server changePlayingTime:progress.value];
	_editingPlayingTime = NO;
}

- (IBAction) buttonSelected:(id)sender{
	DDLogVerbose(@"restoring segmented control position");
	switch (segmentedControl.selectedSegmentIndex) {
		case 0:
			[[PreferencesManager sharedPreferencesManager] saveViewState:kPrefLastSelectedSegControlTrack withKey:kPrefLastSelectedSegControl];
			[detailViewController changeToTrackView];
			break;
		case 1:
			[[PreferencesManager sharedPreferencesManager] saveViewState:kPrefLastSelectedSegControlArtist withKey:kPrefLastSelectedSegControl];
			[detailViewController changeToArtistView];
			break;
		case 2:
			[[PreferencesManager sharedPreferencesManager] saveViewState:kPrefLastSelectedSegControlAlbum withKey:kPrefLastSelectedSegControl];
			[detailViewController changeToAlbumView];
			break;
		case 3:
			NSLog(@"showing testView");
			[self.view bringSubviewToFront:testView];
			AlbumCoverViewController *c = [[AlbumCoverViewController alloc] initWithNibName:@"AlbumCover" bundle:nil];
			[testView addSubview:c.view];
			c.image.image = [UIImage imageNamed:@"defaultCover.png"];
			c.albumTitle.text = @"test";
			
			AlbumCoverViewController *c2 = [[AlbumCoverViewController alloc] initWithNibName:@"AlbumCover" bundle:nil];
			c2.view.frame = CGRectMake(198, 0, 198, 186);
			[testView addSubview:c2.view];
			c2.image.image = [UIImage imageNamed:@"defaultCover.png"];
			c2.albumTitle.text = @"test2";
		default:
			break;
	}
	[self _switchedToDifferentView];
}

- (IBAction)speakerSelectorClicked:(id)sender
{
	if (self.popOver == nil){
		SpeakersViewController* content = [[SpeakersViewController alloc] init];
		UIPopoverController* aPopover = [[UIPopoverController alloc]
									 initWithContentViewController:content];
		aPopover.delegate = self;
		aPopover.popoverContentSize = CGSizeMake(250, 150);
		[content release];
	
		// Store the popover in a custom property for later use.
		self.popOver = aPopover;
		[aPopover release];
	}
	if (self.popOver.popoverVisible) {
		[self.popOver dismissPopoverAnimated:YES];
		return;
	}
	[self.popOver presentPopoverFromBarButtonItem:sender
								   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction) showNowPlayingDetail:(id)sender{
	NowPlayingDetailViewController *c = [[NowPlayingDetailViewController alloc] initWithNibName:kNowPlayingDetailViewNibName bundle:nil];
	self.nowPlayingDetail = c;
	self.nowPlayingDetail.modalPresentationStyle = UIModalPresentationFullScreen;
	[self.nowPlayingDetail setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	[self.nowPlayingDetail setDelegate:self];
	[self presentModalViewController:self.nowPlayingDetail animated:YES];
//	[self.view addSubview:self.nowPlayingDetail.view];
	[c release];
	nowPlayingDetailShown = YES;
}

- (void)didFinishWithNowPlaying{
	[self dismissModalViewControllerAnimated:YES];
	if (CurrentServer != nil && CurrentServer.connected)
		[self _updateVolume];
	nowPlayingDetailShown = NO;
}

- (void)navigationController:(UINavigationController *)theNavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
	if ([self.navigationController.viewControllers objectAtIndex:0] == self.navigationController.visibleViewController) {
		[self.navigationController setNavigationBarHidden:YES animated:NO];
	}
}

#pragma mark -
#pragma mark WifiConfigDelegate methods

- (void) didFinishWifiConfig {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didSetWifiConfig:(NSString *)ssid pwd:(NSString *)pwd  {
    [self dismissModalViewControllerAnimated:YES];
    FDServer *server = CurrentServer;
    if (server != nil) {
        [server setWifiConfig:ssid pwd:pwd];
    }
}

#pragma mark -
#pragma mark LibraryDelegate methods

- (void) didFinishEditingLibraries {
	
	DDLogVerbose(@"Did finish editing libraries");
	[self dismissModalViewControllerAnimated:YES];
	if (CurrentServer != nil ) {
		[self startLoading];
		//[detailViewController display];
		[self buttonSelected:nil];
		[self _updateVolume];
	} else {
		[self _displayNoLib];
	}
	librariesShown = NO;
	[self _showOrHideVolumeControl];
}

#pragma mark -
#pragma mark DetailDelegate methods

- (void) didSelectItem{	
}

- (void) didFinishLoading{
	loadingView.alpha = 0.0;
	loadingView.hidden = YES;
	[activityIndicator stopAnimating];
}

- (void) startLoading{
	loadingView.alpha = 1.0;
	loadingView.hidden = NO;
	[activityIndicator startAnimating];
}




#pragma mark -
#pragma mark MasterDelegate methods

- (void) didSelectPlaylist{
	segmentedControl.hidden = YES;
	[self _switchedToDifferentView];
}

- (void) didSelectLibrary{
	segmentedControl.hidden = NO;
	[self buttonSelected:nil];
	[self _switchedToDifferentView];
}

- (void)didSelectBooksOrPodcasts{
	segmentedControl.hidden = YES;
	[self _switchedToDifferentView];
}

- (void)didSelectShoutCast{
    segmentedControl.hidden = YES;
}

- (void)didSelectWifiConfig{
    // wifi config
    if (wifiConfigController == nil) {
        wifiConfigController = [[WifiConfigController alloc ] initWithNibName:@"WifiConfigController" bundle:nil];
        wifiConfigController.modalPresentationStyle = UIModalPresentationFormSheet;
        [wifiConfigController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [wifiConfigController setDelegate:self];
    }
//    wifiConfigController.preferredContentSize = CGSizeMake(300, 300);
    [self presentModalViewController:wifiConfigController animated:YES];
    wifiConfigController.view.superview.bounds = CGRectMake(0, 0, 200, 200);
//    wifiConfigController.view.superview.frame = CGRectMake(0, 0, 100, 100);
//    wifiConfigController.view.superview.center = self.view.center;
}

#pragma mark -
#pragma mark private methods

- (void) _shoutCastTask{
    dispatch_queue_t queue = dispatch_queue_create("monitor.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSString *url = @"none";
        NSString *account = @"none";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"none" forKey:@"shoutcast"];
        [defaults synchronize];
        while(1) {
            account = [defaults objectForKey:@"shoutcast"];
            if (![url isEqualToString:account] && account != nil) {
                DDLogVerbose(@"set shoutcast by daap ----- %@", account);
                url = account;
                FDServer *server = CurrentServer;
                [server setShoutcast:url];
            }
            [NSThread sleepForTimeInterval:0.5];
        }
    });
}

- (void) _setShoutcast:(NSString *)url{
    FDServer *server = CurrentServer;
    [server setShoutcast:url];
}

- (void) _updateVolume{
	DDLogVerbose(@"updating volume");
	FDServer *server = CurrentServer;
	//long v = [server getVolume];
	[server getVolume:self action:@selector(readVolume:)];
	
}

- (void) readVolume:(DAAPResponse *)resp{
	DAAPResponsecmgt * response = (DAAPResponsecmgt *)resp;
	volumeSlider.value = [response.cmvo longValue];
}

- (void) didFinishLoading:(DAAPResponse *)response{
}

- (void) connectionTimedOut{
	FDServer *server = CurrentServer;
	server.connected = NO;
	[[NSNotificationCenter defaultCenter ]postNotificationName:kNotificationConnectionLost object:nil];
}


- (void) _updateTime{
	if (CurrentServer.playing && !_editingPlayingTime) {
			progress.maximumValue = CurrentServer.numericTotalTime;
			progress.minimumValue = 0;
			progress.value = CurrentServer.numericDoneTime;
			
			donePlayingTime.text = CurrentServer.doneTime;
			remainingPlayingTime.text = CurrentServer.remainingTime;
	}
}



#pragma mark notification handling methods

- (void) _statusUpdate:(NSNotification *)notification{
	progress.maximumValue = CurrentServer.numericTotalTime;
	progress.minimumValue = 0;
	progress.value = CurrentServer.numericDoneTime;
	
	track.text = CurrentServer.currentTrack;
	artist.text = CurrentServer.currentArtist;
	album.text = CurrentServer.currentAlbum;
	if ([CurrentServer playing]) {
		play.alpha = 0.0;
		pause.alpha = 1.0;
	} else {
		play.alpha = 1.0;
		pause.alpha = 0.0;
	} 
	if (CurrentServer.trackChanged) {
		FDServer *server = CurrentServer;
		NSString *string = [NSString stringWithFormat:kRequestNowPlayingArtwork,server.host,server.port,server.sessionId];
		[nowPlaying loadImageFromURL:[NSURL URLWithString:string]];
	}
	
	donePlayingTime.text = CurrentServer.doneTime;
	remainingPlayingTime.text = CurrentServer.remainingTime;
	
}

- (void) _displayNoLib{
	[self didFinishWithNowPlaying];
	[CurrentServer shouldInvalidateTimerUpdates];
	donePlayingTime.text = @"";
	remainingPlayingTime.text = @"";
	progress.hidden = YES;
	volumeSlider.value = 0;
	volumeSlider.hidden = YES;
	segmentedControl.hidden = YES;
	NSString *notConnectedMessage = [[NSBundle mainBundle] localizedStringForKey:@"notConnected" 
																		  value:@"Vous n'êtes pas connecté" 
																		  table:@"Localizable"];
	noLibViewMessage.text = notConnectedMessage;
	nolibView.alpha = 1.0;
}

- (void) _displayError{
	if (nowPlayingDetailShown) {
		[self didFinishWithNowPlaying];
	}
	[CurrentServer shouldInvalidateTimerUpdates];
	donePlayingTime.text = @"";
	remainingPlayingTime.text = @"";
	progress.hidden = YES;
	volumeSlider.value = 0;
	volumeSlider.hidden = YES;
	segmentedControl.hidden = YES;
	NSString *notConnectedMessage = [[NSBundle mainBundle] localizedStringForKey:@"brokenConnection" 
																		   value:@"La communication avec le serveur ne peut être établie" 
																		   table:@"Localizable"];
	noLibViewMessage.text = notConnectedMessage;
	nolibView.alpha = 1.0;
}

- (void) _libraryAvailable {
	DDLogVerbose(@"Library available");
	nolibView.alpha = 0.0;
	progress.hidden = NO;
	volumeSlider.hidden = NO;
	[self startLoading];
	[detailViewController didChangeLibrary];
	[masterViewController didChangeLibrary];
	segmentedControl.hidden = NO;
	NSString *state = [[PreferencesManager sharedPreferencesManager] getViewStateForKey:kPrefLastSelectedSegControl];
	if ([state isEqualToString:kPrefLastSelectedSegControlTrack]) {
	 segmentedControl.selectedSegmentIndex = 0;
	 } else if ([state isEqualToString:kPrefLastSelectedSegControlArtist]) {
	 segmentedControl.selectedSegmentIndex = 1;
	 } else if ([state isEqualToString:kPrefLastSelectedSegControlAlbum]) {
	 segmentedControl.selectedSegmentIndex = 2;
	 }
	
	[self buttonSelected:nil];
	FDServer *server = CurrentServer;
	NSString *string = [NSString stringWithFormat:kRequestNowPlayingArtwork,server.host,server.port,server.sessionId];
	DDLogVerbose(@"requesting now playing artwork");
	[nowPlaying loadImageFromURL:[NSURL URLWithString:string]];
	[self _showOrHideVolumeControl];
}

- (void) _showOrHideVolumeControl {
	FDServer *server = CurrentServer;
	if (![[PreferencesManager sharedPreferencesManager] volumeControl]) {
		[server setVolume:100];
		volumeSlider.hidden = YES;
	}else {
		volumeSlider.hidden = NO;
		[self _updateVolume];
	}
}

- (void) _switchedToDifferentView{
	DDLogVerbose(@"cancel Pending Connections");
	[detailViewController cancelPendingConnections];
}


-(void) networkReachabilityEvent: (NSNotification *) notification{
	Reachability *r = [notification object];
	DDLogVerbose(@"----------------------------------");
	 DDLogVerbose(@"isConnectionRequired : %@",[r isConnectionRequired]?@"YES":@"NO");
	switch ([r currentReachabilityStatus]) {
		case kNotReachable:
			DDLogVerbose(@"not reachable");
			[self _displayError];
			[CurrentServer logout];
			[[SessionManager sharedSessionManager] openLastUsedServer];
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
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
	//[self.popOver release];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}


- (void)dealloc {
	[self.popOver release];
	[self.nowPlayingDetail release];
    [super dealloc];
}

@end
