//
//  BLCMediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Abdellatif Benzzine on 5/14/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import <UIKit/UIKit.h>



@class BLCMedia;

@interface BLCMediaFullScreenViewController : UIViewController

@property (nonatomic, strong) BLCMedia *media;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;


- (void) recalculateZoomScale;

- (instancetype) initWithMedia:(BLCMedia *)media;

- (void) centerScrollView;

@end

