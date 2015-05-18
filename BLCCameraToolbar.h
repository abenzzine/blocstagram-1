//
//  BLCCameraToolbar.h
//  Blocstagram
//
//  Created by Abdellatif Benzzine on 5/17/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import <UIKit/UIKit.h>



@class BLCCameraToolbar;

@protocol CameraToolbarDelegate <NSObject>

- (void) leftButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar;
- (void) rightButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar;
- (void) cameraButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar;

@end

@interface BLCCameraToolbar : UIView

- (instancetype) initWithImageNames:(NSArray *)imageNames;

@property (nonatomic, weak) NSObject <CameraToolbarDelegate> *delegate;

@end
