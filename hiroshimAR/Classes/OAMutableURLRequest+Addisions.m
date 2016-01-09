//
//  OAMutableURLRequest+Addisions.h.m
//
//  Created by YoichiroHino on 11/06/23.
//  Copyright 2011 Yoichiro Hino. All rights reserved.
//

#import "OAMutableURLRequest+Addisions.h"

@implementation OAMutableURLRequest (DC)
- (NSString*)authorizationString {
	NSString *string = [self valueForHTTPHeaderField:@"Authorization"];
	if (!string) {
		[self prepare];
		string = [self valueForHTTPHeaderField:@"Authorization"];
	}
	return string;
}
@end
