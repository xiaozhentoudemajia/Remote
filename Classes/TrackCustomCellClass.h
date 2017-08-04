//
//  TrackCustomCellClass.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 17/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TrackCustomCellClass : UITableViewCell {
	IBOutlet UILabel *trackName;
	IBOutlet UILabel *artistName;
	IBOutlet UIImageView *sep2;
	IBOutlet UILabel *albumName;
	IBOutlet UIImageView *sep3;
	IBOutlet UILabel *trackLength;
	IBOutlet UIView *background;
	IBOutlet UIImageView *nowPlayingIndicator;
	BOOL nowPlaying;
}

@property (nonatomic, retain) UILabel *trackName;
@property (nonatomic, retain) UILabel *artistName;
@property (nonatomic, retain) UILabel *albumName;
@property (nonatomic, retain) UILabel *trackLength;
@property (nonatomic, retain) UIView *background;
@property (nonatomic) BOOL nowPlaying;

@end
