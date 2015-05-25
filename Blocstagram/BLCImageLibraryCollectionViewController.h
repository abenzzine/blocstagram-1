//
//  BLCImageLibraryCollectionViewController.h
//  Blocstagram
//
//  Created by Abdellatif Benzzine on 5/25/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCImageLibraryCollectionViewController;

@protocol ImageLibraryViewControllerDelegate <NSObject>

- (void) imageLibraryViewController:(BLCImageLibraryCollectionViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image;

@end

@interface BLCImageLibraryCollectionViewController : UICollectionViewController
@property (nonatomic, weak) NSObject <ImageLibraryViewControllerDelegate> *delegate;
@end
