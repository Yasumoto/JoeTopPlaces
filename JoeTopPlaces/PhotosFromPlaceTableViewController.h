//
//  PhotosFromPlaceTableViewController.h
//  JoeTopPlaces
//
//  Created by Joe Smith on 4/20/12.
//  Copyright (c) 2012 bjoli.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosFromPlaceTableViewController : UITableViewController
- (IBAction)refresh:(id)sender;
@property (strong, nonatomic) NSDictionary *location;
@end
