//
//  TwitterAccountDelegate.h
//  HiroshimARchive
//
//  Created by YoichiroHino on 11/09/25.
//  Copyright 2011 goga. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TwitterAccountDelegate <NSObject>
-(void)accountSucceeded;
-(void)accountCancelled;

@end
