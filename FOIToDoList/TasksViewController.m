//
//  TasksViewController.m
//  FOIToDoList
//
//  Created by Cong Nguyen on 2/1/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import "TasksViewController.h"
#import "FOICustomerService.h"
#import "Task+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>
#import "AddTaskViewController.h"
#import "TaskTableViewCell.h"
#import "MagicalRecordMan.h"

@interface TasksViewController () <UITableViewDataSource, UITableViewDelegate, AddTaskViewControllerDelegate, TaskTableViewCellDelegate, SWTableViewCellDelegate, CAAnimationDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tasksArray;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *longDateFormatter;
@property (nonatomic, strong) NSIndexPath *taskCellIndexToDelete;
@property (nonatomic, strong) Task *taskToDelete;
@property (nonatomic, strong) Task *taskToEdit;

@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
//    NSArray *tasks = [Task MR_findByAttribute:@"category_id" withValue:self.categoryID];
    NSArray *tasks = [Task MR_findByAttribute:@"category_id" withValue:self.categoryID andOrderBy:@"completed,due" ascending:YES];
    
    //need to order by completed being at bottom
    
    self.tasksArray = [[NSMutableArray alloc]init];
    [self.tasksArray addObjectsFromArray:tasks];
    
    [self.addButton addTarget:self action:@selector(showAddTask) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"MM/dd/YY"];
    
    self.longDateFormatter = [[NSDateFormatter alloc]init];
    [self.longDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    self.navigationItem.leftBarButtonItem = [self getBackButton];
    
    
}


-(UIBarButtonItem*)getBackButton{
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    customView.backgroundColor = [UIColor clearColor];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(12, 12, 20, 20)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [button setImage:[UIImage imageNamed:@"backIcon"]forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:button];
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc]initWithCustomView:button];
    [settingBarButton setTarget:self];
    return settingBarButton;
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshTasks{
    
    NSArray *tasks = [Task MR_findByAttribute:@"category_id" withValue:self.categoryID andOrderBy:@"completed,due" ascending:YES];
    [self.tasksArray removeAllObjects];
    [self.tasksArray addObjectsFromArray:tasks];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tasksArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TasksCell"];
    
    
    if (!cell) {
        cell = [[TaskTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TasksCell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.aDelegate = self;
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:50.0];
    cell.delegate = self;
    
    
    Task *task = self.tasksArray[indexPath.row];
    [cell.aDescriptionLabel setAttributedText: [self addSpacing:.9 forString:task.aDescription]];
    
    
    if ([task.completed isEqualToString:@"1"]) {
        
        
        //cross out
        NSMutableAttributedString *mutAttString = [[self addSpacing:1 forString:task.name]mutableCopy];
        [mutAttString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0, mutAttString.length)];
        [cell.titleLabel setAttributedText: mutAttString];
        
        //set the button to complete
        [cell.checkButton setImage:[UIImage imageNamed:@"smallCompletedIcon"] forState:UIControlStateNormal];
        //setthe completed date
        [cell.dateLabel setAttributedText:[self addSpacing:1.7 forString:[NSString stringWithFormat:@"COMPLETED: %@",[self.dateFormatter stringFromDate:[self.longDateFormatter dateFromString:task.due]]]]];
    }else{
        
        [cell.titleLabel setAttributedText: [self addSpacing:1 forString:task.name]];
        
        [cell.checkButton setImage:[UIImage imageNamed:@"unselectedCircle"] forState:UIControlStateNormal];
        //convert the date
        
        NSMutableAttributedString *muttDue = [[self addSpacing:1.7 forString:[NSString stringWithFormat:@"DUE: %@", [self.dateFormatter stringFromDate:[self.longDateFormatter dateFromString:task.due]]]]mutableCopy];
        
        
        NSDate *today = [NSDate date];
        NSDate *dueDate = [self.longDateFormatter dateFromString:task.due];
        
        NSTimeInterval timeBetween = [dueDate timeIntervalSinceDate:today];
        double secondsInHour = 3600;
        NSInteger hours = timeBetween/secondsInHour;
        
        if (hours <= 24) {
            //need to turn the duedate red
            NSDictionary *atts = @{NSForegroundColorAttributeName:[UIColor colorWithRed:255.0f/255.0f green:0 blue:80.0f/255.0f alpha:1]};
            [muttDue addAttributes:atts range:NSMakeRange(0, muttDue.length)];
        }
        
        [cell.dateLabel setAttributedText:muttDue];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    self.taskToEdit = self.tasksArray[indexPath.row];
    [self showSeeTask];
    
}

-(NSAttributedString *)addSpacing:(double)spacing forString:(NSString*)string{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    [text addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:spacing] range:NSMakeRange(0, text.length)];
    return text;
}

-(void)checkMarkButtonTapped:(SWTableViewCell *)cell{
    
    Task *task = self.tasksArray[[self.tableView indexPathForCell:cell].row];
    TaskTableViewCell *taskCell = (TaskTableViewCell*)cell;
    
    if ([task.completed isEqualToString:@"1"]) {
        
        //mark as the NOT completed
        task.completed = @"0";
        task.completedDate = @"";

        NSAttributedString *normalAttString = [self addSpacing:1 forString:taskCell.titleLabel.text];
        taskCell.titleLabel.attributedText = nil;
        CATransition *transition = [CATransition new];
        transition.delegate = self;
        transition.type = kCATransitionFromLeft;
        transition.duration = .3f;
        taskCell.titleLabel.attributedText = normalAttString;
        [taskCell.titleLabel.layer addAnimation:transition forKey:@"transition"];
        
        
        [taskCell.checkButton setImage:[UIImage imageNamed:@"unselectedCircle"] forState:UIControlStateNormal];
        [taskCell.checkButton.layer addAnimation:transition forKey:@"transition"];
        //convert the date
        [taskCell.dateLabel setAttributedText: [self addSpacing:1.7 forString:[NSString stringWithFormat:@"DUE: %@", [self.dateFormatter stringFromDate:[self.longDateFormatter dateFromString:task.due]]]]];
        [taskCell.dateLabel.layer addAnimation:transition forKey:@"transition"];
        
        
        [self updateTask:task];
        
    }else{

        //mark as the completed completed
        task.completed = @"1";
        task.completedDate = [self.longDateFormatter stringFromDate:[NSDate date]];
    
        NSNumber *strikeSize = [NSNumber numberWithInt:1];
        NSDictionary *strikeThroughAttribute = [NSDictionary dictionaryWithObject:strikeSize forKey:NSStrikethroughStyleAttributeName];
        
        NSMutableAttributedString* strikeThroughText = [[NSMutableAttributedString alloc] initWithString:taskCell.titleLabel.text attributes:strikeThroughAttribute];
        [strikeThroughText addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:1] range:NSMakeRange(0, strikeThroughText.length)];
        
        taskCell.titleLabel.attributedText = nil;
        CATransition *transition = [CATransition new];
        transition.delegate = self;
        transition.type = kCATransitionFromLeft;
        transition.duration = .3f;
        taskCell.titleLabel.attributedText = strikeThroughText;
        [taskCell.titleLabel.layer addAnimation:transition forKey:@"transition"];
        
        //set the button to complete
        [taskCell.checkButton setImage:[UIImage imageNamed:@"smallCompletedIcon"] forState:UIControlStateNormal];
        [taskCell.checkButton.layer addAnimation:transition forKey:@"transition"];
        //setthe completed date
        [taskCell.dateLabel setAttributedText:[self addSpacing:1.7 forString:[NSString stringWithFormat:@"COMPLETED: %@",[self.dateFormatter stringFromDate:[self.longDateFormatter dateFromString:task.completedDate]]]]];
        
        [taskCell.dateLabel.layer addAnimation:transition forKey:@"transition"];
        
        [self updateTask:task];
        
        
        
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
            self.taskToEdit = self.tasksArray[indexPath.row];
            [self showEditTask];
            break;
            
            
        }
        case 1:{
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            self.taskCellIndexToDelete = indexPath;
            self.taskToDelete = self.tasksArray[indexPath.row];
            [self deleteTask];
            break;
        }
        default:
            break;
    }
}



-(void)showAddTask{
    [self performSegueWithIdentifier:@"AddTaskSegue" sender:nil];
}

-(void)showEditTask{
    [self performSegueWithIdentifier:@"EditTaskSegue" sender:nil];
}

-(void)showSeeTask{
    [self performSegueWithIdentifier:@"SeeTaskSegue" sender:nil];
}

-(void)updateTask:(Task*)task{
    
    //should save the task to persistant store first to make it feel like there is no lag time.
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    
    [FOICustomerService updateTaskWithID:task.identifier Name:task.name description:task.aDescription categoryID:task.category_id due:task.due completed:task.completed success:^(NSArray *responseArray) {
        NSLog(@"SUCCESS");
        
    } failure:^(NSError *error) {
        NSLog(@"failure to update the task");
    }];
}


-(void)deleteTask{
    
    [FOICustomerService deleteTaskWithID:self.taskToDelete.identifier success:^(NSArray *responseArray) {
        
        [self.tableView beginUpdates];
        [self.tasksArray removeObject:self.taskToDelete];
        [self.tableView deleteRowsAtIndexPaths:@[self.taskCellIndexToDelete] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        
        [MagicalRecordMan deleteTask:self.taskToDelete withCompletion:^(BOOL didComplete) {
            self.taskToDelete = nil;
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"failure to delete a task.");
    }];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"AddTaskSegue"]) {
        UINavigationController *navC = [segue destinationViewController];
        AddTaskViewController *atvc = (AddTaskViewController*)[navC topViewController];
        atvc.categoryID = self.categoryID;
        atvc.delegate = self;
        atvc.navigationItem.title = @"ADD TASK";
    }else if([[segue identifier] isEqualToString:@"EditTaskSegue"]) {
        UINavigationController *navC = [segue destinationViewController];
        AddTaskViewController *atvc = (AddTaskViewController*)[navC topViewController];
        atvc.delegate = self;
        atvc.taskToEdit = self.taskToEdit;
        atvc.navigationItem.title = @"TASK";
    }else if([[segue identifier] isEqualToString:@"SeeTaskSegue"]) {
        UINavigationController *navC = [segue destinationViewController];
        AddTaskViewController *atvc = (AddTaskViewController*)[navC topViewController];
        atvc.delegate = self;
        atvc.taskToEdit = self.taskToEdit;
        atvc.viewMode = YES;
        atvc.navigationItem.title = @"TASK";
    }
}


@end
