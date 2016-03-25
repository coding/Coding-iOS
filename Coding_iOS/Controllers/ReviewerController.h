

#import "BaseViewController.h"
#import "Projects.h"
#import "XTSegmentControl.h"
#import "iCarousel.h"
#import "CategorySearchBar.h"
#import "Users.h"

@interface ReviewerController : BaseViewController<iCarouselDataSource, iCarouselDelegate>
@property (strong, nonatomic) NSArray *segmentItems;
@property (assign, nonatomic) BOOL icarouselScrollEnabled;
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (assign, nonatomic) NSInteger oldSelectedIndex;
@property (strong, nonatomic) iCarousel *myCarousel;
@property (assign, nonatomic) BOOL useNewStyle;
@property (strong, nonatomic) MainSearchBar *mySearchBar;
@property (strong, nonatomic) User *curUser;
@end