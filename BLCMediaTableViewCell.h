//
//  BLCMediaTableViewCell.h
//  Blocstagram
//
//  Created by Leah Padgett on 4/27/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BLCMedia, BLCMediaTableViewCell;

@protocol MediaTableViewCellDelegate <NSObject>


- (void) cell:(BLCMediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void) cell:(BLCMediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;
- (void) cellDidPressLikeButton:(BLCMediaTableViewCell *)cell;

@end

@interface BLCMediaTableViewCell : UITableViewCell

@property (nonatomic, strong) BLCMedia *mediaItem;
@property (nonatomic, weak) id <MediaTableViewCellDelegate> delegate;

+(CGFloat) heightForMediaItem:(BLCMedia *)mediaItem width:(CGFloat)width;


@end
