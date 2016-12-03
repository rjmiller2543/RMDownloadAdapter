# RMDownloadAdapter

[![CI Status](http://img.shields.io/travis/rjmiller2543/RMDownloadAdapter.svg?style=flat)](https://travis-ci.org/rjmiller2543/RMDownloadAdapter)
[![Version](https://img.shields.io/cocoapods/v/RMDownloadAdapter.svg?style=flat)](http://cocoapods.org/pods/RMDownloadAdapter)
[![License](https://img.shields.io/cocoapods/l/RMDownloadAdapter.svg?style=flat)](http://cocoapods.org/pods/RMDownloadAdapter)
[![Platform](https://img.shields.io/cocoapods/p/RMDownloadAdapter.svg?style=flat)](http://cocoapods.org/pods/RMDownloadAdapter)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

or

From your terminal, if you have cocoapods installed - run this command

```ruby
pod try RMDownloadAdapter
```

If you do not have cocoapods, then first install it by running this command
```ruby
sudo gem install cocoapods
```

## Requirements

## Installation

RMDownloadAdapter is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RMDownloadAdapter"
```

or just download/clone this repo and copy past the class files

To use, simply import into your implementation file

```objective-c
#import <RMDownloadAdapter/RMDownloadAdapter.h>
```

Create and use the RMDownloadAdapter by init, or use the sharedInstance if sharing Cache among different controllers
and calling the start download or cancel methods with an optional progress and a mandatory completion handler

```objective-c
RMDownloadAdapter *downloadAdapter = [[RMDownloadAdapter alloc] init];

NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

RMDownloadAdapterCompletionBlock completionBlock = ^(id object, NSError *error) {
    imageView.image = object;
};

[downloadAdapter startDownloadWithURLString:@"https://i.redd.it/2tm3btii5g0y.jpg" withClass:[UIImage class] indexPath:indexPath progressBlock:nil completionBlock:completionBlock];

```

or

```objective-c
NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

RMDownloadAdapterCompletionBlock completionBlock = ^(id object, NSError *error) {
    imageView.image = object;
};

[[RMDownloadAdapter sharedInstance] startDownloadWithURLString:@"https://i.redd.it/2tm3btii5g0y.jpg" withClass:[UIImage class] indexPath:indexPath progressBlock:nil completionBlock:completionBlock];
```


## Author

rjmiller2543, MBA11

## License

RMDownloadAdapter is available under the MIT license. See the LICENSE file for more info.
