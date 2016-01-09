//
//  TwitterPost.m
//  HiroshimARchive
//
//  Created by YoichiroHino on 11/09/25.
//  Copyright 2011 goga. All rights reserved.
//

#import "TwitterPost.h"
#import "TRUtil.h"

@implementation TwitterPost

@synthesize text = _text;
@synthesize image = _image;
@synthesize twitterAccountDataSource = _twitterAccountDataSource;
@synthesize coordinate = _coordinate;

-(id)initWithTwitterAccountDataSource:(id<TwitterAccountDataSource>)twitterAccountDataSource text:(NSString*)text image:(UIImage*)image
{
    return [self initWithTwitterAccountDataSource:twitterAccountDataSource text:text image:image coordinate:CLLocationCoordinate2DInvalid()];

}

-(id)initWithTwitterAccountDataSource:(id<TwitterAccountDataSource>)twitterAccountDataSource text:(NSString*)text image:(UIImage*)image coordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if( self) {
        self.twitterAccountDataSource = twitterAccountDataSource;
        self.text = text;
        self.image = image;
        self.coordinate = coordinate;
    }
    return self;
}



-(void)dealloc
{
    self.twitterAccountDataSource = nil;
    self.text = nil;
    self.image = nil;
    [super dealloc];
}

@end
