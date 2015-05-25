//
//  BLCCropImageViewController.h
//  Blocstagram
//
//  Created by Abdellatif Benzzine on 5/25/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import "BLCMediaFullScreenViewController.h"

@class BLCCropImageViewController;

@protocol CropImageViewControllerDelegate <NSObject>

- (void) cropImageViewControllerFinishWithImage:(UIImage *) croppedImage;

@end

@interface BLCCropImageViewController : BLCMediaFullScreenViewController

- (instancetype) initWithImage:(UIImage *) sourceImage;

@property (nonatomic, weak) NSObject <CropImageViewControllerDelegate> *delegate;


@end
