//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import "KMLViewerViewController.h"
#import "Define.h"
#import "KMLViewerAppDelegate.h"
#import "AppData.h"
#import	"CustomImagePicker.h"
#import "TwitterPostViewController.h"
#import "TwitterAccountViewController.h"
#import "KMLParser.h"
#import "KMLPlacemarkAnnotation.h"
#import "WebViewController.h"
#import <UIImageView+WebCache.h>
#import <MKAnnotationView+WebCache.h>

@implementation KMLViewerViewController;

@synthesize mapView = _mapView;
@synthesize groundZeroButton = _groundZeroButton;
@synthesize currentLocationButton = _currentLocationButton;
@synthesize appData = _appData;
@synthesize appDelegate = _appDelegate;
@synthesize onPicker = _onPicker;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self) {
        self.onPicker = false;
    }
    return self;
}

#pragma mark -
//メインページ（地図）で[ARモードで見る]ボタンを押した時の処理
-(void)loadARViewController:(BOOL)animated {
    // カメラ機能の有無をチェック
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        [self updateMap:CURRENT_LOCATION];
        
        LOG(@"KMLViewerViewController - ARViewController");
        if(self.appData.picker==nil) {
            self.appData.picker = [[CustomImagePicker alloc] init];
            //	appData.picker.delegate = self;
            LOG(@"KMLViewerViewController - alloc CustomeImagePicker");
        } else if (self.appData.picker != nil) {
            LOG(@"appData.picker != nil");
        }
        self.appData.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.appData.picker.showsCameraControls = NO;
        self.appData.picker.cameraOverlayView.userInteractionEnabled = NO;
        self.appData.picker.appData = self.appData;
        self.appData.picker.view.frame = CGRectMake(0,
                                                    [[UIScreen mainScreen] bounds].size.height,
                                                    self.appData.picker.view.frame.size.width,
                                                    self.appData.picker.view.frame.size.height);
        
        self.appData.picker.parent = self;
        
        [UIView animateWithDuration:0.3f animations:^{
            self.appData.picker.view.frame = CGRectMake(0,
                                                        0,
                                                        self.appData.picker.view.frame.size.width,
                                                        self.appData.picker.view.frame.size.height);
        }];
        
        [self.view addSubview:self.appData.picker.view];
        
        // カメラが使えない機種
    } else {
        if ([[UIDevice currentDevice].systemVersion intValue] >= 8.0) {
            UIAlertController *alertContorller =
            [UIAlertController alertControllerWithTitle:@"ARモードを利用できません"
                                                message:@"カメラが見つかりませんでした"
                                         preferredStyle:UIAlertControllerStyleAlert];
            [alertContorller addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:nil]];
            [self presentViewController:alertContorller animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"ARモードを利用できません"
                                  message:@"カメラが見つかりませんでした"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)removeCameraViewWithAnimate {
    
    [UIView beginAnimations:nil context:nil];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.appData.picker.view.frame = CGRectMake(0,
                                                    [[UIScreen mainScreen] bounds].size.height,
                                                    self.appData.picker.view.frame.size.width,
                                                    self.appData.picker.view.frame.size.height);
    }];
    //To animate, wait for 0.2f
    [self performSelector:@selector(removeCameraView)
               withObject:nil afterDelay:0.3f];
    
}

- (void)removeCameraView {
    [self.appData.picker.view removeFromSuperview];
}

-(void)ARViewController:(id)sender {
    [self loadARViewController:YES];
}

-(void)loadKMLPlacemarkFromImagePicker:(KMLPlacemark*)kmlPlacemark
{
    WebViewController *webViewController = [[WebViewController alloc] init];
    
    [self.navigationController pushViewController:webViewController animated:YES];
    [webViewController loadKMLPlaceMark:kmlPlacemark];
    self.onPicker = YES;
}

-(void)finishPicker
{
    
}

-(void)configViewController:(id)sender {
    UIViewController* vc = [[TwitterAccountViewController alloc]initWithDataSource:self.appData];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)twitterViewController:(id)sender {
    if (self.accountStore == nil) {
        self.accountStore = [ACAccountStore new];
    }
    ACAccountType *accountType =
    [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:nil
                                            completion:^(BOOL granted, NSError *error) {
                                                if (!granted) {
                                                    [self showAlertControllerWithTwitterAccounts:@"認証失敗"
                                                                                     withMessage:@"Twitterの設定が有効になっていません。設定のTwitterから本アプリの設定を許可に変更してください。"];
                                                    return;
                                                }
                                                NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:accountType];
                                                if (!([twitterAccounts count] > 0)) {
                                                    [self showAlertControllerWithTwitterAccounts:@"認証失敗"
                                                                                     withMessage:@"Twitterのアカウントが登録されていません。設定のTwitterからアカウントを登録してください。"];
                                                    return;
                                                }
                                                
                                                self.account = [twitterAccounts lastObject];
                                            }];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        NSString *serviceType = SLServiceTypeTwitter;
        SLComposeViewController *composeCtl =
        [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [composeCtl setInitialText:@" #hiroshima0806"];
        [composeCtl setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone) {
                
            } else if (result == SLComposeViewControllerResultCancelled) {
                
            }
        }];
        [self presentViewController:composeCtl animated:YES completion:nil];
    }
    
    
}

- (void)showAlertControllerWithTwitterAccounts:(NSString *)title
                                   withMessage:(NSString *)message {
    if ([[UIDevice currentDevice].systemVersion intValue] >= 8.0) {
        UIAlertController *alertContorller =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alertContorller addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertContorller animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"cancel"
                                                  otherButtonTitles:nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}


-(void)informationViewController:(id)sender {
    WebViewController* webViewController = [[WebViewController alloc]init];
    [self.navigationController pushViewController: webViewController animated:YES];
    [webViewController loadInformation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}


-(void)updateMap:(ARInformationMode)arInformationMode
{
    self.appData.arInformationMode = arInformationMode;
    MKMapCamera *newCamera = [[self.mapView camera] copy];
    if (arInformationMode == GROUND_ZERO) {
        self.mapView.showsUserLocation = NO;
        [newCamera setCenterCoordinate:self.appData.groundZeroCoordinate];
        [newCamera setPitch:GROUND_ZERO_CAMERA_PITCH];
        [newCamera setHeading:0];
        [newCamera setAltitude:GROUND_ZERO_CAMERA_ALTITUDE];
        [self.mapView setCamera:newCamera animated:YES];
        self.mapView.showsUserLocation = YES;
    } else if (arInformationMode == CURRENT_LOCATION){
        self.mapView.showsUserLocation = NO;
        [newCamera setCenterCoordinate:self.appData.currentCoordinate];
        [newCamera setPitch:CURRENT_LOCATION_CAMERA_PITCH];
        [newCamera setHeading:self.appData.heading];
        [newCamera setAltitude:CURRENT_LOCATION_CAMERA_ALTITUDE];
        [self.mapView setCamera:newCamera animated:YES];
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
        self.mapView.showsUserLocation = YES;
    }
    
    NSMutableArray *existingpoints = [NSMutableArray arrayWithArray:self.mapView.annotations];
    for(id<MKAnnotation> annotation in existingpoints) {
        if(annotation == self.mapView.userLocation) {
            [existingpoints removeObject:annotation];
        }
    }
    [self.mapView removeAnnotations:existingpoints];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    // アノテーションをマップに配置
    NSArray *annotations = [self.appData kmlPlacemarkPoints];
    [self.mapView addAnnotations:annotations];
}

//起動時の地図表示
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (KMLViewerAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appData = self.appDelegate.appData;
    self.mapView.mapType = MKMapTypeSatelliteFlyover;
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    // アノテーションのiボタンの色変更
    [[UIButton appearance] setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    // ズームインするまでのタイマー
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(zoom:)
                                   userInfo:nil
                                    repeats:NO
     ];
}

// タイマーで発火するズームイン
-(void)zoom:(NSTimer*)timer{
    [self updateMap:self.appData.arInformationMode];
}

// Maptype切り替え
static int mapTypeCount = 0;
- (IBAction) changeMapType:(id)sender {
    if (mapTypeCount == 0){
        self.mapView.mapType = MKMapTypeStandard;
        mapTypeCount++;
    } else if (mapTypeCount == 1){
        //地理院タイルをオーバレイ
        NSString *template = @"http://cyberjapandata.gsi.go.jp/xyz/ort_USA10/{z}/{x}/{y}.png";
        MKTileOverlay *tile_overlay = [[MKTileOverlay alloc] initWithURLTemplate:template];
        tile_overlay.minimumZ = 10;
        tile_overlay.maximumZ = 17;
        tile_overlay.canReplaceMapContent = YES;
        [self.mapView addOverlay:tile_overlay];
        mapTypeCount++;
    } else {
        self.mapView.mapType = MKMapTypeSatelliteFlyover;
        //すべてのオーバレイを削除
        for(id<MKOverlay> overlay in [_mapView overlays]) {
            [_mapView removeOverlay:overlay];
        }
        mapTypeCount = 0;
    }
}

-(MKTileOverlayRenderer *)mapView:(MKMapView*)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKTileOverlayRenderer *renderer = [[MKTileOverlayRenderer alloc] initWithOverlay:overlay];
    renderer.alpha = 1.0;
    return renderer;
}

#pragma mark MKMapViewDelegate

// Webviewに移動
- (IBAction)showDetails:(id)sender
{
    LOG(@"KMLViewerViewController - showDetalils");
}


-(IBAction)moveToGroundZero:(id)sender
{
    [self updateMap:GROUND_ZERO];
    
}
-(IBAction)moveToCurrentLocation:(id)sender
{
    [self updateMap:CURRENT_LOCATION];
}

// アラートのボタンが押された時に呼ばれるデリゲート例文
-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self updateMap:CURRENT_LOCATION_VIRTUAL_COORDINATE];
            break;
        case 1:
            [self updateMap:CURRENT_LOCATION];
            break;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation {
    if (annotation == mapView.userLocation) {
        return nil;
    }
    if ([annotation isKindOfClass:[KMLPlacemarkAnnotation class]] == NO) {
        return nil;
    }
    
    KMLPlacemarkAnnotation* kpa = (KMLPlacemarkAnnotation*)annotation;
    
    if (kpa.imageEnabled == NO) {
        return [self pinAnnotationView:mapView
                            Annotation:annotation
                             Placemark:kpa
                            Identifier:[NSString stringWithFormat:@"%lu", (unsigned long)kpa.pinColor]];
    } else {
        return [self annotationView:mapView
                         Annotation:annotation
                          Placemark:kpa
                         Identifier:kpa.kmlPlacemark.name];
    }
    
    return nil;
}

- (MKAnnotationView *)pinAnnotationView:(MKMapView *)mapView
                             Annotation:(id <MKAnnotation>)annotation
                              Placemark:(KMLPlacemarkAnnotation *)kpa
                             Identifier:(NSString *)kmlAnnotationIdentifier {
    MKPinAnnotationView* customPinView =
    (MKPinAnnotationView*)[mapView
                           dequeueReusableAnnotationViewWithIdentifier:kmlAnnotationIdentifier];
    
    if(customPinView == nil) {// ピンのカスタム
        customPinView = [[MKPinAnnotationView alloc]
                         initWithAnnotation:annotation
                         reuseIdentifier:kmlAnnotationIdentifier];
        
        customPinView.animatesDrop = NO;
        customPinView.canShowCallout = YES;
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self
                        action:@selector(showDetails:)
              forControlEvents:UIControlEventTouchUpInside];
        
        customPinView.rightCalloutAccessoryView = rightButton;
        
    }
    else {
        [customPinView setAnnotation:annotation];
    }
    
    customPinView.pinColor = kpa.pinColor;
    return customPinView;
}

- (MKAnnotationView *)annotationView:(MKMapView *)mapView
                          Annotation:(id <MKAnnotation>)annotation
                           Placemark:(KMLPlacemarkAnnotation *)kpa
                          Identifier:(NSString *)kmlAnnotationIdentifier {
    KMLAnnotaionView *customPinView
    = (KMLAnnotaionView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kmlAnnotationIdentifier];
    
    if (kpa.kmlPlacemark.styleUrl != nil &&
        [self.appData.imageMapPin.allKeys containsObject:kpa.kmlPlacemark.styleUrl]) {
        
        NSString *url = [self.appData.imageMapPin objectForKey:kpa.kmlPlacemark.styleUrl];
        NSURL *urlConverted = [NSURL URLWithString:url];
        
        if (customPinView == nil) {// ピンのカスタム
            customPinView = [[KMLAnnotaionView alloc] initWithAnnotation:annotation reuseIdentifier:kmlAnnotationIdentifier];
            
            customPinView.canShowCallout = YES;
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            
            customPinView.rightCalloutAccessoryView = rightButton;
            UIImage *defaultImage = [UIImage imageNamed:@"mappin2"];
            
            // 画像を非同期に読み込み、キャッシュする
            [customPinView sd_setImageWithURL:urlConverted
                             placeholderImage:nil
                                      options:0
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                        // 画像のリサイズ
                                        
                                        NSNumber *num = [self.appData.scaleMapPin objectForKey:kpa.kmlPlacemark.styleUrl];
                                        if(image == nil) {
                                            image = defaultImage;
                                        }
                                        CGFloat scale = num.floatValue;
                                        CGSize size = CGSizeMake(image.size.width*scale, image.size.height*scale);
                                        UIGraphicsBeginImageContext(size);
                                        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
                                        image = UIGraphicsGetImageFromCurrentImageContext();
                                        UIGraphicsEndImageContext();
                                        
                                        // リサイズ後の画像と入れ替え
                                        customPinView.image = image;
                                    }];
            return customPinView;
        } else {
            [customPinView setAnnotation:annotation];
        }
        
    } else {
        // デフォルトの画像を設定する
        UIImage *defaultImage = [UIImage imageNamed:@"mappin2"];
        
        if (customPinView == nil) {// ピンのカスタム
            customPinView = [[KMLAnnotaionView alloc] initWithAnnotation:annotation
                                                         reuseIdentifier:kmlAnnotationIdentifier
                                                               imageName:defaultImage];
            customPinView.canShowCallout = YES;
            
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            
            customPinView.rightCalloutAccessoryView = rightButton;
        } else {
            [customPinView setAnnotation:annotation];
        }
    }
    return customPinView;
}

// ピンのコールアウト設定
// note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:self
                    action:@selector(showDetails:)
          forControlEvents:UIControlEventTouchUpInside];
    
    // 画面定義：initWithNibNameは実際に存在するxibファイル名を入れる事！
    WebViewController *webViewController = [[WebViewController alloc] init];
    
    id <MKAnnotation> annotation = view.annotation;
    KMLPlacemarkAnnotation* kmlAnnotaion = (KMLPlacemarkAnnotation*)annotation;
    KMLPlacemark* kmlPlacemark = kmlAnnotaion.kmlPlacemark;
    [self.navigationController pushViewController: webViewController animated:YES];
    [webViewController loadKMLPlaceMark:kmlPlacemark];
}

- (void)viewDidUnload {
    LOG(@"KMLViewerViewController - viewDidUnload");
    self.mapView = nil;
    self.appDelegate = nil;
    self.appData = nil;
    
    [super viewDidUnload];
}
@end
