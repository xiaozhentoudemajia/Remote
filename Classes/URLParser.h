//
//  URLParser.h
//  NSScannerTest
//
//  Created by Dimitris on 09/02/2010.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLParser : NSObject {
	NSArray *variables;
}

@property (nonatomic, retain) NSArray *variables;

- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;

@end