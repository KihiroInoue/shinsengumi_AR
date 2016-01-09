//
//  TwitterAccount.h
//  Rosetta
//
//  Created by YoichiroHino on 11/06/24.
//  Copyright 2011 Yoichiro Hino. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TwitterAccount : NSObject {
    NSString* _userName;
    NSString* _password;
}

-(BOOL)isInput;

-(void)save:(NSUserDefaults*)defaults;
-(void)load:(NSUserDefaults*)defaults;

@property(nonatomic,copy)NSString* userName;
@property(nonatomic,copy)NSString* password;

-(void)setUserName:(NSString*)userName password:(NSString*)password withSave:(BOOL)save;


@end

