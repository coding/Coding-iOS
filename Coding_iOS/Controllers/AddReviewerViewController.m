#import "AddReviewerViewController.h"
#import "ReviewCell.h"
#import "ProjectListCell.h"
#import "ProjectListTaCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"

//新系列 cell
#import "ProjectAboutMeListCell.h"
#import "ProjectAboutOthersListCell.h"
#import "ProjectPublicListCell.h"
#import "SVPullToRefresh.h"
#import "Reviewer.h"

@interface AddReviewerViewController ()<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (readwrite, nonatomic, strong) NSMutableArray *allrReviewers;
@end

@implementation AddReviewerViewController

static NSString *const kTitleKey = @"kTitleKey";
static NSString *const kValueKey = @"kValueKey";

-(void)viewDidLoad {
    self.title = @"评审人";
    self.allrReviewers = [[NSMutableArray alloc] init];
    [self.myTableView registerNib:[UINib nibWithNibName:kCellIdentifier_ReviewCell bundle:nil] forCellReuseIdentifier:kCellIdentifier_ReviewCell];
    self.myTableView.separatorStyle = NO;
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"确定";
    self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
    _mySearchBar = ({
     UISearchBar *searchBar = [[UISearchBar alloc] init];
     searchBar.delegate = self;
     [searchBar sizeToFit];
     [searchBar setPlaceholder:@"项目名称/创建人"];
     searchBar;
     });
     [self.myTableView sizeToFit];
     _myTableView.tableHeaderView = _mySearchBar;
}

- (void)viewWillAppear:(BOOL)animated {
    for(int i = 0; i < self.reviewers.count; i ++) {
        [self.allrReviewers addObject:self.reviewers[i]];
    }
    
    for(int i = 0; i < self.volunteer_reviewers.count; i ++) {
        [self.allrReviewers addObject:self.volunteer_reviewers[i]];
    }
}

- (id)initWithFrame:(CGRect)frame projects:(Projects *)projects block:(AddReviewerViewControllerBlock)block  tabBarHeight:(CGFloat)tabBarHeight
{
    //self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
#pragma mark Table M

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.allrReviewers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ReviewCell forIndexPath:indexPath];
    
    //   [cell configureCellWithHeadIconURL:@"test" reviewIconURL:@"PointLikeHead" userName:@"test" userState:@"test"];
    [cell initCellWithReviewer:self.allrReviewers[indexPath.row]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ReviewCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    currentCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}
#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.mySearchBar resignFirstResponder];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchProjectWithStr:searchText];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self searchProjectWithStr:searchBar.text];
}

- (void)searchProjectWithStr:(NSString *)searchString{
    NSMutableArray* arry = [[NSMutableArray alloc] init];
  
    for(int i = 0; i < self.reviewers.count; i ++) {
        [arry addObject:self.reviewers[i]];
    }
    
    for(int i = 0; i < self.volunteer_reviewers.count; i ++) {
        [arry addObject:self.volunteer_reviewers[i]];
    }
    // strip out all the leading and trailing spaces
    NSString *strippedStr = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedStr.length > 0)
    {
        searchItems = [strippedStr componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems)
    {
        // each searchString creates an OR predicate for: name, global_key
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"reviewer.name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // at this OR predicate to ourr master AND predicate
        NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    NSCompoundPredicate *finalCompoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    
    self.allrReviewers = [[arry filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    [self.myTableView reloadData];
}

@end