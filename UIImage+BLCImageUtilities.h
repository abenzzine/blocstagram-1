//
//  UIImageBLCImageUtilities.h
//  Blocstagram
//
//  Created by Abdellatif Benzzine on 5/23/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BLCImageUtilities)



- (UIImage *) imageWithFixedOrientation;
- (UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage *) imageCroppedToRect:(CGRect)cropRect;

@end


