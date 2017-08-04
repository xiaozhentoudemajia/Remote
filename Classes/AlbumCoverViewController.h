//
//  AlbumCoverViewController.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 01/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlbumCoverViewController : UIViewController {
	IBOutlet UIImageView *image;
	IBOutlet UILabel *albumTitle;
}

@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, retain) UILabel *albumTitle;

@end
