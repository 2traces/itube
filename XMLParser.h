//
//  PifXMLParser.h
//  iPif
//
//  Created by SergeyM on 30.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kNoDataComplete @"kMyCompleteNoData"


@interface XMLParser : NSOperation <NSXMLParserDelegate> {
    NSString *xml;

	NSMutableString * _currentItemValue;
	NSMutableArray * nextStationItem;
	NSMutableArray * currentStationItem;
    NSDictionary *nextStationDict;
    NSString *currentStation;
    NSString *nextStation;
	
    NSDateFormatter *formatter;
    BOOL isNoData;
    
    NSMutableDictionary *scheduleDict;
}
@property(nonatomic, retain) NSString *xml;
@property(nonatomic, retain) NSMutableString * currentItemValue;
@property(nonatomic, retain) NSMutableArray * nextStationItem; 
@property(nonatomic, retain) NSMutableArray * currentStationItem; 
@property(nonatomic, retain) NSMutableDictionary *scheduleDict;
@property(nonatomic, retain) NSDictionary *nextStationDict;
@property(nonatomic, retain) NSString *currentStation;
@property(nonatomic, retain) NSString *nextStation;


- (id)initWithData:(NSData *)parseData;


@end