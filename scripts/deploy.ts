import yargs from 'yargs/yargs'
import { BigVal } from 'bigval'
import { getBytes, ContractFactory, Wallet, JsonRpcProvider } from 'ethers'
import { FACTORY_ABI, FACTORY_BYTECODE, FACTORY_DEPLOYED_ADDRESS, FACTORY_DEPLOYER_ADDRESS, FACTORY_GAS_LIMIT, FACTORY_GAS_PRICE, FACTORY_SIGNED_RAW_TX } from './create3'
const shell = require('shelljs')

const triballyMultisigWalletBase = '0x4b78Bc43E63AD6524A411F17Ff376Fd362DBB531'
const triballyHotWallet = '0x5c3159337AD78641971B2B2E07215C68805A8427'
const create3Salt = '0xd3adbeefdeadbeefdeadbeefdeadbeefde9dbeefdeadbeefdeadbeefdeadb22f' // DO NOT CHANGE THIS VALUE!

const chains: Record<string, {
  rcpUrl: string,
  chainId: number,
  owner: string,
  minter: string,
  verifierApiUrl: string,
  layerZeroEndpointContract: string,
}> = {
  base: {
    rcpUrl: 'https://mainnet.base.org',
    chainId: 8453,
    owner: triballyMultisigWalletBase,
    minter: triballyHotWallet,
    verifierApiUrl: 'https://api.basescan.org/api',
    layerZeroEndpointContract: '0x1a44076050125825900e736c501f859c50fE728c',
  },
  baseSepolia: {
    rcpUrl: 'https://sepolia.base.org',
    chainId: 84532,
    owner: triballyHotWallet,
    minter: triballyHotWallet,
    verifierApiUrl: 'https://api-sepolia.basescan.org/api',
    layerZeroEndpointContract: '0x6EDCE65403992e310A62460808c4b910D972f10f',
  },
}

const log = console.log.bind(console)

const main = async () => {
  const tokenContractArtifact = require('../out/TribalToken.sol/TribalToken.json')

  const privateKey = process.env.PRIVATE_KEY
  if (!privateKey) {
    throw new Error('PRIVATE_KEY env var is required')
  }
  const verifierApiKey = process.env.VERIFIER_API_KEY
  if (!verifierApiKey) {
    throw new Error('VERIFIER_API_KEY env var is required')
  }

  const { argv } = yargs(process.argv.slice(2))
  const { chain } = argv as any

  if (!chains[chain]) {
    throw new Error(`Chain not configured: ${chain}`)
  }
  log(`Deploying to chain: ${chain}`)

  const chainInfo = chains[chain]

  const provider = new JsonRpcProvider(chains[chain].rcpUrl)
  const wallet = new Wallet(privateKey, provider)

  const sender = wallet.address
  log(`Deploying from address: ${sender}`)

  const code = await provider.getCode(FACTORY_DEPLOYED_ADDRESS)

  if (code && code != '0x') {
    log(`CREATE3 Factory already deployed at ${FACTORY_DEPLOYED_ADDRESS}`)
  } else {
    log(`CREATE3 Factory not yet deployed, doing so now ...`)
    log(`   Checking balance of factory deployer (${FACTORY_DEPLOYER_ADDRESS}) ...`)
    const balance = BigVal.from(await provider.getBalance(FACTORY_DEPLOYER_ADDRESS))
    log(`   Balance: ${balance.toCoinScale().toFixed(7)} ETH`)
    const requiredBalance = BigVal.from(FACTORY_GAS_PRICE).mul(FACTORY_GAS_LIMIT)
    log(`   Required balance: ${requiredBalance.toCoinScale().toFixed(7)} ETH`)
    if (balance.lt(requiredBalance)) {
      const moreNeeded = requiredBalance.sub(balance)
      log(`   Insufficient balance, sending ${moreNeeded.toCoinScale().toFixed(7)} ETH to factory deployer ...`)
      const tx = await wallet.sendTransaction({
        to: FACTORY_DEPLOYER_ADDRESS,
        value: moreNeeded.toString(),
      })
      await tx.wait()
      log(`   ...done`)
    } else {
      log(`   Sufficient balance.`)
    }
    log(`   Deploying factory ...`)
    const tx = await provider.broadcastTransaction(FACTORY_SIGNED_RAW_TX)
    await tx.wait()
    const confirmCode = await provider.getCode(FACTORY_DEPLOYED_ADDRESS)
    if (!confirmCode || confirmCode === '0x') {
      throw new Error(`Failed to deploy CREATE3 factory`)
    }
    log(`...done`)
  }  

  // get deploy transaction
  log(`Calculating deploy transaction data ...`)
  const _nameFactory = new ContractFactory(tokenContractArtifact.abi, tokenContractArtifact.bytecode.object, wallet)
  const constructorArgs = [chainInfo.owner, chainInfo.minter, chainInfo.layerZeroEndpointContract]
  const { data: deployData } = await _nameFactory.getDeployTransaction(...constructorArgs)
  log(`...done (deploy data size = ${getBytes(deployData).length} bytes)`)

  // deploy
  log(`Deploying ...`)
  log(`   CREATE3 salt: ${create3Salt}`)
  const create3Factory = new ContractFactory(FACTORY_ABI, FACTORY_BYTECODE, wallet)
  const create3 = create3Factory.attach(FACTORY_DEPLOYED_ADDRESS) as any
  const address = await create3.getDeployed(wallet, create3Salt)
  log(`   Will be deployed at: ${address}`)
  // check that address is empty
  const existingCode = await provider.getCode(address)
  if (existingCode && existingCode != '0x') {
    log(
      `Address already in use: ${address}. Contract has probably already been deployed, skipping to next step...`
    )
  } else {
    const tx = await create3.deploy(create3Salt, deployData)
    await tx.wait()
    log(`...done`)
  }

  // verify
  log(`Verifying contract ...`)
  const constructorArgsBytecode = shell.exec(`cast abi-encode "constructor(address,address,address)" ${constructorArgs.join(' ')}`, {
    silent: true,
  }).stdout
  log(`   Constructor args bytecode: ${constructorArgsBytecode}`)
  shell.exec(`forge verify-contract --chain-id ${chainInfo.chainId} --etherscan-api-key ${verifierApiKey} --verifier-url ${chainInfo.verifierApiUrl} --num-of-optimizations 200 --watch --constructor-args "${constructorArgsBytecode}" ${address} src/TribalToken.sol:TribalToken`)
  log(`...done`)
}

main()

