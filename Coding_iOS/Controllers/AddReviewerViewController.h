#import <UIKit/UIKit.h>
#import "Projects.h"

typedef void(^AddReviewerViewControllerBlock)(Project *project);

@interface AddReviewerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (readwrite, nonatomic, strong) NSMutableArray *reviewers;
@property (readwrite, nonatomic, strong) NSMutableArray *volunteer_reviewers;

@end