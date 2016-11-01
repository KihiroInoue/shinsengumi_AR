//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import "WebViewController.h"
#import "Define.h"
#import "TRUtil.h"
#import "KMLParser.h"

@implementation WebViewController

@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Initialization code
	}
	return self;
}

- (id)init {
    if (self = [super init]){
        self.webView = [[UIWebView alloc]initWithFrame:CGRectZero];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.webView.scalesPageToFit = YES;
        //WebView透明化（未実装）
        //self.webView.opaque = NO;
        //self.webView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
        self.view = self.webView;
    }
    return self;
}

/*
 If you need to do additional setup after loading the view, override viewDidLoad. */
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    TR_NAVIGATION_CONTROLLER_SEUP_BACKBUTTON(self, @"Back");
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0f alpha:0.9f]};
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
    return YES;
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

-(void)loadKMLPlaceMark:(KMLPlacemark*)kmlPlacemark
{
    self.title = [kmlPlacemark name];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"detail" ofType:@"html"];
    NSError* error;
    NSString* htmlSeed = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    NSString* html = [NSString stringWithFormat:htmlSeed, [kmlPlacemark name], [kmlPlacemark name], [kmlPlacemark placemarkDescription]];
    
    [self.webView loadHTMLString:html baseURL:nil];

}

-(void)loadInformation
{
    self.title = @"東京五輪アーカイブ1964-2020";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://hiroshima.mapping.jp/"]];
    [self.webView loadRequest:request];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
