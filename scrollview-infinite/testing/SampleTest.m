
// BSD License. Created by jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>

@interface SampleTest : SenTestCase
@end

@implementation SampleTest

-(void) testSomething {
    STAssertTrue(true,@"");
}

@end
