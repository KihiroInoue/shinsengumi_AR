//
//  TwitterAccountView.m
//
//  Created by YoichiroHino on 11/06/24.
//  Copyright 2011 Yoichiro Hino. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//  現バージョンではこのビューは使われていません。
//  iOS標準のTwitterビューを利用しています（KMLViewerViewController.m参照）。

#import "TwitterAccountViewController.h"

@interface TwitterAccountViewController()

@property(nonatomic, retain) UITextField* usernameTextField;
@property(nonatomic, retain) UITextField* passwordTextField;

@end

@implementation TwitterAccountViewController

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

- (id)initWithDataSource:(id)dataSource
{
    return [self initWithDataSource:dataSource delegate:nil];
}

- (id)initWithDataSource:(id)dataSource delegate:(id)delegate
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.dataSource = dataSource;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 
- (void)viewDidUnload {
    self.usernameTextField = nil;
    self.passwordTextField = nil;

    [super viewDidUnload];
}

-(void)dealloc
{
    self.dataSource = nil;
    self.delegate = nil;
    self.usernameTextField = nil;
    self.passwordTextField = nil;
}
@end
