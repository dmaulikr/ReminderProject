//
//  NXPageViewController.m
//  Reminder_restarter
//
//  Created by CornerZhang on 14-8-4.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import "NXPageViewController.h"
#import "NXModelController.h"
#import "NXRemindItemsViewController.h"
#import "NXDataStorage.h"
#import "Page.h"

#define DEBUG 1

@interface NXPageViewController () {
    
}
@property (readonly, strong, nonatomic) NXModelController *modelController;
@end

@implementation NXPageViewController
@synthesize pageLimited;
@synthesize modelController = _modelController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.

    pageLimited = 12;
    _modelController = [[NXModelController alloc] init];
    
    self.delegate = self;
    self.dataSource = self.modelController;

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {	// for iPad
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    }
    self.view.frame = pageViewRect;
    
    NXRemindItemsViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];

    NXDataStorage* storage = [NXDataStorage sharedInstance];
    if ( [storage isEmpty] ) {
        // 如果第一次启动，创建第一个演示页
        Page* firstNewPage = [storage createBlankPage];
        firstNewPage.name = [NSString stringWithFormat:@"新页 %d", 1];
        firstNewPage.pageNumber = [NSNumber numberWithUnsignedInteger:1];
#if DEBUG
    NSLog(@"Running %@ '%@' -- first new page", self.class, NSStringFromSelector(_cmd));
#endif
        
        startingViewController.titleString = firstNewPage.name;
    }else{
        // 载入页的缓冲数据，和当前显示页的表数据
        Page* getFirstPage = [storage getPageAtIndex:0];
#if DEBUG
    NSLog(@"Running %@ '%@' -- get exist page", self.class, NSStringFromSelector(_cmd));
#endif

        startingViewController.titleString = getFirstPage.name;
    }

    NSArray *viewControllers = @[startingViewController];
    [self setViewControllers:viewControllers
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIPageViewController delegate methods

/*
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
}
 */

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController
                   spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        
        UIViewController *currentViewController = self.viewControllers[0];
        NSArray *viewControllers = @[currentViewController];
        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        self.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }

    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    NXRemindItemsViewController *currentViewController = self.viewControllers[0];
    NSArray *viewControllers = nil;

    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self viewControllerAfterViewController:currentViewController];
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self viewControllerBeforeViewController:currentViewController];
        viewControllers = @[previousViewController, currentViewController];
    }
    
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];


    return UIPageViewControllerSpineLocationMid;
}

@end
