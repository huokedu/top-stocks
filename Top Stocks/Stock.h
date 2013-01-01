//
//  Stock.h
//  Top Stocks
//
//  Created by Sayem Khan on 12/31/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Stock : NSManagedObject

@property (nonatomic, retain) NSString * ticker;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSDate * dateCreated;

@end
