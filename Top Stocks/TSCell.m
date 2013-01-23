//
//  TSCell.m
//  Top Stocks
//
//  Created by Sayem Khan on 1/22/13.
//  Copyright (c) 2013 HatTrick Labs, LLC. All rights reserved.
//

#import "TSCell.h"

@implementation TSCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, 300, 44)];
        self.label.numberOfLines = 2;
        self.label.textColor = [UIColor colorWithRed: 102.0 / 255 green:102.0 / 255 blue: 102.0 / 255 alpha:1.0];
        self.label.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        [self.contentView addSubview:self.label];
    }
    return self;
}

@end
