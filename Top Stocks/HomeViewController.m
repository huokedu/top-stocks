//
//  HomeViewController.m
//  Top Stocks
//
//  Created by Sayem Khan on 12/29/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "StockViewController.h"
#import "WebViewController.h"
#import "Stock.h"
#import "StockNews.h"
#import "TSCell.h"

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
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", @"Top Stocks for", dateToday];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateTopStocks];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stock" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    topStocks = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (void)updateTopStocks
{
    if ([[PFQuery queryWithClassName:@"Stock"] findObjects]) {
        NSError *error;
        
        NSFetchRequest *stockRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *stockEntity = [NSEntityDescription entityForName:@"Stock" inManagedObjectContext:_managedObjectContext];
        [stockRequest setEntity:stockEntity];
        NSArray *fetchedStocks = [_managedObjectContext executeFetchRequest:stockRequest error:&error];
        
        NSFetchRequest *newsRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *newsEntity = [NSEntityDescription entityForName:@"StockNews" inManagedObjectContext:_managedObjectContext];
        [newsRequest setEntity:newsEntity];
        NSArray *fetchedNews = [_managedObjectContext executeFetchRequest:newsRequest error:&error];
        
        NSDate *pfstockDate = [[[PFQuery queryWithClassName:@"Stock"] getFirstObject] createdAt];
        NSDate *stockDate;
        
        if ([fetchedStocks count] > 0) {
            stockDate = [[fetchedStocks objectAtIndex:0] dateCreated];
        }
        else {
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setMonth:-1];
            stockDate = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
        }
        
        if ([pfstockDate compare:stockDate] == 1) {
            for (Stock *deleteStock in fetchedStocks) {
                [_managedObjectContext deleteObject:deleteStock];
                NSLog(@"Deleted: %@", deleteStock.ticker);
            }
            
            for (StockNews *deleteNews in fetchedNews) {
                [_managedObjectContext deleteObject:deleteNews];
                NSLog(@"Deleted: %@", deleteNews.title);
            }
            
            PFQuery *getStocks = [PFQuery queryWithClassName:@"Stock"];
            NSArray *pfStocks = [getStocks findObjects];
            
            for (PFObject *pfStock in pfStocks) {
                Stock *addStock = [NSEntityDescription insertNewObjectForEntityForName:@"Stock" inManagedObjectContext:_managedObjectContext];
                NSString *symbol = [pfStock objectForKey:@"ticker"];
                NSString *company = [pfStock objectForKey:@"company"];
                
                addStock.ticker = symbol;
                addStock.company = company;
                addStock.dateCreated = [pfStock createdAt];
                [addStock.managedObjectContext save:&error];
                
                NSLog(@"%@", symbol);
                
                PFQuery *getNews = [PFQuery queryWithClassName:@"StockNews"];
                [getNews whereKey:@"company" equalTo:pfStock];
                NSArray *getpfNews = [getNews findObjects];
                
                for (PFObject *pfNews in getpfNews) {
                    StockNews *addNews = [NSEntityDescription insertNewObjectForEntityForName:@"StockNews" inManagedObjectContext:_managedObjectContext];
                    NSString *title = [pfNews objectForKey:@"title"];
                    NSString *link = [pfNews objectForKey:@"link"];
                    
                    addNews.title = title;
                    addNews.link = link;
                    addNews.ticker = symbol;
                    [addNews.managedObjectContext save:&error];
                    
                    NSLog(@"%@", link);
                }
            }
            
            NSFetchRequest *checkstockRequest = [[NSFetchRequest alloc] init];
            [checkstockRequest setEntity:stockEntity];
            NSArray *checkStocks = [_managedObjectContext executeFetchRequest:checkstockRequest error:&error];
            
            NSFetchRequest *checknewsRequest = [[NSFetchRequest alloc] init];
            [checknewsRequest setEntity:newsEntity];
            NSArray *checkNews = [_managedObjectContext executeFetchRequest:checknewsRequest error:&error];
            
            PFQuery *getNews = [PFQuery queryWithClassName:@"StockNews"];
            NSArray *pfStockNews = [getNews findObjects];
            
            if (([checkStocks count] == [pfStocks count]) && ([checkNews count] == [pfStockNews count])) {
                [_managedObjectContext save:&error];
                NSLog(@"Updated model");
            }
        }
    }
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
    TSCell *cell = (TSCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[TSCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
     
    Stock *stockCell = [topStocks objectAtIndex:indexPath.row];
    cell.label.text = [NSString stringWithFormat:@"%@ - %@", stockCell.ticker, stockCell.company];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StockViewController *stockView = [[StockViewController alloc] init];

    WebViewController *wvc = [[WebViewController alloc] init];
    [stockView setWebViewController:wvc];
    stockView.managedObjectContext = [self managedObjectContext];
    Stock *selectedStock = [topStocks objectAtIndex:indexPath.row];
    [stockView setTopStock:selectedStock];

    [self.navigationController pushViewController:stockView animated:YES];
}

@end
