//
//  TwitterAccountDataSourceProtocol.h
//  HiroshimARchive
//
//  Created by YoichiroHino on 11/09/25.
//  Copyright 2011 goga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterAccount.h"

@protocol TwitterAccountDataSource <NSObject>

@property(nonatomic, retain) TwitterAccount* twitterAccount;

@end
