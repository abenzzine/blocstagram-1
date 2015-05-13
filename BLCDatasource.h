//
//  BLCDatasource.h
//  Blocstagram
//
//  Created by Leah Padgett on 4/26/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCMedia;

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface BLCDatasource : NSObject

+(instancetype) sharedInstance;

+(NSString *) instagramClientID;

@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;

@property (nonatomic, strong, readonly) NSString *accessToken;


@property (nonatomic, strong, readonly) NSArray *mediaItems;

-(void) deleteMediaItem:(BLCMedia *)item;

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;



@end