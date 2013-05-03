
// BSD License. Created by jano@jano.com.es

#import "CGRectFunctions.h"

CGRect CGRectSetX(CGRect rect, CGFloat x){
    return CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height);
}
