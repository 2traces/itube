//
//  WeatherXMLParser.h
//  tube
//
//  Created by Сергей on 11.07.13.
//
//

#import <Foundation/Foundation.h>

#define kNoDataComplete @"kMyCompleteNoData"

@interface WeatherXMLParser : NSOperation <NSXMLParserDelegate> {
    NSString *xml;
    
	NSMutableString * _currentItemValue;
	NSMutableArray * nextStationItem;
	NSMutableArray * currentStationItem;
	
    NSDateFormatter *formatter;
    BOOL isNoData;
    
    NSMutableDictionary *scheduleDict;
}
@property(nonatomic, retain) NSString *xml;
@property(nonatomic, retain) NSMutableString * currentItemValue;
@property(nonatomic, retain) NSMutableArray * nextStationItem;
@property(nonatomic, retain) NSMutableArray * currentStationItem;
@property(nonatomic, retain) NSMutableDictionary *scheduleDict;
@property(nonatomic, retain) NSMutableDictionary *currentDayDict;
@property(nonatomic, retain) NSDate *currentDay;
@property(nonatomic, retain) NSString *nextStation;
@property(nonatomic, retain) NSString *tempValue;
@property(nonatomic, retain) NSString *conditionValue;
@property(nonatomic, retain) NSString *varValue;

- (id)initWithString:(NSString *)parseString;

@end