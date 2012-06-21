//
//  SectionInfo.h
//  tube
//
//  Created by sergey on 11.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagedObjects.h"

@class SectionHeaderView;

@interface SectionInfo : NSObject 

@property (nonatomic,assign) BOOL open;
@property (nonatomic,retain) MCategory* line;
@property (nonatomic,retain) SectionHeaderView* headerView;

@property (nonatomic,retain,readonly) NSMutableArray *rowHeights;

- (NSUInteger)countOfRowHeights;
- (id)objectInRowHeightsAtIndex:(NSUInteger)idx;
- (void)insertObject:(id)anObject inRowHeightsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRowHeightsAtIndex:(NSUInteger)idx;
- (void)replaceObjectInRowHeightsAtIndex:(NSUInteger)idx withObject:(id)anObject;
- (void)insertRowHeights:(NSArray *)rowHeightArray atIndexes:(NSIndexSet *)indexes;
- (void)removeRowHeightsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceRowHeightsAtIndexes:(NSIndexSet *)indexes withRowHeights:(NSArray *)rowHeightArray;

@end
