//
//  WebService.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/26/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebServiceDelegate

-(void)webServiceCallFinished:(NSMutableData *)responseData;

@end

@interface WebService : NSObject
{
	id<WebServiceDelegate> delegate;
	NSMutableData *_webServiceResponseData;
}

@property(assign) id<WebServiceDelegate> delegate;

@property(nonatomic, retain)NSMutableData *webServiceResponseData;

-(void)callWebService:(NSMutableURLRequest *)request;

@end