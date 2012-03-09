//
//  Schedule.m
//  tube
//
//  Created by vasiliym on 07.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Schedule.h"

/***** Schedule Loader *****/

@interface ScheduleLoader : NSObject <NSXMLParserDelegate> {
@private
    NSMutableDictionary *result;
}

-(NSDictionary*)loadSchedule:(NSString*)fileName;
@end

@implementation ScheduleLoader

-(NSDictionary*)loadSchedule:(NSString *)fileName
{
    result = [NSMutableDictionary dictionary];
    NSString *fn = [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:fn];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    [xmlData release];
    parser.delegate = self;
    if(![parser parse]) {
        NSLog(@"Can't load xml file %@", fileName);
    }
    [parser release];
    return result;
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"route"]) {
        NSString *lineName = [attributeDict valueForKey:@"route"];
        Schedule *sch = [[Schedule alloc] initWithName:lineName andFile:[attributeDict valueForKey:@"file"]];
        [result setValue:sch forKey:lineName];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
}

@end

/***** Schedule *****/

@implementation Schedule
@synthesize lineName;

+(NSDictionary*)loadSchedules:(NSString *)fileName
{
    ScheduleLoader *loader = [[[ScheduleLoader alloc] init] autorelease];
    return [loader loadSchedule:fileName];
}

-(id)initWithName:(NSString*)name andFile:(NSString *)fileName
{
    if((self = [super init])) {
        lineName = [name retain];
        
        
        
        
    }
    return self;
}

@end
