//
//  BLCLoginViewController.m
//  Blocstagram
//
//  Created by Abdellatif Benzzine on 5/10/15.
//  Copyright (c) 2015 Leah Padgett. All rights reserved.
//

#import "BLCLoginViewController.h"
#import "BLCDatasource.h"

@interface BLCLoginViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;


@end

@implementation BLCLoginViewController

NSString *const BLCLoginViewControllerDidGetAccessTokenNotification = @"BLCLoginViewControllerDidGetAccessTokenNotification";


- (NSString *)redirectURI {
       return @"http://bloc.io";
    }



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
       UIWebView *webView = [[UIWebView alloc] init];
        webView.delegate = self;
    
        [self.view addSubview:webView];
         self.webView = webView;
    
        self.title = NSLocalizedString(@"Login", @"Login");
    
        NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", [BLCDatasource instagramClientID], [self redirectURI]];
        NSURL *url = [NSURL URLWithString:urlString];
    
        if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [self.webView loadRequest:request];
            }
    
}


- (void) viewWillLayoutSubviews {
        self.webView.frame = self.view.bounds;
  }

- (void) dealloc {
        // Removing this line can cause a flickering effect when you relaunch the app after logging in, as the web view is briefly displayed, automatically authenticates with cookies, returns the access token, and dismisses the login view, sometimes in less than a second.
        [self clearInstagramCookies];
    
       // see https://developer.apple.com/library/ios/documentation/uikit/reference/UIWebViewDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40006951-CH3-DontLinkElementID_1
    
        self.webView.delegate = nil;
    }

/**
  + Clears Instagram cookies. This prevents caching the credentials in the cookie jar.
  + */
- (void) clearInstagramCookies {
       for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
               NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
                if(domainRange.location != NSNotFound) {
                        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                    }
           }
    }
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
       NSString *urlString = request.URL.absoluteString;
        if ([urlString hasPrefix:[self redirectURI]]) {
                // This contains our auth token
                NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
                NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
                NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
                [[NSNotificationCenter defaultCenter] postNotificationName:BLCLoginViewControllerDidGetAccessTokenNotification object:accessToken];
        
                return NO;
            }
    
        return YES;
    }
@end