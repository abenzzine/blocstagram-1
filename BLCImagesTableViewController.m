//
//  BLCImagesTableViewController.m
//  Blocstagram
//
//  Created by Leah Padgett on 4/22/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import "BLCImagesTableViewController.h"

#import "BLCDatasource.h"
#import "BLCMedia.h"
#import "BLCUser.h"
#import "BLCComment.h"
#import "BLCMediaTableViewCell.h"
#import "BLCComment.h"
#import "BLCMediaTableViewCell.h"
#import "BLCMediaFullScreenViewController.h"
#import "BLCCameraViewController.h"
#import "BLCImageLibraryCollectionViewController.h"


@interface BLCImagesTableViewController () <MediaTableViewCellDelegate, UIViewControllerTransitioningDelegate, CameraViewControllerDelegate, ImageLibraryViewControllerDelegate>

@property (nonatomic, weak) UIImageView *lastTappedImageView;
@property (nonatomic, weak) UIView *lastSelectedCommentView;
@property (nonatomic, assign) CGFloat lastKeyboardAdjustment;

@end

@implementation BLCImagesTableViewController 

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [BLCDatasource sharedInstance] && [keyPath isEqualToString:@"mediaItems"]) {
        // We know mediaItems changed.  Let's see what kind of change it is.
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            // Someone set a brand new images array
            [self.tableView reloadData];
        } else if (kindOfChange == NSKeyValueChangeInsertion ||
                   kindOfChange == NSKeyValueChangeRemoval ||
                   kindOfChange == NSKeyValueChangeReplacement) {
            // We have an incremental change: inserted, deleted, or replaced images
            
            // Get a list of the index (or indices) that changed
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            // Convert this NSIndexSet to an NSArray of NSIndexPaths (which is what the table view animation methods require)
            NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            // Call `beginUpdates` to tell the table view we're about to make changes
            [self.tableView beginUpdates];
            
            // Tell the table view what the changes are
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            // Tell the table view that we're done telling it about changes, and to complete the animation
            [self.tableView endUpdates];
        }

    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void) imageLibraryViewController:(BLCImageLibraryCollectionViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image {
       [imageLibraryViewController dismissViewControllerAnimated:YES completion:^{
                if (image) {
                        NSLog(@"Got an image!");
                    } else {
                            NSLog(@"Closed without an image.");
                       }
            }];
    }


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"imageCell"];
    
    [[BLCDatasource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    
    [self.tableView registerClass:[BLCMediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    
    
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
                [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraPressed:)];
                self.navigationItem.rightBarButtonItem = cameraButton;
            }
    

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                       selector:@selector(keyboardWillShow:)
                                                           name:UIKeyboardWillShowNotification
                                                         object:nil];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                       selector:@selector(keyboardWillHide:)
                                                           name:UIKeyboardWillHideNotification
                                                         object:nil];

}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {
        // Get the frame of the keyboard within self.view's coordinate system
        NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrameInScreenCoordinates = frameValue.CGRectValue;
        CGRect keyboardFrameInViewCoordinates = [self.navigationController.view convertRect:keyboardFrameInScreenCoordinates fromView:nil];
    
        // Get the frame of the comment view in the same coordinate system
        CGRect commentViewFrameInViewCoordinates = [self.navigationController.view convertRect:self.lastSelectedCommentView.bounds fromView:self.lastSelectedCommentView];
    
        CGPoint contentOffset = self.tableView.contentOffset;
        UIEdgeInsets contentInsets = self.tableView.contentInset;
        UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        CGFloat heightToScroll = 0;
    
        CGFloat keyboardY = CGRectGetMinY(keyboardFrameInViewCoordinates);
        CGFloat commentViewY = CGRectGetMinY(commentViewFrameInViewCoordinates);
        CGFloat difference = commentViewY - keyboardY;
    
        if (difference > 0) {
                heightToScroll = difference;
            }
    
        if (CGRectIntersectsRect(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates)) {
                // The two frames intersect (the keyboard would block the view)
                CGRect intersectionRect = CGRectIntersection(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates);
                heightToScroll = CGRectGetHeight(intersectionRect);
            }
    
        if (heightToScroll > 0) {
                contentInsets.bottom = heightToScroll;
                scrollIndicatorInsets.bottom = heightToScroll;
                contentOffset.y = heightToScroll;
        
                NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
                NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        
                NSTimeInterval duration = durationNumber.doubleValue;
                UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
                UIViewAnimationOptions options = curve << 16;
        
                [UIView animateWithDuration:duration delay:0 options:options animations:^{
                        self.tableView.contentInset = contentInsets;
                        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
                        self.tableView.contentOffset = contentOffset;
                    } completion:nil];
            }
    
        self.lastKeyboardAdjustment = heightToScroll;
    }

- (void)keyboardWillHide:(NSNotification *)notification {
        UIEdgeInsets contentInsets = self.tableView.contentInset;
        contentInsets.bottom -= self.lastKeyboardAdjustment;
    
        UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        scrollIndicatorInsets.bottom -= self.lastKeyboardAdjustment;
    
        NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
        NSTimeInterval duration = durationNumber.doubleValue;
        UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
        UIViewAnimationOptions options = curve << 16;

        [UIView animateWithDuration:duration delay:0 options:options animations:^{
                self.tableView.contentInset = contentInsets;
                self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
            } completion:nil];
    }

-(void) refreshControlDidFire:(UIRefreshControl *) sender {
       [[BLCDatasource sharedInstance] requestOldItemsWithCompletionHandler:^(NSError *error) {
               [sender endRefreshing];
            }];
    }

- (void) infiniteScrollIfNecessary {
    // #3
       NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
        if (bottomIndexPath && bottomIndexPath.row == [BLCDatasource sharedInstance].mediaItems.count - 1) {
                // The very last cell is on screen
                [[BLCDatasource sharedInstance] requestNewItemsWithCompletionHandler:nil];
            }
    }

#pragma mark - UIScrollViewDelegate

// #4
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        [self infiniteScrollIfNecessary];
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Camera, CameraViewControllerDelegate, and ImageLibraryViewControllerDelegate

- (void) cameraPressed:(UIBarButtonItem *) sender {
    
        UIViewController *imageVC;
    
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                BLCCameraViewController *cameraVC = [[BLCCameraViewController alloc] init];
                cameraVC.delegate = self;
                imageVC = cameraVC;
            } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                    BLCImageLibraryCollectionViewController *imageLibraryVC = [[BLCImageLibraryCollectionViewController alloc] init];
                    imageLibraryVC.delegate = self;
                    imageVC = imageLibraryVC;
                }
    
        if (imageVC) {
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageVC];
                [self presentViewController:nav animated:YES completion:nil];
            }
        
    return;
}
    

- (void) BLCCameraViewController:(BLCCameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image {
        [cameraViewController dismissViewControllerAnimated:YES completion:^{
                if (image) {
                        NSLog(@"Got an image!");
                    } else {
                            NSLog(@"Closed without an image.");
                        }
            }];
    }



#pragma mark - Table view data source

/*
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 #warning Potentially incomplete method implementation.
 // Return the number of sections.
 return 0;
 }
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self items].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    BLCMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.mediaItem = [self items][indexPath.row];
    cell.delegate = self;
    cell.mediaItem = [BLCDatasource sharedInstance].mediaItems[indexPath.row];

    return cell;
}

-(void) cellWillStartComposingComment:(BLCMediaTableViewCell *)cell {
        self.lastSelectedCommentView = (UIView *)cell.commentView;
    }

- (void) cell:(BLCMediaTableViewCell *)cell didComposeComment:(NSString *)comment {
        [[BLCDatasource sharedInstance] commentOnMediaItem:cell.mediaItem withCommentText:comment];
    }

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        BLCMediaTableViewCell *cell = (BLCMediaTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell stopComposingComment];
    }

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
        BLCMedia *mediaItem = [BLCDatasource sharedInstance].mediaItems[indexPath.row];
        if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
                [[BLCDatasource sharedInstance] downloadImageForMediaItem:mediaItem];
            }
    }


#pragma mark - MediaTableViewCellDelegate


- (void) cell:(BLCMediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView {
        BLCMediaFullScreenViewController *fullScreenVC = [[BLCMediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    
    [self presentViewController:fullScreenVC animated:YES completion:nil];
    }
- (void) cell:(BLCMediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView {
        NSMutableArray *itemsToShare = [NSMutableArray array];
    
        if (cell.mediaItem.caption.length > 0) {
                [itemsToShare addObject:cell.mediaItem.caption];
            }
    
        if (cell.mediaItem.image) {
                [itemsToShare addObject:cell.mediaItem.image];
            }
    
        if (itemsToShare.count > 0) {
                UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
                [self presentViewController:activityVC animated:YES completion:nil];
            }
    }

- (void) cellDidPressLikeButton:(BLCMediaTableViewCell *)cell {
        BLCMedia *item = cell.mediaItem;
    
        [[BLCDatasource sharedInstance] toggleLikeOnMediaItem:item withCompletionHandler:^{
                if (cell.mediaItem == item) {
                        cell.mediaItem = item;
                    }
            }];
    
        cell.mediaItem = item;
    }



- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return 300;
    
    //UIImage *image = self.images[indexPath.row];
    //return image.size.height;
    
    BLCMedia *item = [BLCDatasource sharedInstance].mediaItems[indexPath.row];
    // UIImage *image = item.image;
    //return 300  image.size.height / image.size.width * CGRectGetWidth(self.view.frame);
    return [BLCMediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the 
//#warning the execution of the next line will cause the app to crash. use your ninja coding skills to solve it.
        BLCMedia *item = [BLCDatasource sharedInstance].mediaItems[indexPath.row];
        [[BLCDatasource sharedInstance] deleteMediaItem:item];
        
        
        // [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //} else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCMedia *item = [BLCDatasource sharedInstance].mediaItems[indexPath.row];
    if (item.image) {
        return 450;
    } else {
        return 250;
    }
}


//- (void) dealloc
//{
//   [[BLCDatasource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
//   [[NSNotificationCenter defaultCenter] removeObserver:self];
//}


-(NSArray *) items{
    return[BLCDatasource sharedInstance].mediaItems;
}

- (void)viewWillAppear:(BOOL)animated {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        if (indexPath) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
        }
    }

- (void) viewWillDisappear:(BOOL)animated {
    
}
/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
