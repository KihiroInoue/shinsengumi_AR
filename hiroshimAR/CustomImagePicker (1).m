//
//  CustomImagePicker.m
//  Nearby
//
//  Created by Yos Hashimoto
//  Copyright 2009 Newton Japan Inc.. All rights reserved.
//

#import "Define.h"
#import "CustomImagePicker.h"
#import	"Article.h"
#import	"Annotation.h"

@interface CustomImagePicker()
- (BOOL)isViewportContainsArticle:(Article *)article;
-(void)timerJobAR ;
- (CGPoint)pointInViewForArtile:(Article *)article;
-(void)plotInfotag ;
- (void) dismissAllIntotag ;
@end

@implementation CustomImagePicker

@synthesize appData, arTimer, timerInAction;
@synthesize parent = _parent;
#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
    LOG(@"CustomImagePicker - viewDidLoad");
    
	// ツールバーとボタンの追加
	NSMutableArray *toolButtons = [NSMutableArray arrayWithCapacity:3];
	UIBarButtonItem *btn;

	btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolButtons addObject:btn];
	[btn release];

	btn = [[UIBarButtonItem alloc] initWithTitle:@"Map View" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPushed)];
	[toolButtons addObject:btn];
	
	btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolButtons addObject:btn];
	[btn release];
    
	
	const CGFloat kToolbarHeight = kARViewToolbarHight;
	CGRect rect = self.view.bounds;
	rect.origin.y = rect.size.height - kToolbarHeight;
	rect.size.height = kToolbarHeight;
	UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:rect]; 
	toolBar.items = toolButtons;
	toolBar.barStyle = UIBarStyleBlack;
	[self.view addSubview:toolBar];
	[toolBar release];
	
	// ARインフォタグ用タイマー
	arTimer =	[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerJobAR) userInfo:nil repeats:YES];
	timerInAction = YES;
}

- (void)viewDidUnload {
    LOG(@"CustomImagePicker - viewDidUnload");
	[arTimer invalidate];
	arTimer = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    LOG(@"CustomImagePicker - viewWillAppear");
}

- (void)viewDidDisappear:(BOOL)animated {
    LOG(@"CustomImagePicker - viewDidDisappear");
	[super viewDidDisappear:animated];
	timerInAction = NO;
	[self dismissAllIntotag];
}

-(void) viewDidAppear: (BOOL)animated {
    LOG(@"CustomImagePicker - viewDidAppear");
	[super viewDidAppear:animated];
	timerInAction = YES;
}

// 空間マップを閉じて前画面に戻る
-(void)backButtonPushed {
    LOG(@"CustomImagePicker - backButtonPushed");
//	[[self parentViewController] dismissModalViewControllerAnimated:NO];
	[self.parent dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Interval job

-(void)timerJobAR {
	if(timerInAction==NO) return;
    
	[self plotInfotag];
}

#pragma mark -
#pragma mark Infotag

// インフォタグの生成
- (InfoTagView*) showInfotagAt:(CGPoint) aPoint withTitle:(NSString*)title andSubtitle:(NSString*)subtitle
{

	InfoTagView *infotag = [[InfoTagView alloc] initWithFrame:CGRectZero];
	infotag.parentView = self.cameraOverlayView;
	// タイトルと位置を設定
	[infotag setTitle:title];
	[infotag setSubtitle:subtitle];
	[infotag setAnchorPoint:aPoint boundaryRect:CGRectMake(0.0f, 0.0f, 320.0f, 426.0f) animate:YES];
	[self.view addSubview:infotag];
	
	return infotag;
}

// 指定した記事のインフォタグを消す
- (void) dismissInfotagOfArticle:(Article*)article {
	if(article.infotag) {
		[article.infotag removeFromSuperview];
		[article.infotag release];
		article.infotag = nil;
	}
}

// すべての記事のインフォタグを消す
- (void) dismissAllIntotag {
	Article	*anArticle;
	for(int i=0; i < [appData.articles count]; i++) {
		anArticle = [appData.articles objectAtIndex:i];
		[self dismissInfotagOfArticle:anArticle];
	}
}

// インフォタグを空間にプロットする、または移動させる
-(void)plotInfotag {
    
    
	for(int i=0; i < [appData.articles count]; i++) {
        Article	*anArticle;

		anArticle = [appData.articles objectAtIndex:i];
		
		// 情報がiPhoneカメラのファインダー空間にあるかどうかをチェック
		if([self isViewportContainsArticle:anArticle]==YES) {
            
            if (anArticle.visible == YES) {
                CGPoint plotPoint = [self pointInViewForArtile:anArticle];
                // すでに空間に浮かんでいれば、位置を変更する
                if(anArticle.infotag) {
                    [anArticle.infotag setAnchorPoint:plotPoint boundaryRect:CGRectMake(0.0f, 0.0f, 320.0f, 426.0f) animate:NO];
                }
                // 表示されていない場合は、生成して空間に浮かべる
                else {
                    anArticle.infotag = [self showInfotagAt:plotPoint withTitle:anArticle.title andSubtitle:[NSString stringWithFormat:@"%d m", (int)anArticle.distance]];
                }
                anArticle.infotag.parent = self;
            }
		}
		// ファインダー空間から外れた場合は、消去する
		else {
			[self dismissInfotagOfArticle:anArticle];
		}
	}
}

#pragma mark -
#pragma mark AR things

// ２地点間の方位角
float CalculateAngle(float nLat1, float nLon1, float nLat2, float nLon2)
{
	float longitudinalDifference = nLon2 - nLon1;
    float latitudinalDifference = nLat2 - nLat1;
    float azimuth = (M_PI * .5f) - atan(latitudinalDifference / longitudinalDifference);
    if (longitudinalDifference > 0) return azimuth;
    else if (longitudinalDifference < 0) return azimuth + M_PI;
    else if (latitudinalDifference < 0) return M_PI;
    return 0.0f;
}

// 記事情報の空間へのプロット座標を計算する
- (CGPoint)pointInViewForArtile:(Article *)article
{	
	CGPoint point;

	// 現在地からターゲットまでの地図上での方位角（ラジアン）
	double pointAzimuth = CalculateAngle(appData.coordinate.latitude, appData.coordinate.longitude, [article.lat doubleValue], [article.lon doubleValue]);
	
	// 現在向いている方向（Heading）からビューポート半分を引いたものがビューポート左端の角度（クリッピングポイント）
	double centerAzimuth = appData.heading * (M_PI/180);
	double leftAzimuth = centerAzimuth - VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (leftAzimuth < 0.0) {
		leftAzimuth = 2 * M_PI + leftAzimuth;
	}

	if (pointAzimuth < leftAzimuth) {
		point.x = ((2 * M_PI - leftAzimuth + pointAzimuth) / VIEWPORT_WIDTH_RADIANS) * self.view.frame.size.width;
	} else {
		point.x = ((pointAzimuth - leftAzimuth) / VIEWPORT_WIDTH_RADIANS) * self.view.frame.size.width;
		
	}
	
	
    //point.y = appData.mapBorderY - (int)article.distance  / 30;
    
    
    point.y = appData.mapBorderY - article.screenOffset ;
	

    /*
    NSLog( @"point.y %f, mapBorder %d, ad %d, /30 = %d , min = %d, max = %d, val =%d",
          point.y, appData.mapBorderY, (int)article.distance, (int)article.distance /30,
          (int)self.appData.minDistance, (int)self.appData.maxDistance, 
          (int)((article.distance - self.appData.minDistance)/(self.appData.maxDistance - self.appData.minDistance) * 480));*/
    return point;
}

// 記事情報がカメラのファインダー空間にあるかどうかのチェック
- (BOOL)isViewportContainsArticle:(Article *)article
{
	CGRect rect = self.view.bounds;
	CGPoint point =	[self pointInViewForArtile:article];
	if(point.x < rect.origin.x)		return NO;
	if(point.x > rect.size.width)	return NO;
	if(point.y < rect.origin.y)		return NO;
	if(point.y > rect.size.height)	return NO;

	return YES;
}

#pragma mark -
#pragma mark Object lifecycle

-(void) dealloc {
    LOG(@"CustomImagePicker - dealloc");
	[super dealloc];
}

#pragma mark -

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}


@end
