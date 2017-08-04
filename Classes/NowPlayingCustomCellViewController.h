//
//  NowPlayingCustomCellViewController.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 05/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NowPlayingCustomCellViewController : UITableViewCell {
	IBOutlet UILabel *trackNumber;
	IBOutlet UILabel *trackName;
	IBOutlet UILabel *artistName;
	IBOutlet UILabel *trackLength;
	IBOutlet UIImageView *nowPlaying;
}

@property (nonatomic, retain) UILabel *trackNumber;
@property (nonatomic, retain) UILabel *trackName;
@property (nonatomic, retain) UILabel *artistName;
@property (nonatomic, retain) UILabel *trackLength;
@property (nonatomic, retain) UIImageView *nowPlaying;

@end
