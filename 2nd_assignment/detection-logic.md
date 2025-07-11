# Detection logics Configuration

## Overview

This document defines detection logic for USDC contract monitoring following Blockaid's platform setup process. Based on Circle's concerns from the challenge requirements:

- **Privileged access** (who can do what)
- **Proxy implementation upgrade risks**
- **Potential for abuse of admin or role-based functions**

## Step 1: Configure Detection Logic Types

### 1.1 Invariant Violation Detection Logic

**Scope**: Inventory  
**Requirements**:

- Supported Labels: token, proxy, upgradeable, role
- Supported Chains: Ethereum Mainnet
- Target Asset: USDC contract in inventory

**Usage Guidelines**: Monitor critical contract invariants that should never be violated under normal operations. Essential for detecting proper Privileged access, privilege escalation, proxy contract upgrade, abusing role based functions. 

**Example**: Detecting when multiple high-privilege roles are assigned to the same address, violating role separation principles.

**Configurable Parameters**:

- **Required**: Target contract address, state variables to monitor, violation conditions

---

### 1.2 Privileged Function Call Detection Logic

**Scope**: Inventory  
**Requirements**:

- Supported Labels: token, proxy, upgradeable
- Supported Chains: Ethereum Mainnet
- Target Asset: USDC contract in inventory

**Usage Guidelines**: Monitor all function calls that require elevated privileges. Critical for tracking admin operations, role changes, and potential abuse of privileged access.

**Example**: Alerting when `transferOwnership()` is called, indicating a change in the most powerful role.

**Configurable Parameters**:

- **Required**: Function signatures, caller address validation
- **Optional**: frequency limits (e,g how many call those function in certain time window), time-based conditions ( need to prevent call those critical role based functions in certan time)

---

### 1.3 Proxy Upgrade Detection Logic

**Scope**: Inventory  
**Requirements**:
- Supported Labels: proxy, upgradeable, contract
- Supported Chains: Ethereum Mainnet
- Target Asset: USDC proxy contract in inventory

**Usage Guidelines**: Monitor proxy implementation changes and admin operations. Highest priority due to potential for complete contract compromise.

**Example**: Detecting when `upgradeTo()` is called, indicating an implementation contract change.

**Configurable Parameters**:
- **Required**: Proxy contract address, implementation storage slots
- **Optional**: upgrade timelock validation (Once upgrade happened, there are time lock unavailable to upgrade in X hours)

---

### 1.4 Abuse Pattern Detection Logic

**Scope**: Chain-wide  
**Requirements**:
- Supported Labels: wallet, token, proxy
- Supported Chains: Ethereum Mainnet
- Threat Intelligence: Known malicious addresses

**Usage Guidelines**: Detect patterns indicating potential abuse of privileged functions through existing threat intelligence correlation.

**Example**: Rapid succession of role changes from unknown addresses, indicating potential compromise.

**Configurable Parameters**:

- **Required**: time windows, frequency
- **Optional**: Threat intelligence feeds, address score data which related with sane activity onchain.

---

## Step 2: Detection Rules

### **Critical Invariant Rules**

#### **Rule 1: Role Separation Violation**

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

#### **Rule 2: Proxy Implementation Unauthorized Change**

**Rule Name**: USDC Proxy Implementation Upgrade Detection  
**Tags**: critical, proxy, upgrade, implementation  
**Scope**: Inventory asset events  
**Target**: USDC Proxy (0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48)  
**Detection Logic**: Proxy Upgrade Detection  

**Parameters**:
- **Event Names**: [Upgraded]
- **Storage Slot**: 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3
- **Current Implementation**: 0x43506849d7c04f9138d1a2050bbf3a0c054402dd
- **Current Admin**: 0x807a96288a1a408dbc13de2b1d087d10356395d2
- **Monitored Variables**: implementation (new implementation address)

**Severity**: Critical

---

#### **Rule 3: Minting Allowance Boundary Violation**

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

#### **Rule 4: Controller-Minter Relationship Integrity**

**Rule Name**: USDC Controller-Minter Mapping Violation  
**Tags**: critical, controller, minter, relationship  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Invariant Violation Detection  

**Parameters**:
- **Function Names**: [configureController]
- **Violation Condition**: Controller assigned to multiple minters OR minter operations from unauthorized controllers
- **Monitored Variables**: controller, minter

**Severity**: Critical

---

#### **Rule 5: Total Supply Conservation**

**Rule Name**: USDC Total Supply Unauthorized Change  
**Tags**: critical, supply, conservation, unauthorized  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Invariant Violation Detection  

**Parameters**:
- **Event Names**: [Mint, Burn]
- **State Variable**: totalSupply
- **Violation Condition**: totalSupply changes without corresponding mint/burn events
- **Monitored Variables**: totalSupply

**Severity**: Critical

---

#### **Rule 6: Balance-Supply Consistency**

**Rule Name**: USDC Balance-Supply Mismatch Detection  
**Tags**: critical, balance, supply, consistency  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Invariant Violation Detection  

**Parameters**:
- **State Variables**: [balanceAndBlacklistStates, totalSupply]
- **Violation Condition**: sum of all user balances ≠ totalSupply (accounting for blacklisted balances)
- **Monitored Variables**: balances, totalSupply

**Severity**: Critical

---

#### **Rule 7: MinterAllowance Decay Integrity**

**Rule Name**: USDC Minter Allowance Unauthorized Increase  
**Tags**: critical, allowance, unauthorized, increase  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Invariant Violation Detection  

**Parameters**:
- **State Variable**: minterAllowed
- **Functions**: [configureMinter, incrementMinterAllowance, mint]
- **Violation Condition**: minterAllowed[address] increases without authorized functions
- **Monitored Variables**: minterAllowed

**Severity**: Critical

---

#### **Rule 8: Emergency State Consistency**

**Rule Name**: USDC Pause State Bypass Detection  
**Tags**: critical, pause, bypass, emergency  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Invariant Violation Detection  

**Parameters**:
- **Event Names**: [Transfer, Mint, Burn]
- **Function Names**: [transfer, transferFrom, mint, burn]
- **Violation Condition**: Contract is paused = true
- **State Variable**: paused

**Severity**: Critical

---

### **Privileged Function Monitoring Rules**

#### **Rule 9: Proxy Admin Role Operations**

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

#### **Rule 10: Owner Role Operations**

**Rule Name**: USDC Owner Privileged Function Calls  
**Tags**: critical, owner, privileged, role-management  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Privileged Function Call Detection  

**Parameters**:
- **Event Names**: [OwnershipTransferred, MasterMinterChanged, PauserChanged, BlacklisterChanged, RescuerChanged]
- **Function Names**: [transferOwnership, updateMasterMinter, updatePauser, updateBlacklister, updateRescuer, configureController, removeController, setMinterManager, upgrade, withdrawFiatToken, abortUpgrade, tearDown]
- **Monitored Variables**: previousOwner, newOwner, newMasterMinter, newPauser, newBlacklister, newRescuer

**Severity**: Critical

---

#### **Rule 11: Master Minter Operations**

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

#### **Rule 12: Minter Role Operations**

**Rule Name**: USDC Minter Function Calls  
**Tags**: high, minter, privileged, token-operations  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Privileged Function Call Detection  

**Parameters**:
- **Event Names**: [Mint, Burn]
- **Function Names**: [mint, burn]
- **Monitored Variables**: minter, to, amount

**Severity**: High

---

#### **Rule 13: Large Minting Operations**

**Rule Name**: USDC Large Mint Detection  
**Tags**: high, minting, large-amount, suspicious  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Privileged Function Call Detection  

**Parameters**:
- **Event Names**: [Mint]
- **Function Names**: [mint]
- **Threshold**: amount > X amount of USDC
- **Monitored Variables**: minter, to, amount

**Severity**: High

---

#### **Rule 14: Emergency Function Usage**

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

#### **Rule 15: Asset Recovery Operations**

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

### **Abuse Pattern Detection Rules**

#### **Rule 16: Rapid Privilege Escalation**

**Rule Name**: USDC Rapid Role Change Pattern  
**Tags**: critical, abuse, rapid-changes, privilege-escalation  
**Scope**: Chain-wide events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Abuse Pattern Detection  

**Parameters**:
- **Event Names**: [OwnershipTransferred, AdminChanged, MasterMinterChanged, PauserChanged, BlacklisterChanged]
- **Time Window**: XXXX seconds or XX slots
- **Threshold**: >= X role change events
- **Pattern**: Multiple privilege-changing events from same or related addresses

**Severity**: Critical

---

#### **Rule 17: Unknown Address Privilege Assignment**

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

#### **Rule 18: Upgrade-to-Drain Attack Pattern**

**Rule Name**: USDC Upgrade-to-Drain Detection  
**Tags**: critical, upgrade-attack, drain, proxy  
**Scope**: Chain-wide events  
**Target**: USDC Proxy (0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48)  
**Detection Logic**: Abuse Pattern Detection  

**Parameters**:
- **Event Sequence**: [Upgraded] -> [Transfer] (large amounts)
- **Time Window**: XXX seconds 

**Severity**: Critical

---

#### **Rule 19: Blacklist Bypass Attempt**

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

#### **Rule 20: Suspicious Minter Activity**

**Rule Name**: USDC Suspicious Minter Pattern  
**Tags**: high, minter, suspicious, pattern  
**Scope**: Inventory asset events  
**Target**: USDC Implementation (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)  
**Detection Logic**: Abuse Pattern Detection  

**Parameters**:
- **Event Names**: [Mint]
- **Pattern**: Minting to same address > X times in XXX seconds
- **Threshold**: Same recipient address, frequency > X times
- **Time Window**: XXXX seconds
- **Monitored Variables**: minter, to, amount

**Severity**: High

---

## Next Steps

1. **[Automated Workflows](./automated-workflows.md)** - Configure response actions for these rules
2. **[Security Modules](./security-modules.md)** - Set up prevention mechanisms  
3. **[Inventory Configuration](./inventory-configuration.md)** - Asset setup and labeling

---
