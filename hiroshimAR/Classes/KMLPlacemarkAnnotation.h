//
//  KMLPlacemarkAnnotation.h
//  HiroshimARchive
//
//  Created by YoichiroHino on 11/10/04.
//  Copyright 2011 goga. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class KMLPlacemark;
@interface KMLPlacemarkAnnotation : NSObject<MKAnnotation> {

  CLLocationCoordinate2D _coordinate ;
  MKPinAnnotationColor _pinColor;
}

@property (nonatomic, retain) KMLPlacemark* kmlPlacemark;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;
@property (nonatomic, assign) BOOL imageEnabled;
- (id) initWithKMLPlacemark:(KMLPlacemark*)kmlPlaceMark
                 coordinate:(CLLocationCoordinate2D)coordinate;
- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate;
@end
