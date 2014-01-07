/*
     File: AppRecord.h 
 Abstract: Object encapsulating information about an iPhone app in the 'Top Paid Apps' RSS feed.
 Each one corresponds to a row in the app's table.
  
 */

@interface AppRecord : NSObject
{
    NSString *appName;
    NSStream *appDesciption;
    UIImage *appIcon;
    NSString *imageURLString;
}

@property (nonatomic, retain) NSString *appName;
@property (nonatomic, retain) UIImage *appIcon;
@property (nonatomic, retain) NSString *imageURLString;
@property (nonatomic, retain) NSString *appDescription;
 

@end