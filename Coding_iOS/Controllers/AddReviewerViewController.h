#import <UIKit/UIKit.h>
#import "Projects.h"
#import "MRPR.h"

typedef void(^AddReviewerViewControllerBlock)(Project *project);

@interface AddReviewerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (readwrite, nonatomic, strong) NSMutableArray *reviewers;
@property (readwrite, nonatomic, strong) NSMutableArray *volunteer_reviewers;
@property (nonatomic, strong) Project *currentProject;
@property (strong, nonatomic) MRPR *curMRPR;

-(IBAction)selectRightAction:(id)sender;

@end