//
//  StockViewController.m
//  Top Stocks
//
//  Created by Sayem Khan on 12/29/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import "StockViewController.h"
#import "StockNews.h"

@implementation StockViewController {
    NSArray *stockNews;
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StockNews" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    stockNews = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
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
    return [stockNews count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    StockNews *news = [stockNews objectAtIndex:indexPath.row];
    cell.textLabel.text = news.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self navigationController] pushViewController:_webViewController animated:YES];
    
    StockNews *news = [stockNews objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:[news link]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [[_webViewController webView] loadRequest:req];
}

@end
