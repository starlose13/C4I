// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {Script, console} from "forge-std/Script.sol";
import {Errors} from "../../contracts/ethereum/Helper/Errors.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address entryPoint;
        address account;
    }

    uint256 private constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 private constant ETH_SEPOLIA_TESTNET_CHAIN_ID = 11155111;
    uint256 private constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 private constant LOCAL_CHAIN_ID = 31337;
    uint256 private constant ZKSYNC_CHAIN_ID = 324;
    uint256 private constant ARBITRUM_MAINNET_CHAIN_ID = 42_161;

    address constant BURNER_WALLET = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address constant ANVIL_DEFAULT_ACCOUNT =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    NetworkConfig public localNetworkConfig;

    mapping(uint256 chainId => NetworkConfig) private networkConfigs;

    constructor() {
        networkConfigs[ETH_MAINNET_CHAIN_ID] = getETHMainNetConfig();
        networkConfigs[ETH_SEPOLIA_TESTNET_CHAIN_ID] = getETHSepoliaConfig();
        networkConfigs[ZKSYNC_CHAIN_ID] = getZkSyncConfig();
        networkConfigs[ARBITRUM_MAINNET_CHAIN_ID] = getARbitrumMainNetConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else if (networkConfigs[chainId].account != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert Errors.HelperConfig__INVALID_CHAIN_ID();
        }
    }

    function getETHMainNetConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entryPoint: 0x0000000071727De22E5E9d8BAf0edAc6f37da032,
                account: BURNER_WALLET
            });
    }

    function getETHSepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
                account: BURNER_WALLET
            });
    }

    function getZkSyncConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: address(0), account: BURNER_WALLET});
    }

    function getARbitrumMainNetConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        return
            NetworkConfig({
                entryPoint: 0x0000000071727De22E5E9d8BAf0edAc6f37da032,
                account: BURNER_WALLET
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }
        // deploy mocks
        console.log("Deploying mocks...");
        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        EntryPoint entryPoint = new EntryPoint();
        vm.stopBroadcast();
        console.log("Mocks deployed!");

        localNetworkConfig = NetworkConfig({
            entryPoint: address(entryPoint),
            account: ANVIL_DEFAULT_ACCOUNT
        });
        return localNetworkConfig;
    }
}
