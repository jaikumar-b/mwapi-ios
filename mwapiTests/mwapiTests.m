//
//  mwapiTests.m
//  mwapiTests
//
//  Created by Brion on 11/5/12.
//  Copyright (c) 2012 Wikimedia Foundation. All rights reserved.
//

#import "mwapiTests.h" 
#import "MWApi.h"
#import "MWApiMultipartRequestBuilder.h"

@implementation mwapiTests

- (void)setUp
{
    [super setUp];
    apiURL = [NSURL URLWithString:@"http://localhost:8888/mediawiki/api.php"];
    mwapi = [[MWApi alloc] initWithApiUrl:apiURL];
}

-(void)setNewMwapiInstance
{
    mwapi = [[MWApi alloc] initWithApiUrl:apiURL];
}

- (void)tearDown
{
    [super tearDown];
}

-(void)testSiteMatrix
{
    MWApiRequestBuilder *builder = [[mwapi action:@"sitematrix"] param:@"smlimit" :[NSNumber numberWithInt:10]];
    MWApiResult *result = [mwapi makeRequest:[builder buildRequest:@"GET"]];
    NSArray *nodes = [result getNodesWithXpath:@"//sitematrix"];
    STAssertTrue(nodes!=nil, nil);
    int nodeCount = [[result getNodesWithXpath:@"//sitematrix/language"] count];
    STAssertTrue(nodeCount == 10, nil);
}

-(void)testLogout
{
    [self setNewMwapiInstance];
    STAssertTrue([[mwapi loginWithUsername:@"jasoncigar" andPassword:@"Wiki123"] isEqualToString:@"Success"],nil);
    STAssertFalse([@"+\\" isEqualToString:[mwapi editToken]], nil);
    [mwapi logout];
    STAssertTrue([@"+\\" isEqualToString:[mwapi editToken]], nil);
}

-(void)testValidateLogin
{
    [self setNewMwapiInstance];
    STAssertFalse([mwapi validateLogin],nil);
    STAssertTrue([[mwapi loginWithUsername:@"jasoncigar" andPassword:@"Wiki123"] isEqualToString:@"Success"],nil);
    STAssertTrue([mwapi validateLogin],nil);
}

-(void)testAnonymousEditToken
{
    [self setNewMwapiInstance];
    STAssertTrue([@"+\\" isEqualToString:[mwapi editToken]],nil);
}

-(void)testLoggedInEditAttempt
{
    [self setNewMwapiInstance];
    STAssertTrue([[mwapi loginWithUsername:@"jasoncigar" andPassword:@"Wiki123"] isEqualToString:@"Success"],nil);
}

-(void)testLogin
{
    [self setNewMwapiInstance];
    STAssertTrue([[mwapi loginWithUsername:@"jasoncigar" andPassword:@"Wiki123"] isEqualToString:@"Success"],nil);
}

-(void)testAuthCookieLogin
{
    [self setNewMwapiInstance];
    STAssertTrue([[mwapi loginWithUsername:@"jasoncigar" andPassword:@"Wiki123" withCookiePersistence:YES] isEqualToString:@"Success"],nil);
    NSArray *authCookie = [mwapi authCookie];
    STAssertNotNil(authCookie, nil);
    
    [self setNewMwapiInstance];
    STAssertFalse([mwapi validateLogin], nil);
    STAssertTrue([@"+\\" isEqualToString:[mwapi editToken]], nil);
    [mwapi setAuthCookie:authCookie];
    STAssertEqualObjects(authCookie, [mwapi authCookie], nil);
    STAssertTrue([mwapi validateLogin], nil);
    STAssertFalse([@"+\\" isEqualToString:[mwapi editToken]], nil);
}

@end
