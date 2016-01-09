    //
//  TwitterPostViewController.m
//  Rosetta
//
//  Created by YoichiroHino on 11/06/23.
//  Copyright 2011 Yoichiro Hino. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//  現バージョンではこのビューは使われていません。
//  iOS標準のTwitterビューを利用しています（KMLViewerViewController.m参照）。

#import "TwitterPostViewController.h"

#import "TwitterAccountViewController.h"
#import "AppData.h"

#define kTwitterPostNumOfCharacters 140


@interface TwitterPostViewController()
@property(nonatomic, retain) UITextView* textView;
@property(nonatomic, retain) TwitterAccountViewController* twitterAccountViewController;
@end

@implementation TwitterPostViewController

@synthesize textView = _textView;
@synthesize twitterAccountViewController = _twitterAccountViewController;

-(id)init {
    self = [super initWithNibName:nil bundle:nil];
  
  //Authentication
  
  if (self.accountStore == nil) {
    self.accountStore = [ACAccountStore new];
  }
  ACAccountType *accountType =
  [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  
  [self.accountStore requestAccessToAccountsWithType:accountType
                                             options:nil
                                          completion:^(BOOL granted, NSError *error) {
                                            if (!granted) {
                                              [self showAlertControllerWithTwitterAccounts:@"認証失敗" withMessage:@"Twitterの利用設定が有効になっていません。設定のTwitterから本アプリの設定を有効にしてください。"];
                                              return;
                                            }
                                            NSLog(@"Twitter granted");
                                            NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:accountType];
                                            if (!([twitterAccounts count] > 0)) {
                                              NSLog(@"Twitterアカウントが登録されていません");
                                              [self showAlertControllerWithTwitterAccounts:@"認証失敗。"
                                                                               withMessage:@"Twitterアカウントが登録されていません。設定のTwitterから登録してください。"];
                                              return;
                                            }
                                            
                                            self.account = [twitterAccounts lastObject];
                                            NSLog(@"%@", self.account.username);
                                          }];

    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Post to Twitter";
    UIBarButtonItem* rightItem = 
    [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self
                                    action:@selector(action:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem* leftItem = 
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(cancel:)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    
    CGRect frame = self.view.bounds;
    frame.size.height = 180;
    self.textView = [[UITextView alloc]initWithFrame:frame];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_textView];
    
    self.textView.text = self.twitterPost;
  
  
}

- (void)showAlertControllerWithTwitterAccounts:(NSString *)title
                                   withMessage:(NSString *)message {
  UIAlertController *alertContorller =
      [UIAlertController alertControllerWithTitle:title
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alertContorller addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
  [self presentViewController:alertContorller animated:YES completion:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
  
    self.textView = nil;
    self.twitterAccountViewController = nil;
}

-(BOOL)canPost {
//    return TR_IS_PRESENT_STRING(_textView.text) && _textView.text.length <= kTwitterPostNumOfCharacters;
  return self.textView.text.length <= kTwitterPostNumOfCharacters;
}

-(IBAction)textFieldDidChange:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = [self canPost];
}

-(void)post {
   NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
   NSDictionary *params = [NSDictionary dictionaryWithObject:@"SLRequest post test." forKey:@"status"];
  SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                          requestMethod:SLRequestMethodPOST
                                                    URL:url
                                             parameters:params];
  [request setAccount:self.account];
  [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
    NSLog(@"responseData=%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
  }];
}

-(IBAction)action:(id)sender {
  NSLog(@"post");
    [self post];
}

-(void)cancel:(NSObject*)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

@end
