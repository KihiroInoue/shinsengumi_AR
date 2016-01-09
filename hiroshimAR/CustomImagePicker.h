//
//  CustomImagePicker.h
//  Nearby
//
//  Created by Yos Hashimoto
//  Copyright 2009 Newton Japan Inc.. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppData.h"
#import "Article.h"
#import "InfoTagView.h"
#import "KMLParser.h"
#import "KMLViewerViewController.h"

// マーカ配置

#define kARViewToolbarHight 55.0f
#define kARViewHeight 400.0f
#define kARViewInfoTagEstimateHeight 20.0f

@class KMLViewerViewController;
@interface CustomImagePicker : UIImagePickerController {
	AppData		*appData;
	NSTimer		*arTimer;
	BOOL		timerInAction;
  
}

@property (nonatomic, retain)	AppData		*appData;
@property (nonatomic, retain)	NSTimer		*arTimer;
@property (nonatomic)			BOOL		timerInAction;
@property (nonatomic, assign)   KMLViewerViewController* parent;

- (CGPoint)pointInViewForArtile:(Article *)article;

@end
