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
@synthesize currentStation;
@synthesize nextStation;
@synthesize nextStationItem;
@synthesize currentStationItem;
@synthesize nextStationDict;

- (id)initWithString:(NSString *)parseString
{
    if (self = [super init]) {
        if (parseString) {
            self.xml = parseString;
        }
        
        
        formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:@"HH:mm:ss"];
    }
    
    return self;
}

// the main function for this NSOperation, to start the parsing
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

static NSString * const kDayfElementName = @"dayf";
static NSString * const kDayElementName = @"day";
static NSString * const kHiElementName = @"hi";
static NSString * const kLowElementName = @"low";

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
    
	if ([elementName isEqualToString:kDayfElementName]) {

        NSMutableDictionary *aDictionary = [[NSMutableDictionary alloc] init];
        self.scheduleDict = aDictionary;
        [aDictionary release];
    
    } else if ([elementName isEqualToString:kDayElementName]) {
        self.currentStation = [attributeDict valueForKey:@"dt"];
    } else if ([elementName isEqualToString:kHiElementName]) {
        self.currentItemValue = [NSMutableString string];
    }  else {
        self.currentItemValue = nil;
    }


//        self.currentStation = [attributeDict valueForKey:@"name"];
//        self.currentStationItem = [NSMutableArray array];
//        isNoData=NO;
//    } else if([elementName isEqualToString:kTimetableElementName] ) {
//        self.nextStation = [attributeDict valueForKey:@"next_station"];
//        self.nextStationItem = [NSMutableArray array];
//    } else if([elementName isEqualToString:kTimeElementName] ) {
//		self.currentItemValue = [NSMutableString string];
//    } else {
//		self.currentItemValue = nil;
//	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if(nil != qName){
		elementName = qName;
	}
    
    if ([elementName isEqualToString:kDayfElementName]) {
        [self.scheduleDict setObject:[NSDate date] forKey:@"timeStamp"];
    } else if ([elementName isEqualToString:kDayElementName]) {
        [self.scheduleDict setObject:self.nextStation forKey:self.currentStation];
        
    } else if ([elementName isEqualToString:kHiElementName]) {
        self.nextStation  = self.currentItemValue;
    }  else {
        self.currentItemValue = nil;
    }

    
        //        [self.scheduleDict setObject:self.currentStationItem forKey:self.currentStation];
//    } else if ([elementName isEqualToString:kTimetableElementName]) {
//        self.nextStationDict = [[[NSDictionary alloc] initWithObjectsAndKeys:self.nextStationItem, self.nextStation,nil] autorelease];
//        [self.currentStationItem addObject:self.nextStationDict];
//    } else if ([elementName isEqualToString:kTimeElementName]) {
//		[self.nextStationItem addObject:[formatter dateFromString:self.currentItemValue]];
//    } else {
//		self.currentItemValue = nil;
//	}
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
    [formatter release];
	[scheduleDict release];
	[super dealloc];
}

@end
