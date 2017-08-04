    //
//  NowPlayingDetailViewController.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 03/08/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "NowPlayingDetailViewController.h"
#import "SessionManager.h"
#import "PreferencesManager.h"
#import "FDServer.h"
#import "DAAPResponsecmgt.h"
#import "DDLog.h"

#ifdef CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@interface NowPlayingDetailViewController(PrivateMethods)

- (void) _statusUpdate:(NSNotification *)notification;
- (void) _didChangeOrientation;
- (void) _repositionToLandscape;
- (void) _repositionToPortrait;
- (void) _showOrHideVolumeControl;
- (void) _updateVolume;
- (void) _updateShuffleState;
- (void) _updateRepeatState;
- (void) _updateTime;

@end


@implementation NowPlayingDetailViewController

@synthesize track;
@synthesize album;
@synthesize artist;
@synthesize coverArt;
@synthesize delegate;
@synthesize albumId;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void) viewWillAppear:(BOOL)animated{
	//ensure that screen layout conforms to device orientation
	[self _didChangeOrientation];
	[self _updateShuffleState];
	[self _updateRepeatState];
	[self _statusUpdate:nil];
	[self _updateTime];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	coverArt.displayShadow = NO;
	coverArt.delegate = self;
	fullScreen = NO;
	isDisplayingCover = YES;
	//[self _didChangeOrientation];
	self.track.text = CurrentServer.currentTrack;
	self.album.text = CurrentServer.currentAlbum;
	self.artist.text = CurrentServer.currentArtist;
	[CurrentServer getTracksForAlbum:CurrentServer.currentAlbumId delegate:listController];
	NSString *string = [NSString stringWithFormat:kRequestNowPlayingArtworkBig,CurrentServer.host,CurrentServer.port,CurrentServer.sessionId];
	
	coverArt.isDefaultCoverBig = YES;
	[coverArt loadImageFromURL:[NSURL URLWithString:string]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_statusUpdate:) name:kNotificationStatusUpdate object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneButtonPressed:) name:kNotificationConnectionLost object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateTime) name:kNotificationTimerTicks object:nil];
	
	volumeSlider.backgroundColor = [UIColor clearColor];	
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"slider-black-fill.png"]
								stretchableImageWithLeftCapWidth:34.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"slider-black-empty.png"]
								 stretchableImageWithLeftCapWidth:34.0 topCapHeight:0.0];
	[volumeSlider setThumbImage: [UIImage imageNamed:@"slider-black-pin.png"] forState:UIControlStateNormal];
	[volumeSlider setThumbImage: [UIImage imageNamed:@"slider-black-pin.png"] forState:UIControlStateSelected];
	[volumeSlider setThumbImage: [UIImage imageNamed:@"slider-black-pin.png"] forState:UIControlStateHighlighted];
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

- (void) _updateShuffleState{
	if (CurrentServer.shuffle) {
		[shuffleButton setImage:[UIImage imageNamed:@"shuffle-icon-highlighted.png"] forState:UIControlStateNormal];
	} else {
		[shuffleButton setImage:[UIImage imageNamed:@"shuffle-icon.png"] forState:UIControlStateNormal];
	}
}

- (void) _updateRepeatState{
	switch (CurrentServer.repeatState) {
		case kRepeatStateTrack:
			[repeatButton setImage:[UIImage imageNamed:@"repeat-icon-track-highlighted.png"] forState:UIControlStateNormal];
			break;
		case kRepeatStateWhole:
			[repeatButton setImage:[UIImage imageNamed:@"repeat-icon-highlighted.png"] forState:UIControlStateNormal];
			break;
		case kRepeatStateNoRepeat:
			[repeatButton setImage:[UIImage imageNamed:@"repeat-icon.png"] forState:UIControlStateNormal];
			break;

		default:
			break;
	} 
}

- (void) _updateVolume{
	[CurrentServer getVolume:self action:@selector(readVolume:)];
}

- (void) readVolume:(DAAPResponse *)resp{
	DAAPResponsecmgt * response = (DAAPResponsecmgt *)resp;
	volumeSlider.value = [response.cmvo longValue];
}

- (void) didFinishLoading:(DAAPResponse *)response{
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

- (IBAction) listButtonClicked:(id)sender{
	[UIView beginAnimations:@"Change view" context:NULL];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:containerView cache:NO];
	[UIView setAnimationDuration:0.6];
	UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
	
	if (isDisplayingCover) {
		
		[coverArt removeFromSuperview];
		
		if (o == UIDeviceOrientationLandscapeLeft || o == UIDeviceOrientationLandscapeRight) {
			DDLogVerbose(@"landscape"); 
			listController.tableView.frame = CGRectMake(0, 142, 768, 529);
			
		} else if (o == UIDeviceOrientationPortrait || o == UIDeviceOrientationPortraitUpsideDown) {
			DDLogVerbose(@"portrait");
			listController.tableView.frame = CGRectMake(0, 0, 768, 768);
		}
		[listController scrollToCurrentlyPlayingTrack];
		[containerView addSubview:[listController view]];
		
		//isDisplayingCover = NO;
	} else {
		[listController.view removeFromSuperview];
		[containerView addSubview:coverArt];
		[[coverButton superview] bringSubviewToFront:coverButton];
		//isDisplayingCover = YES;
	}

//	if (device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight) {
//		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
//	} else if (device.orientation == UIDeviceOrientationPortrait || device.orientation == UIDeviceOrientationPortraitUpsideDown) {
	//	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:containerView cache:NO];
//	}
	
	[UIView commitAnimations];	
	[UIView beginAnimations:@"Change view" context:NULL];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:toggleButtonView cache:NO];
	[UIView setAnimationDuration:0.6];
	
	if (isDisplayingCover) {
		[listButton removeFromSuperview];
		smallcoverButton.hidden = NO;
		smallcoverButton.frame = CGRectMake(0, 0, 44, 44);
		[toggleButtonView addSubview:smallcoverButton];
		isDisplayingCover = NO;
	} else {
		[smallcoverButton removeFromSuperview];
		[toggleButtonView addSubview:listButton];
		isDisplayingCover = YES;
	}
	
	//	if (device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight) {
	//		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	//	} else if (device.orientation == UIDeviceOrientationPortrait || device.orientation == UIDeviceOrientationPortraitUpsideDown) {
	//	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:containerView cache:NO];
	//	}
	
	[UIView commitAnimations];	
}

- (IBAction) shuffleClicked:(id)sender{
	[CurrentServer toggleShuffle];
	[self _updateShuffleState];	
}
- (IBAction) repeatClicked:(id)sender{
	[CurrentServer toggleRepeatState];
	[self _updateRepeatState];	
}

// user did change volume
- (IBAction) volumeChanged:(id)sender{
	FDServer *server = CurrentServer;
	[server setVolume:volumeSlider.value];
	[self _updateVolume];
}


- (void) _repositionToLandscape{
	containerView.frame = CGRectMake(128, 0, 768, 768);
	listController.tableView.frame = CGRectMake(0, 142, 768, 529);
	if (!fullScreen) {
		bottomBackgroundLandscape.alpha = 1.0;
		bottomBackground.alpha = 0.0;
		topBackground.alpha = 0.0;
		topBackgroundLandscape.alpha = 1.0;
	}
	backButton.frame = CGRectMake(158, backButton.frame.origin.y, backButton.frame.size.width, backButton.frame.size.height);
	toggleButtonView.frame = CGRectMake(824, toggleButtonView.frame.origin.y, toggleButtonView.frame.size.width, toggleButtonView.frame.size.height);
	nextButton.frame = CGRectMake(820, nextButton.frame.origin.y, nextButton.frame.size.width, nextButton.frame.size.height);
	previousButton.frame = CGRectMake(706, previousButton.frame.origin.y, previousButton.frame.size.width, previousButton.frame.size.height);
	playButton.frame = CGRectMake(779, playButton.frame.origin.y, playButton.frame.size.width, playButton.frame.size.height);
	pauseButton.frame = CGRectMake(779, pauseButton.frame.origin.y, pauseButton.frame.size.width, pauseButton.frame.size.height);
	repeatButton.frame = CGRectMake(150, repeatButton.frame.origin.y, repeatButton.frame.size.width, repeatButton.frame.size.height);
	shuffleButton.frame = CGRectMake(854, shuffleButton.frame.origin.y, shuffleButton.frame.size.width, shuffleButton.frame.size.height);
	volumeSlider.frame = CGRectMake(148, volumeSlider.frame.origin.y, volumeSlider.frame.size.width, volumeSlider.frame.size.height);
	donePlayingTime.frame = CGRectMake(181, donePlayingTime.frame.origin.y, donePlayingTime.frame.size.width, donePlayingTime.frame.size.height);
	remainingPlayingTime.frame = CGRectMake(791, remainingPlayingTime.frame.origin.y, remainingPlayingTime.frame.size.width, remainingPlayingTime.frame.size.height);
	progress.frame = CGRectMake(237, progress.frame.origin.y, progress.frame.size.width, progress.frame.size.height);
	isPortraitMode = NO;
}

- (void) _repositionToPortrait{
	containerView.frame = CGRectMake(0, 142, 768, 768);
	listController.tableView.frame = CGRectMake(0, 0, 768, 768);
	if (!fullScreen){
		bottomBackground.alpha = 1.0;
		bottomBackgroundLandscape.alpha = 0.0;
		topBackground.alpha = 1.0;
		topBackgroundLandscape.alpha = 0.0;
	}
	backButton.frame = CGRectMake(30, backButton.frame.origin.y, backButton.frame.size.width, backButton.frame.size.height);
	toggleButtonView.frame = CGRectMake(687, toggleButtonView.frame.origin.y, toggleButtonView.frame.size.width, toggleButtonView.frame.size.height);
	nextButton.frame = CGRectMake(689, nextButton.frame.origin.y, nextButton.frame.size.width, nextButton.frame.size.height);
	previousButton.frame = CGRectMake(570, previousButton.frame.origin.y, previousButton.frame.size.width, previousButton.frame.size.height);
	playButton.frame = CGRectMake(643, playButton.frame.origin.y, playButton.frame.size.width, playButton.frame.size.height);
	pauseButton.frame = CGRectMake(643, pauseButton.frame.origin.y, pauseButton.frame.size.width, pauseButton.frame.size.height);
	repeatButton.frame = CGRectMake(20, repeatButton.frame.origin.y, repeatButton.frame.size.width, repeatButton.frame.size.height);
	shuffleButton.frame = CGRectMake(731, shuffleButton.frame.origin.y, shuffleButton.frame.size.width, shuffleButton.frame.size.height);
	volumeSlider.frame = CGRectMake(23, volumeSlider.frame.origin.y, volumeSlider.frame.size.width, volumeSlider.frame.size.height);
	donePlayingTime.frame = CGRectMake(56, donePlayingTime.frame.origin.y, donePlayingTime.frame.size.width, donePlayingTime.frame.size.height);
	remainingPlayingTime.frame = CGRectMake(670, remainingPlayingTime.frame.origin.y, remainingPlayingTime.frame.size.width, remainingPlayingTime.frame.size.height);
	progress.frame = CGRectMake(114, progress.frame.origin.y, progress.frame.size.width, progress.frame.size.height);
	isPortraitMode = YES;
}

-(void) _didChangeOrientation{
	UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
	if (o == UIDeviceOrientationLandscapeLeft || o == UIDeviceOrientationLandscapeRight) {
		DDLogVerbose(@"landscape"); 
		[self _repositionToLandscape];
	} else if (o == UIDeviceOrientationPortrait || o == UIDeviceOrientationPortraitUpsideDown) {
		DDLogVerbose(@"portrait");
		[self _repositionToPortrait];
	} else {
		if (self.view.bounds.size.width == 1024.0) {
			[self _repositionToLandscape];
		} else {
			[self _repositionToPortrait];
		}
	}

}

- (void) _statusUpdate:(NSNotification *)notification{
	DAAPResponsecmst *cmst = (DAAPResponsecmst *)[notification.userInfo objectForKey:@"cmst"];
	BOOL trackChanged = NO;
	if (cmst != nil && cmst.asai && [self.albumId longLongValue] != [cmst.asai longLongValue]){
		trackChanged = YES;
		self.albumId = cmst.asai;
	}
	//BOOL trackChanged = (![track.text isEqualToString:cmst.cann] || ![artist.text isEqualToString:cmst.cana] || ![album.text isEqualToString:cmst.canl]);
	
	track.text = CurrentServer.currentTrack;
	artist.text = CurrentServer.currentArtist;
	album.text = CurrentServer.currentAlbum;

	if (CurrentServer.playing) {
		playButton.alpha = 0.0;
		pauseButton.alpha = 1.0;
	} else {
		playButton.alpha = 1.0;
		pauseButton.alpha = 0.0;
	} 
	if (trackChanged) {
		[CurrentServer getTracksForAlbum:cmst.asai delegate:listController];
		FDServer *server = CurrentServer;
		NSString *string = [NSString stringWithFormat:kRequestNowPlayingArtworkBig,server.host,server.port,server.sessionId];
		[coverArt loadImageFromURL:[NSURL URLWithString:string]];
	}	
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

- (IBAction) doneButtonPressed:(id)sender{
	[delegate didFinishWithNowPlaying];
}

- (IBAction) didTouchCover:(id)sender{
	if (!isDisplayingCover) {
		return;
	}
	DDLogVerbose(@"touched");
	[UIView beginAnimations:@"fullscreen" context:NULL];
	if (!fullScreen) {
		DDLogVerbose(@"full");
		bottomBackgroundLandscape.alpha = 0.0;
		bottomBackground.alpha = 0.0;
		topBackgroundLandscape.alpha = 0.0;
		topBackground.alpha = 0.0;
		backButton.alpha = 0.0;
		toggleButtonView.alpha = 0.0;
		playButton.alpha = 0.0;
		pauseButton.alpha = 0.0;
		previousButton.alpha = 0.0;
		nextButton.alpha = 0.0;
		repeatButton.alpha = 0.0;
		shuffleButton.alpha = 0.0;
		track.alpha = 0.0;
		album.alpha = 0.0;
		artist.alpha = 0.0;
		topSeparator.alpha = 0.0;
		volumeSlider.alpha = 0.0;
		donePlayingTime.alpha = 0.0;
		remainingPlayingTime.alpha = 0.0;
		progress.alpha = 0.0;
		fullScreen = YES;
	} else {
		if (isPortraitMode) {
			topBackground.alpha = 1.0;
			bottomBackground.alpha = 1.0;
		} else {
			topBackgroundLandscape.alpha = 1.0;
			bottomBackgroundLandscape.alpha = 1.0;
		}

		backButton.alpha = 1.0;
		toggleButtonView.alpha = 1.0;
		playButton.alpha = 1.0;
		pauseButton.alpha = 1.0;
		previousButton.alpha = 1.0;
		nextButton.alpha = 1.0;
		repeatButton.alpha = 1.0;
		shuffleButton.alpha = 1.0;
		track.alpha = 1.0;
		album.alpha = 1.0;
		artist.alpha = 1.0;
		topSeparator.alpha = 1.0;
		volumeSlider.alpha = 1.0;
		donePlayingTime.alpha = 1.0;
		remainingPlayingTime.alpha = 1.0;
		progress.alpha = 1.0;
		fullScreen = NO;
	}

	
	[UIView commitAnimations];
	
}

- (void) _updateTime{
	if (!_editingPlayingTime) {
		progress.maximumValue = CurrentServer.numericTotalTime;
		progress.minimumValue = 0;
		progress.value = CurrentServer.numericDoneTime;
		
		donePlayingTime.text = CurrentServer.doneTime;
		remainingPlayingTime.text = CurrentServer.remainingTime;
	}
}

- (void) didFinishLoading{
	[smallcoverButton setBackgroundImage:[coverArt image] forState:UIControlStateNormal];
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[track release];
	[album release];
	[artist release];
	[coverArt release];
	[albumId release];
    [super dealloc];
}


@end
