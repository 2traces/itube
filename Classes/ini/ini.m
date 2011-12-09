
#import "ini.h"

@implementation INIParser

- init {

	self = [super init];
	sections = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)dealloc {

	[sections release];
	return [super dealloc];
}

@end
