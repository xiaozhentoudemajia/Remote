//
//  NowPlayingCustomCellViewController.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 05/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NowPlayingCustomCellViewController.h"


@implementation NowPlayingCustomCellViewController

@synthesize trackName;
@synthesize trackNumber;
@synthesize artistName;
@synthesize trackLength;
@synthesize nowPlaying;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[trackName release];
	[artistName release];
	[trackNumber release];
	[trackLength release];
	[nowPlaying release];
    [super dealloc];
}


@end
