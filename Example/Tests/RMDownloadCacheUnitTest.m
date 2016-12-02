//
//  RMDownloadCacheUnitTest.m
//  RMDownloadAdapter
//
//  Created by Robert Miller on 12/2/16.
//  Copyright © 2016 rjmiller2543. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RMDownloadAdapter/RMDownloadCache.h>

@interface RMDownloadCacheUnitTest : XCTestCase

@property (nonatomic,strong) RMDownloadCache *downloadCache;

@end

@implementation RMDownloadCacheUnitTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.downloadCache = [[RMDownloadCache alloc] init];
    [self.downloadCache setTotalCacheSize:50000];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testAddAndRecallFromCache
{
    NSString *testURL = @"testURL";
    
    RMDownloadModel *downloadModel = [[RMDownloadModel alloc] init];
    downloadModel.url = [NSURL URLWithString:testURL];
    
    [self.downloadCache addObjectToCache:downloadModel];
    
    RMDownloadModel *testModel = [self.downloadCache objectForKey:testURL];
    XCTAssertNotNil(testModel, @"Test that we can successfully add and retrieve model from cache failed");
}

- (void)testCacheEviction
{
    NSString *testURL1 = @"testURL1";
    
    RMDownloadModel *downloadModel1 = [[RMDownloadModel alloc] init];
    downloadModel1.url = [NSURL URLWithString:testURL1];
    
    int twelveMB = 12000;
    NSMutableData* resultData1 = [NSMutableData dataWithCapacity:twelveMB];
    for( unsigned int i = 0 ; i < twelveMB / 4 ; ++i )
    {
        u_int32_t randomBits = arc4random();
        [resultData1 appendBytes:(void*)&randomBits length:4];
    }
    downloadModel1.resultData = resultData1;
    [self.downloadCache addObjectToCache:downloadModel1];
    
    NSString *testURL2 = @"testURL2";
    
    RMDownloadModel *downloadModel2 = [[RMDownloadModel alloc] init];
    downloadModel2.url = [NSURL URLWithString:testURL2];
    
    int fourtyMB = 40000;
    NSMutableData* resultData2 = [NSMutableData dataWithCapacity:fourtyMB];
    for( unsigned int i = 0 ; i < fourtyMB / 4 ; ++i )
    {
        u_int32_t randomBits = arc4random();
        [resultData2 appendBytes:(void*)&randomBits length:4];
    }
    downloadModel2.resultData = resultData2;
    [self.downloadCache addObjectToCache:downloadModel2];
    
    RMDownloadModel *testDownloadModel1 = [self.downloadCache objectForKey:testURL1];
    RMDownloadModel *testDownloadModel2 = [self.downloadCache objectForKey:testURL2];
    XCTAssertNil(testDownloadModel1, @"Tests that the oldest object has been removed failed");
    XCTAssertNotNil(testDownloadModel2, @"Tests that the newest object is still in cache failed");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
