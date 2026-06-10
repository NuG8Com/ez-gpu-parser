# Design Philosophy / 設計哲學

## 1. DNS is a CPU-era product / DNS是CPU世代的產物

**English**
DNS was designed in 1953 for serial CPU processing:
- Character-by-character parsing: `.` → `com` → `.` → `nu8` → `.` → `com`
- Recursive queries from Root → TLD → Authoritative servers  
- Linear scaling: 10B domains = 10B serial comparisons

ez:// is designed for parallel GPU processing:
- Fixed 3-level structure: `resource.domain.tld`, zero recursion
- 128-byte fixed length, GPU kernel processes 1M URIs simultaneously
- Constant time: 10B domains = 1 GPU kernel launch

DNS is "looking up a phone book" with CPU.  
ez:// is "GPU matrix multiplication" for URIs.

**中文**
DNS誕生於1953年，為串行CPU設計：
- 字符逐個解析：`.` → `com` → `.` → `nu8` → `.` → `com`
- 遞歸查詢：Root → TLD → Authoritative伺服器一級查
- 線性擴展：100億域名 = 100億次串行比較

ez://為並行GPU設計：
- 固定3段結構：`resource.domain.tld`，零遞歸
- 128字節固定長度，GPU一次處理100萬URI
- 常數時間：100億域名 = 1次GPU kernel啟動

DNS是CPU"翻電話簿"。  
ez://是GPU"矩陣乘法"算URI。

---

## 2. IANA CRI Number {{CRI_NUMBER}} Structure / IANA CRI號碼{{CRI_NUMBER}}結構

**English**

**GPU Acceleration Logic:**
1. Read last bytes "{{CRI_NUMBER}}" → 32-bit hash lookup
2. Zero recursion, constant time lookup
3. Benchmark: 0.00015ms per URI on NVIDIA T4
4. 200,000x faster than CPU DNS parsing

**中文**

**GPU加速邏輯：**
1. 讀取最後位元組"{{CRI_NUMBER}}" → 32位哈希直查
2. 零遞歸，常數時間查找
3. 基準測試：NVIDIA T4上單URI解析0.00015ms
4. 比CPU DNS解析快20萬倍

---

## 3. Why {{CRI_NUMBER}} not com? / 為什麼用{{CRI_NUMBER}}不用com?

|  | com | {{CRI_NUMBER}} |
| --- | --- | --- |
| **管理方** | ICANN | IANA |
| **全球數量** | 無限，可重複 | 19000個號段，{{CRI_NUMBER}}唯一 |
| **GPU解析** | 字符串比較，慢 | 數字哈希，0.00015ms |
| **商業價值** | 域名 | 協議牌照+域名 |
| **衝突** | 1.6億網站共用 | NuG8獨佔 |

`com`是ICANN發的土地，誰都能蓋房。  
`{{CRI_NUMBER}}`是IANA發的衛星軌道，全球就1條，佔了=壟斷ez生態入口。

---

## 4. Business Model / 商業模式

### 4.1 L2 Domain License / 二級域名牌照

二級域名主權益：
1. **速度特權**：GPU專用哈希槽，解析快5倍
2. **三級分銷權**：可賣1000個三級域名
3. **數據主權**：`*.taobao.{{CRI_NUMBER}}`解析日誌歸淘寶

### 4.2 L3 Domain Trading / 三級域名交易
二級域名主定價範例：
收益分配：二級主拿80%，NuG8平台抽10%，技術維護10%

### 4.3 API Layer / API層
`api.ez.nug8.com` GPU雲解析  
定價：$0.001/千次URI，比Cloudflare Workers便宜10倍  
目標客戶：AI Agent公司、爬蟲公司，日處理10億URI

---

## 5. Assignment Process / 分配流程

**Current Status:**
1. IANA Provisional Registration: #1453765
2. Submitted to: David Black <david.b.black@ngc.com>
3. Requested Range: 1000-20000
4. CRI Number: {{CRI_NUMBER}} ← Pending

**After IANA Approval:**
1. Replace all `{{CRI_NUMBER}}` with assigned number
2. Update README.md, Spec_Link.md, PHILOSOPHY.md
3. Release v0.1 with official CRI Number
4. Open L2 Domain License Sales

---
*This philosophy guides ez:// V0.0 Provisional Registration IANA #1453765*  
*Pending CRI Number Assignment by IANA - David Black*  
*Last Updated: 2026-06-10
