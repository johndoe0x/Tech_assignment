# Inventory Configuration

## Overview

This section covers the configuration of USDC-related contracts in the Blockaid Inventory system. Proper inventory setup is crucial for effective monitoring and detection rule functionality.

## 1. Asset Onboarding

### 1.1 Primary USDC Contracts

Add the following USDC-related contracts to the Blockaid Inventory:

```yaml
Asset Dialog_1:
  - Address: 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 #(USDC Proxy Contract)
    Chains: [Ethereum]
    Tags: ["proxy", "critical", "upgradeable", "USDC"]

Asset Dialog_2:
  - Address: 0x43506849D7C04F9138D1A2050bbF3A0c054402dd #(USDC Implementation Contract)
    Chains: [Ethereum]
    Tags: ["implementation", "critical", "USDC"]
```

## 2. ABI Configuration

### 2.1 Required ABIs

ABIs are required in order to onboard contracts. 

The initial scan will:

- Attempt to fetch ABIs for the proxy and implementation (if applicable)
- Prompt you to upload manually if not found
- Validate ABI structure on upload

## 3. Source Code Handling

### 3.1 Source Code Integration

Add the correct USDC Solidity source code for ABI validation & Enables monitoring of state variables by name.

## Next Steps

Once inventory configuration is complete, proceed to:

1. **[Detection Rules](./detection-rules.md)** - Configure 30 detection rules
2. **[Automated Workflows](./automated-workflows.md)** - Set up response workflows

---