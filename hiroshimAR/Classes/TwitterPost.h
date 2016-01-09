//
//  TwitterPost.h
//  HiroshimARchive
//
//  Created by YoichiroHino on 11/09/25.
//  Copyright 2011 goga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TwitterAccountDataSource.h"
#import "TwitterAccount.h"

@interface TwitterPost : NSObject {
    id<TwitterAccountDataSource> _twitterAccountDataSource;
    NSString* _text;
    UIImage* _image;
    CLLocationCoordinate2D _coordinate;
}

@property(nonatomic,copy) NSString* text;
@property(nonatomic,retain) UIImage* image;
@property(nonatomic,assign) CLLocationCoordinate2D coordinate;
@property(nonatomic,retain) id<TwitterAccountDataSource> twitterAccountDataSource;

-(id)initWithTwitterAccountDataSource:(id<TwitterAccountDataSource>)twitterAccountDataSource text:(NSString*)text image:(UIImage*)image;

-(id)initWithTwitterAccountDataSource:(id<TwitterAccountDataSource>)twitterAccountDataSource text:(NSString*)text image:(UIImage*)image coordinate:(CLLocationCoordinate2D)coordinate;

@end
