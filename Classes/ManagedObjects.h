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


// все объекты для CoreData собраны в одном месте

@class MLine;
@class MTransfer;

@interface MStation : NSManagedObject

@property (nonatomic, retain) NSNumber* index;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) MLine *lines;
@property (nonatomic, retain) MTransfer* transfer;
@end

@interface MHistory : NSManagedObject

@property (nonatomic, retain) NSDate * adate;
@property (nonatomic, retain) MStation *fromStation;
@property (nonatomic, retain) MStation *toStation;

@end

@interface MLine : NSManagedObject

@property (nonatomic, assign) NSNumber* index;
@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *stations;
@end

@interface MHelper : NSObject <StationListViewProtocol, LineListViewProtocol, BookmarkViewProtocol, HistoryViewProtocol,NSFetchedResultsControllerDelegate> {
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

+ (MHelper *) sharedHelper;

-(void)saveContext;
-(NSURL*)applicationDocumentsDirectory;
-(NSArray*)getLineList;
-(NSArray*)getStationList;
-(NSArray*)getTransferList;
-(MLine*)lineByName:(NSString*)name;
-(MLine*)lineByIndex:(int)index;
-(MStation*)getStationWithName:(NSString*)station forLine:(NSString*)lineName;
-(MStation*)getStationWithIndex:(int)index andLineIndex:(int)lineIndex;
// возвращает станции для линии
// сортировка по индексу
-(NSArray*)getStationsForLineIndex:(int)lineIndex;

-(void)addHistory:(NSDate*)date :(NSString*) fs To:(NSString*) ss FirstLine:(NSInteger) fsl LastLine:(NSInteger) ssl; 

-(void)saveBookmarkFile;
-(void)readBookmarkFile;
-(void)saveHistoryFile;
-(void)readHistoryFile;




@end
