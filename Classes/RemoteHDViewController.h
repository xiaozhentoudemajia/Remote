//
//  RemoteHDViewController.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  fabrice.dewasmes@gmail.com
//  Copyright Fabrice Dewasmes 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LibrariesViewController.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AsyncImageView.h"
#import "SessionManager.h"
#import "NowPlayingDetailViewController.h"

@interface RemoteHDViewController : UIViewController <LibraryDelegate, DetailDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, DAAPRequestDelegate, MasterViewDelegate, NowPlayingDelegate>{
	IBOutlet UIToolbar *topToolbar;
	IBOutlet UIToolbar *bottomToolbar;
	IBOutlet UIView *loadingView;
	IBOutlet UIView *nolibView;
	IBOutlet UIView *testView;
	IBOutlet UILabel *noLibViewMessage;
	IBOutlet UILabel *loadingMessageLabel;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UISegmentedControl *segmentedControl;
	IBOutlet UILabel *nowPlayingLabel;
	IBOutlet UIBarButtonItem *settingsButton;
	
	IBOutlet MasterViewController *masterViewController;
	IBOutlet DetailViewController *detailViewController;
	LibrariesViewController *librariesViewController;
	
	IBOutlet AsyncImageView *nowPlaying;
	IBOutlet UISlider *progress;
	IBOutlet UILabel *track;
	IBOutlet UILabel *artist;
	IBOutlet UILabel *album;
	IBOutlet UIButton *play;
	IBOutlet UIButton *pause;
	IBOutlet UISlider *volumeSlider;
	IBOutlet UILabel *donePlayingTime;
	IBOutlet UILabel *remainingPlayingTime;
	UINavigationController *navigationController;
	UIPopoverController *popOver;
	NowPlayingDetailViewController *nowPlayingDetail;
	BOOL nowPlayingDetailShown;
	BOOL librariesShown;
	
@private 
	BOOL _editingPlayingTime;
}

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) UIPopoverController *popOver;
@property (nonatomic, retain) NowPlayingDetailViewController *nowPlayingDetail;

- (IBAction) buttonClicked:(id)sender;
- (IBAction) playClicked:(id)sender;
- (IBAction) pauseClicked:(id)sender;
- (IBAction) nextClicked:(id)sender;
- (IBAction) previousClicked:(id)sender;
- (IBAction) volumeChanged:(id)sender;
- (IBAction) playingTimeChanged:(id)sender;
- (IBAction) startingPlaytimeEdit:(id)sender;
- (IBAction) buttonSelected:(id)sender;
- (IBAction) speakerSelectorClicked:(id)sender;
- (IBAction) showNowPlayingDetail:(id)sender;

@end

