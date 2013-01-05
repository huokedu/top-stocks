//
//  StockNews.h
//  Top Stocks
//
//  Created by Sayem Khan on 1/5/13.
//  Copyright (c) 2013 HatTrick Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StockNews : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * link;

@end
