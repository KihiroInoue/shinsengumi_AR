//
//  WebViewTutorialAppDelegate.m
//  WebViewTutorial
//
//  Created by iPhone SDK Articles on 8/19/08.
//  Copyright www.iPhoneSDKArticles.com 2008. All rights reserved.
//

#import "WebViewTutorialAppDelegate.h"
#import "InformationWebViewController.h"

@implementation WebViewTutorialAppDelegate

@synthesize window, wvTutorial;

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	
	self.wvTutorial = [[InformationWebViewController alloc] initWithNibName:@"InformationWebView" bundle:[NSBundle mainBundle]];
	
	[window addSubview:[wvTutorial view]];
	
	// Override point for customization after app launch	
    [window makeKeyAndVisible];
}


- (void)dealloc {
	[wvTutorial release];
	[window release];
	[super dealloc];
}


@end
