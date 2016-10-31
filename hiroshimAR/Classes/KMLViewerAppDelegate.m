#import "KMLViewerAppDelegate.h"
#import "KMLViewerViewController.h"
#import "AppData.h"
#import "Article.h"
#import "Define.h"
#import <math.h>

@implementation KMLViewerAppDelegate

//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

@synthesize window;
@synthesize navigationController, appData;
@synthesize motionManager;


#pragma mark -
#pragma mark Application lifecycle

UIAccelerationValue rollingX, rollingY, rollingZ;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    LOG(@"KMLViewerAppDelegate - applicationDidFinishLaunching");
    
    // アプリケーションで扱うデータを管理するオブジェクトを生成
    appData = [[AppData alloc] init];
    
    // AR追加部分
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 0.05;
    if (motionManager.accelerometerAvailable) {
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMAccelerometerData *data,
                                                          NSError *error) {
                                                // TODO: not move..
                                                CMAcceleration acceleration = data.acceleration;
                                                rollingX = (acceleration.x * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
                                                rollingY = (acceleration.y * kFilteringFactor) + (rollingY * (1.0 - kFilteringFactor));
                                                rollingZ = (acceleration.z * kFilteringFactor) + (rollingZ * (1.0 - kFilteringFactor));
                                                
                                                double accY = -atan(rollingY /2);
                                                if(accY < ACCY_AT_HOLIZONTAL) accY = ACCY_AT_HOLIZONTAL;
                                                if(accY > ACCY_AT_HANDLING) accY = ACCY_AT_HANDLING;
                                                
                                                double k_y = Y_DISP_UPPER / (ACCY_AT_HANDLING-ACCY_AT_HOLIZONTAL);
                                                double deltaY  = (accY - ACCY_AT_HOLIZONTAL) * k_y;
                                                
                                                if(deltaY > Y_DISP_UPPER) deltaY = Y_DISP_UPPER;
                                                appData.mapBorderY = deltaY;
                                            }];
    }
    
    self.window.rootViewController = self.navigationController;
    
    [window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}

@end
