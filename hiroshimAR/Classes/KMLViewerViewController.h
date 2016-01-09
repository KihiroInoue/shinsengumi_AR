//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "KMLParser.h"
#import "Article.h"
#import <UIImageView+WebCache.h>

@class KMLViewerAppDelegate, AppData;

@interface KMLViewerViewController : UIViewController <SDWebImageManagerDelegate> {
    MKMapView* _mapView;

    UIButton* _groundZeroButton;
    UIButton* _currentLocationButton;

    BOOL _onPicker;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, assign) KMLViewerAppDelegate* appDelegate;
@property (nonatomic, assign) AppData* appData;
@property (nonatomic, retain) IBOutlet UIButton* groundZeroButton;
@property (nonatomic, retain) IBOutlet UIButton* currentLocationButton;
@property (nonatomic, assign) BOOL onPicker;
@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic) ACAccount *account;


-(void)loadKMLPlacemarkFromImagePicker:(KMLPlacemark*)kmlPlacemark;
- (void)removeCameraViewWithAnimate;
- (void)removeCameraView;
-(IBAction)showDetails:(id)sender;
-(IBAction)configViewController:(id)sender;
-(IBAction)twitterViewController:(id)sender;
-(IBAction)informationViewController:(id)sender;
-(IBAction)ARViewController:(id)sender;
-(IBAction)moveToGroundZero:(id)sender;
-(IBAction)moveToCurrentLocation:(id)sender;

@end

