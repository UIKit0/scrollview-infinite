
// BSD License. Author: <jano@jano.com.es>

#import "Logger.h"

@implementation Logger


+(Logger *)singleton {
    static dispatch_once_t pred;
    static Logger *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[Logger alloc] init];
        shared.logThreshold = LOGGER_LEVEL;
        shared.async = FALSE;
        //char *xcode_colors = getenv(XCODE_COLORS);
        //shared.colorize = (xcode_colors && (strcmp(xcode_colors, "YES") == 0));
        shared.colorize = true;
        // https://github.com/robbiehanson/XcodeColors
        NSLog(XCODE_COLORS_ESCAPE @"fg209,57,168;" @"Color test." XCODE_COLORS_RESET);
    });
    return shared;
}


-(void) debugWithLevel:(LoggerLevel)level
                  line:(int)line
              funcName:(const char *)funcName
               message:(NSString *)msg, ... {
    
    const char* const levelName[6] = { "TRACE", "DEBUG", " INFO", " WARN", "ERROR", "SILENT" };
    const char* const levelColor[6] = { "fg220,220,220;", "fg255,255,255;", "fg185,224,150;", "fg255,247,194;", "fg255,0,0;", "fg255,255,255;" };
    
    va_list ap;         // define variable ap of type va
    va_start (ap, msg); // initializes ap
	msg = [[NSString alloc] initWithFormat:msg arguments:ap];
    va_end (ap);        // invalidates ap
    
    BOOL includeClassInfo = TRUE; // should we add class info?
    {
        // Process format characters at the beginning of the string:
        //   - The ` character means skip class/method/line info.
        //   - The > character means use white bg + black fg.
        NSCharacterSet *format = [NSCharacterSet characterSetWithCharactersInString:@"`>"];
        int i = 0;
        for (; i<[msg length]; i++) {
            unichar character = [msg characterAtIndex:i];
            if (![format characterIsMember:character]) break;
            switch (character) {
                case '`':
                    includeClassInfo = FALSE;
                    break;
                default:
                    break;
            }
        }
        if (i>0) msg = [msg substringFromIndex:i];
    }
    
    // Remove user's \n at beginning and end. I'll handle the \n thank you.
    // msg = [msg stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    
    if (level>=self.logThreshold){
        
        // if we didn't start the message with ` then add class/method/line
        if (includeClassInfo){
            msg = [NSString stringWithFormat:@"%s %50s:%3d - %@", levelName[level], funcName, line, msg];
        }
        
        if (self.colorize){
            msg = [NSString stringWithFormat:@"%@%s%@%@", XCODE_COLORS_ESCAPE, levelColor[level], msg, XCODE_COLORS_RESET];
        }
        
        if ([self isAsync]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    fprintf(stdout,"%s\n", [msg UTF8String]);
                });
            });
        } else {
            fprintf(stdout,"%s\n", [msg UTF8String]);
        }
        
    }
}


@end


