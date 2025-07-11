## Second Challenge

**Challenge:**  
Review the smart contract of a stablecoin client and recommend security monitoring configurations based on the Blockaid monitoring platform capabilities.  
Provide a written recommendation for the configurations including invariants.

### Blockaid Product

**Blockaid Information (request access):**  
- Platform Visibility: https://docs.blockaid.io/docs/introduction-to-the-blockaid-platform  
  *(light on details but gives you an idea of what our platform does with monitoring)*  

For the purposes of this worktest, assume our monitoring platform is capable of configuring any custom monitor in Turing-complete code  
with inputs from both threat intel (able to identify known malicious addresses and exploit contracts)  
and on-chain state/events (seeing all confirmed transaction details along with the latest contract state).

### Customer Case Study

Circle wants Blockaid to monitor the USDC stablecoin for potential security risks.  
**Token:** `0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48`

They are especially concerned about:  
- Privileged access (who can do what)  
- Proxy implementation upgrade risks  
  *(details on upgradeable contracts here)*  
- Potential for abuse of admin or role-based functions

---

### Take-home Instructions

To be onboarded, a solution engineer must analyze the smart contract and do the following:

1. Determine if there are any privileged roles in the contract (Owner, Pauser, etc.) and if so, what are they called?  
2. Determine if there are any functions that are controlled by privileged functions (e.g., `onlyRole`, `onlyOwner` modifier).  

Submit a list of privileged functions and the roles required to call them.  
Use this information to suggest access control detection rules that can alert the client to suspicious activity.  
From this research, you should be able to help the client configure access control detection rules to ensure they are able to monitor for any breaches.

---