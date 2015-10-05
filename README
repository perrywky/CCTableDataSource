# CCTableDataSource

参考objc.io里的[一个思路](https://www.objc.io/issues/1-view-controllers/table-views/#bridging-the-gap-between-model-objects-and-cells)写的辅助类，将UITableView的UITableViewDataSource和UITableViewDelegate封装起来，适合以下场景

* TableView使用多种类型的UITableViewCell
* 每个Cell的高度不一致
* 多种类型的SectionHeaderFooter同样适用

#### 简单开始

	CCTableDataSource *ds = [[CCTableDataSource alloc] initWithTableView:tableView];
	NSUInteger section = [ds addSection];
	[ds addCellWithCellConfigure:^(UITableViewCell *cell){
		//configure your cell
	} toSection:section];
	
#### CCTableComponent

CCTableDataSource将TableView里的每一个元素（Cell、SectionHeaderFooter）都封装成一个CCTableComponent，但是它本身并不是一个UIView，它包含以下四种属性

	@interface CCTableComponent : NSObject

	@property (nonatomic, strong) Class<CCTableComponentDelegate> componentClass;
	@property (nonatomic, strong) id data;
	@property (nonatomic, strong) NSString *componentIdentifier;
	@property (nonatomic, strong) CCSelectCellBlock selectCellBlock;

	@end
	
分别代表：

* 实际需要显示的Cell或SectionHeaderFooter的Class（须实现CCTableComponentDelegate）
* 显示它时需要的数据
* 重用识别字符串
* 选中后执行的block

#### CCTableComponentDelegate

提供给CCTableComponent的Cell或SectionHeaderFooter需要实现这个接口，它有一个实例方法和类方法

	@protocol CCTableComponentDelegate<NSObject>
	
	-(void)configureWithData:(id)data;
	+(CGFloat)heightForData:(id)data;
	
	@end

configureWithData: 就是实际控制ui显示的代码。

heightForData: 是用来计算高度的，因为它不需要修改ui，所以是个类方法。

#### 结合使用

	CCTableComponent *component = [CCTableComponent componentWithClass:[UserCell class] data:data identifier:@"user" selectedBlock:^(NSIndexPath *indexPath, UITableViewCell<CCTableComponentDelegate> *cell, CCTableComponent *component) {
		//show user
	}];
    [ds addCell:component toSection:section];
    
#### UITableViewDelegate被占用了？

因为和高度相关的方法都定义在了UITableViewDelegate里，所以CCTableDataSource实现了UITableViewDelegate，如果你需要使用UITableViewDelegate，可以使用

	-(id)initWithTableView:(UITableView *)tableview delegate:(id<UITableViewDelegate>)delegate;
	

CCTableDataSource会负责转发给传入的delegate。

**注意**：我并没有实现全部的UITableViewDelegate，如果缺了什么你需要的，可以自己添加。

