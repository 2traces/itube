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


@implementation MPlace

@dynamic posX;
@dynamic posY;
@dynamic index;
@dynamic accessLevel;
@dynamic isFavorite;
@dynamic name;
@dynamic text;
@dynamic categories;
@dynamic photos;
@end

@implementation MCategory

@dynamic index;
@dynamic color;
@dynamic name;
@dynamic items;
@dynamic image_highlighted;
@dynamic image_normal;
@end

@implementation MMedia

@dynamic repeatCount;
@dynamic index;
@dynamic isFavorite;
@dynamic filename;
@dynamic place;
@dynamic mediaType;
@end

@implementation MStation

@dynamic index;
@dynamic isFavorite;
@dynamic name;
@dynamic altname;
@dynamic lines;
@dynamic transfer;
@end

@implementation MHistory

@dynamic adate;
@dynamic fromStation;
@dynamic toStation;
@end

@implementation MLine

@dynamic index;
@dynamic color;
@dynamic name;
@dynamic stations;
@end

@implementation MHelper

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize languageIndex;

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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"tubee" withExtension:@"momd"];
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

-(MLine*)lineByIndex:(int)index
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.managedObjectContext];
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

-(MCategory*)categoryByIndex:(int)index {
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


-(MLine*)lineByName:(NSString *)name
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like[c] %@",name];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(![fetchedItems count]) NSLog(@"line not found %@", name);
    
    if ([fetchedItems count]>0) {
        return [fetchedItems objectAtIndex:0];
    } else {
        return nil;
    }
}

-(MCategory*)categoryByName:(NSString*)name {
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


-(MMedia*)photoByFilename:(NSString*)filename {
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename like[c] %@",filename];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(![fetchedItems count]) {
        //NSLog(@"photo not found %@", filename);

    }
    
    if ([fetchedItems count]>0) {
        return [fetchedItems objectAtIndex:0];
    } else {
        return nil;
    }
}


-(NSArray*)getStationList
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor;
    if (languageIndex%2) {
//        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"altname" ascending:YES] autorelease];
        sortDescriptor = [[[NSSortDescriptor alloc]
                                     initWithKey:@"altname"
                                     ascending:YES
                                     selector:@selector(localizedCompare:)] autorelease];
    } else {
        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];        
    }
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems;    
}

-(NSArray*)getLineList
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.managedObjectContext];
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

-(NSArray*)getCategoriesList {
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

/// сортировка по индексу
-(NSArray*)getStationsForLineIndex:(int)lineIndex
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lines.index=%@",[NSNumber numberWithInt:lineIndex]];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems; 
}

-(NSArray*)getPlacesForCategoryIndex:(int)catIndex {
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    ///!!!
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"any categories.index=%@",[NSNumber numberWithInt:catIndex]];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    //Return only those that are allowed by current access level
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger accessLevel = [[defaults objectForKey:@"additionalContentAccessLevel"] integerValue];
    NSMutableArray *filteredItems = [[NSMutableArray alloc] initWithCapacity:[fetchedItems count]];
    for (MPlace *place in fetchedItems) {
        if ([place.accessLevel integerValue] <= accessLevel) {
            [filteredItems addObject:place];
        }
    }
    
    return [filteredItems autorelease];
}


/// сортировка по имени
-(NSArray*)getStationsForLine:(MLine*)line
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lines=%@",line];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor;
    if (languageIndex%2) {
//        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"altname" ascending:YES] autorelease];
        sortDescriptor = [[[NSSortDescriptor alloc]
                           initWithKey:@"altname"
                           ascending:YES
                           selector:@selector(localizedCompare:)] autorelease];
    } else {
        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    }
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems; 
}


-(NSArray*)getFavoritePlacesList
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite=%@",[NSNumber numberWithInt:1]];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor;
    if (languageIndex%2) {
        //        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"altname" ascending:YES] autorelease];
        sortDescriptor = [[[NSSortDescriptor alloc]
                           initWithKey:@"altname"
                           ascending:YES
                           selector:@selector(localizedCompare:)] autorelease];
    } else {
        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    }
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems;
}


-(NSArray*)getFavoriteStationList
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite=%@",[NSNumber numberWithInt:1]];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor;
    if (languageIndex%2) {
//        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"altname" ascending:YES] autorelease];
        sortDescriptor = [[[NSSortDescriptor alloc]
                           initWithKey:@"altname"
                           ascending:YES
                           selector:@selector(localizedCompare:)] autorelease];
    } else {
        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    }
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedItems;    
}

-(MPlace*)getPlaceWithIndex:(int)index {
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index=%@", [NSNumber numberWithInt:index]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([fetchedItems count]>0) {
        return [fetchedItems objectAtIndex:0];
    } else {
        return nil;
    }

}


-(MStation*)getStationWithIndex:(int)index andLineIndex:(int)lineIndex
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lines.index=%@ and index=%@",[NSNumber numberWithInt:lineIndex], [NSNumber numberWithInt:index]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([fetchedItems count]>0) {
        return [fetchedItems objectAtIndex:0];
    } else {
        return nil;
    }
}

-(MStation*)getStationWithName:(NSString*)station forLine:(NSString*)lineName
{
    NSError *error =nil;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lines.name like[c] %@ and name like[c] %@",lineName,station];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if([fetchedItems count] == 0) {
        NSFetchRequest *fetchRequest2 = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest2 setEntity:entity2];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"lines.name like[c] %@",lineName];
        [fetchRequest2 setPredicate:predicate2];
        NSArray *fetchedItems2 = [self.managedObjectContext executeFetchRequest:fetchRequest2 error:&error];
        for (MStation* s in fetchedItems2) {
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
        NSArray *favIndexes = [temp objectForKey:@"favoritePlacesIndexes"];

        if (!temp || !favIndexes)
        {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
            return;
        }
        
                
        for(NSNumber *index in favIndexes){
            
            MPlace *place = [self getPlaceWithIndex:[index integerValue]];
            
            if (place) {
                [place setIsFavorite:[NSNumber numberWithInt:1]];
            }
        }
    }
}

-(void)saveBookmarkFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    tubeAppDelegate *delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *fileName = [NSString stringWithFormat:@"%@_bookmarks.plist",[delegate nameCurrentMap]];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:fileName];
    
    NSArray *favPlaces = [self getFavoritePlacesList];
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:[favPlaces count]];
    
    for (MPlace *place in favPlaces) {
        [temp addObject:place.index];
    }
    
    // create dictionary with values in UITextFields
    NSDictionary *plistDict = [NSDictionary dictionaryWithObject:temp forKey:@"favoritePlacesIndexes"];
    
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

-(void)readLanguageIndex:(NSString*)mapName
{
    int index=0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_language.plist",mapName];
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
            
        index = [[temp objectForKey:@"language"] intValue];
    }

    self.languageIndex=index;
}

-(void)saveLanguageIndex:(int)index
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    tubeAppDelegate *delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *fileName = [NSString stringWithFormat:@"%@_language.plist",[delegate nameCurrentMap]];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:fileName];
    
    // create dictionary with values in UITextFields
    NSDictionary *plistDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:@"language"];
    
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
    
    self.languageIndex=index;
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
            
            NSArray *fromArray = [histDict objectForKey:@"From"]; 
            NSArray *toArray = [histDict objectForKey:@"To"];
            
            MStation *fromStation = [self getStationWithName:[fromArray objectAtIndex:1] forLine:[fromArray objectAtIndex:0]];
            MStation *toStation = [self getStationWithName:[toArray objectAtIndex:1] forLine:[toArray objectAtIndex:0]];
            
            if (fromStation && toStation) {
                
                NSError *error =nil;
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:__managedObjectContext];
                MHistory *newhistory = [[MHistory alloc] initWithEntity:entity insertIntoManagedObjectContext:__managedObjectContext];
                
                newhistory.adate=historyDate;
                newhistory.fromStation=fromStation;
                newhistory.toStation =toStation;
                
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

-(void)addHistory:(NSDate*)date fromStation:(MStation*)fromStation toStation:(MStation*)toStation
{
    NSError *error =nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:__managedObjectContext];
    MHistory *newhistory = [[MHistory alloc] initWithEntity:entity insertIntoManagedObjectContext:__managedObjectContext];    
    newhistory.adate=date;
    newhistory.fromStation=fromStation;
    newhistory.toStation =toStation;
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

-(void)addHistory:(NSDate*)date :(NSString*) fs To:(NSString*) ss FirstLine:(NSInteger) fsl LastLine:(NSInteger) ssl 
{
    MLine *fromLine = [self lineByIndex:fsl];
    MLine *toLine;
  
    if (fsl==ssl) {
        toLine = fromLine;
    } else {
        toLine = [self lineByIndex:ssl];
    }
    
    MStation *fromStation = [self getStationWithName:fs forLine:fromLine.name];
    MStation *toStation = [self getStationWithName:ss forLine:toLine.name];
    
    [self addHistory:date fromStation:fromStation toStation:toStation];
}


-(void)saveHistoryFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    tubeAppDelegate *delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
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
        
        NSString *fromlineName = [history.fromStation name];
        NSString *fromstationName = [[history.fromStation lines] name];
        
        NSString *tolineName = [history.toStation name];
        NSString *tostationName = [[history.toStation lines] name];
        
        NSString *fromKey = @"From";
        NSString *toKey = @"To";
        
        NSArray *fromkeyArray = [NSArray arrayWithObjects:fromstationName,fromlineName, nil];
        NSArray *tokeyArray = [NSArray arrayWithObjects:tostationName,tolineName, nil];
        
        NSDictionary *oneHistDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:fromkeyArray,tokeyArray,nil] forKeys:[NSArray arrayWithObjects:fromKey,toKey,nil]];
        
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