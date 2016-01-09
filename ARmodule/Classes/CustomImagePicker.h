//
//  CustomImagePicker.h
//  Nearby
//
//  Created by Yos Hashimoto
//  Copyright 2009 Newton Japan Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppData.h"
#import "Article.h"
#import "InfoTagView.h"

@interface CustomImagePicker : UIImagePickerController {
	AppData		*appData;
	NSTimer		*arTimer;
	BOOL		timerInAction;
}

@property (nonatomic, retain)	AppData		*appData;
@property (nonatomic, retain)	NSTimer		*arTimer;
@property (nonatomic)			BOOL		timerInAction;

- (CGPoint)pointInViewForArtile:(Article *)article;

@end
