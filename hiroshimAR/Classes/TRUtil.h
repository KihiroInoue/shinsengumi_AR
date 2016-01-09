//
//  YHUtil.h
//  HiroshimARchive
//
//  Created by YoichiroHino on 11/09/25.
//  Copyright 2011 goga. All rights reserved.
//

#import "TTDebug.h"
#import <MapKit/MapKit.h>

//便利関数
UIKIT_STATIC_INLINE BOOL TR_IS_PRESENT(NSObject* value)
{
	return value && (NSNull*)value != [NSNull null] ;
}

UIKIT_STATIC_INLINE BOOL TR_IS_PRESENT_ARRAY( NSArray* value)
{
	return TR_IS_PRESENT(value) && [value count] > 0;
}


UIKIT_STATIC_INLINE BOOL TR_IS_PRESENT_STRING( NSString* value)
{
	return TR_IS_PRESENT(value) && [@"" isEqualToString:value] == FALSE;
}	

UIKIT_STATIC_INLINE void TR_ALERT(NSString* title, NSString* message, id delegate)
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message
												   delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
}

UIKIT_STATIC_INLINE void TR_ALERT_ERROR(NSError* error, id delegate)
{
	NSString* message = [[NSString alloc]initWithFormat:@"Error(%ld)", (long)[error code]] ;
	TR_ALERT( message, [error localizedDescription], delegate);
}

UIKIT_STATIC_INLINE void TR_NAVIGATION_CONTROLLER_SEUP_BACKBUTTON(UIViewController* viewConrtoller, NSString* title)
{
    viewConrtoller.navigationController.navigationBarHidden = NO;
    
    
    if( title != nil && [viewConrtoller.navigationController.viewControllers count] >= 2) {
        UIViewController* controller = [viewConrtoller.navigationController.viewControllers objectAtIndex:viewConrtoller.navigationController.viewControllers.count - 2];
        //戻るボタンは遷移前のViewControllerに対して設定する必要がある
        controller.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    
}

UIKIT_STATIC_INLINE CLLocationCoordinate2D CLLocationCoordinate2DInvalid()
{
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = DBL_MAX;
	coordinate.longitude = DBL_MAX;
	return coordinate;
}
UIKIT_STATIC_INLINE BOOL CLLocationCoordinate2DIsInvalid(CLLocationCoordinate2D coordinate)
{
  //Update: semantic issue && and ||
	return (coordinate.latitude == DBL_MAX && coordinate.longitude == DBL_MAX) ||
    (coordinate.latitude == 0.0 && coordinate.longitude == 0.0);
}


UIKIT_STATIC_INLINE BOOL TR_IS_iPAD()
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return TRUE;
    }else {
        return FALSE;
    }
}

