//
//  DeviceList.m
//  AcaRemote
//
//  Created by ALI_MAC on 2017/9/15.
//
//

#import "DeviceList.h"

@interface DeviceList()

@end

@implementation DeviceList

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        NSLog(@"self=%@", self);
        //self.delegate   = self;
        //self.dataSource = self;
    }
    return self;
}

@end
