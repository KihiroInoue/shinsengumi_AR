//
//  KMLAnnotaionView.m
//  HiroshimARchive
//
//  Created by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import "KMLAnnotaionView.h"

@implementation KMLAnnotaionView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
               imageName:(UIImage *)image {
  self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
  self.image = image;
  return self;
}

@end