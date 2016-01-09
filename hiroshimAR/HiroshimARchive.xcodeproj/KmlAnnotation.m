//
//  KmlAnnotation.m
//  HiroshimARchive
//
//  Created by Yuichi Abe on 7/6/11.
//  Copyright 2011 goga. All rights reserved.
//

#import "KmlAnnotation.h"

@implementation KmlAnnotation

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = 37.810000;
    theCoordinate.longitude = -122.477989;
    return theCoordinate; 
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
//- (NSString *)title
//{
//    return @"Golden Gate Bridge";
//}
//
//// optional
//- (NSString *)subtitle
//{
//    return @"Opened: May 27, 1937";
//}

//- (void)dealloc
//{
//    [super dealloc];
//}

@end
