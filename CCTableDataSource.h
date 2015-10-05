#import <UIKit/UIKit.h>

@protocol CCTableComponentDelegate<NSObject>

-(void)configureWithData:(id)data;
+(CGFloat)heightForData:(id)data;

@end

@interface CCViewTableComponent : UIView<CCTableComponentDelegate>
@end
@interface CCCellTableComponent : UITableViewCell<CCTableComponentDelegate>
@end
@interface CCHeaderFooterTableComponent : UITableViewHeaderFooterView<CCTableComponentDelegate>
@end

@class CCTableComponent;
typedef void(^CCSelectCellBlock)(NSIndexPath *indexPath, UITableViewCell<CCTableComponentDelegate> *cell, CCTableComponent *component);

typedef void(^CCViewConfigureBlock)(UIView *view);
typedef void(^CCCellConfigureBlock)(UITableViewCell *cell);
typedef void(^CCHeaderFooterConfigureBlock)(UITableViewHeaderFooterView *view);

@interface CCTableComponent : NSObject

@property (nonatomic, strong) Class<CCTableComponentDelegate> componentClass;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSString *componentIdentifier;
@property (nonatomic, strong) CCSelectCellBlock CCSelectCellBlock;

+(CCTableComponent *)componentWithClass:(Class<CCTableComponentDelegate>)class data:(id)data;
+(CCTableComponent *)componentWithClass:(Class<CCTableComponentDelegate>)class data:(id)data identifier:(NSString *)identifier;
+(CCTableComponent *)componentWithClass:(Class<CCTableComponentDelegate>)class data:(id)data identifier:(NSString *)identifier selectedBlock:(CCSelectCellBlock)selectedBlock;

+(CCTableComponent *)componentWithViewConfigure:(CCViewConfigureBlock)block andHeight:(CGFloat)height;
+(CCTableComponent *)componentWithCellConfigure:(CCCellConfigureBlock)block andHeight:(CGFloat)height;
+(CCTableComponent *)componentWithHeaderFooterConfigure:(CCHeaderFooterConfigureBlock)block andHeight:(CGFloat)height;
+(CCTableComponent *)componentWithHeaderFooterConfigure:(CCHeaderFooterConfigureBlock)block andHeight:(CGFloat)height identifier:(NSString *)identifier;

@end

@interface CCTableDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

-(id)initWithTableView:(UITableView *)tableview;
-(id)initWithTableView:(UITableView *)tableview delegate:(id<UITableViewDelegate>)delegate;

-(void)setTableHeader:(CCTableComponent *)component;
-(void)setTableFooter:(CCTableComponent *)component;
-(NSUInteger)addSection;
-(void)setHeader:(CCTableComponent *)component ofSection:(NSUInteger)section;
-(void)setFooter:(CCTableComponent *)component ofSection:(NSUInteger)section;
-(void)addCell:(CCTableComponent *)component toSection:(NSUInteger)section;
-(void)addCellWithCellConfigure:(CCCellConfigureBlock)block toSection:(NSUInteger)section; //use tableview's default rowHeight
-(void)addCellWithCellConfigure:(CCCellConfigureBlock)block andHeight:(CGFloat)height toSection:(NSUInteger)section;

-(void)removeCellAtIndexPath:(NSIndexPath *)indexPath;
-(void)removeLastCellOfSection:(NSUInteger)section;

-(id)dataAtIndexPath:(NSIndexPath *)indexPath;
-(void)updateData:(id)data atIndexPath:(NSIndexPath *)indexPath;

-(id)dataForHeaderAtSection:(NSUInteger)section;
-(void)updateData:(id)data forHeaderOfSection:(NSUInteger)section;

-(id)dataForFooterAtSection:(NSUInteger)section;
-(void)updateData:(id)data forFooterOfSection:(NSUInteger)section;

-(void)clearAll;
-(void)clearAllSections;

@end
