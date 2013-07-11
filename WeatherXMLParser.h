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

- (id)initWithString:(NSString *)parseString;

@end