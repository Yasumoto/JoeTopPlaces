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
    NSURL *photoURL = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
    NSData *photo = [[NSData alloc] initWithContentsOfURL:photoURL];
    UIImage *image = [UIImage imageWithData:photo];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.scrollView.minimumZoomScale = MINIMUM_SCROLL_SCALE;
    self.scrollView.maximumZoomScale = MAXIMUM_SCROLL_SCALE;
    self.navigationItem.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
}

- (void) viewWillAppear:(BOOL)animated {
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UIScrollViewDelegate
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}
@end
