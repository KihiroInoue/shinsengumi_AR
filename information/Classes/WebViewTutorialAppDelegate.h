//
//  WebViewTutorialAppDelegate.h
//  WebViewTutorial
//
//  Created by iPhone SDK Articles on 8/19/08.
//  Copyright www.iPhoneSDKArticles.com 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebViewTutorialViewController, InformationWebViewController;

@interface WebViewTutorialAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	InformationWebViewController *wvTutorial;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) InformationWebViewController *wvTutorial;

@end

