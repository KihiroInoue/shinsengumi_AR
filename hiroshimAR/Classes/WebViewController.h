//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMLPlacemark;

@interface WebViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, retain) UIWebView *webView;
-(void)loadKMLPlaceMark:(KMLPlacemark*)kmlPlacemark;
-(void)loadInformation;
@end
