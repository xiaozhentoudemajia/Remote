//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

@protocol PairingServerDelegate

- (int) obtainPinCode;
- (int) obtainGUID;

@optional
- (void) pairedSuccessfully:(NSString *)serviceName;

@end


@interface MyHTTPConnection : HTTPConnection
{
	id<PairingServerDelegate> delegate;
}

@property (nonatomic, assign) id<PairingServerDelegate> delegate;



@end