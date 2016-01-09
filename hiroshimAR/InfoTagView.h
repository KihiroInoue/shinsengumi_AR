//
//  InfoTagView.h
//  Nearby
//
//  Created by Yos Hashimoto
//  Copyright 2009 Newton Japan Inc.. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@class Article;
@class CustomImagePicker;

@interface InfoTagView : UIView {
  
	UIView			*parentView;
	
  UIImageView *infoTagImage;
  UIImageView *faceImage;
	NSString		*title;
	NSString		*subtitle;
	UILabel			*titleLabel;
	UILabel			*subtitleLabel;

	CGPoint			centerPoint;
	CGPoint			centerPointBeforeTouch;
	int				brownMoveX;
	int				brownMoveY;
	int				deltaX;
	int				deltaY;
	BOOL			touchInProgress;
}

@property (nonatomic, assign)   Article     *article;
@property (nonatomic, assign)   CustomImagePicker *parent;
@property (nonatomic, retain)	UIView		*parentView;
@property (nonatomic, retain)   UIWebView   *webView;
@property (nonatomic, retain)	NSString	*title;
@property (nonatomic, retain)	NSString	*subtitle;
@property (nonatomic, retain) NSString *faceImageName;
@property (nonatomic)			CGPoint		centerPoint;
@property (nonatomic)			CGPoint		centerPointBeforeTouch;
@property (nonatomic)			int			brownMoveX;
@property (nonatomic)			int			brownMoveY;
@property (nonatomic)			int			deltaX;
@property (nonatomic)			int			deltaY;
@property (nonatomic)			BOOL		touchInProgress;

// initWithFrame:, withImageUrlString:
//    インフォタグの左に写真を追加する場合、imageUrlStringに画像のURLを指定して呼び出す
//    写真を追加しない場合は、initWithFrame:を呼び出す
- (id)initWithFrame:(CGRect)frame
 withImageUrlString:(NSString *)imageUrlString
          withColor:(UIColor *)KMLColor;
- (void)setAnchorPoint:(CGPoint)fp8 boundaryRect:(CGRect)fp16 animate:(BOOL)fp32;
- (NSString*)title;
- (void)setTitle:(NSString*)tt;
- (NSString*)subtitle;
- (void)setSubtitle:(NSString*)stt;

@end
