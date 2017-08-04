//
//  TrackCustomCellClass.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 17/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "TrackCustomCellClass.h"


@interface TrackCustomCellClass(PrivateMethods)

- (void) _repositionToLandscape;
- (void) _repositionToPortrait;

@end

@implementation TrackCustomCellClass
@synthesize trackName;
@synthesize artistName;
@synthesize trackLength;
@synthesize albumName;
@synthesize background;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void) _repositionToLandscape{
	sep2.center = CGPointMake(450, sep2.center.y);
	albumName.center = CGPointMake(550, albumName.center.y);
	sep3.center = CGPointMake(650, sep3.center.y);
	trackLength.center = CGPointMake(700, trackLength.center.y);
	nowPlayingIndicator.center = CGPointMake(735, nowPlayingIndicator.center.y);
	
}
- (void) _repositionToPortrait{
	sep2.center = CGPointMake(540, sep2.center.y);
	albumName.center = CGPointMake(650, albumName.center.y);
	sep3.center = CGPointMake(674, sep3.center.y);
	trackLength.center = CGPointMake(719, trackLength.center.y);
	nowPlayingIndicator.center = CGPointMake(480, nowPlayingIndicator.center.y);
}

- (void)drawRect:(CGRect)rect{
	UIDevice *device = [UIDevice currentDevice];
	if (device.orientation == UIDeviceOrientationPortrait || device.orientation == UIDeviceOrientationPortraitUpsideDown) {
		[self _repositionToPortrait];
	} else if (device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight){
		[self _repositionToLandscape];
	} else {
		if (self.bounds.size.width > 768.0) {
			[self _repositionToLandscape];
		} else {
			[self _repositionToPortrait];
		}

	}


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL) nowPlaying{
	return nowPlaying;
}

- (void) setNowPlaying:(BOOL)value{
	nowPlaying = value;
	if (nowPlaying) {
		nowPlayingIndicator.hidden = NO;
	} else {
		nowPlayingIndicator.hidden = YES;
	}
	[self setNeedsDisplay];
}


- (void)dealloc {
	[self.trackName release];
	[self.artistName release];
	[self.albumName release];
	[self.trackLength release];
    [super dealloc];
}


@end
