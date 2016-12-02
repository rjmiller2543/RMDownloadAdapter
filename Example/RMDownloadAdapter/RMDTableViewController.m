//
//  RMDTableViewController.m
//  RMDownloadAdapter
//
//  Created by Robert Miller on 12/2/16.
//  Copyright © 2016 rjmiller2543. All rights reserved.
//

#import "RMDTableViewController.h"
#import <RMDownloadAdapter/RMDownloadAdapter.h>

@interface RMDTableViewController ()

@property (nonatomic,strong) RMDownloadAdapter *downloadAdapter;

@end

@implementation RMDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.downloadAdapter = [[RMDownloadAdapter alloc] init];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *urlString = [NSString stringWithFormat:@"http://echo.jsontest.com/section/%ld/row/%ld", (long)indexPath.section, (long)indexPath.row];
    
    RMDownloadAdapterProgressBLock progress = ^(float progress) {
        
    };
    
    RMDownloadAdapterCompletionBlock completion = ^(id object, NSError *error) {
        
        if (error == nil || error.code == RMDownloadAdapterErrorCodeInvalidClass) {
            NSError *jsonSerializationError = nil;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingAllowFragments error:&jsonSerializationError];
            
            if (jsonSerializationError == nil && jsonDictionary != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.textLabel.text = [jsonDictionary objectForKey:@"row"];
                    cell.detailTextLabel.text = [jsonDictionary objectForKey:@"section"];
                });
            }
        }
        
    };
    
    [self.downloadAdapter startDownloadWithURLString:urlString withClass:nil indexPath:indexPath progressBlock:progress completionBlock:completion];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
