//
//  ManagedObjects.h
//  tube
//
//  Created by Vasiliy Makarov on 07.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "StationListViewController.h"
#import "LineListViewController.h"
#import "BookmarkViewController.h"
#import "HistoryViewController.h"
#import "FastAccessTableViewController.h"


// все объекты для CoreData собраны в одном месте

@class MCategory;
@class MTransfer;

@interface MItem : NSManagedObject

@property (nonatomic, retain) NSNumber* index;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) MTransfer* transfer;


@end

@interface MHistory : NSManagedObject

@property (nonatomic, retain) NSDate * adate;
@property (nonatomic, retain) MItem *theItem;

@end

@interface MCategory : NSManagedObject

@property (nonatomic, assign) NSNumber* index;
@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *items;
@end

@interface MHelper : NSObject <StationListViewProtocol, LineListViewProtocol, BookmarkViewProtocol, HistoryViewProtocol, FastAccessTableViewProtocol, NSFetchedResultsControllerDelegate> {
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

+ (MHelper *) sharedHelper;

-(void)saveContext;
-(void)clearContent;
-(NSURL*)applicationDocumentsDirectory;
-(NSArray*)getCategoryList;
-(NSArray*)getItemList;
-(NSArray*)getTransferList;
-(MCategory*)categoryByName:(NSString*)name;
-(MCategory*)categoryByIndex:(int)index;
-(MItem*)getItemWithName:(NSString*)item forCategories:(NSArray*)categoryNames;
-(MItem*)getItemWithIndex:(int)index andCategoryIndex:(int)categoryIndex;
// возвращает станции для линии
// сортировка по индексу
-(NSArray*)getItemForCategoryIndex:(int)lineIndex;

-(void)addHistory:(NSDate*)date item:(NSString*)item categories:(NSArray*) categories;

-(void)saveBookmarkFile;
-(void)readBookmarkFile:(NSString*)mapName;
-(void)saveHistoryFile;
-(void)readHistoryFile:(NSString*)mapName;




@end
