//
//  BLCDatasource.m
//  Blocstagram
//
//  Created by Leah Padgett on 4/26/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import "BLCDatasource.h"
#import "BLCUser.h"
#import "BLCMedia.h"
#import "BLCComment.h"
#import "BLCLoginViewController.h"


@interface BLCDatasource () {
    NSMutableArray *_mediaItems;
}

@property (nonatomic, strong) NSArray *mediaItems;

@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL isLoadingNewItems;

@property (nonatomic, assign) BOOL isLoadingOlderItems;

@property (nonatomic, strong) NSString *accessToken;

@end

@implementation BLCDatasource

- (void) deleteMediaItem:(BLCMedia *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        
        [self registerForAccessTokenNotification];
    }
    
    return self;
}

- (void) populateDataWithParameters:(NSDictionary *)parameters {
    if (self.accessToken) {
        // only try to get the data if there's an access token
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // do the network request in the background, so the UI doesn't lock up
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters) {
                // for example, if dictionary contains {count: 50}, append `&count=50` to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse *response;
                NSError *webError;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                NSError *jsonError;
                NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                
                if (feedDictionary) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // done networking, go back on the main thread
                        [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                    });
                }
            }
        });
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSLog(@"%@", feedDictionary);
}

- (void) registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:BLCLoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        
        // Got a token, populate the initial data
        [self populateDataWithParameters:nil];
    }];
}

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    // #1
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        self.isRefreshing = NO;
        
        
        
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

+(NSString *) instagramClientID {
    return @"ffcc1cfb052846e79ad97eff80ef647f";
}


- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
       if (self.isLoadingOlderItems == NO) {
                self.isLoadingOlderItems = YES;
           
           
           
           
                if (completionHandler) {
                       completionHandler(nil);
                    }
            }
    }






#pragma mark - Key/Value Observing

- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void) insertObject:(BLCMedia *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

@end
