//
//  HomeViewController.m
//  Top Stocks
//
//  Created by Sayem Khan on 12/29/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "StockViewController.h"
#import "Stock.h"

@implementation HomeViewController {
    NSArray *topStocks;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSDate *today = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d"];
        NSString *dateToday = [formatter stringFromDate:today];
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", @"Top Stocks -", dateToday];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stock" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    topStocks = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"$$" forState:UIControlStateNormal];
    
    button.frame=CGRectMake(0,0, 29, 29);
    //        [button addTarget:self action:@selector(regimenInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = btnDone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [topStocks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Stock *stockCell = [topStocks objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", stockCell.ticker, stockCell.company];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

        
    StockViewController *controller = [[StockViewController alloc] init];

    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
