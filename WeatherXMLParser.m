//
//  WeatherXMLParser.m
//  tube
//
//  Created by Сергей on 11.07.13.
//
//

#import "WeatherXMLParser.h"
#import "tubeAppDelegate.h"

@implementation WeatherXMLParser

@synthesize currentItemValue = _currentItemValue;
@synthesize xml;
@synthesize scheduleDict;
@synthesize nextStation;
@synthesize nextStationItem;
@synthesize currentStationItem;
@synthesize currentDayDict;
@synthesize currentDay;
@synthesize tempValue;
@synthesize conditionValue;
@synthesize varValue;


- (id)initWithString:(NSString *)parseString
{
    if (self = [super init]) {
        if (parseString) {
            self.xml = parseString;
        }
        
        
        formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:@"YYYY-MM-DD"];
    }
    
    return self;
}

- (void)main
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSData* aData = [xml dataUsingEncoding:NSUTF8StringEncoding];
    
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:aData];
	
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:YES];
	[parser setShouldReportNamespacePrefixes:YES];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	
	
    if (![self isCancelled]) {
        if ([self.scheduleDict count] > 0) {
            [self performSelectorOnMainThread:@selector(parseCompleteSuccess:)
                                   withObject:self
                                waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(parseCompleteNoData:)
                                   withObject:self
                                waitUntilDone:NO];
        }
    }
    
    self.currentItemValue = nil;
    
    [parser release];
}

static NSString * const kForecastElementName = @"forecast";
static NSString * const kTimeElementName = @"time";
static NSString * const kTemperatureElementName = @"temperature";
static NSString * const kSymbolElementName = @"symbol";

-(void)parseCompleteNoData:(WeatherXMLParser*)myoperation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoDataComplete object:self];
}

-(void)parseCompleteSuccess:(WeatherXMLParser*)myoperation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kParseComplete object:self.scheduleDict];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
	if(nil != qualifiedName){
		elementName = qualifiedName;
	}
    
	if ([elementName isEqualToString:kForecastElementName]) {

        NSMutableDictionary *aDictionary = [[NSMutableDictionary alloc] init];
        self.scheduleDict = aDictionary;
        [aDictionary release];
    
    } else if ([elementName isEqualToString:kTimeElementName]) {
        self.currentDay = [formatter dateFromString:[attributeDict valueForKey:@"day"]];
        
        NSMutableDictionary *aDictionary = [[NSMutableDictionary alloc] init];
        self.currentDayDict = aDictionary;
        [aDictionary release];

    } else if ([elementName isEqualToString:kTemperatureElementName]) {
        self.tempValue = [attributeDict valueForKey:@"day"];
    } else if ([elementName isEqualToString:kSymbolElementName]) {
        self.conditionValue = [attributeDict valueForKey:@"number"];
        self.varValue = [attributeDict valueForKey:@"var"];
    }  else {
        self.currentItemValue = nil;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if(nil != qName){
		elementName = qName;
	}
    
    if ([elementName isEqualToString:kForecastElementName]) {
//        [self.scheduleDict setObject:[NSDate date] forKey:@"timeStamp"];
    } else if ([elementName isEqualToString:kTimeElementName]) {
        [self.scheduleDict setObject:self.currentDayDict forKey:self.currentDay];
    } else if ([elementName isEqualToString:kTemperatureElementName]) {
        [self.currentDayDict setObject:self.tempValue forKey:@"temperature"];
    } else if ([elementName isEqualToString:kSymbolElementName]) {
        [self.currentDayDict setObject:self.conditionValue forKey:@"number"];
        [self.currentDayDict setObject:self.varValue forKey:@"var"];
    }  else {
        self.currentItemValue = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if(nil != self.currentItemValue){
		[self.currentItemValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock{
	//Not needed for now
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	if(parseError.code != NSXMLParserDelegateAbortedParseError) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


-(void)dealloc{
	self.currentItemValue = nil;
    self.scheduleDict = nil;
    
    [xml release];
    [_currentItemValue release];
    [nextStationItem release];
    [currentStationItem release];
    [scheduleDict release];
    [currentDayDict release];
    [currentDay release];
    [nextStation release];
    [tempValue release];
    [conditionValue release];
    [varValue release];
    
    [super dealloc];
}

@end
