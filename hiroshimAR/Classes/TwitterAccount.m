//
//  TwitterAccount.m
//  Rosetta
//
//  Created by YoichiroHino on 11/06/24.
//  Copyright 2011 Yoichiro Hino. All rights reserved.
//

#import "TwitterAccount.h"
#import "TRUtil.h"

@implementation TwitterAccount

@synthesize userName = _userName;
@synthesize password = _password;

-(id)initWithUserName:(NSString*)userName password:(NSString*)password
{
    self = [super init];
    if( self) {
        self.userName = userName;
        self.password = password;
    }
    return self;
}

-(BOOL)isInput
{
    return TR_IS_PRESENT_STRING(self.userName) && TR_IS_PRESENT_STRING(self.password);
}

-(void)save:(NSUserDefaults*)defaults
{
    [defaults setObject:self.userName forKey:@"ApplicationTwitterAccountUserName"];
    [defaults setObject:self.password forKey:@"ApplicationTwitterAccountPassword"];
}

-(void)load:(NSUserDefaults*)defaults
{
	self.userName = [defaults valueForKey:@"ApplicationTwitterAccountUserName"];
    self.password = [defaults valueForKey:@"ApplicationTwitterAccountPassword"];
}

-(void)setUserName:(NSString*)userName password:(NSString*)password withSave:(BOOL)save{
    
    self.userName = userName;
    self.password = password;
    if( save) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [self save:defaults];
    }

}

-(void)dealloc
{
    self.userName = nil;
    self.password = nil;
    [super dealloc];
}

@end
