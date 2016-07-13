
### Coding_iOS客户端项目介绍 
*编译环境：Xcode-Version 7.2 (7C68)*
#### 让项目跑起来先
Clone 代码后，初次执行前，需要双击运行根目录下的`bootstrap`脚本。这个过程涉及到下载依赖，可能会有点久，需耐心等待。

**Tip：由于用到了 submodule，所以必需要把 git 仓库 clone 到本地，而不是只点击‘下载’按钮下载 zip 文件！！！**

代码托管|在线讨论|任务管理|冒泡社交|项目文档
------------ | ------------- | ------------| ------------| ------------
![图片1][1]|![图片2][2]|![图片3][3]|![图片4][4]|![图片5][5]



####下面介绍一下文件的大概目录先：
    .
    ├── Coding_iOS
    │   ├── Models：数据类
    │   ├── Views：视图类
    │   │   ├── CCell：所有的CollectionViewCell都在这里
    │   │   ├── Cell：所有的TableViewCell都在这里
    │   │   └── XXX：ListView（项目、动态、任务、讨论、文档、代码）和InputView（用于聊天和评论的输入框）
    │   ├── Controllers：控制器，对应app中的各个页面
    │   │   ├── Login：登录页面
    │   │   ├── RootControllers：登录后的根页面
    │   │   ├── MeSetting：设置信息页面
    │   │   └── XXX：其它页面
    │   ├── Images：app中用到的所有的图片都在这里
    │   ├── Resources：资源文件
    │   ├── Util：一些常用控件和Category、Manager之类
    │   │   ├── Common
    │   │   ├── Manager
    │   │   ├── OC_Category
    │   │   └── ObjcRuntime
    │   └── Vendor：用到的一些第三方类库，一般都有改动
    │       ├── AFNetworking
    │       ├── AGEmojiKeyboard
    │       ├── ASProgressPopUpView
    │       ├── ActionSheetPicker
    │       ├── FontAwesome+iOS
    │       ├── MJPhotoBrowser
    │       ├── MLEmojiLabel
    │       ├── NSDate+Helper
    │       ├── NSStringEmojize
    │       ├── PPiAwesomeButton
    │       ├── QBImagePickerController
    │       ├── RDVTabBarController
    │       ├── SMPageControl
    │       ├── SVPullToRefresh
    │       ├── SWTableViewCell
    │       ├── UMENG
    │       ├── UMessage_Sdk_1.1.0
    │       ├── XGPush
    │       ├── XTSegmentControl
    │       └── iCarousel
    └── Pods：项目使用了[CocoaPods](http://code4app.com/article/cocoapods-install-usage)这个类库管理工具



####再说下项目的启动流程：
在AppDelegate的启动方法中，先设置了一下Appearance的样式，然后根据用户的登录状态选择是去加载登录页面LoginViewController，还是登录后的RootTabViewController页面。

RootTabViewController继承自第三方库[RDVTabBarController](https://github.com/robbdimitrov/RDVTabBarController)。在RootTabViewController里面依次加载了Project_RootViewController、MyTask_RootViewController、Tweet_RootViewController、Message_RootViewController、Me_RootViewController五个RootViewController，后续的页面跳转都是基于这几个RootViewController引过去的。

####项目里面还有些需要注意的点
 - Coding_NetAPIManager：基本上app的所有请求接口都放在了这里。网络请求使用的是[AFNetworking](https://github.com/AFNetworking/AFNetworking)库，与服务器之间的数据交互格式用的都是json（与[Coding](https://coding.net)使用的api一致）。
  
 - 关于推送：刚开始是用的[友盟推送](http://www.umeng.com/)，后来又改用了[腾讯信鸽](http://xg.qq.com/)，因为要兼顾旧版本app的推送，所以服务器是同时保留了两套推送。但是为了确保新版本的app不同时收到双份相同的推送消息，所以当前代码里还存留了友盟的sdk，用于解除推送token与友盟Alias的绑定。
 
 - 关于ProjectViewController：这个就是进入到某个项目之后的页面，这里包含了项目的动态、任务、讨论、文档、代码、成员各类信息，而且每类信息里面还可能会有新的分类（如‘任务’里面还分有各个成员的任务）；这个页面相当的臃肿，我对它们做了拆分，都放在视图类Views目录下面。 首先是把数据列表独立成了对应的XXXListView（如ProjectTaskListView）；然后如果需要标签切换的话，会再新建一个XXXsView（如：ProjectTasksView），在这个视图中，上面会放一个切换栏[XTSegmentControl](https://github.com/xushao1990/XTNews)显示各个标签，下面放一个[iCarousel](https://github.com/nicklockwood/iCarousel)可以滑动显示各个标签的内容；最后这些视图都会存储在ProjectViewController的projectContentDict变量里面，根据顶部导航栏选择的类别，去显示或隐藏对应的视图。
 
 - 关于UIMessageInputView：这个是私信聊天的输入框。因为这个输入框好多地方都有用到（冒泡、任务、讨论的评论还有私信），所以这个输入框就写成了一个相对独立的控件，并且直接显示在了keyWindow里面而不是某个视图里。这里的表情键盘用的是[AGEmojiKeyboard](https://github.com/ayushgoel/AGEmojiKeyboard)改写了一下。
 
 - 关于Emoji：这个，[Coding](https://coding.net)站点的emoji都是用的图片，而且服务器是不接受大部分emoji字符的，所以刚开始的时候app一直不能处理emoji表情；又因为没有emoji图片名和emoji code码的对应关系表，所以拖了很久都没能做好转换。直到在github上面找到了[NSStringEmojize](https://github.com/diy/NSStringEmojize)这个项目；试了一下，虽然也不能全部解析，但是大部分表情都能正确显示了，不能更感谢。
 
 - 关于如何正确显示冒泡的内容：api返回的数据里面，冒泡内容都是html格式，需要做一下预处理；其实私信、讨论里面的内容也是html。解析html的类名是HtmlMediaItem，它是先用[hpple](https://github.com/topfunky/hpple)对html进行了解析，然后把对应的media元素和对应的位置做一个存储，显示的时候便可以根据需要来显示了。

####最后说下[CocoaPods](http://cocoapods.org/)里面用到的第三方类库
 - [SDWebImage](https://github.com/rs/SDWebImage)：图片加载
 - [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel)：富文本的label，可点击链接
 - [RegexKitLite](https://github.com/wezm/RegexKitLite)：正则表达式
 - [hpple](https://github.com/topfunky/hpple)：html解析
 - [MBProgressHUD](https://github.com/jdg/MBProgressHUD)：hud提示框
 - [ODRefreshControl](https://github.com/Sephiroth87/ODRefreshControl)：下拉刷新
 - [TPKeyboardAvoiding](https://github.com/michaeltyson/TPKeyboardAvoiding)：有文字输入时，能根据键盘是否弹出来调整自身显示内容的位置
 - [JDStatusBarNotification](https://github.com/jaydee3/JDStatusBarNotification)：状态栏提示框
 - [BlocksKit](https://github.com/zwaldowski/BlocksKit)：block工具包。将很多需要用delegate实现的方法整合成了block的形式
 - [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)：基于响应式编程思想的oc实践（是个好东西呢）
 
####License
Coding is available under the MIT license. See the LICENSE file for more info.


  [1]: Screenshots/image1.png
  [2]: Screenshots/image2.png
  [3]: Screenshots/image3.png
  [4]: Screenshots/image4.png
  [5]: Screenshots/image5.png
