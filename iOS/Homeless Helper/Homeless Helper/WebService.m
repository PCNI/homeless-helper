//
//  WebService.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/26/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "WebService.h"

@implementation WebService

@synthesize webServiceResponseData = _webServiceResponseData;
@synthesize delegate;

-(void)callWebService:(NSMutableURLRequest *)request
{
	DLog(@"WebService.callWebService");
	[self setWebServiceResponseData: [[NSMutableData data] retain]];
    
	[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	DLog(@"WebService.callWebService -- response");
	[_webServiceResponseData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	DLog(@"WebService.callWebService -- data");
	[_webServiceResponseData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	DLog(@"Connection failed: %@", [error description]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	DLog(@"WebService.callWebService -- end top");
	[delegate webServiceCallFinished:_webServiceResponseData];
	DLog(@"WebService.callWebService - end");
}


#pragma mark -
#pragma mark dont verify ssl certs

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end