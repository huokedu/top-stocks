//
//  HomeViewController.h
//  Top Stocks
//
//  Created by Sayem Khan on 12/29/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stock.h"
#import "StockNews.h"


@interface HomeViewController : UITableViewController <NSXMLParserDelegate> {
    NSURLConnection *connection;
    NSMutableData *xmlData;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)updateTrendingStocks;

@end
