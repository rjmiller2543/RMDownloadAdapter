//
//  RMDCollectionViewController.m
//  RMDownloadAdapter
//
//  Created by Robert Miller on 11/30/16.
//  Copyright © 2016 rjmiller2543. All rights reserved.
//

#import "RMDCollectionViewController.h"
#import <RMDownloadAdapter/RMDownloadAdapter.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface RMDCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong) NSArray *dataSource;
@property(nonatomic,strong) RMDownloadAdapter *downloadAdapter;

@end

@implementation RMDCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    /*  https://i.redd.it/2tm3btii5g0y.jpg  http://i.imgur.com/H498PBE.jpg  https://i.redd.it/jnkfs93rzqzx.jpg */
    self.dataSource = [[NSArray alloc] initWithObjects:@"https://i.redd.it/2tm3btii5g0y.jpg", @"https://i.redd.it/e5uylwsqzizx.jpg", @"https://i.redd.it/jnkfs93rzqzx.jpg", @"https://i.redd.it/ain3qywj8lzx.png", @"https://i.redd.it/foe2t4fn3ozx.png", @"https://i.redd.it/uz7clsht3ezx.jpg", @"https://i.redd.it/ini77kpxtgzx.png", @"https://i.redd.it/578x04g9kazx.png", @"https://i.redd.it/8yzefezlygzx.png", @"https://i.redd.it/nroylcti37zx.png", @"https://i.redd.it/f2pm5uiim7zx.png", @"https://i.redd.it/ioxwlod3u6zx.png", @"https://i.redd.it/hn28lyqen5zx.png", @"https://i.redd.it/bb3mcv3mc0zx.png", @"https://i.redd.it/fowtnso693zx.png", @"https://i.redd.it/ibn19t23u0zx.jpg", @"https://i.redd.it/agzi2rlcgtyx.png", @"https://i.redd.it/5doe7fjbw3zx.png", nil];
    
    self.downloadAdapter = [[RMDownloadAdapter alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor lightGrayColor];
    
    // Configure the cell
    UIImageView *imageView = nil;
    
    for (UIView *subview in cell.contentView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            imageView = (UIImageView *)subview;
            imageView.image = nil;
            break;
        }
    }
    
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    }
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [cell.contentView addSubview:imageView];
    
    MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:cell.contentView];
    [progressHUD setMode:MBProgressHUDModeDeterminate];
    
    RMDownloadAdapterProgressBLock progressBlock = ^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressHUD showAnimated:YES];
            [progressHUD setProgress:progress];
        });
    };
    
    __block UIImageView *blockImageView = imageView;
    RMDownloadAdapterCompletionBlock completionBlock = ^(id object, NSError *error) {
        if (error == nil && [object isKindOfClass:[UIImage class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                blockImageView.image = object;
                [progressHUD hideAnimated:YES];
            });
        } else if ([error code] == RMDownloadAdapterErrorCodeInvalidClass && [object isKindOfClass:[NSData class]]) {
            UIImage *image = [UIImage imageWithData:object];
            dispatch_async(dispatch_get_main_queue(), ^{
                blockImageView.image = image;
                [progressHUD hideAnimated:YES];
            });
        } else {
            [blockImageView setImage:[UIImage imageNamed:@"exclamation_mark-100"]];
        }
    };
    
    [self.downloadAdapter startDownloadWithURLString:[self.dataSource objectAtIndex:indexPath.row] withClass:[UIImage class] indexPath:indexPath progressBlock:progressBlock completionBlock:completionBlock];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}
*/
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    [self.downloadAdapter cancelDownloadAtIndexPath:indexPath];
}


#pragma mark - UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeMake(self.view.frame.size.width / 2 - 8, self.view.frame.size.height / 4);
    return cellSize;
}

@end
