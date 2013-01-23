//
//  StockViewController.m
//  Top Stocks
//
//  Created by Sayem Khan on 12/29/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import "StockViewController.h"
#import "HomeViewController.h"
#import "StockNews.h"
#import "TSCell.h"

@implementation StockViewController {
    NSArray *stockNews;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(homeView)];
    self.navigationItem.leftBarButtonItem = btnBack;
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StockNews" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *stockPredicate = [NSPredicate predicateWithFormat:@"ticker == %@", [_topStock ticker]];
    [fetchRequest setPredicate:stockPredicate];
    stockNews = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", [_topStock ticker], @"News"];
}

- (void)homeView {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    TSCell *cell = (TSCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TSCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    StockNews *news = [stockNews objectAtIndex:indexPath.row];
    cell.label.text = news.title;
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
