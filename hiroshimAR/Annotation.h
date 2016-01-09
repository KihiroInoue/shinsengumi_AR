//
//  Annotation.h
//  Nearby
//
//  Created by Yos Hashimoto.
//  Copyright 2009 Newton Japan Inc.. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	<MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	BOOL isMyAnnotation;
}

@end
