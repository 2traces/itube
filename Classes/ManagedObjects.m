//
//  ManagedObjects.m
//  tube
//
//  Created by Vasiliy Makarov on 07.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ManagedObjects.h"
#import "tubeAppDelegate.h"

@interface MItem (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(MCategory*)value;

@end

@implementation MItem

@dynamic posX;
@dynamic posY;
@dynamic index;
@dynamic isFavorite;
@dynamic name;
@dynamic categories;
@dynamic photos;
@dynamic transfer;
@end

@implementation MHistory

@dynamic adate;
@dynamic theItem;
@end

@implementation MCategory

@dynamic index;
@dynamic color;
@dynamic name;
@dynamic items;
@end

@implementation MPhoto

@dynamic isFavorite;
@dynamic fileName;
@dynamic theItem;
@end

@implementation MHelper

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize fetchedResultsController = __fetchedResultsController;

static MHelper * _sharedHelper;

+ (MHelper *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[MHelper alloc] init];
    return _sharedHelper;
}

- (id)init {
    
    if ((self = [super init])) {                
        [self managedObjectContext];
    }
    return self;
    
}

- (void)dealloc
{
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [__fetchedResultsController release];
    [super dealloc];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"offlinemaps" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)clearContent
{
    NSArray *stores = [__persistentStoreCoordinator persistentStores];
    
    for(NSPersistentStore *store in stores) {
        [__persistentStoreCoordinator removePersistentStore:store error:nil];
    }
    
    NSError *error = nil;
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
}

-(MCategory*)categoryByIndex:(int)index
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index=%@",[NSNumber numberWithInt:index]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([fetchedItems count]>0) {
        return [fetchedItems objectAtIndex:0];
    } else {
        return nil;
    }
}

-(MCategory*)categoryByName:(NSString *)name
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like[c] %@",name];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(![fetchedItems count]) NSLog(@"category not found %@", name);
    
    if ([fetchedItems count]>0) {
        return [fetchedItems objectAtIndex:0];
    } else {
        return nil;
    }
}

-(NSArray*)getItemList
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems;    
}

-(NSArray*)getPhotoList {
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"fileName" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems; 
}

-(NSArray*)getTransferList
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transfer" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems; 
}


-(NSArray*)getCategoryList
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems; 
}

/// сортировка по индексу
-(NSArray*)getItemsForCategoryIndex:(int)lineIndex
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    ///!!!
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"any categories.index=%@",[NSNumber numberWithInt:lineIndex]];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems; 
}

/// сортировка по имени
-(NSArray*)getItemsForCategory:(MCategory*)category
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"any categories=%@",category];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems; 
}

-(NSArray*)getFavoriteItemList
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite=%@",[NSNumber numberWithInt:1]];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems;    
}

-(MItem*)getItemWithIndex:(int)index andCategoryIndex:(int)catIndex
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"any categories.index=%@ and index=%@",[NSNumber numberWithInt:catIndex], [NSNumber numberWithInt:index]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([fetchedItems count]>0) {
        return [fetchedItems objectAtIndex:0];
    } else {
        return nil;
    }
}

-(MItem*)getItemWithIndex:(int)index
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index=%@",[NSNumber numberWithInt:index]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([fetchedItems count]>0) {
        return [fetchedItems objectAtIndex:0];
    } else {
        return nil;
    }
}

-(MItem*)getItemWithName:(NSString*)item forCategories:(NSArray*)categoryNames
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = nil;
    NSMutableArray *categoriesListing = [NSMutableArray arrayWithCapacity:1];
    
    if (categoryNames && [categoryNames count]) {
        for (NSString *catName in categoryNames) {
            [categoriesListing addObject:[NSPredicate predicateWithFormat:@"any categories.name like[c] %@", catName]];

        }
    }
    
    [categoriesListing addObject:[NSPredicate predicateWithFormat:@"name like[c] %@", item]];
    
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:categoriesListing];
    [fetchRequest setPredicate:predicate]; 

    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if([fetchedItems count] == 0 && categoriesListing) {
        NSFetchRequest *fetchRequest2 = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest2 setEntity:entity2];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"%@", categoriesListing];
        [fetchRequest2 setPredicate:predicate2];
        NSArray *fetchedItems2 = [self.managedObjectContext executeFetchRequest:fetchRequest2 error:&error];
        for (MItem* s in fetchedItems2) {
            NSLog(@"%@", s.name);
        }
    }

    // у меня стойкое ощущение, что всегда должен выбираться только один объект
    if ([fetchedItems count]>0) {
        return [fetchedItems objectAtIndex:0];
    } else {
        return nil;
    }
     
}



-(NSArray*)getHistoryList
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"adate" ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems;       
}



-(void)readBookmarkFile:(NSString*)mapName
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_bookmarks.plist",mapName];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:fileName];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        
        NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
        
        if (!temp)
        {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
        
        NSEnumerator *enumerator = [temp keyEnumerator];
        
        for(NSString *aKey in enumerator){
            
            MItem *item = [self getItemWithName:aKey forCategories:[temp objectForKey:aKey]];
            
            if (item) {
                [item setIsFavorite:[NSNumber numberWithInt:1]];
            }
        }
    }
}

-(void)saveBookmarkFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    tubeAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *fileName = [NSString stringWithFormat:@"%@_bookmarks.plist",[delegate nameCurrentMap]];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:fileName];
    
    NSArray *favStations = [self getFavoriteItemList];
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithCapacity:[favStations count]];
    
    for (MItem *item in favStations) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[item.categories count]];
        for (MCategory *category in [item categories]) {
            [tempArray addObject:[category name]];
        }
        NSArray *categoriesNames = [NSArray arrayWithArray:tempArray];
        
        NSString *itemName = [item name];
        
        [temp setObject:categoriesNames forKey:itemName];
    }
    
    // create dictionary with values in UITextFields
    NSDictionary *plistDict = [NSDictionary dictionaryWithDictionary:temp];
    
    [temp release];
    
    NSString *error = nil;
    // create NSData from dictionary
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    // check is plistData exists
    if(plistData)
    {
        // write plistData to our Data.plist file
        [plistData writeToFile:plistPath atomically:YES];
    }
    else
    {
        NSLog(@"Error in saveData: %@", error);
        [error release];
    }
}



-(void)readHistoryFile:(NSString*)mapName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_history.plist",mapName];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        
        NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
        
        if (!temp)
        {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
        
        NSEnumerator *enumerator = [temp keyEnumerator];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        [formatter setTimeStyle:NSDateFormatterLongStyle];
        [formatter setDateStyle:NSDateFormatterLongStyle];
        
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
        [formatter setLocale:usLocale];
        
        for(NSString *dataKey in enumerator){
            
            NSDate *historyDate = [formatter dateFromString:dataKey];
            
            NSDictionary *histDict = [temp objectForKey:dataKey]; 
            
            NSString *itemName = [[histDict allKeys] lastObject];
            NSArray *categoriesArray = [histDict objectForKey:itemName];
            
            MItem *theItem = [self getItemWithName:itemName forCategories:categoriesArray];

            if (theItem) {
                
                NSError *error =nil;
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:__managedObjectContext];
                MHistory *newhistory = [[MHistory alloc] initWithEntity:entity insertIntoManagedObjectContext:__managedObjectContext];
                
                newhistory.adate=historyDate;
                newhistory.theItem=theItem;
                
  //              NSLog(@"From: %@ --- To: %@",[fromStation name],[toStation name]);
                
                [newhistory release];
                
                if (![__managedObjectContext save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate.
                    // You should not use this function in a shipping application, although it may be useful
                    // during development. If it is not possible to recover from the error, display an alert
                    // panel that instructs the user to quit the application by pressing the Home button.
                    //
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            }
        }
        
        [usLocale release];
        [formatter release];
    }
}




-(void)addHistory:(NSDate*)date item:(MItem*)item
{
    NSError *error =nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:__managedObjectContext];
    MHistory *newhistory = [[MHistory alloc] initWithEntity:entity insertIntoManagedObjectContext:__managedObjectContext];    
    newhistory.adate=date;
    newhistory.theItem=item;
    [newhistory release];
    
    if (![__managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

-(void)addHistory:(NSDate*)date item:(NSString*)item categories:(NSArray *)categories {

    MItem *theItem = [self getItemWithName:item forCategories:categories];
    
    [self addHistory:date item:theItem];
}


-(void)saveHistoryFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    tubeAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *fileName = [NSString stringWithFormat:@"%@_history.plist",[delegate nameCurrentMap]];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:fileName];

    NSArray *histList = [self getHistoryList];
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithCapacity:[histList count]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeStyle:NSDateFormatterLongStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
    [formatter setLocale:usLocale];
    
    int countH = [histList count];
    
    if (countH>30) {
        countH=30;
    }
    
    for (int i=0;i<countH;i++) {
        
        MHistory *history = [histList objectAtIndex:i];
        
        NSString *mainKey = [formatter stringFromDate:history.adate]; 
        
        NSString *theItemName = [history.theItem name];
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[history.theItem.categories count]];
        for (MCategory *category in [history.theItem categories]) {
            [tempArray addObject:[category name]];
        }
        NSArray *categoriesNames = [NSArray arrayWithArray:tempArray];
        
        NSDictionary *oneHistDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:categoriesNames,nil] forKeys:[NSArray arrayWithObjects:theItemName,nil]];
        
        [temp setObject:oneHistDict forKey:mainKey];
        
        [oneHistDict release];
        
    }
    
    [formatter release];
    [usLocale release];
    
    // create dictionary with values in UITextFields
    NSDictionary *plistDict = [NSDictionary dictionaryWithDictionary:temp];
    
    [temp release];
    
    NSString *error = nil;
    // create NSData from dictionary
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    // check is plistData exists
    if(plistData)
    {
        // write plistData to our Data.plist file
        [plistData writeToFile:plistPath atomically:YES];
    }
    else
    {
        NSLog(@"Error in saveData: %@", error);
        [error release];
    }
    
}


@end