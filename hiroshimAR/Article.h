//
//  Article.h
//  Nearby
//
//  Created by Yos Hashimoto.
//  Copyright Newton Japan Inc. 2009. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoTagView.h"

@class KMLPlacemark;

@interface Article: NSObject {
	
	NSString *articleID;
	NSString *title;
	NSString *lat;
	NSString *lon;
	double distance;
  NSInteger screenOffset;
    
	NSMutableDictionary* propertyDic;
  KMLPlacemark*   kmlPlacemark;
}

@property (nonatomic, retain) NSString *articleID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *lat;
@property (nonatomic, retain) NSString *lon;
@property (nonatomic, assign) double distance;
@property (nonatomic, assign) NSInteger screenOffset;
@property (nonatomic, retain) NSMutableDictionary *propertyDic;
@property (nonatomic, assign) InfoTagView	*infotag;	// AR追加部分
@property (nonatomic, retain) KMLPlacemark* kmlPlacemark;
@property (nonatomic) BOOL visible;  //ARに表示するかどうか

-(NSMutableDictionary *) makePropertyDictionary;
-(NSString*) getPropertyNameFor:(NSString*)elementName;
-(NSComparisonResult)compareDistance:(Article *)article;

@end
