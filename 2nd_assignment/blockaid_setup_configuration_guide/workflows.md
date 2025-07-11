# Automated Workflows Configuration

## Overview

Workflows in Blockaid are policy-based automation rules that execute predefined actions in response to security incidents triggered by Detection Rules. This document defines available action types and workflow configurations for USDC contract monitoring.

## Why Workflows Matter

In modern security operations, and especially in a web3 ecosystem, speed and precision are critical. Workflows allow security teams to scale their response mechanisms by:

- Automatically notifying relevant stakeholders
- Executing containment procedures (e.g., pausing contracts, changing positions, enforcing security modules blocking)
- Propagating alerts to external systems
- Ensuring consistency in remediation steps

## Action Types Available

- Note: Couldn't find Appenix mentioned on the Document, So self-define for set up workflows.

### **Notification Actions**

#### 1. `send_slack_notification`

**Description**: Send alert to Slack channels  
**Configuration Fields**:

- **message**: Alert message template (e,g payger duty)

#### 2. `send_email_notification`

**Description**: Send email alerts to specified recipients  
**Configuration Fields**:

- **recipients**: Email addresses (required)
- **subject**: Email subject line (required)
- **message**: Email body template (required)
- **Prefix for email subject**: normal, high, urgent (optional)

#### 3. `send_sms_notification`

**Description**: Send SMS alerts for critical incidents  
**Configuration Fields**:

- **phone_numbers**: List of phone numbers (required)
- **message**: SMS text (required, max 160 chars)

#### 4. `send_webhook_notification`

**Description**: POST alert data to external webhook  
**Configuration Fields**:

- **url**: Webhook endpoint URL (required)
- **headers**: HTTP headers (optional)
- **payload**: JSON payload template (required)

---

### **Platform Actions**

#### 5. `create_incident`

**Description**: Create incident ticket in ticketing system  
**Configuration Fields**:

- **title**: Incident title (required)
- **description**: Incident description (required)
- **severity**: P0, P1, P2, P3 (required)
- **assignee**: Default assignee (required)

#### 6. `label_address`

**Description**: Add labels to blockchain addresses  
**Configuration Fields**:

- **address**: Target address (required)
- **labels**: Labels to add (required)
- **expiration**: Label expiration time (optional)

---

### **Security Module Actions**

#### 7. `trigger_transaction_scan`

**Description**: Force transaction scanning for specific addresses  
**Configuration Fields**:

- **addresses**: List of addresses to scan (required)
- **scan_depth**: Number of transactions to scan (optional)

---

### **External Integration Actions**

#### 8. `pause_contract`

**Description**: Call pause function on target contract  
**Configuration Fields**:

- **contract_address**: Contract to pause (required)
- **function_signature**: Pause function signature (required)
- **caller_key**: Private key or wallet for transaction (required)

#### 9. `emergency_multisig_alert`

**Description**: Send emergency alerts to multisig signers  
**Configuration Fields**:

- **multisig_address**: Target multisig address (required)
- **signers**: List of signer contacts (required)
- **message**: Emergency message (required)

---

### **Investigation Actions**

#### 10. `capture_transaction_data`

**Description**: Capture and store transaction details for investigation  
**Configuration Fields**:

- **transaction_hash**: Target transaction (required)
- **include_traces**: Include execution traces (optional)
- **include_logs**: Include event logs (optional)

#### 11. `analyze_address`

**Description**: Perform historical analysis on addresses  
**Configuration Fields**:

- **address**: Target address (required)
- **lookback_period**: Initiated block number for Analysis (required)

---

## Workflows Configuration

### **Workflow 1: Critical Infrastructure Protection**

**Name**: USDC Critical Infrastructure Security Response  
**Tags**: ["critical", "infrastructure", "proxy", "ownership"]  
**Detection Rules**:

- Rule 1: Role Separation Violation
- Rule 2: Proxy Implementation Unauthorized Change
- Rule 9: Proxy Admin Role Operations
- Rule 10: Owner Role Operations

**Severity**: Critical

**Actions**:

1. **Action Type**: `send_slack_notification`
   **Configuration**:
   - channel: "#usdc-security-critical"
   - message: "🚨 CRITICAL INFRASTRUCTURE THREAT: {{rule_name}} detected on {{target_address}}"

2. **Action Type**: `send_sms_notification`
   **Configuration**:
   - phone_numbers: ["+1234567890", "+1234567891"]
   - message: "USDC CRITICAL: {{rule_name}} - Immediate action required"

3. **Action Type**: `create_incident`
   **Configuration**:
   - title: "USDC Critical Infrastructure Incident: {{rule_name}}"
   - description: "{{rule_name}} triggered for {{target_address}} at {{timestamp}}"
   - severity: "P0"
   - assignee: "security-team-lead"

4. **Action Type**: `emergency_multisig_alert`
   **Configuration**:
   - multisig_address: "{{admin_multisig}}"
   - signers: ["admin1@circle.com", "admin2@circle.com"]
   - message: "Emergency: {{rule_name}} - Review and respond immediately"

5. **Action Type**: `capture_transaction_data`
   **Configuration**:
   - transaction_hash: "{{incident_tx_hash}}"
   - include_traces: true
   - include_logs: true

---

### **Workflow 2: Minting Security Response**

**Name**: USDC Minting Operations Security  
**Tags**: ["minting", "allowance", "supply"]  
**Detection Rules**:

- Rule 3: Minting Allowance Boundary Violation
- Rule 5: Total Supply Conservation
- Rule 7: MinterAllowance Decay Integrity
- Rule 11: Master Minter Operations
- Rule 12: Minter Role Operations
- Rule 13: Large Minting Operations

**Severity**: High

**Actions**:

1. **Action Type**: `send_slack_notification`
   **Configuration**:
   - channel: "#usdc-minting-security"
   - message: "⚠️ MINTING ALERT: {{rule_name}} - Amount: {{amount}} USDC"

2. **Action Type**: `label_address`
   **Configuration**:
   - address: "{{minter_address}}"
   - labels: ["flagged-minter", "requires-review"]
   - expiration: 86400

3. **Action Type**: `trigger_transaction_scan`
   **Configuration**:
   - addresses: ["{{minter_address}}", "{{recipient_address}}"]
   - scan_depth: 100

4. **Action Type**: `analyze_address`
   **Configuration**:
   - address: "{{minter_address}}"
   - lookback_period: "{{current_block - 7200}}"

---

### **Workflow 3: Emergency Function Response**

**Name**: USDC Emergency Functions Monitoring  
**Tags**: ["emergency", "pause", "blacklist"]  
**Detection Rules**:

- Rule 8: Emergency State Consistency
- Rule 14: Emergency Function Usage
- Rule 19: Blacklist Bypass Attempt

**Severity**: High

**Actions**:

1. **Action Type**: `send_email_notification`
   **Configuration**:
   - recipients: ["compliance@circle.com", "legal@circle.com"]
   - subject: "USDC Emergency Function Activated"
   - message: "{{rule_name}} triggered. Function: {{function_name}}, Target: {{target_address}}"
   - prefix_for_email_subject: "urgent"

2. **Action Type**: `create_incident`
   **Configuration**:
   - title: "USDC Emergency Function: {{function_name}}"
   - description: "Emergency function {{function_name}} called by {{caller_address}}"
   - severity: "P1"
   - assignee: "compliance-team-lead"

3. **Action Type**: `capture_transaction_data`
   **Configuration**:
   - transaction_hash: "{{incident_tx_hash}}"
   - include_traces: true
   - include_logs: true

---

### **Workflow 4: Controller Management Security**

**Name**: USDC Controller-Minter Relationship Security  
**Tags**: ["controller", "relationship", "integrity"]  
**Detection Rules**:

- Rule 4: Controller-Minter Relationship Integrity

**Severity**: Critical

**Actions**:

1. **Action Type**: `send_slack_notification`
   **Configuration**:
   - channel: "#usdc-controller-security"
   - message: "🔴 CONTROLLER VIOLATION: {{rule_name}} - Controller: {{controller_address}}"

2. **Action Type**: `analyze_address`
   **Configuration**:
   - address: "{{controller_address}}"
   - lookback_period: "{{current_block - 28800}}"

3. **Action Type**: `label_address`
   **Configuration**:
   - address: "{{controller_address}}"
   - labels: ["suspicious-controller", "requires-investigation"]
   - expiration: 604800

---

### **Workflow 5: Balance Integrity Monitoring**

**Name**: USDC Balance and Supply Integrity  
**Tags**: ["balance", "supply", "consistency"]  
**Detection Rules**:

- Rule 6: Balance-Supply Consistency

**Severity**: Critical

**Actions**:

1. **Action Type**: `send_slack_notification`
   **Configuration**:
   - channel: "#usdc-accounting-critical"
   - message: "ACCOUNTING ANOMALY: {{rule_name}} - Balance/Supply mismatch detected"

2. **Action Type**: `send_email_notification`
   **Configuration**:
   - recipients: ["cfo@circle.com", "accounting@circle.com"]
   - subject: "CRITICAL: USDC Balance-Supply Inconsistency"
   - message: "Balance-supply mismatch detected. Immediate reconciliation required."
   - prefix_for_email_subject: "urgent"

3. **Action Type**: `create_incident`
   **Configuration**:
   - title: "USDC Balance-Supply Mismatch"
   - description: "Critical accounting inconsistency detected in USDC contract"
   - severity: "P0"
   - assignee: "accounting-team-lead"

---

### **Workflow 6: Advanced Threat Response**

**Name**: USDC Advanced Attack Pattern Detection  
**Tags**: ["advanced", "attack", "pattern"]  
**Detection Rules**:

- Rule 16: Rapid Privilege Escalation
- Rule 17: Unknown Address Privilege Assignment
- Rule 18: Upgrade-to-Drain Attack Pattern
- Rule 20: Suspicious Minter Activity

**Severity**: Critical

**Actions**:

1. **Action Type**: `send_sms_notification`
   **Configuration**:
   - phone_numbers: ["+1234567890", "+1234567891"]
   - message: "USDC ATTACK DETECTED: {{rule_name}} - Immediate response required"

2. **Action Type**: `pause_contract`
   **Configuration**:
   - contract_address: "{{target_contract}}"
   - function_signature: "pause()"
   - caller_key: "{{emergency_pause_key}}"

3. **Action Type**: `emergency_multisig_alert`
   **Configuration**:
   - multisig_address: "{{emergency_multisig}}"
   - signers: ["security1@circle.com", "security2@circle.com", "cto@circle.com"]
   - message: "CRITICAL: {{rule_name}} detected - Emergency response activated"

4. **Action Type**: `label_address`
   **Configuration**:
   - address: "{{attacker_address}}"
   - labels: ["threat-actor", "blocked", "investigation"]
   - expiration: 2592000

5. **Action Type**: `analyze_address`
   **Configuration**:
   - address: "{{attacker_address}}"
   - lookback_period: "{{current_block - 43200}}"

---

## Workflow Activation Matrix

| Detection Rule | Workflow | Severity | Action Count |
|----------------|----------|----------|--------------|
| Rules 1,2,9,10 | Workflow 1 | Critical | 5 actions |
| Rules 3,5,7,11,12,13 | Workflow 2 | High | 4 actions |
| Rules 8,14,19 | Workflow 3 | High | 3 actions |
| Rule 4 | Workflow 4 | Critical | 3 actions |
| Rule 6 | Workflow 5 | Critical | 3 actions |
| Rules 16,17,18,20 | Workflow 6 | Critical | 5 actions |
