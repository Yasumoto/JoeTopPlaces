//
//  PhotosFromPlaceTableViewController.m
//  JoeTopPlaces
//
//  Created by Joe Smith on 4/20/12.
//  Copyright (c) 2012 bjoli.com. All rights reserved.
//

#import "PhotosFromPlaceTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface PhotosFromPlaceTableViewController ()
@property (strong, nonatomic) NSArray *photos;
-(void) addPhoto:(NSDictionary *)photo toDefaults:(NSUserDefaults *)defaults;
@end

@implementation PhotosFromPlaceTableViewController

@synthesize location = _location;
@synthesize photos = _photos;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos {
    if (_photos != photos) {
        _photos = photos;
        if (self.tableView.window) [self.tableView reloadData];
    }

}

- (IBAction)refresh:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    dispatch_queue_t downloadPhotoListQueue = dispatch_queue_create("download photo list", NULL);
    dispatch_async(downloadPhotoListQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.location maxResults:50];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
            self.photos = photos;
        });
    });
    dispatch_release(downloadPhotoListQueue);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self refresh:self.navigationItem.rightBarButtonItem];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) addPhoto:(NSDictionary *)photo toDefaults:(NSUserDefaults *)defaults {
    NSArray *recentPhotos = [defaults arrayForKey:@"recent photos"];
    for (NSDictionary *addedPhoto in recentPhotos) {
        if ([addedPhoto isEqualToDictionary:photo]) {
            return;
        }
    }
    NSArray *photos = [[[NSMutableArray alloc] initWithObjects:photo, nil] arrayByAddingObjectsFromArray:recentPhotos];
    [defaults setValue:photos forKey:@"recent photos"];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewPhoto"]) {
        if ([segue.destinationViewController isKindOfClass:[PhotoViewController class]]) {
            NSDictionary *photo = [self.photos objectAtIndex:[self.tableView indexPathForCell:sender].row];
            [self addPhoto:photo toDefaults:[NSUserDefaults standardUserDefaults]];
            [segue.destinationViewController setPhoto:photo];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photos From Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    NSString *title = [photo objectForKey:FLICKR_PHOTO_TITLE];
    if (title.length == 0) {
        title = [photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
    }
    if (title.length == 0) {
        title = @"Unknown";
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = [photo objectForKey:FLICKR_PHOTO_DESCRIPTION];

    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
    // Return NO if you do not want the specified item to be editable.
    return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {

 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


@end
