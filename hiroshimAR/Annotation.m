//
//  Annotation.m
//  Nearby
//
//  Created by Yos Hashimoto.
//  Copyright 2009 Newton Japan Inc.. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

@synthesize	coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord {
	coordinate = coord;
	isMyAnnotation = YES;
	return self;
}


@end
