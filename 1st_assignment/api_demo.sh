#!/bin/bash

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display the main menu
show_menu() {
    clear
    echo -e "${CYAN}🛡️  BLOCKAID API INTERACTIVE DEMO${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    echo -e "${YELLOW}Choose an API endpoint to explore:${NC}"
    echo ""
    echo -e "${CYAN}DApp Scanning API: 1.${NC} /v0/site/scan"
    echo -e "${GREEN}Transaction Scanning API: 2.${NC} /v0/evm/json-rpc/scan"
    echo -e "${GREEN}Transaction Scanning API: 3.${NC} /v0/evm/transaction/scan"
    echo -e "${GREEN}Transaction Scanning API: 4.${NC} /v0/evm/transaction-bulk/scan"
    echo -e "${RED}0.${NC} Exit"
    echo ""
    echo -n "Enter your choice (0-4): "
}

# Function to ask if user wants to see response
ask_for_response() {
    echo ""
    echo -n "Do you want to see the response example? (y/n): "
    read -r show_response
    case $show_response in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer yes or no."; ask_for_response;;
    esac
}

# Function to pause and wait for user input
pause() {
    echo ""
    echo -e "${YELLOW}Press any key to continue...${NC}"
    read -n 1 -s
}

# Site Scan Demo
demo_site_scan() {
    clear
    echo -e "${PURPLE}🛡️ Blockaid API Demo: /v0/site/scan${NC}"
    echo -e "${PURPLE}====================================${NC}"
    echo ""
    echo -e "${BLUE}📋 Description:${NC} Detect malicious airdrop websites and phishing scams before users interact with them "
    echo ""
    
    echo -e "${GREEN}🚀 REQUEST EXAMPLE:${NC}"
    echo "==================="
    echo ""
    echo "curl -X POST 'https://api.blockaid.io/v0/site/scan' \\"
    echo "  -H 'Content-Type: application/json' \\"
    echo "  -H 'X-API-Key: YOUR_API_KEY' \\"
    echo "  -d '{"
    echo "    \"url\": \"https://app.uniswap.org\""
    echo "  }'"
    
    if ask_for_response; then
        echo ""
        echo -e "${GREEN}✅ BENIGN SITE RESPONSE:${NC}"
        echo "========================"
        echo ""
        cat << 'EOF'
{
  "status": "hit",
  "url": "https://app.uniswap.org",
  "scan_start_time": "2024-03-15T10:30:00Z",
  "scan_end_time": "2024-03-15T10:30:05Z",
  "malicious_score": 0.02,
  "is_reachable": true,
  "is_web3_site": true,
  "is_malicious": false,
  "attack_types": {
    "phishing": {"score": 0.01, "threshold": 0.5},
    "malware": {"score": 0.01, "threshold": 0.5},
    "scam": {"score": 0.02, "threshold": 0.5}
  },
  "network_operations": ["eth_accounts", "eth_requestAccounts"],
  "json_rpc_operations": ["eth_sendTransaction", "eth_signTypedData_v4"],
  "contract_write": {
    "contract_addresses": ["0x1F98431c8aD98523631AE4a59f267346ea31F984"],
    "functions": {"0x1F98431c8aD98523631AE4a59f267346ea31F984": ["swap", "mint"]}
  },
  "contract_read": {
    "contract_addresses": ["0x1F98431c8aD98523631AE4a59f267346ea31F984"],
    "functions": {"0x1F98431c8aD98523631AE4a59f267346ea31F984": ["getReserves", "getPrice"]}
  }
}
EOF
    fi
    
    pause
}

# JSON-RPC Scan Demo
demo_jsonrpc_scan() {
    clear
    echo -e "${PURPLE}🛡️ Blockaid API Demo: /v0/evm/json-rpc/scan${NC}"
    echo -e "${PURPLE}=============================================${NC}"
    echo ""
    echo -e "${BLUE}📋 Description:${NC} Gets a json-rpc request and returns a full simulation indicating what will happen in the transaction together with a recommended action and some textual reasons of why the transaction was flagged that way."
    echo ""
    
    echo -e "${GREEN}🚀 REQUEST EXAMPLE:${NC}"
    echo "==================="
    echo ""
    echo "curl -X POST 'https://api.blockaid.io/v0/evm/json-rpc/scan' \\"
    echo "  -H 'Content-Type: application/json' \\"
    echo "  -H 'X-API-Key: YOUR_API_KEY' \\"
    echo "  -d '{"
    echo "    \"chain\": \"ethereum\","
    echo "    \"account_address\": \"0xf60c2ea62edbfe808163751dd0d8693dcb30019c\","
    echo "    \"data\": {"
    echo "      \"jsonrpc\": \"2.0\","
    echo "      \"params\": [{"
    echo "        \"from\": \"0xf60c2ea62edbfe808163751dd0d8693dcb30019c\","
    echo "        \"to\": \"0xdac17f958d2ee523a2206206994597c13d831ec7\","
    echo "        \"data\": \"0x095ea7b300000000000000000000000000002644e79602f056b03235106a9963826d0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\","
    echo "        \"value\": \"0x0000\""
    echo "      }],"
    echo "      \"method\": \"eth_sendTransaction\""
    echo "    },"
    echo "    \"options\": [\"simulation\", \"validation\"],"
    echo "    \"metadata\": {"
    echo "      \"domain\": \"https://shibicoin.org\""
    echo "    },"
    echo "    \"block\": \"18370320\""
    echo "  }'"
    
    if ask_for_response; then
        echo ""
        echo -e "${RED}🚨 MALICIOUS RESPONSE:${NC}"
        echo "======================"
        echo ""
        cat << 'EOF'
{
  "validation": {
    "result_type": "Malicious",
    "description": "This transaction grants unlimited approval to a suspicious address",
    "reason": "malicious_approval",
    "classification": "Unlimited token approval to malicious spender",
    "features": [
      "Unlimited token approval",
      "Approval to suspicious address",
      "High-risk transaction pattern"
    ]
  },
  "simulation": {
    "status": "Success",
    "assets_diffs": {
      "0xf60c2ea62edbfe808163751dd0d8693dcb30019c": []
    },
    "total_usd_diff": {
      "0xf60c2ea62edbfe808163751dd0d8693dcb30019c": {
        "in": "0.0",
        "out": "0.0",
        "total": "0.0"
      }
    },
    "exposures": {
      "0xf60c2ea62edbfe808163751dd0d8693dcb30019c": [{
        "asset": {
          "type": "ERC20",
          "address": "0xdac17f958d2ee523a2206206994597c13d831ec7",
          "name": "Tether USD",
          "symbol": "USDT",
          "decimals": 6,
          "chain_id": 1
        },
        "spenders": [{
          "exposure": [{
            "approval": "unlimited",
            "summary": "Unlimited USDT approval to suspicious address"
          }]
        }]
      }]
    },
    "total_usd_exposure": {
      "0xf60c2ea62edbfe808163751dd0d8693dcb30019c": {
        "0x002644e79602f056b03235106a9963826d0000": "999999999999.999999"
      }
    },
    "address_details": {
      "0xf60c2ea62edbfe808163751dd0d8693dcb30019c": {},
      "0xdac17f958d2ee523a2206206994597c13d831ec7": {
        "name_tag": "Tether USD",
        "contract_name": "TetherToken"
      },
      "0x002644e79602f056b03235106a9963826d0000": {
        "name_tag": "Suspicious Address"
      }
    },
    "account_summary": {
      "account_address": "0xf60c2ea62edbfe808163751dd0d8693dcb30019c",
      "total_usd_diff": "0.0",
      "total_usd_exposure": "999999999999.999999",
      "assets": ["USDT"]
    }
  },
  "block": "18370320",
  "chain": "ethereum"
}
EOF
    fi
    
    pause
}

# Transaction Scan Demo
demo_transaction_scan() {
    clear
    echo -e "${PURPLE}🛡️ Blockaid API Demo: /v0/evm/transaction/scan${NC}"
    echo -e "${PURPLE}==============================================${NC}"
    echo ""
    echo -e "${BLUE}📋 Description:${NC} Gets a transaction and returns a full simulation indicating what will happen in the transaction together with a recommended action and some textual reasons of why the transaction was flagged that way."
    echo ""
    
    echo -e "${GREEN}🚀 REQUEST EXAMPLE:${NC}"
    echo "==================="
    echo ""
    echo "curl -X POST 'https://api.blockaid.io/v0/evm/transaction/scan' \\"
    echo "  -H 'Content-Type: application/json' \\"
    echo "  -H 'X-API-Key: YOUR_API_KEY' \\"
    echo "  -d '{"
    echo "    \"chain\": \"ethereum\","
    echo "    \"data\": {"
    echo "      \"from\": \"0xf60c2ea62edbfe808163751dd0d8693dcb30019c\","
    echo "      \"to\": \"0xdac17f958d2ee523a2206206994597c13d831ec7\","
    echo "      \"data\": \"0x095ea7b300000000000000000000000000002644e79602f056b03235106a9963826d0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\","
    echo "      \"value\": \"0x0000\","
    echo "      \"nonce\": \"0x1a2bd4\""
    echo "    },"
    echo "    \"options\": [\"simulation\", \"validation\"],"
    echo "    \"metadata\": {"
    echo "      \"domain\": \"ORIGIN\""
    echo "    }"
    echo "  }'"
    
    if ask_for_response; then
        echo ""
        echo -e "${GREEN}✅ RESPONSE (with additional data):${NC}"
        echo "=================================="
        echo ""
        cat << 'EOF'
{
  "validation": {
    "status": "Success",
    "result_type": "Malicious",
    "description": "Unlimited approval to suspicious address",
    "reason": "malicious_approval"
  },
  "simulation": {
    "status": "Success",
    "params": {
      "from": "0xf60c2ea62edbfe808163751dd0d8693dcb30019c",
      "to": "0xdac17f958d2ee523a2206206994597c13d831ec7",
      "data": "0x095ea7b3...",
      "nonce": "0x1a2bd4"
    },
    "gas_estimation": {
      "status": "Success",
      "used": 46109,
      "estimate": 46109
    }
  },
  "events": [{
    "emitter_address": "0xdac17f958d2ee523a2206206994597c13d831ec7",
    "emitter_name": "TetherToken",
    "name": "Approval",
    "params": [
      {"type": "address", "value": "0xf60c2ea62edbfe808163751dd0d8693dcb30019c", "name": "owner"},
      {"type": "address", "value": "0x002644e79602f056b03235106a9963826d0000", "name": "spender"},
      {"type": "uint256", "value": "unlimited", "name": "value"}
    ]
  }]
}
EOF
    fi
    
    pause
}

# Bulk Transaction Scan Demo
demo_bulk_scan() {
    clear
    echo -e "${PURPLE}🛡️ Blockaid API Demo: /v0/evm/transaction-bulk/scan${NC}"
    echo -e "${PURPLE}====================================================${NC}"
    echo ""
    echo -e "${BLUE}📋 Description:${NC} Gets a bulk of transactions and returns a simulation showcasing the outcome after executing the transactions synchronously, along with a suggested course of action and textual explanations highlighting the reasons for flagging the bulk in that manner."
    echo ""
    
    echo -e "${GREEN}🚀 REQUEST EXAMPLE:${NC}"
    echo "==================="
    echo ""
    echo "curl -X POST 'https://api.blockaid.io/v0/evm/transaction-bulk/scan' \\"
    echo "  -H 'Content-Type: application/json' \\"
    echo "  -H 'X-API-Key: YOUR_API_KEY' \\"
    echo "  -d '{"
    echo "    \"chain\": \"ethereum\","
    echo "    \"account_address\": \"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\","
    echo "    \"data\": ["
    echo "      {"
    echo "        \"data\": \"0x\","
    echo "        \"value\": \"0x100000000000\","
    echo "        \"to\": \"0xA4e5961B58DBE487639929643dCB1Dc3848dAF5E\","
    echo "        \"from\": \"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\""
    echo "      },"
    echo "      {"
    echo "        \"data\": \"0x\","
    echo "        \"value\": \"0xdeadbeef\","
    echo "        \"to\": \"0x0D524a5B52737C0a02880d5E84F7D20b8d66bfba\","
    echo "        \"from\": \"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\""
    echo "      }"
    echo "    ],"
    echo "    \"block\": \"20224477\","
    echo "    \"metadata\": {"
    echo "      \"domain\": \"https://example.com\""
    echo "    },"
    echo "    \"options\": [\"validation\"]"
    echo "  }'"
    
    if ask_for_response; then
        echo ""
        echo -e "${YELLOW}📊 BULK RESPONSE (Array):${NC}"
        echo "========================="
        echo ""
        cat << 'EOF'
[
  {
    "validation": {
      "result_type": "Benign",
      "description": "Safe ETH transfer",
      "reason": "benign_transfer",
      "classification": "Normal transaction",
      "features": [
        "ETH transfer",
        "Standard transaction"
      ]
    },
    "simulation": {
      "status": "Success",
      "assets_diffs": {
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2": [
          {
            "asset": {
              "type": "NATIVE",
              "name": "Ether",
              "symbol": "ETH",
              "chain_name": "Ethereum Mainnet",
              "chain_id": 1,
              "decimals": 18
            },
            "in": [],
            "out": [
              {
                "usd_price": "2500.50",
                "summary": "Sent 0.001 ETH",
                "value": "0.001",
                "raw_value": "0x38d7ea4c68000"
              }
            ]
          }
        ],
        "0xA4e5961B58DBE487639929643dCB1Dc3848dAF5E": [
          {
            "asset": {
              "type": "NATIVE",
              "name": "Ether",
              "symbol": "ETH",
              "chain_name": "Ethereum Mainnet",
              "chain_id": 1,
              "decimals": 18
            },
            "in": [
              {
                "usd_price": "2500.50",
                "summary": "Received 0.001 ETH",
                "value": "0.001",
                "raw_value": "0x38d7ea4c68000"
              }
            ],
            "out": []
          }
        ]
      },
      "total_usd_diff": {
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2": {
          "in": "0.0",
          "out": "2.5005",
          "total": "-2.5005"
        },
        "0xA4e5961B58DBE487639929643dCB1Dc3848dAF5E": {
          "in": "2.5005",
          "out": "0.0",
          "total": "2.5005"
        }
      },
      "exposures": {},
      "total_usd_exposure": {},
      "address_details": {
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2": {
          "name_tag": "Wrapped Ether",
          "contract_name": "WETH"
        },
        "0xA4e5961B58DBE487639929643dCB1Dc3848dAF5E": {}
      },
      "account_summary": {
        "account_address": "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        "total_usd_diff": "-2.5005",
        "total_usd_exposure": "0.0",
        "assets": ["ETH"]
      }
    },
    "block": "20224477",
    "chain": "ethereum"
  },
  {
    "validation": {
      "result_type": "Warning",
      "description": "Transfer to suspicious address",
      "reason": "suspicious_recipient",
      "classification": "Potentially risky transaction",
      "features": [
        "Transfer to flagged address",
        "Unusual transaction pattern"
      ]
    },
    "simulation": {
      "status": "Success",
      "assets_diffs": {
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2": [
          {
            "asset": {
              "type": "NATIVE",
              "name": "Ether",
              "symbol": "ETH",
              "chain_name": "Ethereum Mainnet",
              "chain_id": 1,
              "decimals": 18
            },
            "in": [],
            "out": [
              {
                "usd_price": "2500.50",
                "summary": "Sent 0.0037 ETH",
                "value": "0.0037",
                "raw_value": "0xdeadbeef"
              }
            ]
          }
        ],
        "0x0D524a5B52737C0a02880d5E84F7D20b8d66bfba": [
          {
            "asset": {
              "type": "NATIVE",
              "name": "Ether",
              "symbol": "ETH",
              "chain_name": "Ethereum Mainnet",
              "chain_id": 1,
              "decimals": 18
            },
            "in": [
              {
                "usd_price": "2500.50",
                "summary": "Received 0.0037 ETH",
                "value": "0.0037",
                "raw_value": "0xdeadbeef"
              }
            ],
            "out": []
          }
        ]
      },
      "total_usd_diff": {
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2": {
          "in": "0.0",
          "out": "9.25185",
          "total": "-9.25185"
        },
        "0x0D524a5B52737C0a02880d5E84F7D20b8d66bfba": {
          "in": "9.25185",
          "out": "0.0",
          "total": "9.25185"
        }
      },
      "exposures": {},
      "total_usd_exposure": {},
      "address_details": {
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2": {
          "name_tag": "Wrapped Ether",
          "contract_name": "WETH"
        },
        "0x0D524a5B52737C0a02880d5E84F7D20b8d66bfba": {
          "name_tag": "Suspicious Address"
        }
      },
      "account_summary": {
        "account_address": "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        "total_usd_diff": "-9.25185",
        "total_usd_exposure": "0.0",
        "assets": ["ETH"]
      }
    },
    "block": "20224477",
    "chain": "ethereum"
  }
]
EOF
    fi
    
    pause
}





# Main loop
main() {
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1) demo_site_scan ;;
            2) demo_jsonrpc_scan ;;
            3) demo_transaction_scan ;;
            4) demo_bulk_scan ;;
            0) echo -e "\n${GREEN}Thank you for using Blockaid API Demo!${NC}"; exit 0 ;;
            *) echo -e "\n${RED}Invalid option. Please try again.${NC}"; sleep 2 ;;
        esac
    done
}

# Run the main function
main