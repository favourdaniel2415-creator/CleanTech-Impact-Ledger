# 🌱 CleanTech Impact Ledger

A comprehensive blockchain-based platform for tracking environmental impact, issuing carbon credits, and managing clean technology projects with transparent verification and measurement systems.

## ✨ Features

### 🌿 Environmental Impact Tracking
- **Project Registration**: Create and manage clean technology projects with detailed descriptions
- **Impact Measurement**: Record environmental metrics with verification systems
- **Progress Monitoring**: Track project progress against sustainability targets
- **Category Management**: Organize projects by clean technology categories

### 💰 Carbon Credit System
- **Credit Issuance**: Generate verified carbon credits for successful environmental projects
- **Credit Trading**: Peer-to-peer carbon credit marketplace with transparent pricing
- **Credit Retirement**: Permanently retire credits to offset carbon footprints
- **Balance Management**: Real-time tracking of carbon credit portfolios

### 🔍 Verification & Validation
- **Community Verification**: Distributed verification system with reputation-based validators
- **Multi-Verifier Consensus**: Require multiple verifications before project approval
- **Impact Confirmation**: Validate claimed environmental benefits through community review
- **Verification Notes**: Detailed feedback from environmental impact validators

### 📊 Analytics & Reporting
- **Platform Metrics**: Track total carbon offset and project statistics
- **Impact Efficiency**: Calculate project success rates and impact ratios
- **User Reputation**: Build trust through successful project creation and verification
- **Transaction History**: Complete audit trail of all carbon credit activities

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- Basic understanding of Clarity smart contract language

### Installation
1. Clone this repository
2. Navigate to the project directory
3. Run `clarinet check` to verify the contract

### Usage Examples

#### Register as a User
```bash
clarinet call cleantech-impact register-user u5
```
- `u5`: Verification power level (determines voting weight)

#### Create a Clean Technology Project
```bash
clarinet call cleantech-impact create-project "Solar Community Initiative" "renewable-energy" "Installing solar panels for low-income housing communities" u10000
```
- `"Solar Community Initiative"`: Project name
- `"renewable-energy"`: Technology category
- `"Installing solar panels..."`: Project description
- `u10000`: Target environmental impact units

#### Record Impact Measurement
```bash
clarinet call cleantech-impact record-impact-measurement u1 "carbon-reduction" u2500 "tons-co2"
```
- `u1`: Project ID
- `"carbon-reduction"`: Type of measurement
- `u2500`: Measured value
- `"tons-co2"`: Unit of measurement

#### Verify a Project
```bash
clarinet call cleantech-impact verify-project u1 u2500 "Verified solar installation with measured 2500 tons CO2 reduction"
```
- `u1`: Project ID to verify
- `u2500`: Confirmed impact amount
- `"Verified solar installation..."`: Verification notes

#### Issue Carbon Credits (Admin Only)
```bash
clarinet call cleantech-impact issue-carbon-credits u1 u2000
```
- `u1`: Project ID
- `u2000`: Number of carbon credits to issue

#### Transfer Carbon Credits
```bash
clarinet call cleantech-impact transfer-carbon-credits 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE u500
```
- Recipient principal address
- `u500`: Number of credits to transfer

#### Purchase Carbon Credits
```bash
clarinet call cleantech-impact purchase-carbon-credits 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE u250 u1000
```
- Seller principal address
- `u250`: Number of credits to purchase
- `u1000`: Total price (micro-STX)

#### Retire Carbon Credits
```bash
clarinet call cleantech-impact retire-carbon-credits u100 u1
```
- `u100`: Number of credits to retire
- `u1`: Project ID for retirement tracking

## 📋 Smart Contract Functions

### Public Functions
- `register-user(verification-power)` - Register as platform participant with verification rights
- `create-project(name, category, description, target-impact)` - Create new clean technology project
- `record-impact-measurement(project-id, measurement-type, value, unit)` - Log environmental measurements
- `verify-project(project-id, impact-confirmed, verification-note)` - Verify project impact claims
- `issue-carbon-credits(project-id, amount)` - Issue credits for verified projects (admin only)
- `transfer-carbon-credits(recipient, amount)` - Send credits to another user
- `purchase-carbon-credits(seller, amount, price)` - Buy credits from marketplace
- `retire-carbon-credits(amount, project-id)` - Permanently retire credits for offset
- `update-project-status(project-id, new-status)` - Modify project operational status
- `update-verification-threshold(new-threshold)` - Adjust verification requirements (admin)
- `update-platform-fee(new-rate)` - Modify platform fee structure (admin)

### Read-Only Functions
- `get-user-data(user)` - Retrieve user profile and statistics
- `get-project-data(project-id)` - Get complete project information
- `get-measurement-data(measurement-id)` - Access measurement details
- `get-transaction-data(transaction-id)` - View transaction history
- `get-project-verification(project-id, verifier)` - Check verification status
- `get-platform-stats()` - Platform-wide metrics and statistics
- `calculate-impact-efficiency(project-id)` - Project success rate calculation
- `get-user-carbon-balance(user)` - Individual carbon credit balance

## 🏗️ System Architecture

### Data Structures
- **Users**: Carbon credit balances, project creation history, verification power, reputation
- **Projects**: Creator, impact targets, verification status, carbon credits issued
- **Verifications**: Validator consensus, impact confirmation, verification notes
- **Measurements**: Environmental impact data with verification status
- **Transactions**: Complete history of credit transfers, purchases, and retirements
- **Categories**: Technology classification with aggregate statistics

### Economic Model
- **Platform Fee**: 2% fee on carbon credit issuance supports platform operations
- **Verification Incentives**: Reputation rewards for accurate project verification
- **Impact Rewards**: Bonus reputation for successful environmental project creation
- **Retirement Benefits**: Enhanced impact scores for carbon credit retirement

## 🛡️ Security Features

- **Ownership Validation**: Only project creators can record measurements and update status
- **Verification Consensus**: Multiple verifiers required before project approval
- **Balance Verification**: Prevents transfers exceeding available carbon credits
- **Admin Controls**: Platform parameters restricted to contract owner
- **Input Validation**: Comprehensive checks on all user inputs and data

## 🌍 Environmental Impact

### Supported Project Categories
- **Renewable Energy**: Solar, wind, hydroelectric, and other clean energy projects
- **Energy Efficiency**: Building retrofits, industrial efficiency improvements
- **Carbon Sequestration**: Reforestation, soil carbon, direct air capture
- **Sustainable Transportation**: Electric vehicle infrastructure, public transit
- **Waste Reduction**: Recycling programs, circular economy initiatives
- **Clean Technology**: Innovation in environmental solutions and green tech

### Impact Measurement
- **Carbon Reduction**: Direct CO2 emission reductions (tons)
- **Energy Savings**: Renewable energy generation (kWh)
- **Resource Conservation**: Water, material, and land use efficiency
- **Ecosystem Benefits**: Biodiversity protection and restoration metrics
- **Social Impact**: Community benefits and environmental justice outcomes

## 📈 Platform Metrics

The contract tracks comprehensive environmental and economic metrics:
- Total carbon credits issued and retired
- Number of verified clean technology projects
- Platform verification threshold and fee rates
- User participation and reputation statistics
- Project success rates by technology category

## 🤝 Contributing

This smart contract provides the foundation for transparent environmental impact tracking and carbon credit management. Contributions welcome for:
- Additional measurement types and verification methods
- Integration with external environmental data sources
- Enhanced project categorization and impact modeling
- Community governance and decentralized administration

## 📄 License

Open source - ready for community development and deployment on the Stacks blockchain.

---

**🌱 Building a sustainable future through transparent environmental impact tracking! 🌍**
