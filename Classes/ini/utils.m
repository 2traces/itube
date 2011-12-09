
#include <string.h>
#include <ctype.h>

#import "ini.h"

@implementation INIParser (Utilities)

- (char *)ltrim: (char *)line {
	
	while (*line && isspace (*line)) line++;
	return line;
}

- (void)rtrim: (char *)line {
	char * begin;
	
	begin = line;
	line += (strlen (line) -1);
	while ((line >= begin) && isspace (*line)) line--;
	
	line [1] = 0;
	return;
}

- (char *)trim: (char *)line
{
	[self rtrim: line];
	return [self ltrim: line];
}

@end
