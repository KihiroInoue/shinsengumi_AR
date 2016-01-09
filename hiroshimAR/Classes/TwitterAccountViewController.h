//
//  TwitterAccountView.h
//
//  Created by YoichiroHino on 11/06/24.
//  Copyright 2011 Yoichiro Hino. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//  現バージョンではこのビューは使われていません。
//  iOS標準のTwitterビューを利用しています（KMLViewerViewController.m参照）。

#import <UIKit/UIKit.h>

@class TwitterAccountViewController;


@interface TwitterAccountViewController :  UITableViewController <UITextFieldDelegate> {
    UITextField* _usernameTextField;
    UITextField* _passwordTextField;
}

- (id)initWithDataSource:(id)dataSource delegate:(id)delegate ;
- (id)initWithDataSource:(id)dataSource ;
@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) id dataSource;

@end
