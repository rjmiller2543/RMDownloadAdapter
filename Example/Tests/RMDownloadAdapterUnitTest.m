//
//  RMDownloadAdapterUnitTest.m
//  RMDownloadAdapter
//
//  Created by Robert Miller on 12/2/16.
//  Copyright © 2016 rjmiller2543. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RMDownloadAdapter/RMDownloadAdapter.h>

@interface RMDownloadAdapterUnitTest : XCTestCase

@property (nonatomic,strong) RMDownloadAdapter *downloadAdapter;

@end

@implementation RMDownloadAdapterUnitTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.downloadAdapter = [[RMDownloadAdapter alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testJSONDownloadWithProgress {
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Copmletion of JSON Download"];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:10 inSection:12];
    NSString *urlString = [NSString stringWithFormat:@"http://echo.jsontest.com/section/%ld/row/%ld", (long)indexPath.section, (long)indexPath.row];
    
    RMDownloadAdapterProgressBLock progress = ^(float progress) {
        XCTAssertLessThanOrEqual(progress, 1.0f);
    };
    
    RMDownloadAdapterCompletionBlock completion = ^(id object, NSError *error) {
        
        if (error == nil || error.code == RMDownloadAdapterErrorCodeInvalidClass) {
            NSError *jsonSerializationError = nil;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingAllowFragments error:&jsonSerializationError];
            
            if (jsonSerializationError == nil && jsonDictionary != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *row = [jsonDictionary objectForKey:@"row"];
                    NSString *section = [jsonDictionary objectForKey:@"section"];
                    XCTAssertEqualObjects(row, @"10", @"JSON row was correct");
                    XCTAssertEqualObjects(section, @"12", @"JSON section was correct");
                    [completionExpectation fulfill];
                });
            }
        }
        
    };
    
    [self.downloadAdapter startDownloadWithURLString:urlString withClass:nil indexPath:indexPath progressBlock:progress completionBlock:completion];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testImageDownloadWithouProgress {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Copmletion of JSON Download"];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    RMDownloadAdapterCompletionBlock completionBlock = ^(id object, NSError *error) {
        XCTAssertNotNil(object);
        [completionExpectation fulfill];
    };
    
    [self.downloadAdapter startDownloadWithURLString:@"https://i.redd.it/2tm3btii5g0y.jpg" withClass:[UIImage class] indexPath:indexPath progressBlock:nil completionBlock:completionBlock];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testCancelDownload {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Completion of non-canceled Image Download"];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    RMDownloadAdapterCompletionBlock completionBlock = ^(id object, NSError *error) {
        XCTAssertThrows(@"Completion Should not happen when download is canceled");
        [completionExpectation fulfill];
    };
    
    [self.downloadAdapter startDownloadWithURLString:@"https://i.redd.it/2tm3btii5g0y.jpg" withClass:[UIImage class] indexPath:indexPath progressBlock:nil completionBlock:completionBlock];
    [self.downloadAdapter cancelDownloadAtIndexPath:indexPath];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertNoThrow(@"Passed because the completion was never called");
        [completionExpectation fulfill]; //this is a test pass
    });
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testConcurrentDownloadsWithCancellation {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Completion of non-canceled Image Download"];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    RMDownloadAdapterCompletionBlock completionBlock = ^(id object, NSError *error) {
        XCTAssertNotNil(object);
        //[completionExpectation fulfill];
    };
    
    
    NSIndexPath *cancelIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    RMDownloadAdapterCompletionBlock completionBlockForCanceled = ^(id object, NSError *error) {
        XCTAssertThrows(@"Completion Should not happen when download is canceled");
        [completionExpectation fulfill];
    };
    
    [self.downloadAdapter startDownloadWithURLString:@"https://i.redd.it/2tm3btii5g0y.jpg" withClass:[UIImage class] indexPath:indexPath progressBlock:nil completionBlock:completionBlock];
    [self.downloadAdapter startDownloadWithURLString:@"https://i.redd.it/2tm3btii5g0y.jpg" withClass:[UIImage class] indexPath:cancelIndexPath progressBlock:nil completionBlock:completionBlockForCanceled];
    [self.downloadAdapter cancelDownloadAtIndexPath:cancelIndexPath];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertNoThrow(@"Passed because the completion was never called");
        [completionExpectation fulfill]; //this is a test pass
    });
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
