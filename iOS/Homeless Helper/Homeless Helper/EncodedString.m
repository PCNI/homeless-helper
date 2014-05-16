//
//  EncodedString.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/26/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "EncodedString.h"

@implementation EncodedString

+ (NSString *)URLEncodedString:(NSString *)stringToEncode
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[stringToEncode UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' || 
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end