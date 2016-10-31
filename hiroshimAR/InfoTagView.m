//
//  InfoTagView.m
//  Nearby
//
//  Created by Yos Hashimoto
//  Copyright 2009 Newton Japan Inc.. All rights reserved.
//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import "InfoTagView.h"
#import "CustomImagePicker.h"
#import "KMLViewerViewController.h"

@implementation InfoTagView

@synthesize	parentView, title, subtitle, faceImageName;
@synthesize	centerPoint, centerPointBeforeTouch, brownMoveX, brownMoveY, deltaX, deltaY;
@synthesize touchInProgress;
@synthesize webView;
@synthesize article;
@synthesize parent;


- (id)initWithFrame:(CGRect)frame
     withImageUrlString:(NSString *)imageUrlString
      withColor:(UIColor *)KMLColor {
  self = [super initWithFrame:frame];
  
  if (self) {
    CGFloat widthDiffX = 0;
    CGFloat widthDiffY = 0;
    
    if (imageUrlString == nil || imageUrlString.length <= 0) {
      self.frame  = CGRectMake(0, 0, 171, 36);
      self.center = CGPointMake(85, 18);
    } else {
      self.frame = CGRectMake(0, 0, 223, 50);
      widthDiffX = 51;
      widthDiffY = 7;

      NSURL *url = [NSURL URLWithString:imageUrlString];
      NSData *data = [NSData dataWithContentsOfURL:url];
      UIImage *image = [[UIImage alloc] initWithData:data];
      faceImage = [[UIImageView alloc] initWithImage:image];
      faceImage.frame = CGRectMake(1, 1, 48, 48);
      faceImage.layer.cornerRadius = 0;
      faceImage.clipsToBounds = YES;
      [self addSubview:faceImage];
      self.center = CGPointMake(111, 25);
    }
    
    if (KMLColor == nil) {
      infoTagImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"infotag"]];
      infoTagImage.frame = CGRectMake(0, 0, 171, 36);
    } else {
      infoTagImage =
        [[UIImageView alloc] initWithImage:
         [self drawBackGroundImage:CGRectMake(0, 0, 169, 34)
                     withColor:KMLColor]];
      widthDiffX++;
      widthDiffY++;
    }
    infoTagImage.frame = CGRectMake(widthDiffX, widthDiffY, 171, 36);
    [self addSubview:infoTagImage];

    self.alpha = 1.0;

		// インフォタグ内のラベルを生成
		CGRect  bounds, rect;
		bounds = self.bounds;
		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
		titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 9.0f / 14.0f;
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		rect.origin.x = 5 + widthDiffX;
		rect.origin.y = 4 + widthDiffY;
		rect.size.width = bounds.size.width - 13;
		rect.size.height = 16;
		titleLabel.frame = rect;
		[self addSubview:titleLabel];

		subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		subtitleLabel.font = [UIFont systemFontOfSize:12.0f];
		subtitleLabel.adjustsFontSizeToFitWidth = YES;
    subtitleLabel.minimumScaleFactor = 0.5f;
		subtitleLabel.textColor = [UIColor whiteColor];
		subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
		rect.origin.x = 5 + widthDiffX;
		rect.origin.y = 15 + widthDiffY;
		rect.size.width = bounds.size.width - 10;;
		rect.size.height = 16;
		subtitleLabel.frame = rect;
		[self addSubview:subtitleLabel];
    
		self.userInteractionEnabled = YES;

		// ブラウン運動の準備
		brownMoveX = 0;
		brownMoveY = 0;
		deltaX = 1;
		deltaY = 1;
		centerPoint.x = -1;
		centerPoint.y = -1;
		self.hidden = YES;

		[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerJob) userInfo:nil repeats:YES];

	}
    return self;
}

- (void)timerJob {

	// タッチされている間はブラウン運動を起こさない
	if(touchInProgress==YES) {
		return;
	}
	
	brownMoveY += deltaY;
	if(brownMoveY > 1) {
		deltaY = -1;
	}
	if(brownMoveY < -1) {
		deltaY = 1;
	}
	
	CGPoint	point = centerPoint;
	point.x += brownMoveX;
	point.y += brownMoveY;
	
	self.center = point;
	self.hidden = NO;
}

- (void)setAnchorPoint:(CGPoint)point boundaryRect:(CGRect)boundrect animate:(BOOL)flag {
	centerPoint = point;
}

- (NSString*)title {
	return titleLabel.text;
}

- (void)setTitle:(NSString*)tt {
	[titleLabel setText:tt];
}

- (NSString*)subtitle {
	return subtitleLabel.text;
}

- (void)setSubtitle:(NSString*)stt {
	[subtitleLabel setText:stt];
}

- (UIImage *)drawBackGroundImage:(CGRect)frame
                       withColor:(UIColor *)KMLColor {

  CGFloat red;
  CGFloat green;
  CGFloat blue;
  CGFloat alpha;
  [KMLColor getRed:&red green:&green blue:&blue alpha:&alpha];
  UIColor *darkColor = [UIColor colorWithRed:red+0.20f green:green+0.20f blue:blue+0.20f alpha:alpha];

  UIGraphicsBeginImageContext(CGSizeMake(169, 34));
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGRect rect = frame;
  CGFloat radius = 10;

  CGFloat lx = CGRectGetMinX(rect);
  CGFloat cx = CGRectGetMidX(rect);
  CGFloat rx = CGRectGetMaxX(rect);
  CGFloat by = CGRectGetMinY(rect);
  CGFloat cy = CGRectGetMidY(rect);
  CGFloat ty = CGRectGetMaxY(rect);

  CGContextSetFillColorWithColor(context, darkColor.CGColor);
  CGContextMoveToPoint(context, lx, cy);
  CGContextAddArcToPoint(context, lx, by, cx, by, radius);
  CGContextAddArcToPoint(context, rx, by, rx, cy, radius);
  CGContextAddLineToPoint(context, rx, cy);
  CGContextClosePath(context);
  CGContextDrawPath(context, kCGPathFill);

  CGContextSetFillColorWithColor(context, KMLColor.CGColor);
  CGContextMoveToPoint(context, rx, cy);
  CGContextAddArcToPoint(context, rx, ty, cx, ty, radius);
  CGContextAddArcToPoint(context, lx, ty, lx, cy, radius);
  CGContextAddLineToPoint(context, lx, cy);
  CGContextClosePath(context);
  CGContextDrawPath(context, kCGPathFill);

  return UIGraphicsGetImageFromCurrentImageContext();
}

#pragma mark -
#pragma mark Touch handling

// タッチ開始
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    self.touchInProgress = YES;
    
    //UITouch *touch = [touches anyObject];
    centerPointBeforeTouch = centerPoint;

    [self.parent dismissViewControllerAnimated:NO
                                    completion:nil];
  // TODO: clash!
    [self.parent.parent performSelector:@selector(loadKMLPlacemarkFromImagePicker:)
                             withObject:self.article.kmlPlacemark afterDelay:0];
}   
 


//{
//	touchInProgress = YES;
//	// インフォタグ（自分）を最前面に持ってくる
//	[[self superview] bringSubviewToFront:self];
//
//	UITouch *touch = [touches anyObject];
//	centerPointBeforeTouch = centerPoint;
//	// タッチされたViewをアニメーションで拡大表示する
//	[self animateFirstTouchAtPoint:[touch locationInView:parentView] forView:self];
//}


// タッチされた時に新しい窓を開く





// タッチしたまま移動
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{  
//	UITouch *touch = [touches anyObject];
//	self.center = [touch locationInView:parentView];
//}


// ボタンをタップして離した時
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    touchInProgress = NO;
      
}




//{
//	UITouch *touch = [touches anyObject];
//	// Viewをアニメーションで元の大きさに戻す
//	[self animateView:self toPosition:[touch locationInView:parentView]];
//	centerPoint = centerPointBeforeTouch;
//	touchInProgress = NO;
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	centerPoint = centerPointBeforeTouch;
//	touchInProgress = NO;
//}

#pragma mark -
#pragma mark Touch Animation

- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint forView:(UIImageView *)theView 
{
//	NSValue *touchPointValue = [[NSValue valueWithCGPoint:touchPoint] retain];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.15];
	CGAffineTransform transform = CGAffineTransformMakeScale(1.5, 1.5);
	theView.transform = transform;
	[UIView commitAnimations];
}

- (void)animateView:(UIImageView *)theView toPosition:(CGPoint) thePosition
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.15];
	theView.center = thePosition;
	theView.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];	
}


@end
