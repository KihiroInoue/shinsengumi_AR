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
    self.title = @"information";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"information" ofType:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];        
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
