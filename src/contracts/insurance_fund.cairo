#[starknet::contract]
pub mod insurance_fund{
    #[storage]
    struct Storage {
        ammMap: LegacyMap::<ContractAddress, boolean>,
        quoteTokenMap: LegacyMap::<ContractAddress, boolean>,
        amms: LegacyMap::<u256, ContractAddress>,
        ammsLen: u256,
        quoteTokens: LegacyMap::<u256, ContractAddress>,
        quoteTokensLen: u256,
        // contract dependencies
        exchange: ContractAddress,
        ifnxToken: ContractAddress,
        minter: ContractAddress,
        inflationMonitor: ContractAddress,
        beneficiary: ContractAddress,
        __gap: LegacyMap::<u256, u256>,
        __gapLen: u256, 
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
    }
   
}