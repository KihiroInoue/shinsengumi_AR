//
//  MaskedActivityIndicatorView.h
//  Rosetta
//
//  Created by Yoichiro Hino on 10/06/27.
//  Copyright 2011 Yoichiro Hino. All rights reserved.
//

#import <UIKit/UIKit.h>

// INFO:画面全体をブラックアウト（半透明）して、ローディングアイコンを表示するクラス
// 現在はデザイン上の問題から利用していない
@interface MaskedActivityIndicatorView : UIView {
	UIActivityIndicatorView* _activityIndicatorView;
    UILabel* _textLabel;
}

@property(nonatomic,retain) UILabel* textLabel;
-(void) startAnimating;
-(void) stopAnimating;

@end
