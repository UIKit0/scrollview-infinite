
// BSD License. Author: <jano@jano.com.es>

#define trace(args...) [[Logger singleton] debugWithLevel:kTrace line:__LINE__ funcName:__PRETTY_FUNCTION__ message:args];
#define debug(args...) [[Logger singleton] debugWithLevel:kDebug line:__LINE__ funcName:__PRETTY_FUNCTION__ message:args];
#define info(args...)  [[Logger singleton] debugWithLevel:kInfo  line:__LINE__ funcName:__PRETTY_FUNCTION__ message:args];
#define warn(args...)  [[Logger singleton] debugWithLevel:kWarn  line:__LINE__ funcName:__PRETTY_FUNCTION__ message:args];
#define error(args...) [[Logger singleton] debugWithLevel:kError line:__LINE__ funcName:__PRETTY_FUNCTION__ message:args];

#ifndef LOGGER_LEVEL
#define LOGGER_LEVEL 0 // 0=silent,5=error
#endif

// How to apply color formatting to your log statements:
//
// To set the foreground color:
// Insert the ESCAPE_SEQ into your string, followed by "fg124,12,255;" where r=124, g=12, b=255.
//
// To set the background color:
// Insert the ESCAPE_SEQ into your string, followed by "bg12,24,36;" where r=12, g=24, b=36.
//
// To reset the foreground color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "fg;"
//
// To reset the background color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "bg;"
//
// To reset the foreground and background color (to default values) in one operation:
// Insert the ESCAPE_SEQ into your string, followed by ";"
#define XCODE_COLORS_ESCAPE @"\033["
#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color
#define XCODE_COLORS "XcodeColors"


/** Logger. */
@interface Logger : NSObject

typedef enum {
    kTrace=0, kDebug=1, kInfo=2, kWarn=3, kError=4, KSilent=5
} LoggerLevel;

// silently ignore logs beyond this level
@property (nonatomic, assign) LoggerLevel logThreshold;
@property (nonatomic, assign, getter=isAsync) BOOL async;
@property (nonatomic, assign) BOOL colorize;

+(Logger *)singleton;

-(void) debugWithLevel:(LoggerLevel)level
                  line:(int)line
              funcName:(const char *)funcName
               message:(NSString *)msg, ...;

@end
