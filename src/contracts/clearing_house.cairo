#[starknet::contract]
pub mod clearing_house{
    use starknet::{ContractAddress};
    

    #[derive(Drop, Copy, Serde)]
    struct AmmMap{
        lastRestrictionBlock: u256,
        // cumulativePremiumFractions: LegacyMap::<ContractAddress, u256>,
            // mapping(address => Position) positionMap;
    }    
    

    #[storage]
    struct Storage {
        versionRecipient: felt252,
        initMarginRatio: u256,
        maintenanceMarginRatio: u256,
        liquidationFeeRatio: u256,
        openInterestNotionalMap: LegacyMap::<ContractAddress, u256>,
        ammMap: LegacyMap::<ContractAddress, AmmMap>,

    // // prepaid bad debt balance, key by ERC20 token address
    // mapping(address => Decimal.decimal) internal prepaidBadDebt;

    // // contract dependencies
    // IInsuranceFund public insuranceFund;
    // IMultiTokenRewardRecipient public feePool;

    // // designed for arbitragers who can hold unlimited positions. will be removed after guarded period
    // address internal whitelist;

    // uint256[50] private __gap;
    // //**********************************************************//
    // //    Can not change the order of above state variables     //
    // //**********************************************************//

    // //◥◤◥◤◥◤◥◤◥◤◥◤◥◤◥◤ add state variables below ◥◤◥◤◥◤◥◤◥◤◥◤◥◤◥◤//
    // Decimal.decimal public partialLiquidationRatio;

    // mapping(address => bool) public backstopLiquidityProviderMap;
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
    }
    
}