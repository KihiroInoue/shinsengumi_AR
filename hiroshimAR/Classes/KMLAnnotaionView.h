//
//  KMLAnnotaionView.h
//  HiroshimARchive
//
//  Created by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface KMLAnnotaionView : MKAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
               imageName:(UIImage *)image;
@end

@interface ViewController : UIViewController <MKMapViewDelegate> {
    IBOutlet MKMapView *mapView;
}
@property (nonatomic, retain) MKTileOverlay *tile_overlay;
@end
