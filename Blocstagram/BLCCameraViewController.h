//
//  BLCCameraViewController.h
//  Blocstagram
//
//  Created by Abdellatif Benzzine on 5/17/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCCameraViewController;

@protocol CameraViewControllerDelegate <NSObject>

-(void) BLCCameraViewController:(BLCCameraViewController *)BLCCameraViewController didCompleteWithImage:(UIImage *)image;

@end


@interface BLCCameraViewController : UIViewController

@property (nonatomic, weak) NSObject <CameraViewControllerDelegate> *delegate;

@end
