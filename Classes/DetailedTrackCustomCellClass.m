//
//  DetailedTrackCustomCellClass.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 25/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DetailedTrackCustomCellClass.h"


@implementation DetailedTrackCustomCellClass
@synthesize trackName;
@synthesize trackNumber;
@synthesize trackLength;
@synthesize background;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
	UIDevice *device = [UIDevice currentDevice];
	CGRect initial = self.frame;
	if (device.orientation == UIDeviceOrientationPortrait || device.orientation == UIDeviceOrientationPortraitUpsideDown) {
		self.frame = CGRectMake(initial.origin.x, initial.origin.y, 524, initial.size.height);
	} else if (device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight){
		self.frame = CGRectMake(initial.origin.x, initial.origin.y, 780, initial.size.height);
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
		trackNumber.hidden = YES;
	} else {
		nowPlayingIndicator.hidden = YES;
		trackNumber.hidden = NO;
	}
	[self setNeedsDisplay];
}


- (void)dealloc {
	[self.trackName release];
	[self.trackNumber release];
	[self.trackLength release];
    [super dealloc];
}


@end
