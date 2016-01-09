//
//  KMLPlacemarkAnnotation.m
//  HiroshimARchive
//
//  Created by YoichiroHino on 11/10/04.
//  Copyright 2011 goga. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import "KMLPlacemarkAnnotation.h"
#import "KMLParser.h"


@implementation KMLPlacemarkAnnotation


@synthesize coordinate = _coordinate;
@synthesize kmlPlacemark = _kmlPlaceMark;
@synthesize pinColor = _pinColor;

-(id)initWithKMLPlacemark:(KMLPlacemark*)kmlPlaceMark coordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if(self) {
        self.coordinate = coordinate;
        self.kmlPlacemark = kmlPlaceMark;
    }
    return self;
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}
-(NSString*)title
{
    return [_kmlPlaceMark name];
}

-(NSString*)subtitle
{
    return nil;
}

@end
