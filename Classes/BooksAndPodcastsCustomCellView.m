//
//  BooksAndPodcastsCustomCellView.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 06/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BooksAndPodcastsCustomCellView.h"


@interface BooksAndPodcastsCustomCellView(PrivateMethods)

- (void) _repositionToLandscape;
- (void) _repositionToPortrait;

@end

@implementation BooksAndPodcastsCustomCellView
@synthesize trackName;
@synthesize artistName;
@synthesize background;
@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

- (void) _repositionToLandscape{
	sep.center = CGPointMake(461, sep.center.y);
	trackName.frame = CGRectMake(trackName.frame.origin.x, trackName.frame.origin.y, 355, trackName.frame.size.height);	
	artistName.frame = CGRectMake(470, artistName.frame.origin.y, 302, artistName.frame.size.height);	
}
- (void) _repositionToPortrait{
	sep.center = CGPointMake(300, sep.center.y);
	trackName.frame = CGRectMake(trackName.frame.origin.x, trackName.frame.origin.y, 190, trackName.frame.size.height);	
	artistName.frame = CGRectMake(309, artistName.frame.origin.y, 200, artistName.frame.size.height);	
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


- (void)dealloc {
	[self.trackName release];
	[self.artistName release];
    [super dealloc];
}



@end
