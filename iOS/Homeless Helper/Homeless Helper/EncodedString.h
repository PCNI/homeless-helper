//
//  EncodedString.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/26/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncodedString : NSString
{
    
}

+ (NSString *)URLEncodedString:(NSString *)stringToEncode;

@end