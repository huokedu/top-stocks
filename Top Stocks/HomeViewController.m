//
//  HomeViewController.m
//  Top Stocks
//
//  Created by Sayem Khan on 12/29/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import "HomeViewController.h"

@implementation HomeViewController

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

    [self updateTrendingStocks];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"$$" forState:UIControlStateNormal];
    
    button.frame=CGRectMake(0,0, 29, 29);
    //        [button addTarget:self action:@selector(regimenInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = btnDone;
}

- (void)updateTrendingStocks {

    // check if pfquery not nill
    
    
    NSError *error;
    
    NSFetchRequest *stockRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *stockEntity = [NSEntityDescription entityForName:@"Stock" inManagedObjectContext:_managedObjectContext];
    [stockRequest setEntity:stockEntity];
    NSArray *fetchedStocks = [_managedObjectContext executeFetchRequest:stockRequest error:&error];

    NSFetchRequest *newsRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *newsEntity = [NSEntityDescription entityForName:@"StockNews" inManagedObjectContext:_managedObjectContext];
    [newsRequest setEntity:newsEntity];
    NSArray *fetchedNews = [_managedObjectContext executeFetchRequest:newsRequest error:&error];

    NSDate *checkStock = [[fetchedStocks objectAtIndex:0] dateCreated];
    NSDate *checkpfStock = [[[PFQuery queryWithClassName:@"Stock"] getFirstObject] createdAt];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *nowComponents = [cal components:( NSHourCalendarUnit ) fromDate:[NSDate date]];
    NSDateComponents *stockComponents = [cal components:( NSHourCalendarUnit ) fromDate:checkStock];
    NSDateComponents *pfstockComponents = [cal components:( NSHourCalendarUnit ) fromDate:checkpfStock];
    
    if (nowComponents.hour > stockComponents.hour) {
        
        for (Stock *deleteStock in fetchedStocks) {
            [_managedObjectContext deleteObject:deleteStock];
            
            NSLog(@"Deleted: %@", deleteStock.ticker);
        }
        
        for (StockNews *deleteNews in fetchedNews) {
            [_managedObjectContext deleteObject:deleteNews];
            NSLog(@"Deleted: %@", deleteNews.title);
        }
        
        if (nowComponents.hour > pfstockComponents.hour) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"apikey" ofType:NULL];
            NSString *apikey = [NSString stringWithContentsOfFile:path encoding:4 error:NULL];
            NSString *trendingStocks = [NSString stringWithFormat:@"%@%@", @"https://api.stocktwits.com/api/2/trending/symbols/equities.json?access_token=", apikey];
            NSURL *trendingUrl = [NSURL URLWithString:trendingStocks];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:trendingUrl];
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
                NSArray *symbols = [JSON valueForKeyPath:@"symbols"];
                
                for (NSDictionary *stock in symbols) {
                    NSString *symbol = [stock valueForKey:@"symbol"];
                    NSString *company = [stock valueForKey:@"title"];

                    Stock *trendingStock = [NSEntityDescription insertNewObjectForEntityForName:@"Stock" inManagedObjectContext:_managedObjectContext];
                    NSError *error;
                    
                    trendingStock.ticker = symbol;
                    trendingStock.company = company;
                    trendingStock.dateCreated = [NSDate date];
                    [trendingStock.managedObjectContext save:&error];
                
                    PFObject *pfStock = [PFObject objectWithClassName:@"Stock"];
                    [pfStock setObject:symbol forKey:@"ticker"];
                    [pfStock setObject:company forKey:@"company"];
                    [pfStock save];
                
                    NSLog(@"%@", symbol);
                
                    NSURL *newsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://finance.yahoo.com/rss/headline?s=", symbol]];
                
                    RXMLElement *rootXML = [RXMLElement elementFromURL:newsUrl];
                
                    [rootXML iterate:@"channel.item" usingBlock: ^(RXMLElement *item) {
                        StockNews *trendingNews = [NSEntityDescription insertNewObjectForEntityForName:@"StockNews" inManagedObjectContext:_managedObjectContext];
                        NSError *error;
                    
                        trendingNews.title = [item child:@"title"].text;
                        trendingNews.link = [item child:@"link"].text;
                        [trendingNews.managedObjectContext save:&error];
                    
                        PFObject *pfNews = [PFObject objectWithClassName:@"StockNews"];
                        [pfNews setObject:pfStock forKey:@"company"];
                        [pfNews setObject:[item child:@"title"].text forKey:@"title"];
                        [pfNews setObject:[item child:@"link"].text forKey:@"link"];
                        [pfNews save];
                    
                        NSLog(@"%@", trendingNews.title);
                    }];
                }

                NSError *error;
                [_managedObjectContext save:&error];
                NSLog(@"Updated parse");
                
            } failure:nil];
            [operation start];
        }
        else {
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
            }
            
            PFQuery *getStockNews = [PFQuery queryWithClassName:@"StockNews"];
            NSArray *pfStockNews = [getStockNews findObjects];
            
            for (PFObject *pfNews in pfStockNews) {
                StockNews *addNews = [NSEntityDescription insertNewObjectForEntityForName:@"StockNews" inManagedObjectContext:_managedObjectContext];
                NSString *title = [pfNews objectForKey:@"ticker"];
                NSString *link = [pfNews objectForKey:@"company"];
                
                addNews.title = title;
                addNews.link = link;
                [addNews.managedObjectContext save:&error];
                
                NSLog(@"%@", link);
            }
            
            NSFetchRequest *checkstockRequest = [[NSFetchRequest alloc] init];
            [checkstockRequest setEntity:stockEntity];
            NSArray *checkStocks = [_managedObjectContext executeFetchRequest:checkstockRequest error:&error];

            NSFetchRequest *checknewsRequest = [[NSFetchRequest alloc] init];
            [checknewsRequest setEntity:newsEntity];
            NSArray *checkNews = [_managedObjectContext executeFetchRequest:checknewsRequest error:&error];

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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
