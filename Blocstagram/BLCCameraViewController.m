//
//  BLCCameraViewController.m
//  Blocstagram
//
//  Created by Abdellatif Benzzine on 5/17/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import "BLCCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BLCCameraToolbar.h"

@interface BLCCameraViewController () <CameraToolbarDelegate>

@property (nonatomic, strong) UIView *imagePreview;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) NSArray *horizontalLines;
@property (nonatomic, strong) NSArray *verticalLines;
@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

@property (nonatomic, strong) BLCCameraToolbar *cameraToolbar;

@end

@implementation BLCCameraViewController

#pragma mark - Build View Hierarchy

- (void)viewDidLoad {
        [super viewDidLoad];
        // Do any additional setup after loading the view.
    
        [self createViews];
    }

- (void) createViews {
        self.imagePreview = [UIView new];
        self.topView = [UIToolbar new];
        self.bottomView = [UIToolbar new];
        self.cameraToolbar = [[BLCCameraToolbar alloc] initWithImageNames:@[@"rotate", @"road"]];
        self.cameraToolbar.delegate = self;
        UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
        self.topView.barTintColor = whiteBG;
        self.bottomView.barTintColor = whiteBG;
        self.topView.alpha = 0.5;
        self.bottomView.alpha = 0.5;
    }



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
