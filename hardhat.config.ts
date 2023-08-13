import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  // 我们可以在不同链、区块、私钥之间切换 
  defaultNetwork: "hardhat", 
 
  solidity: "0.8.19",
};

export default config;
