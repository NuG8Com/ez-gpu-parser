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
---
*This philosophy guides ez:// V0.0 Provisional Registration IANA #1453765*
