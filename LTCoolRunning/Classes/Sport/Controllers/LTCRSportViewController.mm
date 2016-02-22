//
//  LTCRSportViewController.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/30.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRSportViewController.h"
#import "BMapKit.h"
#import "AFNetworking.h"
#import "LTCRXMPPTool.h"
#import "LTCRUserInfo.h"
#import "NSString+LTCRNMd5.h"
//#import "BMKAnnotationView.h"
//#import "BMKAnnotation.h"
/** 是TrailStart就在地图上画轨迹线，否则不画 */
typedef enum {
    TrailStart = 1,
    TrailEnd
}Trail;
#define BMKSPAN 0.002
@interface LTCRSportViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
@property (nonatomic, strong) BMKMapView *mapView;
///百度地图位置服务
@property (nonatomic, strong) BMKLocationService *bmkLocationService;
///用户标记是否画轨迹线
@property (nonatomic, assign, getter=isTrail) Trail trail;
/** 起点大头针 和 终点大头针*/
@property (nonatomic, strong) BMKPointAnnotation *startPoint;
@property (nonatomic, strong) BMKPointAnnotation *endPoint;

///用来保存位置的数组
@property (nonatomic, strong) NSMutableArray *locationMutableArray;

///记录上一次位置
@property (nonatomic, strong) CLLocation *preLocation;
///本次运动的距离
@property (nonatomic, assign) CGFloat sumDistance;
///本次运动的持续时间
@property (nonatomic, assign) CGFloat sportTime;
///本次运动消耗的热量
@property (nonatomic, assign) CGFloat sumHeat;

///地图上的遮盖线
@property (nonatomic, strong) BMKPolyline *polyLine;

@property (weak, nonatomic) IBOutlet UIButton *startSportButton;
@property (weak, nonatomic) IBOutlet UIButton *stopRunningButton;
@property (weak, nonatomic) IBOutlet UIView *pauseSportView;
///点击完成运动后要显示的视图
@property (weak, nonatomic) IBOutlet UIView *completeSportView;

@end

@implementation LTCRSportViewController
#pragma mark - 各种服务的初始化
- (NSMutableArray *)locationMutableArray {
    if (!_locationMutableArray) {
        _locationMutableArray = [NSMutableArray array];
    }
    return _locationMutableArray;
}
/** 初始化百度位置服务 */
- (void)initBMLocationService {
    self.bmkLocationService = [[BMKLocationService alloc] init];
    [BMKLocationService setLocationDistanceFilter:5];
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
}
/** 设置百度的mapView的一些属性 */
- (void)setMapViewProperty {
    //显示定位图层
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.rotateEnabled = NO;
    self.mapView.showMapScaleBar = YES;
    //比例尺的位置
    self.mapView.mapScaleBarPosition = CGPointMake(self.view.frame.size.width - 50, self.view.frame.size.height - 25);
    //定位图层 自定义样式参数
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc] init];
    displayParam.isAccuracyCircleShow = YES;
    displayParam.isRotateAngleValid = NO;
    displayParam.locationViewOffsetX = 0;
    displayParam.locationViewOffsetY = 0;
    [self.mapView updateLocationViewWithParam:displayParam];
}

#pragma mark - 视图控制器的生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.mapView atIndex:0];
    [self initBMLocationService];
    [self setMapViewProperty];
    self.trail = TrailEnd;
    self.bmkLocationService.delegate = self;
    self.mapView.delegate = self;
    [self.bmkLocationService startUserLocationService];
    //对暂停按钮增加手势识别
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(pauseButtonSwipe)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.stopRunningButton addGestureRecognizer:swipeGestureRecognizer];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.stopRunningButton.hidden = YES;
    self.pauseSportView.hidden = YES;
    self.completeSportView.hidden = YES;
}
#pragma mark - 按钮的响应方法
//点击开始运动
- (IBAction)startSport:(id)sender {
    self.startSportButton.hidden = YES;
    self.stopRunningButton.hidden = NO;
    self.trail = TrailStart;
    //self.startPoint = [self createPointWithLocation:self.bmkLocationService.userLocation.location title:@"起点"];
    if (self.locationMutableArray.count > 0) {
        [self.locationMutableArray addObject:self.bmkLocationService.userLocation.location];
    }else {
        return;
    }
}
//继续按钮的触发方法
- (IBAction)clickButtonContinueSport:(id)sender {
    self.pauseSportView.hidden = YES;
    self.stopRunningButton.hidden = NO;
    [self.bmkLocationService startUserLocationService];
}
//点击按钮完成运动
- (IBAction)clickButtonCompleteSport:(id)sender {
    // 关闭定位 隐藏暂停视图 把起点和终点同时显示在地图上 重新产生新界面
    [self.bmkLocationService stopUserLocationService];
    self.pauseSportView.hidden = YES;
    if (self.startPoint) {
        self.endPoint = [self createPointWithLocation:[self.locationMutableArray lastObject] title:@"终点"];
    }
    [self mapViewFitPolyLine:self.polyLine];
    //显示运动完成的view
    self.completeSportView.hidden = NO;
    CLLocation *firstLocation = self.locationMutableArray.firstObject;
    CLLocation *lastLocation = self.locationMutableArray.lastObject;
    self.sportTime = [lastLocation.timestamp timeIntervalSince1970] - [firstLocation.timestamp timeIntervalSince1970];
    /* 计算总共的距离 热量  总运动时间
     爬楼梯1500级（不计时） 250卡
     快走（一小时8公里） 　　 555卡
     快跑(一小时12公里） 700卡
     单车(一小时9公里) 245卡
     单车(一小时16公里) 415卡
     单车(一小时21公里) 655卡
     舞池跳舞 300卡
     健身操 300卡
     骑马 350卡
     网球 425卡
     爬梯机 680卡
     手球 600卡
     桌球 300卡
     慢走(一小时4公里) 255卡
     慢跑(一小时9公里) 655卡
     游泳(一小时3公里) 550卡
     有氧运动(轻度) 275卡
     有氧运动(中度) 350卡
     高尔夫球(走路自背球杆) 270卡
     锯木 400卡
     体能训练 300卡
     走步机(一小时6公里) 345卡
     轮式溜冰 350卡
     跳绳 660卡
     郊外滑雪(一小时8公里) 600卡
     练武术 790 */
    self.sumHeat = (self.sportTime/3600.0) * 600.0;
}
- (void)pauseButtonSwipe {
    self.stopRunningButton.hidden = YES;
    self.pauseSportView.hidden = NO;
    //停止位置服务
    [self.bmkLocationService stopUserLocationService];
}
/** 根据用户的位置点 把所有的位置都显示在地图范围 */
- (void)mapViewFitPolyLine:(BMKPolyline *)polyLine {
    CGFloat smallX,smallY,maxX,maxY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint point = polyLine.points[0];
    smallX = point.x,smallY = point.y;
    maxX   = point.x,maxY   = point.y;
    for (int i = 1; i < polyLine.pointCount; i ++) {
        BMKMapPoint temp = polyLine.points[i];
        if (temp.x < smallX) {
            smallX = temp.x;
        }
        if (temp.y < smallY) {
            smallY = temp.y;
        }
        if (temp.x > maxX) {
            maxX = temp.x;
        }
        if (temp.y > maxY) {
            maxY = temp.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(smallX - 40, smallY - 60);
    rect.size = BMKMapSizeMake((maxX - smallX) + 80, (maxY - smallY) + 120);
    [self.mapView setVisibleMapRect:rect];
}
- (IBAction)clickCancelButton:(id)sender {
    NSLog(@" cancel Sport");
    /* 回到初始状态 */
    [self clean];
    self.completeSportView.hidden = YES;
    self.startSportButton.hidden = NO;
    BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(self.bmkLocationService.userLocation.location.coordinate, BMKCoordinateSpanMake(BMKSPAN,BMKSPAN))];
    [self.mapView setRegion:adjustRegion animated:NO];

}
- (IBAction)clickSaveButton:(id)sender {
    [self shareSportDataToLTCoolRunning:nil];
    [self clean];
}
- (IBAction)shareSportDataToSina:(id)sender {
    //组装微博数据 运动距离 运动时长 运动消耗热量
    NSString *statusStr = [NSString stringWithFormat:@"我用“健康酷跑”本次运动了%.1lf米,运动总时长为%.1lf秒,消耗热量%.4lf卡",self.sumDistance,self.sportTime,self.sumHeat];
    UIImage *image = [self.mapView takeSnapshot];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = @"https://upload.api.weibo.com/2/statuses/upload.json";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"access_token"] = [LTCRUserInfo sharedLTCRUserInfo].sinaToken;
    parameters[@"status"] = statusStr;
    if ([LTCRUserInfo sharedLTCRUserInfo].sinaLoginAndRegister) {
        if (self.sumDistance <= 0.0) {
            return;
        }else {
            [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"pic" fileName:@"运动记录.png" mimeType:@"image/jpeg"];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                MYLog(@"发布微博成功");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                MYLog(@"发布微博失败:%@",error.userInfo);
            }];
        }
    }else {
        //这里暂时只测试一下，不做实现具体逻辑
        MYLog(@"请使用微博第三方登陆");
    }
    [self shareSportDataToLTCoolRunning:nil];
    [self clean];
}
//上传运动记录到本地服务器
- (IBAction)shareSportDataToLTCoolRunning:(id)sender {
    if (self.sumDistance <= 0.0) {
        return;
    }else {
        NSString *statusStr = [NSString stringWithFormat:@"我用“健康酷跑”本次运动了%.1lf米,运动总时长为%.1lf秒,消耗热量%.4lf卡",self.sumDistance,self.sportTime,self.sumHeat];
        UIImage *image = [self.mapView takeSnapshot];

        NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServer/addTopic.jsp",LTCRXMPPHOSTNAME];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        LTCRUserInfo *userInfo = [LTCRUserInfo sharedLTCRUserInfo];
        parameters[@"username"] = userInfo.userName;
        parameters[@"md5password"] = [userInfo.userPassword md5StrXor];
        parameters[@"content"] = statusStr;
        CLLocation *lastLocation = self.locationMutableArray.lastObject;
        parameters[@"latitude"] = @(lastLocation.coordinate.latitude);
        parameters[@"longitude"] = @(lastLocation.coordinate.longitude);
        parameters[@"address"] = @"这里要执行反地理编码，有待实现";
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            //按照日期生成文件名
            NSDate *date = [NSDate date];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yy-MM-ddHH:mm:ss"];
            NSString *dateName = [format stringFromDate:date];
            NSString *picName = [dateName stringByAppendingFormat:@"%@.png",[LTCRUserInfo sharedLTCRUserInfo].userName];
            //把图片处理成宽度200 高度等比例压缩
            UIImage *newImage = [self thumbnailWithImage:image size:CGSizeMake(200, (200.0 / image.size.width) * image.size.height)];
            [formData appendPartWithFileData:UIImagePNGRepresentation(newImage) name:@"pic" fileName:picName mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            MYLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            MYLog(@"上传失败:%@",error.userInfo);
        }];
    }
    [self clean];
}
- (IBAction)shareSportDataToWechat:(id)sender {
    //由于微信的服务都是收费的所以这里有待实现
}
- (IBAction)shareSportDataToRenren:(id)sender {
    //由于人人网开放平台有问题所以这里有待实现
}
/* 生成图片缩略图 */
- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize

{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }else{
        UIGraphicsBeginImageContext(asize);
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

#pragma mark - BMKMapViewDelegate  And BMKLocationServiceDelegate
///用户位置更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    MYLog(@"用户当前位置:%f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
#warning TODO:真机测试的时候把定位方式设置成为前台模式
    [self.mapView updateLocationData:userLocation];
    //以用户目前位置为中心点 并设置一个显示的扇区范围
    if (self.trail == TrailEnd) {
        BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(BMKSPAN, BMKSPAN))];
        [self.mapView setRegion:adjustRegion];
    }
    /* //以下代码为判断是否在室外活动，如果需要可以打开注释
    if (userLocation.location.horizontalAccuracy > kCLLocationAccuracyNearestTenMeters) {
        //判断有没有在室外活动,如果没有在户外活动，提示用户到室外活动
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示！" message:@"请到户外活动。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *enterAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:enterAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
     */
    if (self.trail == TrailStart) {
        //开始跟踪用户位置
        [self startTrailRouterWithUserLocation:userLocation];
        [self.mapView setRegion:BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(BMKSPAN, BMKSPAN)) animated:YES];
    }
}
/** 用户跟踪的逻辑方法 */
- (void)startTrailRouterWithUserLocation:(BMKUserLocation *)userLocation {
    if (self.preLocation) {
        //计算本次定位和上一个位置的距离
        CGFloat distance = [userLocation.location distanceFromLocation:self.preLocation];
        self.sumDistance += distance;
    }
    self.preLocation = userLocation.location;
    //把用户位置存入数组中
    [self.locationMutableArray addObject:userLocation.location];
    //实现在地图上绘图的逻辑
    [self drawWalkPolyline];
}
/** 绘制覆盖线 */
- (void)drawWalkPolyline {
    NSInteger count = self.locationMutableArray.count;
//    BMKMapPoint *tempPoints = (BMKMapPoint *)malloc(sizeof(BMKMapPoint) * count);//C语言申请动态内存
    BMKMapPoint *tempPoints = new BMKMapPoint[count];//C++申请动态内存 使用C++更直观，不需要强转类型
    [self.locationMutableArray enumerateObjectsUsingBlock:^(CLLocation * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (0 == idx && TrailStart == self.trail && self.startPoint == nil) {
            self.startPoint = [self createPointWithLocation:obj title:@"起点"];
        }
        //把CLLocation 转换成BMKMapPoint
        BMKMapPoint point = BMKMapPointForCoordinate(obj.coordinate);
        tempPoints[idx] = point;
    }];
    self.polyLine = [BMKPolyline polylineWithPoints:tempPoints count:count];
    if (self.polyLine) {
        [self.mapView addOverlay:self.polyLine];
    }
    //释放内存
//    free(tempPoints);//C语言标准释放内存
    delete [] tempPoints;//C++标准释放内存
}
/** 遮盖线的显示 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView *polyLineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polyLineView.fillColor = [[UIColor clearColor] colorWithAlphaComponent:0.7];
        polyLineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
        polyLineView.lineWidth = 4.0;
        return polyLineView;
    }
    return nil;
}
/** 显示大头针 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        //如果有起点 设置终点的图片，否则设置起点图片
        if (self.startPoint) {
            annotationView.image = [UIImage imageNamed:@"定位-终"];
        }else {
            annotationView.image = [UIImage imageNamed:@"定位-起"];
        }
        //从天而降的效果
        annotationView.animatesDrop = YES;
        annotationView.draggable = NO;
        return annotationView;
    }
    return nil;
}
/** 添加大头针的方法 */
- (BMKPointAnnotation *)createPointWithLocation:(CLLocation *)location title:(NSString *)title {
    BMKPointAnnotation *point = [[BMKPointAnnotation alloc] init];
    point.coordinate = location.coordinate;
    point.title = title;
    //添加大头针到地图上
    [self.mapView addAnnotation:point];
    return point;
}
#pragma mark - 工具封装
/**
 *  清空数组以及地图上的轨迹
 */
- (void)clean
{
    // 清空状态信息
    self.sumDistance = 0.0;
    self.sumHeat = 0.0;
    self.sportTime  = 0.0;
    //清空数组
    [self.locationMutableArray removeAllObjects];
    
    //清屏，移除标注点
    if (self.startPoint) {
        [self.mapView removeAnnotation:self.startPoint];
        self.startPoint = nil;
    }
    if (self.endPoint) {
        [self.mapView removeAnnotation:self.endPoint];
        self.endPoint = nil;
    }
    if (self.polyLine) {
        [self.mapView removeOverlay:self.polyLine];
        self.polyLine = nil;
    }
    
}

@end