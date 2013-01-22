//
//  WebViewController.m
//  Top Stocks
//
//  Created by Sayem Khan on 1/21/13.
//  Copyright (c) 2013 HatTrick Labs, LLC. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

- (void)loadView {
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    UIWebView *wv = [[UIWebView alloc] initWithFrame:screenFrame];
    [wv setScalesPageToFit:YES];
    
    [self setView:wv];
}

- (UIWebView *)webView {
    return (UIWebView *)[self view];
}

@end
