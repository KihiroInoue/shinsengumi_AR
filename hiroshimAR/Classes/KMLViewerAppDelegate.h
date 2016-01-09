//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
@class AppData;

@interface KMLViewerAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
  UIWindow *window;
  UINavigationController *navigationController;
	AppData	*appData;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain)	AppData	*appData;
@property (nonatomic) CMMotionManager *motionManager;


@end

