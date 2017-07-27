//
//  AppData.m
//  Nearby
//
//  Created by Yos Hashimoto.
//  Copyright 2009 Newton Japan Inc.. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import "AppData.h"
#import "Define.h"
#import "Article.h"
#import "KMLParser.h"
#import "KMLPlacemarkAnnotation.h"
#import "CustomImagePicker.h"

@implementation AppData

@synthesize currentCoordinate = _currentCoordinate;
@synthesize	coordinate = _coordinate;
@synthesize heading = _heading;
@synthesize course = _course;
@synthesize speed = _speed;

//@synthesize kml = _kml;
@synthesize articles = _articles;
@synthesize kmlPlacemarkPoints = _kmlPlacemarkPoints;

@synthesize imageMapPin = _imageMapPin;
@synthesize scaleMapPin = _scaleMapPin;

@synthesize locationManager = _locationManager;
@synthesize isLocationChanged = _isLocationChanged;
@synthesize groundZeroCoordinate = _groundZeroCoordinate;
@synthesize groundZeroRegion = _groundZeroRegion;

// AR追加部分
@synthesize picker = _picker;
@synthesize mapBorderY = _mapBorderY;
@synthesize arInformationMode = _arInformationMode;


-(AppData*)init {
    self = [super init];
    if (self) {
        self.picker = nil;	// AR追加部分
        self.isLocationChanged = NO;
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 5.0;
        self.locationManager.headingFilter = kCLHeadingFilterNone;
        self.locationManager.headingOrientation = CLDeviceOrientationPortrait;
        self.locationManager.activityType = CLActivityTypeFitness;
        self.groundZeroCoordinate = CLLocationCoordinate2DMake(GROUND_ZERO_LATITUDE, GROUND_ZERO_LONGITUDE);
        self.arInformationMode = GROUND_ZERO;
        
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
        
        // まだ許可されていない場合
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"位置情報が利用できません"
                                  message:@"位置情報サービスを有効にしてください"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    return self;
}

#pragma mark -
#pragma mark Sort Function

NSComparisonResult DistanceSortClosestFirst(Article *a1, Article *a2, void *ignore) {
    long d1 = (long long)a1.distance ;
    long d2 = (long long)a2.distance ;
    
    if (d1 < d2) {
        return NSOrderedAscending;
    } else if (d1 > d2) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

#pragma mark -
#pragma mark Information handling

- (void)getAndParseInfomation {
    LOG(@"KMLViewerAppDelegate - getAndParseInfomation");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    ///[Todo] KMLViewerViewController.m の viewDidLoadでKMLからarticlesを作成し、
    //ここでは距離の再計算だけを行う (緯度１度あたり111km、経度１度あたり91km)
    //(参考)http://lamp.blab7.net/archives/78
    
    double x, y, distance;
    double maxDistance = 0;
    double minDistance = (double)INT32_MAX;
    for (Article *anArticle in self.articles)
    {
        x = ([anArticle.lat doubleValue] - self.coordinate.latitude) /0.0111;
        y = ([anArticle.lon doubleValue] - self.coordinate.longitude)/0.0091;
        distance = round(sqrt(pow(x, 2) + pow(y, 2)) * 1000);
        anArticle.distance = distance ;
        if (distance <= NEAR_BY_DISTANCE) {
            anArticle.visible = YES;
            
            maxDistance = MAX(maxDistance, distance);
            minDistance = MIN(minDistance, distance);
            
        } else {
            anArticle.visible = NO;
        }
    }
    
    [self.articles sortUsingSelector:@selector(compareDistance:)];
    NSInteger step = 0;
    NSInteger articleIndex = 0;
    for( Article* article in self.articles) {
        
        //マーカ間隔を設定（最初の乗数）
        article.screenOffset = MARKER_INTERVAL * step * InfoTagEstimateHeight +  (arc4random() % 10);
        articleIndex ++ ;
        step ++ ;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)loadFromInformation:(ARInformationMode)mode
                   kmlName:(NSString*)kmlName
                  pinColor:(MKPinAnnotationColor)pinColor
              imageEnabled:(BOOL)imageEnabled
{
    // route のKMLファイルをゲットしてKMLPerserに渡す
    NSString *path = [[NSBundle mainBundle] pathForResource:kmlName ofType:@"kml"];
    KMLParser* kml = [KMLParser parseKMLAtPath:path] ;
    
    NSArray* kmlPlacemarkPoints = [kml kmlPlacemarkPoints];
    
    for( KMLPlacemarkAnnotation* annotation in kmlPlacemarkPoints) {
        
        if( mode == CURRENT_LOCATION_VIRTUAL_COORDINATE) {
            CLLocationCoordinate2D ac = annotation.coordinate;
            CLLocationCoordinate2D current = self.currentCoordinate;
            CLLocationCoordinate2D newAC
            = CLLocationCoordinate2DMake(ac.latitude - self.groundZeroCoordinate.latitude + current.latitude,
                                         ac.longitude - self.groundZeroCoordinate.longitude + current.longitude);
            annotation.coordinate = newAC;
        }
        if (imageEnabled) {
            annotation.imageEnabled = YES;
        } else {
            annotation.pinColor = pinColor;
            annotation.imageEnabled = NO;
        }
    }
    [self.kmlPlacemarkPoints addObjectsFromArray:kmlPlacemarkPoints];
    
    NSArray *keys = [kml.styleMaps allKeys];
    for (NSString *key in keys) {
        NSString *styleID = [kml.styleMaps objectForKey:key];
        KMLStyle *style = [kml.styles objectForKey:styleID];
        NSString *iconUrl = style.iconUrl;
        CGFloat scale = style.iconScale;
        
        if (![self.imageMapPin.allKeys containsObject:key]) {
            if (iconUrl != nil) {
                [self.imageMapPin setObject:iconUrl
                                     forKey:key];
            }
        }
        if (![self.scaleMapPin.allKeys containsObject:key]) {
            [self.scaleMapPin setObject:[NSNumber numberWithFloat:scale]
                                 forKey:key];
        }
    }
}

-(void)updateArticle:(ARInformationMode)mode
{
    self.kmlPlacemarkPoints = [NSMutableArray array];
    self.imageMapPin = [[NSMutableDictionary alloc] init];
    self.scaleMapPin = [[NSMutableDictionary alloc] init];
    
    //KMLファイル名を指定
    // ピン：デフォルトのピンを使う場合、imageEnabledをNOに、pinColorでカラーを指定
    //      カスタム画像のピンを使う場合、imageEnabledをYESに（pinColorは指定しなくて良い）
    
    // 言語判別
    NSArray  *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    // 日本語の場合は日本語KMLをロード
    if ([currentLanguage hasPrefix:@"ja"]) {
        [self loadFromInformation:mode
                          kmlName:@"shinsengumi"
                         pinColor:MKPinAnnotationColorGreen
                     imageEnabled:YES];
       
    } else {
    
    // 日本語以外の場合は英語KMLをロード
    [self loadFromInformation:mode
                      kmlName:@"shinsengumi"
                     pinColor:MKPinAnnotationColorGreen
                 imageEnabled:YES];
   
/*
    [self loadFromInformation:mode
                      kmlName:@"genshiun"
                     pinColor:MKPinAnnotationColorGreen
                 imageEnabled:YES];
*/
    }
    
    self.articles = [[NSMutableArray alloc] init];
    
    for ( KMLPlacemarkAnnotation* annotation in self.kmlPlacemarkPoints) {
        
        Article* article;
        article = [[Article alloc] init];
        article.lat = [NSString stringWithFormat:@"%f", annotation.coordinate.latitude];
        article.lon = [NSString stringWithFormat:@"%f", annotation.coordinate.longitude];
        article.title = annotation.title;
        article.distance = 0.0;
        article.visible = NO;
        article.kmlPlacemark = annotation.kmlPlacemark;
        [self.articles addObject:article];
    }
}

-(void)setArInformationMode:(ARInformationMode)arInformationMode
{
    _arInformationMode = arInformationMode;
    [self updateArticle:arInformationMode];
    
    switch(arInformationMode) {
        case GROUND_ZERO:
            self.coordinate = self.groundZeroCoordinate;
            break;
        case CURRENT_LOCATION:
        case CURRENT_LOCATION_VIRTUAL_COORDINATE:
            self.coordinate = self.currentCoordinate;
    }
    [self getAndParseInfomation];
}

#pragma mark -
#pragma mark CoreLocation delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // 位置情報取得パラメータ設定
        [manager startUpdatingLocation];
        [manager startUpdatingHeading];
    } else {
        // TODO: アラート表示: 位置情報を取得できません
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    LOG(@"KMLViewerAppDelegate - didUpdateToLocation");
    LOG(@"latitude = %f, longtitude = %f", [newLocation coordinate].latitude, [newLocation coordinate].longitude);
    
    
    // 緯度経度取得に成功した場合
    self.currentCoordinate = newLocation.coordinate;
    self.course = newLocation.course;
    self.speed = newLocation.speed;
    
    if(self.isLocationChanged == NO && self.arInformationMode == CURRENT_LOCATION) {
        self.coordinate = self.currentCoordinate;
        [self getAndParseInfomation];
        self.isLocationChanged = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    // 緯度経度取得に失敗した場合
    LOG(@"緯度経度取得に失敗");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.heading = newHeading.trueHeading;	// 北が0.0、東が90.0（倍精度浮動小数点）
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return YES;
}

@end
