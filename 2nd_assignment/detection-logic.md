# Detection Rules Configuration

## Overview

This document defines detection rules for USDC contract monitoring following Blockaid's platform setup process. Based on Circle's concerns from the challenge requirements:

- **Privileged access** (who can do what)
- **Proxy implementation upgrade risks**
- **Potential for abuse of admin or role-based functions**

## Step 1: Choosing Detection Logic Types

### 1.1 Invariant Violation Detection Logic

**Scope**: Inventory  
**Requirements**:

- Supported Labels: token, proxy, upgradeable
- Supported Chains: Ethereum Mainnet
- Target Asset: USDC contract in inventory

**Usage Guidelines**: Monitor critical contract invariants that should never be violated under normal operations. Essential for detecting state manipulation, privilege escalation, and bypass attempts.

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
- **Required**: Pattern definitions, time windows, frequency thresholds
- **Optional**: Threat intelligence feeds, address score data which related with sane activity onchain.

---

## Step 2: Critical Invariants Configuration

### Invariant 1: Role Separation Enforcement

**Detection Logic**: Invariant Violation Detection  
**Scope**: Inventory  
**Target**: USDC contract (0x43506849d7c04f9138d1a2050bbf3a0c054402dd), USDC proxy contract (0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48)

**Violation Condition**: Same address holds multiple high-privilege roles

**Required Parameters**:
- **State Variables**: [owner, admin, masterMinter, minter, pauser, blacklister, rescuer]
- **Violation Logic**: "ANY_ADDRESS_OVERLAP"
- **Severity**: Critical

**Purpose**: Prevents privilege concentration that could lead to single point of failure

---

### Invariant 2: Authorized Role Assignment

**Detection Logic**: Invariant Violation Detection  
**Scope**: Inventory  
**Target**: USDC contract (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)

**Violation Condition**: Role assignment from unauthorized caller

**Required Parameters**:
- **Functions**: [transferOwnership, updateMasterMinter, updatePauser, updateBlacklister, updateRescuer, changeAdmin]
- **Expected Callers**: 
  - transferOwnership: current owner
  - updateMasterMinter: current owner
  - updatePauser: current owner
  - updateBlacklister: current owner
  - updateRescuer: current owner
  - changeAdmin: current admin
- **Severity**: Critical
- **Multisig Validation**: Require multisig/cosigner for role changes.
- **Timelock Validation**: Enforce minimum delay for role changes.
**Purpose**: Ensures only authorized roles can modify other roles

---

### Invariant 3: Proxy Implementation Integrity

**Detection Logic**: Proxy Upgrade Detection  
**Scope**: Inventory  
**Target**: USDC proxy contract (0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48)

**Violation Condition**: Implementation change to unknown/malicious contract

**Required Parameters**:
- **Storage Slots**: 
  - Implementation: 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3  # keccak256("org.zeppelinos.proxy.implementation")
  - Admin: 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b  # keccak256("org.zeppelinos.proxy.admin")
- **Severity**: Critical

**Optional Parameters**:
- **Implementation Whitelist**: Approved implementation addresses
- **Code Verification**: Verify implementation source code
- **Upgrade Timelock**: Enforce delay before implementation activation

**Purpose**: Prevents malicious proxy implementation upgrades

---

### Invariant 4: Minting Authorization Boundaries

**Detection Logic**: Invariant Violation Detection  
**Scope**: Inventory  
**Target**: USDC contract (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)

**Violation Condition**: Minting exceeds authorized allowance

**Required Parameters**:
- **Function**: mint
- **State Variable**: minterAllowed
- **Violation Logic**: "mint_amount > minterAllowed[caller]"
- **Severity**: Critical

**Optional Parameters**:
- **Large Amount Threshold**: Additional alerts for large mints
- **Minter Whitelist**: Approved minter addresses

**Purpose**: Prevents unauthorized token creation beyond approved limits

---

## Step 3: Privileged Role Monitoring

### 3.1 Proxy Admin Role detection rule

**Detection Logic**: Privileged Function Call Detection  
**Scope**: Inventory  
**Target**: USDC proxy contract (0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48)

**Monitored Functions**:
- `upgradeTo(address newImplementation)`
- `upgradeToAndCall(address newImplementation, bytes data)`
- `changeAdmin(address newAdmin)`

**Required Parameters**:
- **Function Signatures**: [upgradeTo, upgradeToAndCall, changeAdmin]
- **Severity**: Critical
- **Alert Condition**: Any function call

**Optional Parameters**:
- **Implementation Validation**: Check if newImplementation is approved
- **Admin Validation**: Verify newAdmin is expected address
- **Caller Validation**: Ensure caller is current admin

**Purpose**: Track all proxy-level administrative operations

---

### 3.2 Owner Role

**Detection Logic**: Privileged Function Call Detection  
**Scope**: Inventory  
**Target**: USDC contract (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)

**Monitored Functions**:

- `transferOwnership(address newOwner)`
- `updateMasterMinter(address _newMasterMinter)`
- `updatePauser(address _newPauser)`
- `updateBlacklister(address _newBlacklister)`
- `updateRescuer(address newRescuer)`
- `configureController(address _controller, address _worker)`
- `removeController(address _controller)`
- `setMinterManager(address _newMinterManager)`
- `upgrade()` (from upgrader contracts)
- `withdrawFiatToken()` (from upgrader contracts)
- `abortUpgrade()` (from upgrader contracts)
- `tearDown()` (from upgrader contracts)

**Required Parameters**:

- **Function Signatures**: [transferOwnership, updateMasterMinter, updatePauser, updateBlacklister, updateRescuer, configureController, removeController, setMinterManager, upgrade, withdrawFiatToken, abortUpgrade, tearDown]
- **Severity**: Critical
- **Alert Condition**: Any function call

**Optional Parameters**:

- **New Address Validation**: Check if new role addresses are known
- **Multisig Requirement**: Validate calls come from multisig with consigner module

**Purpose**: Monitor all owner-level configuration changes

---

### 3.3 Master Minter Role

**Detection Logic**: Privileged Function Call Detection  
**Scope**: Inventory  
**Target**: USDC contract (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)

**Monitored Functions**:

- `configureMinter(address minter, uint256 minterAllowedAmount)`
- `removeMinter(address minter)`

**Required Parameters**:

- **Function Signatures**: [configureMinter, removeMinter]
- **Severity**: High
- **Alert Condition**: Any function call

**Optional Parameters**:

- **Minter Validation**: Check if minter address is approved

**Purpose**: Monitor minter authorization and allowance management

---

### 3.4 Emergency Roles (Pauser, Blacklister)

**Detection Logic**: Privileged Function Call Detection  
**Scope**: Inventory  
**Target**: USDC contract (0x43506849d7c04f9138d1a2050bbf3a0c054402dd)

**Monitored Functions**:

- `pause()`
- `unpause()`
- `blacklist(address _account)`
- `unBlacklist(address _account)`

**Required Parameters**:

- **Function Signatures**: [pause, unpause, blacklist, unBlacklist]
- **Severity**: High
- **Alert Condition**: Any function call

**Optional Parameters**:

- **Context Requirement**: Validate emergency use case
- **Address Validation**: Check blacklisted addresses against threat intel

**Purpose**: Monitor emergency functions and compliance operations

---

## Step 4: Abuse Prevention Patterns

### 4.1 Rapid Privilege Escalation

**Detection Logic**: Abuse Pattern Detection  
**Scope**: Chain-wide  
**Target**: USDC contract + related addresses

**Pattern Definition**: Multiple privilege-changing functions called within short timeframe

**Required Parameters**:

- **Time Window**: XXXX seconds
- **Function Count**: >= X privileged functions
- **Severity**: Critical

**Purpose**: Detect coordinated privilege escalation attacks

---

### 4.2 Unknown Address Privilege Assignment

**Detection Logic**: Abuse Pattern Detection  
**Scope**: Inventory + Chain-wide  
**Target**: USDC contract

**Pattern Definition**: Privileged role assigned to address with no previous interaction history

**Required Parameters**:

- **Functions**: All role update functions
- **Address History**: Check transaction history
- **Severity**: Critical

**Optional Parameters**:

- **Multisig Validation**: Require multisig and cosigner module setup

**Purpose**: Prevent privilege assignment to potentially compromised addresses

---

### 4.3 Upgrade-to-Drain Pattern

**Detection Logic**: Abuse Pattern Detection  
**Scope**: Chain-wide  
**Target**: USDC proxy contract

**Pattern Definition**: Proxy upgrade followed by suspicious token operations

**Required Parameters**:
- **Sequence**: upgradeTo -> large token operations
- **Time Window**: 24 hours
- **Severity**: Critical

**Optional Parameters**:
- **Implementation Analysis**: Analyze new implementation code
- **Token Flow Analysis**: Track large token movements

**Purpose**: Detect potential upgrade-to-drain attack patterns

---

## Next Steps

1. **[Automated Workflows](./automated-workflows.md)** - Configure response actions
2. **[Security Modules](./security-modules.md)** - Set up prevention mechanisms
3. **[Inventory Configuration](./inventory-configuration.md)** - Asset setup and labeling 