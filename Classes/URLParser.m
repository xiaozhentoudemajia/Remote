//
//  URLParser.m
//  NSScannerTest
//
//  Created by Dimitris on 09/02/2010.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "URLParser.h"


@implementation URLParser
@synthesize variables;

- (id) initWithURLString:(NSString *)url{
	self = [super init];
	if (self != nil) {
		NSString *string = url;
		NSScanner *scanner = [NSScanner scannerWithString:string];
		[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
		NSString *tempString;
		NSMutableArray *vars = [NSMutableArray new];
		[scanner scanUpToString:@"?" intoString:nil];		//ignore the beginning of the string and skip to the vars
		while ([scanner scanUpToString:@"&" intoString:&tempString]) {
			NSString *val = [tempString copy];
			[vars addObject:val];
			[val release];
		}
		self.variables = vars;
		[vars release];
	}
	return self;
}

- (NSString *)valueForVariable:(NSString *)varName {
	for (NSString *var in self.variables) {
		if ([var length] > [varName length]+1 && [[var substringWithRange:NSMakeRange(0, [varName length]+1)] isEqualToString:[varName stringByAppendingString:@"="]]) {
			NSString *varValue = [var substringFromIndex:[varName length]+1];
			return varValue;
		}
	}
	return nil;
}

- (void) dealloc{
	self.variables = nil;
	[super dealloc];
}

@end