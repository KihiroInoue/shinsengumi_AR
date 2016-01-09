//
//  AppData.h
//  Nearby
//
//  Created by Yos Hashimoto.
//  Copyright 2009 Newton Japan Inc.. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class	CustomImagePicker;	// AR追加部分
@class  KMLPlacemark;
@class  KMLParser;

typedef enum _ARInformationMode
{
    CURRENT_LOCATION, CURRENT_LOCATION_VIRTUAL_COORDINATE, GROUND_ZERO
} ARInformationMode;

@interface AppData : NSObject<CLLocationManagerDelegate> {

    CLLocationCoordinate2D	_currentCoordinate;
	CLLocationCoordinate2D	_coordinate;
	CLLocationDirection		_heading;	// 　　　方角
	CLLocationDirection		_course;		// 　　　進行方向
	CLLocationSpeed			_speed;		// 　　　進行速度
    
    
    //
	NSMutableArray*         _articles;
    NSMutableArray*         _kmlPlacemarkPoints;
    
	// AR追加部分
	CustomImagePicker*      _picker;
	int						_mapBorderY;		// マップの下端のY座標
    
    CLLocationManager*      _locationManager;    
	BOOL					_isLocationChanged;
    
    CLLocationCoordinate2D  _groundZeroCoordinate;
    MKCoordinateRegion      _groundZeroRegion;

    ARInformationMode       _arInformationMode;
}

@property (nonatomic)			CLLocationCoordinate2D	currentCoordinate;
@property (nonatomic)			CLLocationCoordinate2D	coordinate;
@property (nonatomic)			CLLocationDirection		heading;
@property (nonatomic)			CLLocationDirection		course;
@property (nonatomic)			CLLocationSpeed			speed;

@property (nonatomic, retain)	NSMutableArray*			articles;
@property (nonatomic, retain)   NSMutableArray*         kmlPlacemarkPoints;

// UIImage for mappin
//  Key: ID
//  Value: URL or Scale
@property (nonatomic, retain) NSMutableDictionary *imageMapPin;
@property (nonatomic, retain) NSMutableDictionary *scaleMapPin;

// AR追加部分
@property (nonatomic, retain)	CustomImagePicker		*picker;
@property (nonatomic)			int						mapBorderY;

// Location
@property (nonatomic, retain)	CLLocationManager	*locationManager;
@property (nonatomic)			BOOL	isLocationChanged;
@property (nonatomic)           CLLocationCoordinate2D groundZeroCoordinate;
@property (nonatomic)           MKCoordinateRegion     groundZeroRegion;

- (void)getAndParseInfomation ;
@property (nonatomic, assign) ARInformationMode arInformationMode;

@end
