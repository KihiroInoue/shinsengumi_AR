//
//  MaskedActivityIndicatorView.m
//  Rosetta
//
//  Created by Yoichiro Hino on 10/06/27.
//  Copyright 2011 Yoichiro Hino. All rights reserved.
//

#import "MaskedActivityIndicatorView.h"
#import "TRUtil.h"


@interface MaskedActivityIndicatorView ()
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicatorView;
@end

@implementation MaskedActivityIndicatorView


@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize textLabel = _textLabel;

- (void)commonInit
{
	UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicatorView.hidesWhenStopped = YES;
	
	self.activityIndicatorView = [activityIndicatorView autorelease];		
	
	[self addSubview:self.activityIndicatorView];
	
    self.alpha = 0.70f;
	self.backgroundColor = [UIColor blackColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
    
    self.textLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0,300,40)] autorelease];
    self.textLabel.textAlignment = UITextAlignmentCenter;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor whiteColor];
    
    [self addSubview:self.textLabel];
    [activityIndicatorView release];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    CGPoint point = CGPointMake( self.center.x, self.center.y - 50 );
	self.activityIndicatorView.center = point;
    self.textLabel.center = CGPointMake( point.x, point.y + (CGRectGetHeight(self.activityIndicatorView.frame) + CGRectGetHeight(self.textLabel.frame)) / 2);
	
}

-(void) startAnimating
{
	[UIView beginAnimations:@"Mask" context:NULL];
	self.alpha = 0.80f;
	[UIView commitAnimations];
	[self.activityIndicatorView startAnimating];
}

-(void) stopAnimating
{
	[UIView beginAnimations:@"Unmask" context:NULL];
	self.alpha = 0.0f;
	[UIView commitAnimations];
	[self.activityIndicatorView stopAnimating];		
}

- (void)dealloc
{
    //TODO:ここでnil解放するとおちる。参照関係はあっているはずなのだが...
    //self.activityIndicatorView = nil;
    self.textLabel = nil;
    [super dealloc];
}

@end
