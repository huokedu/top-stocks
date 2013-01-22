//
//  TSAppDelegate.m
//  Top Stocks
//
//  Created by Sayem Khan on 12/29/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import "TSAppDelegate.h"
#import "HomeViewController.h"
#import "StockViewController.h"
#import "WebViewController.h"
#import <CoreData/CoreData.h>
#import "Stock.h"
#import "StockNews.h"

@implementation TSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"parse" ofType:@"json"];
    NSArray *parse = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath] options:kNilOptions error:nil];
    
    [Parse setApplicationId:[[parse objectAtIndex:0] valueForKey:@"app_id"]
                  clientKey:[[parse objectAtIndex:1] valueForKey:@"client_key"]];
    
    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    HomeViewController *hvc = [[HomeViewController alloc] init];
    StockViewController *svc = [[StockViewController alloc] init];
    
    hvc.managedObjectContext = [self managedObjectContext];
    svc.managedObjectContext = [self managedObjectContext];
    
    WebViewController *wvc = [[WebViewController alloc] init];
    [svc setWebViewController:wvc];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:hvc];
    
    [[self window] setRootViewController:navController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Top_Stocks" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Top_Stocks.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
