//
//  Article.m
//  Nearby
//
//  Created by Yos Hashimoto.
//  Copyright Newton Japan Inc. 2009. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <objc/objc.h>
#import <objc/runtime.h>
#import "Article.h"
#import "KMLParser.h"

#define kPrefix	@"im:"

@implementation Article

@synthesize articleID, title, lat, lon, distance, propertyDic;
@synthesize infotag, visible;
@synthesize kmlPlacemark;
@synthesize screenOffset;

#pragma mark -
#pragma mark Object lifecycle

// インスタンスを初期化する
-(id)init {
    self = [super init];
    if( self) {
        propertyDic = [[NSMutableDictionary alloc] initWithDictionary:[self makePropertyDictionary]];
	}
    return self;
}

#pragma mark -
#pragma mark Property handling

// クラスのプロパティ名称の一覧辞書を作成する
-(NSMutableDictionary *)makePropertyDictionary {     
	unsigned int outCount;
	
	objc_property_t *propList = class_copyPropertyList([self class], &outCount);
	NSMutableDictionary *properties = [[NSMutableDictionary alloc] initWithCapacity:outCount];
	
	int i;
	for (i=0; i < outCount; i++) {
		objc_property_t* aProp = propList + i;
    // Deprecated: initWithCString
		NSString *propName = [[NSString alloc] initWithCString:property_getName(*aProp)
                                                  encoding:NSUTF8StringEncoding];
		[properties setValue:propName forKey:propName];

	}

    free(propList);
	return properties;
}

// RSSのエレメントに対応するインスタンスプロパティ名を得る
-(NSString*)getPropertyNameFor:(NSString*)elementName {
	
	NSString* propName = [propertyDic objectForKey:elementName];
	return propName;
}

-(void)setInfotag:(InfoTagView *)newInfotag
{
    infotag = newInfotag;
    infotag.article = self;
    
}

- (NSComparisonResult)compareDistance:(Article *)article {
	if (self.distance < article.distance ){
		return NSOrderedAscending;
	} else if (self.distance > article.distance){
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

@end
