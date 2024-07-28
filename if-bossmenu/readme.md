
# New Advanced Bossmenu & Invoices With NUI

Easy Drag and Drop Usage

## Features
  - Employee Management:
    - Hire/Fire Employees: Add or remove members from the organization.
    - Promote/Demote Employees: Adjust the rank or position of employees within the organization.
    - View Employee List: See a list of current employees and their roles.
 - Financial Management:
   - Company Funds: View and manage the organization's funds.
   - Withdraw/Deposit Money: Handle the organization's bank transactions.
- Boss Inventory
    - Access to Boss Inventory: View and manage the organization's inventory of items.
- Hiring
  - Anyone can apply to any business at any time, anywhere.
  - Easy to hire and fire employees and update ranks.


### Supported Framework & Depencencies
- ESX
- QBCore
- ox_lib

### Inventory Trigger
- Go to client -> client.lua line no. 133 You can change according to your Inventory Trigger

### Outfit Trigger
- Go to client -> client.lua line no. 165 You can change according to your Trigger

## Commands
- /apply [job] [reason]
This will create a application to particular business and Employers can hire you

- /bill [targetId] [amount]
To bill someone only for employees

- /getbills [type  personal/company]
    - personal will fectch your personal bills
    - company will fetch your all pending bills
