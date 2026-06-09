# Design Philosophy / 設計哲學

## DNS is a CPU-era product / DNS是CPU世代的產物

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
*This philosophy guides ez:// V0.0 Provisional Registration IANA #1453765*
