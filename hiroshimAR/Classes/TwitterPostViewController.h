//
//  TwitterPostViewController.h
//  Rosetta
//
//  Created by YoichiroHino on 11/06/23.
//  Copyright 2011 Yoichiro Hino. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//  現バージョンではこのビューは使われていません。
//  iOS標準のTwitterビューを利用しています（KMLViewerViewController.m参照）。

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TwitterPostViewController : UIViewController<UITextViewDelegate> {
    
    UITextView* _textView;
}

@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic) ACAccount *account;
@property (nonatomic) NSString *twitterPost;

- (id)init;

@end
