//
//  StockViewController.h
//  Top Stocks
//
//  Created by Sayem Khan on 12/29/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"
#import "Stock.h"

@class Stock;
@class WebViewController;

@interface StockViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Stock *topStock;
@property (strong, nonatomic) WebViewController *webViewController;

@end
