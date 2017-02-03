//
//  ViewController.m
//  FOIToDoList
//
//  Created by Cong Nguyen on 1/31/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import "ViewController.h"
#import "FOICustomerService.h"
#import <MagicalRecord/MagicalRecord.h>
#import "MagicalRecordMan.h"

#import "Category+CoreDataClass.h"
#import "Task+CoreDataClass.h"

#import "TasksViewController.h"
#import "AddCategoryViewController.h"
//#import "SWTableViewCell.h"
#import "CategoryTableViewCell.h"
#import "AddCategoryTableViewCell.h"


@interface ViewController () <UITableViewDelegate, UITableViewDataSource, AddCategoryViewControllerDelegate, SWTableViewCellDelegate>


@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) NSString *categoryID;

@property (nonatomic, strong) Category *categoryToEdit;
@property (nonatomic, strong) Category *categoryToDelete;
@property (nonatomic, strong) NSIndexPath *categoryCellIndexToDelete;

@property (nonatomic, weak) IBOutlet UIView *infoView;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;

@property (nonatomic, strong) NSString *passingTitle;


@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray* portraitConstraints;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray* landscapeConstraints;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"Avenir-Black" size:18.0f],NSForegroundColorAttributeName: [UIColor blackColor],NSKernAttributeName: @2}];
    
    self.navigationItem.title = @"CATEGORY";
    UILabel *titleLabel = [UILabel new];
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"Avenir-Black" size:17.0],
                                 NSKernAttributeName: @4};
    titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.navigationItem.title attributes:attributes];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    NSArray *array = [Category MR_findAll];
    self.categoryArray = [[NSMutableArray alloc]init];
    [self.categoryArray addObjectsFromArray:array]; //make it mutable...
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    self.infoView.hidden = YES;
    self.infoView.alpha = 0;
    
    [self.infoButton addTarget:self action:@selector(showInfoView) forControlEvents:UIControlEventTouchUpInside];
    
    
    //NUKE IT TO CLEAN the data
//    NSArray *categoryArray = [Category MR_findAll];
//    NSArray *taskArray = [Task MR_findAll];
////    
////    
//    for (Category *category in categoryArray) {
//        [FOICustomerService deleteCategoryWithID:category.identifier success:^(NSArray *responseArray) {
//            
//        } failure:^(NSError *error) {
//            
//        }];
//    }
//    
//    for (Task *task in taskArray){
//        [FOICustomerService deleteTaskWithID:task.identifier success:^(NSArray *responseArray) {
//            
//        } failure:^(NSError *error) {
//            
//        }];
//    }
//
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(orientation == 0){ //Default orientation
        //UI is in Default (Portrait) -- this is really a just a failsafe.
        [NSLayoutConstraint deactivateConstraints:self.landscapeConstraints];
        [NSLayoutConstraint activateConstraints:self.portraitConstraints];
    }else if(orientation == UIInterfaceOrientationPortrait){
            //Do something if the orientation is in Portrait
        [NSLayoutConstraint deactivateConstraints:self.landscapeConstraints];
        [NSLayoutConstraint activateConstraints:self.portraitConstraints];
    }else if(orientation == UIInterfaceOrientationLandscapeLeft){
        [NSLayoutConstraint deactivateConstraints:self.portraitConstraints];
        [NSLayoutConstraint activateConstraints:self.landscapeConstraints];
                // Do something if Left
    }else if(orientation == UIInterfaceOrientationLandscapeRight){
        [NSLayoutConstraint deactivateConstraints:self.portraitConstraints];
        [NSLayoutConstraint activateConstraints:self.landscapeConstraints];
                    //Do something if right
    }
    [super updateViewConstraints];
    

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        
        [NSLayoutConstraint deactivateConstraints:self.landscapeConstraints];
        [NSLayoutConstraint activateConstraints:self.portraitConstraints];
        
    }else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [NSLayoutConstraint deactivateConstraints:self.portraitConstraints];
        [NSLayoutConstraint activateConstraints:self.landscapeConstraints];
    }
    [super updateViewConstraints];
}


-(void)showInfoView{
    
    self.infoView.hidden = NO;
    
    [self.infoButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.infoButton addTarget:self action:@selector(hideInfoView) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:.3 animations:^{
        self.infoView.alpha = 1;
    }completion:^(BOOL finished) {
        
    }];
    
}

-(void)hideInfoView{
    
    [self.infoButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.infoButton addTarget:self action:@selector(showInfoView) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:.3 animations:^{
        self.infoView.alpha = 0;
    }completion:^(BOOL finished) {
        self.infoView.hidden = YES;
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadCategories{
    
    [self.categoryArray removeAllObjects];
    [self.categoryArray addObjectsFromArray:[Category MR_findAll]];
    [self.tableView reloadData];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return 80.0;
    }else{
        return 64.0;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if (section == 0) {
        return self.categoryArray.count;
    }else{
        return 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.section == 0) {
        CategoryTableViewCell *cell = (CategoryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
        if (!cell) {
            cell = [[CategoryTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CategoryCell"];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        Category *category = self.categoryArray[indexPath.row];
        
        NSString *capString = [category.name uppercaseString];
        
        [cell.categoryTitleLabel setAttributedText:[self addSpacing:4 forString:capString]];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category_id = %@", category.identifier];
        NSNumber *count = [Task MR_numberOfEntitiesWithPredicate:predicate];
        
        NSString *countString = [NSString stringWithFormat:@"%@ TASKS", count];
        
        [cell.taskCountLabel setAttributedText:[self addSpacing:3 forString:countString]];
        
        
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:50.0];
        cell.delegate = self;
        return cell;
        
        
    }else{
        AddCategoryTableViewCell *cell = (AddCategoryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"AddCategoryCell"];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (!cell) {
            cell = [[AddCategoryTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AddCategoryCell"];
        }
        
        return cell;
    }

}


-(NSAttributedString *)addSpacing:(double)spacing forString:(NSString*)string{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    [text addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:spacing] range:NSMakeRange(0, text.length)];
    return text;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (indexPath.section == 0) {
        Category *category = self.categoryArray[indexPath.row];
        self.categoryID = category.identifier;
        
        self.passingTitle = category.name;
        
        [self goToTasks];
    }else{
        [self showAddCategory];
    }
    
}


- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"swipeEditIcon"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"trashEditIcon"]];
    
    return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    switch (index) {
        case 0:{
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            self.categoryToEdit = self.categoryArray[indexPath.row];
            [self showEditCategory];
            break;
            
            
        }
        case 1:{
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            self.categoryCellIndexToDelete = indexPath;
            self.categoryToDelete = self.categoryArray[indexPath.row];
            [self deleteCategory];
            break;
        }
        default:
            break;
    }
}


-(void)deleteCategory{
    
    [self.tableView beginUpdates];
    [self.categoryArray removeObject:self.categoryToDelete];
    [self.tableView deleteRowsAtIndexPaths:@[self.categoryCellIndexToDelete] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    //delete first and make the call later so it doesnt lag
    
    [FOICustomerService deleteCategoryWithID:self.categoryToDelete.identifier success:^(NSArray *responseArray) {
        
        //also going to need to remove it from the tableview
        
        //if success, then we probably want to delete all the tasks that were associated with it as well
        NSString *catID = self.categoryToDelete.identifier;
        [MagicalRecordMan deleteCategory:self.categoryToDelete withCompletion:^(BOOL didComplete) {
            //do other things
            ///like delete all the tasks that were associated with it
            NSArray *deleteTasksArray = [Task MR_findByAttribute:@"category_id" withValue:catID];
            [self deleteAssociatedTasksWithArray:deleteTasksArray];
            
            self.categoryToDelete = nil; //nil it out
            
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"failure to delete");
    }];
    
}


-(void)deleteAssociatedTasksWithArray:(NSArray*)deleteTasksArray{
    
    for (Task *task in deleteTasksArray) {
        [FOICustomerService deleteTaskWithID:task.identifier success:^(NSArray *responseArray) {
            [MagicalRecordMan deleteTask:task withCompletion:^(BOOL didComplete) {
                NSLog(@"was delete successful? %d", didComplete);
            }];
        } failure:^(NSError *error) {
            
        }];
    }
    
}

-(void)goToTasks{
    [self performSegueWithIdentifier:@"TasksViewControllerSegue" sender:nil];
}

-(void)showAddCategory{
    [self performSegueWithIdentifier:@"AddCategorySegue" sender:nil];
}

-(void)showEditCategory{
    [self performSegueWithIdentifier:@"EditCategorySegue" sender:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"TasksViewControllerSegue"]) {
        TasksViewController *tvc = (TasksViewController*)[segue destinationViewController];
        tvc.categoryID = self.categoryID;
        tvc.navigationItem.title = [self.passingTitle uppercaseString];
        
    }else if([[segue identifier] isEqualToString:@"AddCategorySegue"]){
        UINavigationController *navC = [segue destinationViewController];
        AddCategoryViewController *acvc = (AddCategoryViewController*)[navC topViewController];
        acvc.delegate = self;
        acvc.navigationItem.title = @"ADD CATEGORY";
    }else if([[segue identifier] isEqualToString:@"EditCategorySegue"]){
        UINavigationController *navC = [segue destinationViewController];
        AddCategoryViewController *acvc = (AddCategoryViewController*)[navC topViewController];
        acvc.delegate = self;
        acvc.categoryToEdit = self.categoryToEdit;
        acvc.navigationItem.title = @"EDIT CATEGORY";
    }
    
}





@end
