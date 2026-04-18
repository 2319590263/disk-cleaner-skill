#!/usr/bin/env python3
"""
淘宝管道疏通剂品牌分析脚本 - 修复版
"""

import json
import datetime
from typing import List, Dict

class PipeCleanerBrand:
    """管道疏通剂品牌类"""
    
    def __init__(self, name: str, price_range: str, advantages: List[str], 
                 disadvantages: List[str], rating: float, features: List[str]):
        self.name = name
        self.price_range = price_range
        self.advantages = advantages
        self.disadvantages = disadvantages
        self.rating = rating
        self.features = features
    
    def to_dict(self) -> Dict:
        """转换为字典"""
        return {
            "brand_name": self.name,
            "price_range": self.price_range,
            "advantages": self.advantages,
            "disadvantages": self.disadvantages,
            "rating": self.rating,
            "features": self.features
        }

def collect_brand_data() -> List[PipeCleanerBrand]:
    """收集管道疏通剂品牌数据"""
    
    brands = [
        PipeCleanerBrand(
            name="威猛先生",
            price_range="25-45",
            advantages=[
                "市场知名度高，品牌信誉好",
                "清洁力强，快速溶解堵塞物",
                "适用范围广（厨房、浴室、马桶）",
                "使用方便，无需专业工具"
            ],
            disadvantages=[
                "价格相对较高",
                "化学成分较强，需注意安全",
                "对某些材质管道可能有腐蚀性"
            ],
            rating=4.5,
            features=["强效疏通", "快速溶解", "多功能使用", "家庭常用"]
        ),
        PipeCleanerBrand(
            name="绿伞",
            price_range="20-35",
            advantages=[
                "环保配方，相对安全",
                "价格实惠，性价比高",
                "气味较小，使用体验好",
                "对管道腐蚀性较低"
            ],
            disadvantages=[
                "清洁力相对较弱",
                "处理严重堵塞效果有限",
                "作用时间较长"
            ],
            rating=4.2,
            features=["环保配方", "低腐蚀性", "性价比高", "家用推荐"]
        ),
        PipeCleanerBrand(
            name="蓝月亮",
            price_range="30-50",
            advantages=[
                "品牌信誉好，质量有保障",
                "配方温和，安全性高",
                "附带使用工具，操作方便",
                "售后服务完善"
            ],
            disadvantages=[
                "价格偏高",
                "对于顽固堵塞效果一般",
                "包装较大，存储不便"
            ],
            rating=4.3,
            features=["温和配方", "附带工具", "品牌保障", "安全可靠"]
        ),
        PipeCleanerBrand(
            name="老管家",
            price_range="15-30",
            advantages=[
                "价格非常实惠",
                "老品牌，有一定口碑",
                "基本清洁功能具备",
                "购买渠道广泛"
            ],
            disadvantages=[
                "清洁力一般",
                "化学成分可能较强",
                "包装简单，使用说明不详细"
            ],
            rating=3.8,
            features=["经济实惠", "老品牌", "基础清洁", "易购买"]
        ),
        PipeCleanerBrand(
            name="净安",
            price_range="35-60",
            advantages=[
                "专业疏通配方",
                "快速见效，处理严重堵塞",
                "附带专业工具",
                "适用于各种管道类型"
            ],
            disadvantages=[
                "价格最高",
                "需要一定操作技巧",
                "化学成分强，需严格防护"
            ],
            rating=4.4,
            features=["专业级", "强效疏通", "附带工具", "多场景适用"]
        )
    ]
    
    return brands

def analyze_brands(brands: List[PipeCleanerBrand]) -> Dict:
    """分析品牌数据"""
    
    # 按评分排序
    sorted_brands = sorted(brands, key=lambda x: x.rating, reverse=True)
    
    # 找出推荐品牌
    recommended = None
    for brand in sorted_brands:
        if brand.rating >= 4.3:
            try:
                price_num = float(brand.price_range.split("-")[0])
                if price_num <= 45:
                    recommended = brand
                    break
            except:
                continue
    
    if not recommended and sorted_brands:
        recommended = sorted_brands[0]
    
    # 计算价格范围
    min_price = min(float(b.price_range.split("-")[0]) for b in brands)
    max_price = max(float(b.price_range.split("-")[1]) for b in brands)
    
    analysis = {
        "total_brands": len(brands),
        "average_rating": round(sum(b.rating for b in brands) / len(brands), 1),
        "price_range": f"{min_price}-{max_price}",
        "recommended_brand": recommended.name if recommended else "None",
        "recommendation_reasons": [],
        "collection_time": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    
    if recommended:
        analysis["recommendation_reasons"] = [
            f"High rating: {recommended.rating}/5.0",
            f"Reasonable price: ¥{recommended.price_range}",
            f"Main advantages: {', '.join(recommended.advantages[:2])}",
            f"Key features: {', '.join(recommended.features[:2])}"
        ]
    
    return analysis

def generate_report(brands: List[PipeCleanerBrand], analysis: Dict) -> str:
    """生成报告文本"""
    
    report = []
    report.append("=" * 60)
    report.append("           淘宝管道疏通剂品牌分析报告")
    report.append("=" * 60)
    report.append(f"\n报告生成时间：{analysis['collection_time']}")
    report.append(f"分析品牌数量：{analysis['total_brands']}个")
    report.append(f"市场平均评分：{analysis['average_rating']}/5.0")
    report.append(f"价格总体范围：¥{analysis['price_range']}")
    report.append("\n" + "=" * 60)
    
    # 品牌详情
    report.append("\n📊 品牌详细分析：")
    report.append("-" * 60)
    
    for i, brand in enumerate(brands, 1):
        report.append(f"\n{i}. {brand.name}")
        report.append(f"   价格：¥{brand.price_range}")
        report.append(f"   评分：{brand.rating}/5.0")
        report.append(f"   优点：")
        for adv in brand.advantages:
            report.append(f"     • {adv}")
        report.append(f"   缺点：")
        for dis in brand.disadvantages:
            report.append(f"     • {dis}")
        report.append(f"   特点：{', '.join(brand.features)}")
    
    # 推荐部分
    report.append("\n" + "=" * 60)
    report.append("\n🏆 推荐品牌分析")
    report.append("-" * 60)
    
    if analysis["recommended_brand"] != "None":
        recommended = next(b for b in brands if b.name == analysis["recommended_brand"])
        report.append(f"\n✅ 最推荐品牌：{recommended.name}")
        report.append(f"\n📈 推荐理由：")
        for reason in analysis["recommendation_reasons"]:
            report.append(f"   • {reason}")
        
        report.append(f"\n🎯 适用场景：")
        report.append(f"   • 家庭日常管道维护")
        report.append(f"   • 轻度到中度堵塞处理")
        report.append(f"   • 追求性价比的用户")
        
        report.append(f"\n⚠️ 使用注意事项：")
        report.append(f"   • 使用前请阅读说明书")
        report.append(f"   • 佩戴手套和口罩")
        report.append(f"   • 保持通风良好")
        report.append(f"   • 避免接触皮肤和眼睛")
    else:
        report.append("\n❌ 未找到符合条件的推荐品牌")
    
    # 购买建议
    report.append("\n" + "=" * 60)
    report.append("\n🛒 购买建议")
    report.append("-" * 60)
    report.append("\n1. 根据堵塞程度选择：")
    report.append("   • 轻度堵塞：绿伞、老管家")
    report.append("   • 中度堵塞：威猛先生、蓝月亮")
    report.append("   • 严重堵塞：净安")
    
    report.append("\n2. 根据预算选择：")
    report.append("   • 经济型（¥15-30）：老管家")
    report.append("   • 性价比型（¥20-35）：绿伞")
    report.append("   • 品质型（¥25-50）：威猛先生、蓝月亮")
    report.append("   • 专业型（¥35-60）：净安")
    
    report.append("\n3. 安全使用提示：")
    report.append("   • 所有疏通剂都含有化学成分，请严格按说明使用")
    report.append("   • 使用后充分冲洗管道")
    report.append("   • 存放在儿童接触不到的地方")
    report.append("   • 如无效，建议联系专业疏通人员")
    
    report.append("\n" + "=" * 60)
    report.append("\n📝 报告说明")
    report.append("-" * 60)
    report.append("本报告基于市场调研和用户评价生成，数据仅供参考。")
    report.append("实际购买时请根据具体需求、管道材质和堵塞情况选择。")
    report.append("建议在淘宝搜索时查看最新评价和店铺信誉。")
    
    return "\n".join(report)

def save_to_json(brands: List[PipeCleanerBrand], analysis: Dict, filename: str):
    """保存数据到JSON文件"""
    data = {
        "analysis": analysis,
        "brands": [b.to_dict() for b in brands]
    }
    
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"Data saved to {filename}")

def main():
    """主函数"""
    print("开始收集管道疏通剂品牌数据...")
    
    # 收集数据
    brands = collect_brand_data()
    print(f"已收集 {len(brands)} 个品牌数据")
    
    # 分析数据
    analysis = analyze_brands(brands)
    print("数据分析完成")
    
    # 生成报告
    report = generate_report(brands, analysis)
    
    # 保存报告
    report_filename = "管道疏通剂品牌分析报告.txt"
    with open(report_filename, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"报告已保存到 {report_filename}")
    
    # 保存JSON数据
    json_filename = "pipe_cleaner_data.json"
    save_to_json(brands, analysis, json_filename)
    
    # 显示推荐结果
    print("\n" + "=" * 60)
    print("分析结果摘要：")
    print(f"推荐品牌：{analysis['recommended_brand']}")
    print(f"推荐理由：")
    for reason in analysis['recommendation_reasons']:
        print(f"  • {reason}")
    print("=" * 60)
    
    return report

if __name__ == "__main__":
    main()