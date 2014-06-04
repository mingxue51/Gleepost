//
//  GLPWalkthroughModelController.m
//  Gleepost
//
//  Created by Silouanos on 02/06/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPWalkthroughModelController.h"
#import "GLPWalkthoughDataViewController.h"

@interface GLPWalkthroughModelController ()

@property (readonly, strong, nonatomic) NSArray *pageData;

@end

@implementation GLPWalkthroughModelController

@synthesize pageData = _pageData;

-(id)init
{
    self = [super init];
    
    if(self)
    {
        [self initialiseData];
    }
    
    return self;
}

-(void)initialiseData
{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    _pageData = [[dateFormatter monthSymbols] copy];
    
    [self loadXibs];
}

-(void)loadXibs
{
    UIView *firstView = [[[NSBundle mainBundle] loadNibNamed:@"WTFirstScreen" owner:self options:nil] lastObject];
    UIView *secondView = [[[NSBundle mainBundle] loadNibNamed:@"WTSecondScreen" owner:self options:nil] lastObject];
    
    _pageData = [[NSArray alloc] initWithObjects:firstView, secondView, nil];

}

- (GLPWalkthoughDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    GLPWalkthoughDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"GLPWalkthoughDataViewController"];
    dataViewController.dataObject = self.pageData[index];
    [dataViewController setView:self.pageData[index]];
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(GLPWalkthoughDataViewController *)viewController
{
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.pageData indexOfObject:viewController.dataObject];
}

//-(NSInteger)getCurrentIndexWithData:(NSString *)month
//{
//    return [self.pageData indexOfObject:month];
//}

-(NSInteger)numberOfViews
{
    return [self.pageData count];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    NSUInteger index = [self indexOfViewController:(GLPWalkthoughDataViewController *)viewController];
    
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    DDLogDebug(@"pageViewController before index: %ld", (long)index);

    index--;
    
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{

    NSUInteger index = [self indexOfViewController:(GLPWalkthoughDataViewController *)viewController];
   
    if (index == NSNotFound) {
        return nil;
    }
    DDLogDebug(@"pageViewController after index: %ld", (long)index);

    index++;
    
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
