# PayLink

// Creation of Global payment link
// The following details must be required:
// - servie/purpose,creator, - date of creation, - link, - the transion hash

// ================when contributing to Global/Fixed pay=====
//  - creator, contributor's address, - the amount, transaction hash, date(timpestamp)


// Functions and params
// 1. createGlobalPaymentLink // Param: linkID
// 2. contributeToGlobalPaymentLink // Param: linkID, amount
// 3. createFixedPaymentLink // Param: linkID, amount
// 4. payFixedPaymentLink // Param: linkID and amount


=====Deploying PayLink=====
deploying "DefaultProxyAdmin" (tx: 0x66e22039dd4c4a947c30f91c964e75d97d3a86a6bca511aeda9dd82ecccdb802)...: deployed at 0xBD3d54122dBAF5355dfebb1F7243BE7af6AD55f2 with 643983 gas
deploying "PayLink_Implementation" (tx: 0x0f33690f54591884dbb4ef2ba1263ec7f06ab4a2c33469abd629848f8de64e93)...: deployed at 0xA622bd8C70727C1cAf20F5a20Dd5C7651B5C2654 with 1436887 gas
deploying "PayLink_Proxy" (tx: 0xd5180ad5044cd72bd6fcc5a2a3935ccac16cce782a33e941aeea1f751fa034fe)...: deployed at 0x06B4637C35f7AA7220b6242BfBe89F8560dD30F2 with 790638 gas
========Deploying PayLink========


### Current version
Deploying PayLink
reusing "DefaultProxyAdmin" at 0xBD3d54122dBAF5355dfebb1F7243BE7af6AD55f2
reusing "PayLink_Implementation" at 0xe15Bac267992b7a7E07733356bD83A03e65cD437
========Deploying PayLink========
Contract address:  0x06B4637C35f7AA7220b6242BfBe89F8560dD30F2

## Deploy

```
npx hardhat --network metis-sepolia deploy --tags
```

## Verify

```
npx hardhat --network metis-sepolia etherscan-verify
```

## More

See the [migration guide](./migration.md)
