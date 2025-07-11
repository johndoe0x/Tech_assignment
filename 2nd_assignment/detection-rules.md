# Detection Rules Configuration

## ⚠️ **DISCLAIMER**
**These detection rules are RECOMMENDATIONS based on contract analysis. The specific configurations are for implementing monitoring using the detection logic types defined in [`detection-logic.md`](./detection-logic.md).**

## Overview

This document defines specific detection rules built using the detection logic types. Each rule follows the Rule Builder format and monitors specific events from the USDC contract ecosystem.

---

## **Critical Invariant Rules**

### **Rule 1: Role Separation Violation**

**Rule Name**: USDC Role Address Overlap Detection  
**Tags**: critical, invariant, role-separation, security  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Invariant Violation Detection  

**Parameters**:
- **Event Names**: [OwnershipTransferred, AdminChanged, MasterMinterChanged, PauserChanged, BlacklisterChanged, RescuerChanged]
- **Violation Condition**: Same address appears in multiple role events within 24 hours
- **Monitored Variables**: newOwner, newAdmin, newMasterMinter, newPauser, newBlacklister, newRescuer

**Severity**: Critical

---

### **Rule 2: Proxy Implementation Unauthorized Change**

**Rule Name**: USDC Proxy Implementation Upgrade Detection  
**Tags**: critical, proxy, upgrade, implementation  
**Scope**: Inventory asset events  
**Target**: USDC Proxy (0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48)  
**Detection Logic**: Proxy Upgrade Detection  

**Parameters**:
- **Event Names**: [Upgraded]
- **Storage Slot**: 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3
- **Monitored Variables**: implementation (new implementation address)

**Severity**: Critical

---

### **Rule 3: Minting Allowance Boundary Violation**

**Rule Name**: USDC Mint Allowance Exceeded Detection  
**Tags**: critical, minting, allowance, boundary  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Invariant Violation Detection  

**Parameters**:
- **Event Names**: [Mint]
- **Function Call**: mint(address _to, uint256 _amount)
- **Violation Condition**: _amount > minterAllowed[msg.sender]
- **Monitored Variables**: minter, to, amount

**Severity**: Critical

---

## **Privileged Function Monitoring Rules**

### **Rule 4: Proxy Admin Role Operations**

**Rule Name**: USDC Proxy Admin Function Calls  
**Tags**: critical, admin, proxy, privileged  
**Scope**: Inventory asset events  
**Target**: USDC Proxy (0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48)  
**Detection Logic**: Privileged Function Call Detection  

**Parameters**:
- **Event Names**: [AdminChanged, Upgraded]
- **Function Names**: [changeAdmin, upgradeTo, upgradeToAndCall]
- **Monitored Variables**: previousAdmin, newAdmin, implementation

**Severity**: Critical

---

### **Rule 5: Owner Role Operations**

**Rule Name**: USDC Owner Privileged Function Calls  
**Tags**: critical, owner, privileged, role-management  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Privileged Function Call Detection  

**Parameters**:
- **Event Names**: [OwnershipTransferred, MasterMinterChanged, PauserChanged, BlacklisterChanged, RescuerChanged]
- **Function Names**: [transferOwnership, updateMasterMinter, updatePauser, updateBlacklister, updateRescuer]
- **Monitored Variables**: previousOwner, newOwner, newMasterMinter, newPauser, newBlacklister, newRescuer

**Severity**: Critical

---

### **Rule 6: Master Minter Operations**

**Rule Name**: USDC Master Minter Function Calls  
**Tags**: high, master-minter, minting, privileged  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Privileged Function Call Detection  

**Parameters**:
- **Event Names**: [MinterConfigured, MinterRemoved]
- **Function Names**: [configureMinter, removeMinter]
- **Monitored Variables**: minter, minterAllowedAmount, oldMinter

**Severity**: High

---

### **Rule 7: Large Minting Operations**

**Rule Name**: USDC Large Mint Detection  
**Tags**: high, minting, large-amount, suspicious  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Privileged Function Call Detection  

**Parameters**:
- **Event Names**: [Mint]
- **Function Names**: [mint]
- **Threshold**: amount > 1,000,000 USDC (1e12 wei)
- **Monitored Variables**: minter, to, amount

**Severity**: High

---

### **Rule 8: Emergency Function Usage**

**Rule Name**: USDC Emergency Function Detection  
**Tags**: high, emergency, pause, blacklist  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Privileged Function Call Detection  

**Parameters**:
- **Event Names**: [Pause, Unpause, Blacklisted, UnBlacklisted]
- **Function Names**: [pause, unpause, blacklist, unBlacklist]
- **Monitored Variables**: _account (for blacklist operations)

**Severity**: High

---

### **Rule 9: Asset Recovery Operations**

**Rule Name**: USDC Asset Rescue Detection  
**Tags**: medium, rescue, asset-recovery, erc20  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Privileged Function Call Detection  

**Parameters**:
- **Event Names**: [Transfer] (when from=rescuer contract)
- **Function Names**: [rescueERC20]
- **Monitored Variables**: tokenContract, to, amount

**Severity**: Medium

---

## **Abuse Pattern Detection Rules**

### **Rule 10: Rapid Privilege Escalation**

**Rule Name**: USDC Rapid Role Change Pattern  
**Tags**: critical, abuse, rapid-changes, privilege-escalation  
**Scope**: Chain-wide events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Abuse Pattern Detection  

**Parameters**:
- **Event Names**: [OwnershipTransferred, AdminChanged, MasterMinterChanged, PauserChanged, BlacklisterChanged]
- **Time Window**: 3600 seconds (1 hour)
- **Threshold**: >= 3 role change events
- **Pattern**: Multiple privilege-changing events from same or related addresses

**Severity**: Critical

---

### **Rule 11: Unknown Address Privilege Assignment**

**Rule Name**: USDC Unknown Address Role Assignment  
**Tags**: critical, unknown-address, privilege-assignment, suspicious  
**Scope**: Chain-wide events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Abuse Pattern Detection  

**Parameters**:
- **Event Names**: [OwnershipTransferred, AdminChanged, MasterMinterChanged, PauserChanged, BlacklisterChanged, RescuerChanged]
- **Address History Check**: newAddress has < 10 previous transactions
- **Monitored Variables**: All new role addresses
- **Threat Intel**: Cross-reference with known malicious addresses

**Severity**: Critical

---

### **Rule 12: Upgrade-to-Drain Attack Pattern**

**Rule Name**: USDC Upgrade-to-Drain Detection  
**Tags**: critical, upgrade-attack, drain, proxy  
**Scope**: Chain-wide events  
**Target**: USDC Proxy (0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48)  
**Detection Logic**: Abuse Pattern Detection  

**Parameters**:
- **Event Sequence**: [Upgraded] -> [Transfer] (large amounts)
- **Time Window**: 86400 seconds (24 hours)
- **Threshold**: Transfers > 10,000,000 USDC after upgrade
- **Pattern**: Proxy upgrade followed by large token movements

**Severity**: Critical

---

### **Rule 13: Blacklist Bypass Attempt**

**Rule Name**: USDC Blacklist Bypass Detection  
**Tags**: high, blacklist, bypass, compliance  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Invariant Violation Detection  

**Parameters**:
- **Event Names**: [Transfer, Mint]
- **Function Names**: [transfer, transferFrom, mint]
- **Violation Condition**: from/to address is blacklisted
- **Monitored Variables**: from, to, amount

**Severity**: High

---

### **Rule 14: Pause State Bypass Attempt**

**Rule Name**: USDC Pause State Bypass Detection  
**Tags**: high, pause, bypass, emergency  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Invariant Violation Detection  

**Parameters**:
- **Event Names**: [Transfer, Mint, Burn]
- **Function Names**: [transfer, transferFrom, mint, burn]
- **Violation Condition**: Contract is paused = true
- **State Variable**: paused

**Severity**: High

---

### **Rule 15: Suspicious Minter Activity**

**Rule Name**: USDC Suspicious Minter Pattern  
**Tags**: high, minter, suspicious, pattern  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Abuse Pattern Detection  

**Parameters**:
- **Event Names**: [Mint]
- **Pattern**: Minting to same address > 5 times in 1 hour
- **Threshold**: Same recipient address, frequency > 5
- **Time Window**: 3600 seconds
- **Monitored Variables**: minter, to, amount

**Severity**: High

---

## **Configuration Parameters**

### **General Parameters**
- **Alert Frequency**: Real-time for Critical, 5-minute batching for High/Medium
- **Data Retention**: 30 days for all events
- **False Positive Threshold**: < 5% for Critical alerts

### **Threshold Configuration**
- **Large Mint Amount**: 1,000,000 USDC (1e12 wei)
- **Massive Transfer**: 10,000,000 USDC (1e13 wei)
- **Rapid Change Window**: 3600 seconds (1 hour)
- **Unknown Address Threshold**: < 10 previous transactions

### **Integration Requirements**
- **Threat Intelligence**: Real-time address reputation feeds
- **Multisig Detection**: Identify known multisig patterns
- **Historical Analysis**: 90-day baseline for pattern recognition

---

## **Implementation Priority**

1. **Critical Rules** (1-3, 10-12): Immediate deployment
2. **High Priority Rules** (4-8, 13-15): Deploy within 48 hours
3. **Medium Priority Rules** (9): Deploy within 1 week

## **Next Steps**

1. **[Automated Workflows](./automated-workflows.md)** - Configure response actions for these rules
2. **[Security Modules](./security-modules.md)** - Set up prevention mechanisms
3. **[Inventory Configuration](./inventory-configuration.md)** - Asset setup and labeling
4. **[Detection Logic Types](./detection-logic.md)** - Review available detection capabilities

---

*These 15 detection rules provide comprehensive coverage of Circle's security concerns using the detection logic types defined in detection-logic.md. Each rule monitors specific events from the USDC contract ecosystem and follows the Rule Builder format.* 