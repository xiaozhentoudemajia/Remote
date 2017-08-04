//
//  DetailedTrackCustomCellClass.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 25/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailedTrackCustomCellClass : UITableViewCell {
	IBOutlet UILabel *trackNumber;
	IBOutlet UIImageView *sep1;
	IBOutlet UILabel *trackName;
	IBOutlet UIImageView *sep2;
	IBOutlet UILabel *trackLength;
	IBOutlet UIView *background;
	IBOutlet UIImageView *nowPlayingIndicator;
	
	BOOL nowPlaying;
}

@property (nonatomic, retain) UILabel *trackName;
@property (nonatomic, retain) UILabel *trackNumber;
@property (nonatomic, retain) UILabel *trackLength;
@property (nonatomic, retain) UIView *background;
@property (nonatomic) BOOL nowPlaying;

@end
