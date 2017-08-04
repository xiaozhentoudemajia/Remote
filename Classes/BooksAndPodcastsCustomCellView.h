//
//  BooksAndPodcastsCustomCellView.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 06/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BooksAndPodcastsCustomCellView : UITableViewCell {
	IBOutlet UILabel *trackName;
	IBOutlet UIImageView *sep;
	IBOutlet UILabel *artistName;
	IBOutlet UIView *background;
	IBOutlet UIImageView *imageView;
}

@property (nonatomic, retain) UILabel *trackName;
@property (nonatomic, retain) UILabel *artistName;
@property (nonatomic, retain) UIView *background;
@property (nonatomic, retain) UIImageView *imageView;

@end
