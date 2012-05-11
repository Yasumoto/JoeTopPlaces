//
//  RecentPhotosTableViewController.h
//  JoeTopPlaces
//
//  Created by Joe Smith on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentPhotosTableViewController : UITableViewController
- (IBAction)refresh:(id)sender;
@property (strong, nonatomic) NSArray *recentPhotos;
@end
