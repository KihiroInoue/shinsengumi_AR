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
    self.title = @"Twitter Account";
    
    UIBarButtonItem* rightItem = 
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(done:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    rightItem.enabled = NO;
    
    UIBarButtonItem* leftItem = 
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(cancel:)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
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

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 2;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    switch (section) {
//        case (0):
//            return 2;
//            break;
//        case 1:
//            return 0;
//    }
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        
//        CGRect textFieldFrame = 
//        TR_IS_iPAD() ? CGRectMake( 150, 12, 240, 30) : CGRectMake( 120, 12, 160, 30);
//        
//        switch ([indexPath indexAtPosition:0]) {
//            case (0):
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                              reuseIdentifier:CellIdentifier];
//                cell.frame = CGRectZero;
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                switch ([indexPath indexAtPosition:1]) {
//                    case (0):
//                        self.usernameTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
//                        [cell addSubview:_usernameTextField];
//                        [self.usernameTextField setEnabled:YES];
//                        self.usernameTextField.returnKeyType = UIReturnKeyNext;
//                        self.usernameTextField.delegate = self;
//                        self.usernameTextField.text = [self.dataSource twitterAccount].userName;                        
//                        self.usernameTextField.enablesReturnKeyAutomatically = YES;
//                        cell.textLabel.text = @"User ID";
//                        [self.usernameTextField addTarget:self
//                                                   action:@selector(textFieldDidChange:)
//                                         forControlEvents:UIControlEventEditingChanged];
//                        [self.usernameTextField becomeFirstResponder];
//                        
//                        break;
//                    case (1):
//                        self.passwordTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
//                        [cell addSubview:_passwordTextField];
//                        [self.passwordTextField setEnabled:YES];
//                        self.passwordTextField.delegate = self;
//                        
//                        [self.passwordTextField setSecureTextEntry:YES];
//                        self.passwordTextField.enablesReturnKeyAutomatically = YES;
//                        self.passwordTextField.returnKeyType = UIReturnKeyDone;
//                        [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//                        
//                        cell.textLabel.text = @"Password";
//                        break;
//                }
//                break;
//        }
//    }
//    return cell;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    switch(section) {
//        case 1: 
//            return @"Input User ID and Password of Twitter";
//            break;
//    }
//    return nil; 
//}
//
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
//{
//    switch( indexPath.section) {
//        case 1:
//            cell.backgroundColor = [UIColor clearColor];
//            
//    }
//    
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (textField == self.usernameTextField) {
//        [self.usernameTextField resignFirstResponder];
//        [self.passwordTextField becomeFirstResponder];
//    }
//    else if(textField == self.passwordTextField) {
//        [self activate];
//    }
//    return YES;
//}
//
//-(void)startConnection
//{
//    if( self.maskedView == nil) {
//        self.maskedView = [[MaskedActivityIndicatorView alloc]initWithFrame:self.view.bounds];
//        self.maskedView.textLabel.text = @"認証中...";
//    }
//    self.navigationItem.rightBarButtonItem.enabled = NO;
//    self.navigationItem.leftBarButtonItem.enabled = NO;
//    [self.view insertSubview:_maskedView atIndex:self.view.subviews.count - 1];
//    [self.maskedView startAnimating];
//    
//}
//
//-(void)endConnection
//{
//    [self.maskedView stopAnimating];
//    [self.maskedView removeFromSuperview];
//    self.navigationItem.rightBarButtonItem.enabled = NO;
//    self.navigationItem.leftBarButtonItem.enabled = TR_IS_PRESENT_STRING(self.usernameTextField.text) && TR_IS_PRESENT_STRING(self.passwordTextField.text);
//}
//
//-(void)activate
//{
//    if( TR_IS_PRESENT_STRING(_usernameTextField.text) && TR_IS_PRESENT_STRING(_passwordTextField.text)) {
//        
//        [self startConnection];
//        self.twitterEngine = [[XAuthTwitterStatusPost alloc]init];
//        self.twitterEngine.delegate = self;
//        [self.twitterEngine setUserName:self.usernameTextField.text password:self.passwordTextField.text];
//        
//        [self.twitterEngine authorize:0.0];
//    }
//}
//
//
//
//-(void)didXAuthTwitterPostSuccess
//{
//    [self endConnection];
//    
//    [[self.dataSource twitterAccount] setUserName:self.usernameTextField.text password:self.passwordTextField.text withSave:YES];
//    
//    if( self.delegate) {
//        [self.delegate performSelector:@selector(accountSucceeded) withObject:nil afterDelay:0.1];
//    }
//    else {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    
//}
//-(void)didXAuthTwitterPostAccountFailed:(NSError*)error
//{
//    [self endConnection];
//    TR_ALERT(@"Twitter認証", @"認証に失敗しました。ユーザー名とパスワードを確認してください。", self);
//}
//-(void)didXAuthTwitterPostFailed:(NSError*)error
//{
//    [self endConnection];
//    TR_ALERT(@"Twitter認証", @"認証に失敗しました。ユーザー名とパスワードを確認してください。", self);
//}
//
//-(IBAction)textFieldDidChange:(id)sender
//{
//    self.navigationItem.rightBarButtonItem.enabled = TR_IS_PRESENT_STRING(self.usernameTextField.text) && TR_IS_PRESENT_STRING(self.passwordTextField.text);
//}
//
//-(void)done:(NSObject*)sender
//{
//    [self activate];
//}
//
//-(void)cancel:(NSObject*)sender
//{
//    if( self.delegate) {
////        [self.delegate performSelector:@selector(accountCancelled) withObject:nil afterDelay:0.1];
//    }
//    else {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//
//        
//}

@end
