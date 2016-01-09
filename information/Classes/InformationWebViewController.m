//
//  WebViewController.m
//  WebViewTutorial
//
//  Created by iPhone SDK Articles on 8/19/08.
//  Copyright 2008 www.iPhoneSDKArticles.com. All rights reserved.
//

#import "InformationWebViewController.h"


@implementation InformationWebViewController

@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

/*
 If you need to do additional setup after loading the view, override viewDidLoad. */

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if(navigationType ==  UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
	else 
		return YES;
}

- (void)viewDidLoad {

    NSString* a_path = [[NSBundle mainBundle] pathForResource:@"information" ofType:@"html"];

    //Create a URL object
    NSURL* a_url = [NSURL fileURLWithPath:a_path];
   
    //URL Requst Object
    [webView loadRequest:[NSURLRequest requestWithURL:a_url]];

    
	//NSString *urlAddress = @"http://rinkaisenjutsu.sakura.ne.jp/goga_sample/information/information.html";
	
	
    // ステータスバー消す
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
	//Load the request in the UIWebView.

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[webView release];
	[super dealloc];
}


@end
