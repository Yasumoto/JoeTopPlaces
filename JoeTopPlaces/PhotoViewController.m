//
//  PhotoViewController.m
//  JoeTopPlaces
//
//  Created by Joe Smith on 4/20/12.
//  Copyright (c) 2012 bjoli.com. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"

#define MINIMUM_SCROLL_SCALE 0.5;
#define MAXIMUM_SCROLL_SCALE 2.0;

@interface PhotoViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation PhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photo = _photo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.minimumZoomScale = MINIMUM_SCROLL_SCALE;
    self.scrollView.maximumZoomScale = MAXIMUM_SCROLL_SCALE;

}

- (void) viewWillAppear:(BOOL)animated {
    dispatch_queue_t downloadPhotoQueue = dispatch_queue_create("downlooad photo from flickr", NULL);
    dispatch_async(downloadPhotoQueue, ^{
        NSURL *photoURL = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
        NSLog(@"We are downloading a photo located at: %@", photoURL);
        NSData *photo = [[NSData alloc] initWithContentsOfURL:photoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:photo];
            self.imageView = [[UIImageView alloc] initWithImage:image];
            self.navigationItem.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
            [self.scrollView addSubview:self.imageView];
            self.scrollView.zoomScale = 1;
            self.scrollView.contentSize = self.imageView.bounds.size;
            CGFloat widthZoom = self.scrollView.bounds.size.width / self.imageView.image.size.width;
            CGFloat heightZoom = self.scrollView.bounds.size.height / self.imageView.image.size.height;
            if (widthZoom > heightZoom) {
                self.scrollView.zoomScale = widthZoom;
            }
            else {
                self.scrollView.zoomScale = heightZoom;
            }
        });
    });
    dispatch_release(downloadPhotoQueue);
}

- (void) viewDidAppear:(BOOL)animated {
    [self.scrollView flashScrollIndicators];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark UIScrollViewDelegate
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}
@end
