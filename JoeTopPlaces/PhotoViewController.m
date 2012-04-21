//
//  PhotoViewController.m
//  JoeTopPlaces
//
//  Created by Joe Smith on 4/20/12.
//  Copyright (c) 2012 bjoli.com. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation PhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;

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
    UIImage *image = [UIImage imageNamed:@"beer.jpg"];
    self.imageView = [[UIImageView alloc] initWithImage:image];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = self.imageView.bounds.size;
}

- (void) viewDidAppear:(BOOL)animated {
    NSLog(@"flashed...");
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

@end
