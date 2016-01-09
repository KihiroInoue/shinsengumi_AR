//
//  XAuthTwitterStatusPost.h
//  Rosetta
//
//  Created by YoichiroHino on 11/06/23.
//  Copyright 2011 Yoichiro Hino. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "XAuthTwitterEngineDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TwitterPost.h"

@protocol XAuthTwitterStatusPostDelegate
-(void)didXAuthTwitterPostSuccess;
-(void)didXAuthTwitterPostFailed:(NSError*)error;
-(void)didXAuthTwitterPostAccountFailed:(NSError*)error;
@end

@class XAuthTwitterEngine;

@interface XAuthTwitterStatusPost : NSObject  <XAuthTwitterEngineDelegate> {

    id       _delegate;
    XAuthTwitterEngine* _twitterEngine;
    ASIFormDataRequest* _request; 
    
    NSString* _username;
    NSString* _password;
    TwitterPost* _twitterPost;
}
@property (nonatomic, assign) id delegate;


- (void) setUserName:(NSString *)aUsername password:(NSString *)aPassword;
- (void) authorize:(NSTimeInterval)timeoutInterval;
- (void) postMessage:(TwitterPost*)twitterPost timeoutInterval:(NSTimeInterval)timeoutInterval;
 @end