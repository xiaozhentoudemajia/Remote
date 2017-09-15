//
//  DeviceList.h
//  AcaRemote
//
//  Created by ALI_MAC on 2017/9/15.
//
//

#import <UIKit/UIKit.h>

@interface DeviceList : UITableView

// tableView的坐标
@property (nonatomic, assign) CGRect        tableViewFrame;

// 存放Cell上各行textLabel值
@property (nonatomic, copy)NSMutableArray * textLabel_MArray;

// 存放Cell上各行imageView上图片
@property (nonatomic, copy)NSMutableArray * images_MArray;

// 存放Cell上各行detailLabel值
@property (nonatomic, copy)NSMutableArray * subtitle_MArray;

@end
