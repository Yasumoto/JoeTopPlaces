//
//  FirstViewController.m
//  JoeTopPlaces
//
//  Created by Joe Smith on 4/18/12.
//  Copyright (c) 2012 bjoli.com. All rights reserved.
//

#import "PopularPhotosTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotosFromPlaceTableViewController.h"

@interface PopularPhotosTableViewController ()
@property (strong, nonatomic) NSDictionary *photoDictionaries;
- (NSArray *) sortPlaces:(NSArray *)places;
@end

@implementation PopularPhotosTableViewController

@synthesize photoDictionaries = _photoDictionaries;

#pragma mark - Places Helper Methods
- (NSArray *) sortPlaces:(NSArray *)places {
    return [self merge:places];
}

- (NSArray *) merge:(NSArray *)places {
    if ([places count] > 1) {
        NSRange leftRange;
        leftRange.length = [places count] / 2;
        leftRange.location = 0;
        NSRange rightRange;
        rightRange.length = [places count] / 2;
        rightRange.location = [places count] / 2;
        NSMutableArray *left = [[self merge:[places subarrayWithRange:leftRange]] mutableCopy];
        NSMutableArray *right = [[self merge:[places subarrayWithRange:rightRange]] mutableCopy];
        NSMutableArray *sortedPlaces = [[NSMutableArray alloc] init];
        while ([left count] > 0 && [right count] > 0) {
            NSString *leftName = [[left objectAtIndex:0] objectForKey:FLICKR_PLACE_NAME];
            NSString *rightName = [[right objectAtIndex:0] objectForKey:FLICKR_PLACE_NAME];
            if ([leftName compare:rightName] == NSOrderedAscending) {
                [sortedPlaces addObject:[left objectAtIndex:0]];
                [left removeObjectAtIndex:0];
            }
            else {
                [sortedPlaces addObject:[right objectAtIndex:0]];
                [right removeObjectAtIndex:0];
            }
        }
        if ([left count] > 0) {
            return [sortedPlaces arrayByAddingObjectsFromArray:left];
        }
        else {
            return [sortedPlaces arrayByAddingObjectsFromArray:right];
        }
    }
    return places;
}

- (NSDictionary *) splitPlacesFromArray:(NSArray *)places {
    NSMutableDictionary *placesByCountry = [[NSMutableDictionary alloc] init];
    for (NSDictionary *location in places) {
        NSString *country = [[[location objectForKey:FLICKR_PLACE_NAME] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]] lastObject];
        NSMutableArray *photosInCountry = [placesByCountry objectForKey:country];
        if (!photosInCountry) {
            photosInCountry = [[NSMutableArray alloc] init];
            [placesByCountry setValue:photosInCountry forKey:country];
        }
        [photosInCountry addObject:location];
    }
    for (NSString *placeKey in [placesByCountry allKeys]) {
        [placesByCountry setValue:[self sortPlaces:[placesByCountry valueForKey:placeKey]] forKey:placeKey] ;
    }
    return [NSDictionary dictionaryWithDictionary:placesByCountry];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    dispatch_queue_t downloadTopPlacesQueue = dispatch_queue_create("top places downloader", NULL);
    dispatch_async(downloadTopPlacesQueue, ^{
        NSDictionary *places = [self splitPlacesFromArray:[FlickrFetcher topPlaces]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoDictionaries = places;
        });
    });
    dispatch_release(downloadTopPlacesQueue);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) setPhotoDictionaries:(NSDictionary *)photoDictionaries {
    if (_photoDictionaries != photoDictionaries) {
        _photoDictionaries = photoDictionaries;
        // Update the view
        [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.photoDictionaries allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.photoDictionaries valueForKey:[[[self.photoDictionaries allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Popular Photo Description Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSString *placeLocationName = [[[self.photoDictionaries valueForKey:[[[self.photoDictionaries allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:FLICKR_PLACE_NAME];
    NSString *cityName = [[placeLocationName componentsSeparatedByString:@","] objectAtIndex:0];
    cell.textLabel.text = cityName;
    cell.detailTextLabel.text = [placeLocationName stringByReplacingOccurrencesOfString:[cityName stringByAppendingString:@", "] withString:@""] ;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[self.photoDictionaries allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([@"ViewLocationPhotos" isEqualToString:[segue identifier]]) {
        if ([segue.destinationViewController isKindOfClass:[PhotosFromPlaceTableViewController class]]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            NSDictionary *place = [[self.photoDictionaries valueForKey:[[[self.photoDictionaries allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            [segue.destinationViewController setLocation:place];
            [[segue.destinationViewController navigationItem] setTitle:[[[place objectForKey:FLICKR_PLACE_NAME] componentsSeparatedByString:@","] objectAtIndex:0]];
        }
    }
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (IBAction)refresh:(id)sender {
}
@end
