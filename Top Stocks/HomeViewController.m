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

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"$$" forState:UIControlStateNormal];
    
    button.frame=CGRectMake(0,0, 29, 29);
    //        [button addTarget:self action:@selector(regimenInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = btnDone;
}

- (void)updateTrendingStocks {
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
        [offsetComponents setMonth:-1]; // note that I'm setting it to -1
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
