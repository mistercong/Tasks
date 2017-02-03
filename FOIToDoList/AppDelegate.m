//
//  AppDelegate.m
//  FOIToDoList
//
//  Created by Cong Nguyen on 1/31/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import "AppDelegate.h"

#import <MagicalRecord/MagicalRecord.h>
#import "FOICustomerService.h"
#import "MagicalRecordMan.h"

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController *rootNav;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [MagicalRecord setupCoreDataStack];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *lnc = [storyboard instantiateViewControllerWithIdentifier:@"LoadingNavigationController"];
    self.rootNav = lnc;
    self.window.rootViewController = lnc;
    [self.window makeKeyAndVisible];
    
    [FOICustomerService getCategoriesWithSuccess:^(NSArray *responseArray) {
        //        [self.categoryArray addObjectsFromArray:responseArray];
        
        [MagicalRecordMan saveCategoriesWithArray:responseArray completion:^(BOOL didComplete) {
            //if completed, then we need to move on to the category screen
            [self setCategoryListViewNavControllerAsRootViewController];
        }];
        
    } failure:^(NSError *error) {
        
    }];
    
    [FOICustomerService getTasksWithSuccess:^(NSArray *responseArray) {
        
        [MagicalRecordMan saveTasksWithArray:responseArray completion:^(BOOL didComplete) {
            //if completed then we need to move on to the category screen
            [self setCategoryListViewNavControllerAsRootViewController];
        }];
        
    } failure:^(NSError *error) {
        
    }];
    
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [MagicalRecord cleanUp];
}


-(void)setCategoryListViewNavControllerAsRootViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *obnc = [storyboard instantiateViewControllerWithIdentifier:@"CategoryListViewNavController"];
    [self setRootViewController:obnc];
}



// set the window's root view controller using a cross dissolve transition
- (void)setRootViewController:(UIViewController *)controller
{
    if ([self.window.rootViewController isEqual:controller]) {
        return;
    }
    
    if (self.window.rootViewController) {
        [UIView transitionWithView:self.window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent
                        animations:^{
                            //Quick disable animation to avoid flicker
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            self.window.rootViewController = controller;
                            [UIView setAnimationsEnabled:oldState];
                        }
                        completion:nil];
    } else {
        self.window.rootViewController = controller;
    }
}


@end
