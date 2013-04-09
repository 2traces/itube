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

@class MLine;
@class MTransfer;
@class MCategory;

@interface MItem : NSManagedObject

@property (nonatomic, retain) NSNumber* index;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSNumber* posX;
@property (nonatomic, retain) NSNumber* posY;
@property (nonatomic, retain) MTransfer* transfer;

@end


@interface MPlace : NSManagedObject

@property (nonatomic, retain) NSNumber* index;
@property (nonatomic, retain) NSNumber* accessLevel;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSNumber* posX;
@property (nonatomic, retain) NSNumber* posY;

@end

@interface MCategory : NSManagedObject

@property (nonatomic, assign) NSNumber* index;
@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *image_normal;
@property (nonatomic, retain) NSString *image_highlighted;
@property (nonatomic, retain) NSSet *items;
@end

@interface PhotosSetConf : NSManagedObject

@property (nonatomic, retain) NSNumber* photosCount;
@property (nonatomic, retain) NSString* photosPrefix;
@property (nonatomic, retain) NSString* photosExt;

@end

@interface MMedia : NSManagedObject

@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) MPlace* place;
@property (nonatomic, retain) NSString* mediaType;
@property (nonatomic, retain) PhotosSetConf* photosSet;
@property (nonatomic, retain) NSString* videoPath;
@property (nonatomic, assign) NSNumber* index;
@property (nonatomic, assign) NSNumber* repeatCount;
@property (nonatomic, retain) NSString* previewPath;

@end

@interface MStation : NSManagedObject

@property (nonatomic, retain) NSNumber* index;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * altname;
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

@interface MHelper : NSObject <StationListViewProtocol, LineListViewProtocol, BookmarkViewProtocol, HistoryViewProtocol, FastAccessTableViewProtocol, NSFetchedResultsControllerDelegate> {
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) int languageIndex;

+ (MHelper *) sharedHelper;

-(void)saveContext;
-(void)clearContent;
-(NSURL*)applicationDocumentsDirectory;
-(NSArray*)getLineList;
-(NSArray*)getStationList;
-(NSArray*)getTransferList;

-(NSArray*)getCategoriesList;
-(MCategory*)categoryByName:(NSString*)name;
-(NSArray*)getPlacesForCategoryIndex:(int)catIndex;
-(MPlace*)getPlaceWithIndex:(int)index;
-(NSArray*)getFavoritePlacesList;

-(MLine*)lineByName:(NSString*)name;
-(MMedia*)mediaByFilename:(NSString*)filename;
-(MLine*)lineByIndex:(int)index;
-(MCategory*)categoryByIndex:(int)index;
-(MStation*)getStationWithName:(NSString*)station forLine:(NSString*)lineName;
-(MStation*)getStationWithIndex:(int)index andLineIndex:(int)lineIndex;
// возвращает станции для линии
// сортировка по индексу
-(NSArray*)getStationsForLineIndex:(int)lineIndex;

-(void)readLanguageIndex:(NSString*)mapName;
-(void)saveLanguageIndex:(int)index;

-(void)addHistory:(NSDate*)date :(NSString*) fs To:(NSString*) ss FirstLine:(NSInteger) fsl LastLine:(NSInteger) ssl; 

-(void)saveBookmarkFile;
-(void)readBookmarkFile:(NSString*)mapName;
-(void)saveHistoryFile;
-(void)readHistoryFile:(NSString*)mapName;




@end
