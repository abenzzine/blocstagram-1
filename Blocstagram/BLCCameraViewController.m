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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
